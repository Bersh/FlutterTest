import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

import 'repo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPage = 1;
  bool isLoading = false;
  bool allLoaded = false;
  final int perPage = 10;
  List<Repo> repos = [];
  ScrollController _scrollController = new ScrollController();

  void _getRepos() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    var data = await http.get(
        "https://api.github.com/users/JakeWharton/repos?page=$currentPage&per_page=$perPage");
    var jsonData = json.decode(data.body);
    List<Repo> tempList = [];
    for (var repo in jsonData) {
      tempList.add(Repo(
          id: repo["id"], name: repo["name"], fullName: repo["full_name"]));
    }

    setState(() {
      allLoaded = tempList.isEmpty;
      currentPage++;
      isLoading = false;
      repos.addAll(tempList);
    });
  }

  @override
  void initState() {
    this._getRepos();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if(allLoaded) {
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

  Widget _buildList() {
    return ListView.builder(
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
    );
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
