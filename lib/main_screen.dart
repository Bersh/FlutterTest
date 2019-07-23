import 'package:flutter/material.dart';
import 'package:flutter_app/repo/repository_service_repos.dart';
import 'package:flutter_app/shared_prefs_manager.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

import 'package:flutter_app/model/repo.dart';
import 'dart:async';
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPage = -1;
  bool isLoading = false;
  bool allLoaded = false;
  bool dbDataLoaded = false;
  final int perPage = 10;
  List<Repo> repos = [];
  ScrollController _scrollController = new ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  SharedPrefsManager _sharedPrefsManager = SharedPrefsManager();

  void _getRepos() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    if (currentPage < 0) {
      currentPage = await _sharedPrefsManager.getLastLoadedPage();
    }
    allLoaded = await _sharedPrefsManager.getAllLoadedFromNetwork();
    if (allLoaded) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    var tempList = <Repo>[];
    if (!dbDataLoaded) {
      tempList = await _getFromDb();
      dbDataLoaded = true;
    }
    if (tempList.isEmpty) {
      tempList = await _getFromNetwork();
    }

    await _sharedPrefsManager.setAllLoadedFromNetwork(tempList.isEmpty);
    await _sharedPrefsManager.setLastLoadedPage(currentPage);
    setState(() {
      allLoaded = tempList.isEmpty;
      currentPage++;
      isLoading = false;
      repos.addAll(tempList);
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
        "https://api.github.com/users/JakeWharton/repos?page=$currentPage&per_page=$perPage");
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
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (allLoaded) {
          _scrollController.dispose();
        } else {
          _getRepos();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    RepositoryServiceRepos.deleteAll();
    await _sharedPrefsManager.clear();
    setState(() {
      repos.clear();
      allLoaded = false;
      currentPage = 1;
    });
    _getRepos();
    return null;
  }

  Widget _buildList() {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: ListView.builder(
          //+1 for progressbar
          itemCount: allLoaded ? repos.length : repos.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == repos.length && !allLoaded) {
              return _buildProgressIndicator();
            } else {
              return Card(
                  child: ListTile(
                title: Text((repos[index].name)),
                onTap: () {
                  Toast.show(repos[index].fullName, context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                },
              ));
            }
          },
          controller: _scrollController,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Container(
          child: _buildList(),
        ),
        resizeToAvoidBottomPadding: false);
  }
}
