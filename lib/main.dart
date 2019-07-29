import 'package:flutter/material.dart';
import 'package:flutter_app/repo/db_creator.dart';

import 'main_screen.dart';

void main() async {
  await DatabaseCreator().initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Repositories List'),
    );
  }
}
