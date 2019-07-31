import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/model/repo.dart';
import 'package:flutter_app/repo/repository_service_repos.dart';
import 'package:flutter_app/shared_prefs_manager.dart';
import 'package:http/http.dart' as http;

import '../app_localizations.dart';
import 'package:flutter_app/view/detail_screen.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String title = "";
  int _currentPage = -1;
  bool _isLoading = false;
  bool _allLoaded = false;
  bool _dbDataLoaded = false;
  int _perPage;
  List<Repo> _repos = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  SharedPrefsManager _sharedPrefsManager = SharedPrefsManager();

  void _getRepos() async {
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    if (_currentPage < 0) {
      _currentPage = await _sharedPrefsManager.getLastLoadedPage();
    }
    _allLoaded = await _sharedPrefsManager.getAllLoadedFromNetwork();
    if (_allLoaded) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var tempList = <Repo>[];
    if (!_dbDataLoaded) {
      tempList = await _getFromDb();
      _dbDataLoaded = true;
    }
    if (tempList.isEmpty) {
      tempList = await _getFromNetwork();
    }

    await _sharedPrefsManager.setAllLoadedFromNetwork(tempList.isEmpty);
    await _sharedPrefsManager.setLastLoadedPage(_currentPage);
    setState(() {
      _allLoaded = tempList.isEmpty;
      _currentPage++;
      _isLoading = false;
      _repos.addAll(tempList);
    });
  }

  Future<List<Repo>> _getFromDb() async {
    var completer = new Completer<List<Repo>>();
    List<Repo> repos = await RepositoryServiceRepos.getAllRepos();
    completer.complete(repos);
    return completer.future;
  }

  Future<List<Repo>> _getFromNetwork() async {
    var completer = new Completer<List<Repo>>();
    var data = await http.get(
        "https://api.github.com/users/JakeWharton/repos?page=$_currentPage&per_page=$_perPage");
    var jsonData = json.decode(data.body);
    List<Repo> tempList = [];
    for (var repo in jsonData) {
      var newRepo =
          Repo(id: repo["id"], name: repo["name"], fullName: repo["full_name"]);
      tempList.add(newRepo);
      await _saveToDb(newRepo);
    }

    completer.complete(tempList);
    return completer.future;
  }

  Future<void> _saveToDb(Repo repo) async {
    return RepositoryServiceRepos.addRepo(repo);
  }

  @override
  void initState() {
    _getRepos();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: _isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    RepositoryServiceRepos.deleteAll();
    await _sharedPrefsManager.clear();
    setState(() {
      _repos.clear();
      _allLoaded = false;
      _currentPage = 1;
    });
    _getRepos();
    return null;
  }

  bool _handleScrollPosition(ScrollNotification notification) {
    if (notification.metrics.pixels == notification.metrics.maxScrollExtent &&
        !_allLoaded) {
      _getRepos();
      return true;
    } else {
      return false;
    }
  }

  Widget _buildList() {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: NotificationListener(
            onNotification: _handleScrollPosition,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              //+1 for progressbar
              itemCount: _allLoaded ? _repos.length : _repos.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == _repos.length && !_allLoaded) {
                  return _buildProgressIndicator();
                } else {
                  return Card(
                      child: ListTile(
                    title: Text((_repos[index].name)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailScreen(_repos[index])),
                      );
                    },
                  ));
                }
              },
            )));
  }

  @override
  Widget build(BuildContext context) {
    _perPage = _perPage ??= (MediaQuery.of(context).size.height / 60).round();
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(AppLocalizations.of(context).translate("main_screen_title")),
        ),
        body: Container(
          child: _buildList(),
        ),
        resizeToAvoidBottomPadding: false);
  }
}
