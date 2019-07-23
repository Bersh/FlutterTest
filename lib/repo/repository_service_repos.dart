import 'package:flutter_app/model/repo.dart';
import 'package:flutter_app/repo/db_creator.dart';

class RepositoryServiceRepos {
  static Future<List<Repo>> getAllRepos() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.reposTable} ORDER BY ${DatabaseCreator.name}''';
    final data = await db.rawQuery(sql);
    List<Repo> repos = List();

    for (final node in data) {
      final repo = Repo.fromJson(node);
      repos.add(repo);
    }
    return repos;
  }

  static Future<Repo> getRepo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.reposTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final repo = Repo.fromJson(data.first);
    return repo;
  }

  static Future<void> addRepo(Repo repo) async {
    final sql = '''INSERT INTO ${DatabaseCreator.reposTable}
    (
      ${DatabaseCreator.id},
      ${DatabaseCreator.name},
      ${DatabaseCreator.fullName}
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [
      repo.id,
      repo.name,
      repo.fullName,
    ];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add repo', sql, null, result, params);
  }

  static Future<void> deleteRepo(Repo repo) async {
    final sql = '''DELETE FROM ${DatabaseCreator.reposTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [repo.id];
    final result = await db.rawDelete(sql, params);

    DatabaseCreator.databaseLog('Delete repo', sql, null, result, params);
  }

  static Future<void> deleteAll() async {
    final sql = '''DELETE FROM ${DatabaseCreator.reposTable}''';

    final result = await db.rawDelete(sql);

    DatabaseCreator.databaseLog('Delete all repos', sql, null, result);
  }

  static Future<void> updateRepo(Repo repo) async {
    final sql = '''UPDATE ${DatabaseCreator.reposTable}
    SET ${DatabaseCreator.name} = ?,
    ${DatabaseCreator.fullName} = ?
    WHERE ${DatabaseCreator.id} = ?
    ''';

    List<dynamic> params = [repo.name, repo.fullName, repo.id];
    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Update repo', sql, null, result, params);
  }

  static Future<int> reposCount() async {
    final data = await db
        .rawQuery('''SELECT COUNT(*) FROM ${DatabaseCreator.reposTable}''');

    int count = data[0].values.elementAt(0);
    int idForNewItem = count++;
    return idForNewItem;
  }
}
