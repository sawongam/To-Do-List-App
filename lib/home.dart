import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Database db;
  late List<Map> tasks = [];

  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('To-Do App'),
        backgroundColor: Colors.blueGrey[900],
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButton: tasks.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          'Add Task',
                          textAlign: TextAlign.center,
                        ),
                        content: TextField(
                          controller: _taskController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your task',
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.blueGrey[900],
                        titleTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        actions: [
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                insertData(_taskController.text);
                                _taskController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white24,
                                foregroundColor: Colors.white,
                                elevation: 3,
                              ),
                              child: const Text('Add'),
                            ),
                          ),
                        ],
                      );
                    });
              },
              backgroundColor: Colors.blueGrey[800],
              elevation: 7,
              child: const Icon(
                Icons.add,
                color: Colors.white70,
              ),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey[900],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[900]!,
                blurRadius: 25,
                spreadRadius: 1,
                offset: const Offset(3, 2),
              ),
            ],
          ),
          child: FutureBuilder(
            future: readInitialData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return tasks.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          int id = tasks[index]['id'];
                          String task = tasks[index]['title'];
                          int isDone = tasks[index]['isDone'];
                          bool isDoneBool = isDone == 1;
                          return GestureDetector(
                            onLongPress: () {
                              deleteData(id);
                            },
                            child: Card(
                              color: Colors.blueGrey[900],
                              child: ListTile(
                                leading: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    height: 35,
                                    width: 5,
                                    color: isDoneBool
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  task,
                                  style: !isDoneBool
                                      ? const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        )
                                      : const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationStyle:
                                              TextDecorationStyle.solid,
                                          decorationColor: Colors.white,
                                          decorationThickness: 2,
                                        ),
                                ),
                                trailing: CupertinoSwitch(
                                  value: isDoneBool,
                                  onChanged: (value) {
                                    setState(() {
                                      isDoneBool = !isDoneBool;
                                    });
                                    updateIsDone(id, isDone);
                                  },
                                  activeColor: Colors.green,
                                ),
                              ),
                            ),
                          );
                        })
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No task added yet!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Add Task',
                                          textAlign: TextAlign.center,
                                        ),
                                        content: TextField(
                                          controller: _taskController,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter your task',
                                            hintStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.blueGrey[900],
                                        titleTextStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        actions: [
                                          Center(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                insertData(
                                                    _taskController.text);
                                                _taskController.clear();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white24,
                                                foregroundColor: Colors.white,
                                                elevation: 3,
                                              ),
                                              child: const Text('Add'),
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[800],
                                foregroundColor: Colors.white,
                                elevation: 3,
                              ),
                              child: const Text('Add Task'),
                            )
                          ],
                        ),
                      );
              } else {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[700]!,
                  child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Container(
                            height: 45,
                            color: Colors.grey[900],
                          ),
                        );
                      }),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void initDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = '${databasesPath}todo.db';
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, isDone INTEGER)');
    });
    readInitialData();
    readData();
  }

  Future<List<Map>> readInitialData() async {
    List<Map> tempTasks =
        List<Map>.from(await db.rawQuery('SELECT * FROM tasks'));
    tempTasks.sort((a, b) => a['isDone'].compareTo(b['isDone']));
    return tempTasks;
  }

  void readData() async {
    List<Map> tempTasks =
        List<Map>.from(await db.rawQuery('SELECT * FROM tasks'));
    tempTasks.sort((a, b) => a['isDone'].compareTo(b['isDone']));
    setState(() {
      tasks = tempTasks;
    });
  }

  void insertData(String task) async {
    await db.transaction((txn) async {
      txn.rawInsert('INSERT INTO tasks(title, isDone) VALUES("$task", 0)');
    });
    readData();
  }

  void updateIsDone(int id, int isDone) async {
    await db.transaction((txn) async {
      txn.rawUpdate('UPDATE tasks SET isDone = ? WHERE id = ?',
          [isDone == 1 ? 0 : 1, id]);
    });
    readData();
  }

  void deleteData(int id) async {
    await db.transaction((txn) async {
      txn.rawDelete('DELETE FROM tasks WHERE id = $id');
    });
    readData();
  }

  void deleteAllData() async {
    await db.transaction((txn) async {
      txn.rawDelete('DELETE FROM tasks');
    });
    readData();
  }
}
