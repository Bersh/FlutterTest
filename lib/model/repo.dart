import 'package:flutter_app/repo/db_creator.dart';

class Repo {
  final int id;
  final String name;
  final String fullName;

  Repo({this.id, this.name, this.fullName});

  factory Repo.fromJson(Map<String, dynamic> json) {
    return Repo(id: json[DatabaseCreator.id],
        name: json[DatabaseCreator.name],
        fullName: json[DatabaseCreator.fullName]);
  }
}