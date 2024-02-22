import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Database db;
  List<Map> tasks = [];

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
        title: InkWell(
            onTap: () {
              deleteAllData();
            },
            child: const Text('To-Do App')),
        backgroundColor: Colors.blueGrey[900],
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
                      // fontSize: 18,
                      // fontWeight: FontWeight.bold,
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
                          insertData(_taskController.text);
                          Navigator.pop(context);
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
        child: const Icon(
          Icons.add,
          color: Colors.white70,
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 7,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey[900],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[900]!,
                blurRadius: 25,
                spreadRadius: 1,
                offset: Offset(3, 2),
              ),
            ],
          ),
          child: tasks.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    String task = tasks[index]['title'];
                    int isDone = tasks[index]['isDone'];
                    bool isDoneBool = isDone == 1;
                    return GestureDetector(
                      onLongPress: () {
                        deleteData();
                      },
                      child: Card(
                        color: Colors.blueGrey[900],
                        child: ListTile(
                          leading: InkWell(
                            onTap: () {
                              print(tasks[index]);
                            },
                            child: Container(
                              height: 35,
                              width: 5,
                              color: Colors.green,
                            ),
                          ),
                          title: Text(
                            task,
                            style: !isDoneBool
                                ? const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )
                                : TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.lineThrough,
                                    decorationStyle: TextDecorationStyle.solid,
                                    decorationColor: Colors.grey[900]!,
                                    decorationThickness: 3,
                                  ),
                          ),
                          trailing: CupertinoSwitch(
                            value: isDoneBool,
                            onChanged: (value) {
                              setState(() {
                                isDoneBool = !isDoneBool;
                              });
                              updateIsDone(index, isDone);
                            },
                            activeColor: Colors.green,
                          ),
                        ),
                      ),
                    );
                  })
              : const Center(
                  child: Text(
                    'No tasks added yet!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
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
    readData();
  }

  void readData() async {
    List<Map> tempTasks = await db.rawQuery('SELECT * FROM tasks');
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

  void updateIsDone(int index, int isDone) async {
    int id = tasks[index]['id'];
    await db.transaction((txn) async {
      txn.rawUpdate('UPDATE tasks SET isDone = ? WHERE id = ?',
          [isDone == 1 ? 0 : 1, id]);
    });
    readData();
  }

  void deleteData() async {
    await db.transaction((txn) async {
      txn.rawDelete('DELETE FROM tasks WHERE isDone = 1');
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
