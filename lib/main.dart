import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'page.dart';

void main() async {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorBlue = Color(0xFF8280FF);
    const greyColor = Color(0xFFB4B4C6);

    return ChangeNotifierProvider(
      create: (context) => AppStateChange()
        ..openDatabase(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            inputDecorationTheme: const InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: greyColor),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: colorBlue),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                labelStyle: TextStyle(color: colorBlue))),
        home: const MyHomePage(),
      ),
    );
  }
}

class DatabaseHelper {
  late Database _database;

  Future<void> open() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'todo2.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE todo2(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            mark INTEGER,
            colorMark TEXT,
            remind INTEGER,
            time INTEGER,
            timeClock TEXT,
            done INTEGER
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> getTodoList() async {
    return _database.query('todo2');
  }

  Future<void> insertTodoItem(Map<String, dynamic> item) async {
    await _database.insert('todo2', item);
  }

  Future<void> deleteTodoItem(int id) async {
    await _database.delete('todo2', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTodoItemByName(String name) async {
    await _database.delete(
      'todo2',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<void>updateToDo(String name, int value) async {
    await _database.update(
      'todo2',
      {'done': value}, // Update 'done' value in the database (1 represents true)
      where: 'name = ?',
      whereArgs: [name],
    );
  }



}

class AppStateChange extends ChangeNotifier {
  String _nameToDo = '';
  String _selectedOptionRemind = '';
  String _selectedOptionPriority = '';
  String _timeClock = '';
  bool _timeSet = false;

  final List<Map<String, dynamic>> _toDo = [];

  get nameToDo => _nameToDo;

  get selectedOptionRemind => _selectedOptionRemind;

  get selectedOptionPriority => _selectedOptionPriority;

  get lengthToDoList => _toDo.length;

  get timeSet => _timeSet;

  get timeClock => _timeClock;

  get toDoList => _toDo;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> openDatabase() async {
    await _databaseHelper.open();
    await loadTodoList();
  }

  Future<void> loadTodoList() async {
    final List<Map<String, dynamic>> todoList = await _databaseHelper.getTodoList();
    _toDo.clear();
    _toDo.addAll(todoList);
    notifyListeners();
  }

  Future<void> saveTodoItem(Map<String, dynamic> item) async {
    await _databaseHelper.insertTodoItem(item);
    await loadTodoList();
  }

  Future<void> deleteTodoItem(int id) async {
    await _databaseHelper.deleteTodoItem(id);
    await loadTodoList();
  }

  Future<void> updateDoneItem(String name, int value) async {
    await _databaseHelper.updateToDo(name, value);
    await loadTodoList();
  }

  void updateNameToDo(String value) {
    _nameToDo = value;
    notifyListeners();
  }

  void updateSelectedOptionRemind(String value) {
    _selectedOptionRemind = value;
    notifyListeners();
  }

  void updateSelectedOptionPriority(String value) {
    _selectedOptionPriority = value;
    notifyListeners();
  }

  void updateTimeClock(String value) {
    _timeClock = value;
    notifyListeners();
  }

  void updateTimeSet(bool value) {
    _timeSet = value;
    notifyListeners();
  }

  void createListToDo() async {
    String safeColor = 'green';
    // String safeRemind = 'An hour before';

    if (_nameToDo.isNotEmpty) {
      _toDo.add({
        'name': _nameToDo,
        'mark': _selectedOptionPriority.isNotEmpty ? true : false,
        'colorMark': _selectedOptionPriority.isNotEmpty
            ? _selectedOptionPriority
            : safeColor,
        'remind': _selectedOptionRemind.isNotEmpty ? true : false,
        'time': timeSet,
        'timeClock': _timeClock,
        'done': 0,
      });
      _nameToDo = '';
      _selectedOptionPriority = '';
      _selectedOptionRemind = '';
      _timeClock = '';
      _timeSet = false;
    }
    saveTodoItem(_toDo.last);
    notifyListeners();
  }

  void deleteListToDo(String value) async {
    _toDo.removeWhere((item) => item['name'] == value);
    await _databaseHelper.deleteTodoItemByName(value);
    notifyListeners();
  }

  Map toDoItem(int index) {
    return _toDo[index];
  }
}
