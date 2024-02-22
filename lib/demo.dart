import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  late Database db;

  @override
  void initState() {
    super.initState();
    createDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),
          ElevatedButton(
            onPressed: () {
              insertData();
            },
            child: const Text('Create'),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              retrieveData();
            },
            child: const Text('Read'),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              updateData();
            },
            child: const Text('Update'),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              deleteData();
            },
            child: const Text('Delete'),
          )
        ],
      ),
    ));
  }

  void createDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = '${databasesPath}test.db';
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT)');
    });
  }

  void insertData() async {
    await db.transaction((txn) async {
      txn.rawInsert('INSERT INTO Test(name) VALUES("Sangam Adhikari")');
    });
  }

  void retrieveData() async {
    List list = await db.rawQuery('SELECT * FROM Test');
    print(list);
  }

  void deleteData() async {
    await db.transaction((txn) async {
      txn.rawDelete('DELETE FROM Test');
    });
  }

  void updateData() async {
    await db.transaction((txn) async {
      txn.rawUpdate('UPDATE Test SET name = "Update Adhikari" WHERE id = 1');
    });
  }
}
