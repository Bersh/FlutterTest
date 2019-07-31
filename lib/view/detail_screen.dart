import 'package:flutter/material.dart';
import 'package:flutter_app/model/repo.dart';

import '../app_localizations.dart';


class DetailScreen extends StatelessWidget {
  final Repo _repo;

  DetailScreen(this._repo);

  Widget _getDataText(String data) {
    return Expanded(
        child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              data,
              style: TextStyle(fontSize: 20),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )));
  }

  Widget _getTitleText(String title) {
    return Text(title + ": ",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _createDataRow(String title, String data) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_getTitleText(title), _getDataText(data)],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate("details_screen_title")),
        ),
        body: Container(
            child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _createDataRow(AppLocalizations.of(context).translate("id"), _repo.id.toString()),
                _createDataRow(AppLocalizations.of(context).translate("name"), _repo.name),
                _createDataRow(AppLocalizations.of(context).translate("full_name"), _repo.fullName)
              ]),
        )));
  }
}