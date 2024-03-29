import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/repos/repos_bloc.dart';
import 'package:flutter_app/model/repo.dart';
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
  bool _loading = false;
  bool _allLoaded = false;
  int _perPage;
  List<Repo> _repos = [];
  ReposBloc _bloc = ReposBloc();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _bloc.dispatch(LoadReposEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  Widget _buildPageProgressIndicator() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  //Build progress indicator for list item
  Widget _buildItemProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _refresh() async {
    _allLoaded = false;
    _bloc.dispatch(ReloadReposEvent());
    return null;
  }

  bool _handleScrollPosition(ScrollNotification notification) {
    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100 &&
        !_loading &&
        !_allLoaded) {
      _loading = true;
      _bloc.dispatch(LoadReposEvent());
      return true;
    } else {
      return false;
    }
  }

  Widget _buildPage(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (BuildContext context, ReposState state) {
        // Changing the UI based on the current state
        if (state is InitialReposState) {
          return _buildPageProgressIndicator();
        } else if (state is LoadingReposState) {
          return _buildList(true);
        } else if (state is LoadedReposState) {
          _repos = state.repos;
        } else if (state is AllReposLoadedState) {
          _allLoaded = true;
        }

        _loading = false;
        return _buildList(false);
      },
    );
  }

  Widget _buildList(bool isLoadingNextPage) {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: NotificationListener(
            onNotification: _handleScrollPosition,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              //+1 for progressbar
              itemCount: isLoadingNextPage ? _repos.length + 1 : _repos.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildListItem(context, index, isLoadingNextPage);
              },
            )));
  }

  Widget _buildListItem(
      BuildContext context, int index, bool isLoadingNextPage) {
    if (index == _repos.length && isLoadingNextPage) {
      return _buildItemProgressIndicator();
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
        body: Container(child: _buildPage(context)),
        resizeToAvoidBottomPadding: false);
  }
}
