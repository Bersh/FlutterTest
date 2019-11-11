import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/model/repo.dart';
import 'package:flutter_app/repo/repository_service_repos.dart';
import 'package:http/http.dart' as http;

import '../shared_prefs_manager.dart';

class Repository {
  int _currentPage = -1;
  SharedPrefsManager _sharedPrefsManager = SharedPrefsManager();
  bool _allLoaded = false;
  bool _dbDataLoaded = false;
  List<Repo> _repos = [];
  int itemsPerPage; //TODO calculate this  _perPage = _perPage ??= (MediaQuery.of(context).size.height / 60).round();
  Repository({this.itemsPerPage = 20});

  Future<List<Repo>> getRepos() async {
    if (_currentPage < 0) {
      _currentPage = await _sharedPrefsManager.getLastLoadedPage();
    }
    if(!_allLoaded) {
      _allLoaded = await _sharedPrefsManager.getAllLoadedFromNetwork();
    }

    var tempList = <Repo>[];
    if (!_dbDataLoaded) {
      tempList = await _getFromDb();
      _dbDataLoaded = true;
    }

    if (_allLoaded) {
      _repos.addAll(tempList);
      return _repos;
    }

    if (tempList.isEmpty) {
      tempList = await _getFromNetwork();
      _repos.addAll(tempList);
    }

    await _sharedPrefsManager.setAllLoadedFromNetwork(tempList.isEmpty);
    await _sharedPrefsManager.setLastLoadedPage(_currentPage);
    _allLoaded = tempList.isEmpty;
    _currentPage++;
    return _repos;
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
        "https://api.github.com/users/JakeWharton/repos?page=$_currentPage&per_page=$itemsPerPage");
    print(data.statusCode);
    print(data.body);
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

  Future<List<Repo>> reload() async {
    _allLoaded = false;
    _dbDataLoaded = false;
    _currentPage = 0;
    RepositoryServiceRepos.deleteAll();
    await _sharedPrefsManager.clear();
    return getRepos();
  }
}
