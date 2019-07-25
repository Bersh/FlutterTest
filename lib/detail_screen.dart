import 'package:flutter/material.dart';

import 'model/repo.dart';

class DetailScreen extends StatelessWidget {
  Repo _repo;

  DetailScreen(this._repo);

  Widget _getDataText(String data) {
    return Expanded(
//      alignment: Alignment.center,
        child: Text(
      data,
      style: TextStyle(fontSize: 18),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Repo details"),
      ),
      body: Container(
          child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("ID: ",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _getDataText(_repo.id.toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Name: ",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _getDataText(_repo.name)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Full name: ",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _getDataText(_repo.fullName)
              ],
            ),
          ],
        ),
      )),
    );
  }
}
