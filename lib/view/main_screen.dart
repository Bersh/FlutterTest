import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/repos/repos_bloc.dart';
import 'package:flutter_app/model/repo.dart';
import 'package:flutter_app/repo/repository_service_repos.dart';
import 'package:flutter_app/shared_prefs_manager.dart';
import 'package:flutter_app/view/detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ReposBloc>(context).dispatch(LoadReposEvent());
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

  void _refresh() async {
    BlocProvider.of<ReposBloc>(context).dispatch(ReloadReposEvent());
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
        child: BlocProvider(
            builder: (BuildContext context) => ReposBloc(),
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
                                builder: (context) =>
                                    DetailScreen(_repos[index])),
                          );
                        },
                      ));
                    }
                  },
                ))));
  }

  @override
  Widget build(BuildContext context) {
    _perPage = _perPage ??= (MediaQuery.of(context).size.height / 60).round();
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title:
              Text(AppLocalizations.of(context).translate("main_screen_title")),
        ),
        body: Container(
          child: _buildList(),
        ),
        resizeToAvoidBottomPadding: false);
  }
}
