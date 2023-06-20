import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/notifi_service.dart';
import 'page.dart';
import 'package:timezone/data/latest.dart' as tz;


void main() async {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService().initializeNotification();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorBlue = Color(0xFF8280FF);
    const greyColor = Color(0xFFB4B4C6);

    return ChangeNotifierProvider(
      create: (context) => AppStateChange()..openDatabase(),
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

class TodoManager {
  static final TodoManager _instance = TodoManager._internal();
  factory TodoManager() => _instance;
  TodoManager._internal();
  
  List<Map<String, dynamic>> _todoList = [];

  List<Map<String, dynamic>> get todoList => _todoList;

  int get todoListLength => _todoList.length;

  void addTodoItem(Map<String, dynamic> item) {
    _todoList.add(item);
  }

  void deleteTodoItem(String name) {
    _todoList.removeWhere((item) => item['name'] == name);
  }

  void updateTodoItem(int index, Map<String, dynamic> updatedItem) {
    _todoList[index] = updatedItem;
  }

  void addAll(List<Map<String, dynamic>> todoList){
    todoList.forEach((element) {_todoList.add(element);});
  }

  void clear(){
    _todoList.clear();
  }
}


class DatabaseManager {
// There a new update Singleton
  static final DatabaseManager _instance = DatabaseManager._internal();
  factory DatabaseManager() => _instance;
  DatabaseManager._internal();
  late Database _database;
  
  Future<void> open() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'todo4.db');

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE todo4(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            mark INTEGER,
            colorMark TEXT,
            remind INTEGER,
            time INTEGER,
            timeClock TEXT,
            stringRemind TEXT,
            done INTEGER,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> getTodoList() async {
    return _database.query('todo4');
  }

  Future<void> insertTodoItem(Map<String, dynamic> item) async {
    await _database.insert('todo4', item);
  }

  Future<void> deleteTodoItem(int id) async {
    await _database.delete('todo4', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTodoItemByName(String name) async {
    await _database.delete(
      'todo4',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<void> updateTodoItem(Map<String, dynamic> item) async {
    await _database.update(
      'todo4',
      item,
      where: 'name = ?',
      whereArgs: [item['name']],
    );
  }

  Future<String> getTodoListAsJson() async {
    final todoList = await _database.query('todo4');
    return jsonEncode(todoList);
  }
}

class AppStateChange extends ChangeNotifier {
  String _nameToDo = '';
  String _selectedOptionRemind = '';
  String _selectedOptionPriority = '';
  String _timeClock = '';
  bool _timeSet = false;
  DateTime _selectedDay = DateTime.now();

  final TodoManager _todoManager = TodoManager();
  final DatabaseManager _databaseManager = DatabaseManager();

  String get nameToDo => _nameToDo;

  String get selectedOptionRemind => _selectedOptionRemind;

  String get selectedOptionPriority => _selectedOptionPriority;

  DateTime get selectedDate => _selectedDay;

  int get lengthToDoList => _todoManager.todoListLength;

  bool get timeSet => _timeSet;

  String get timeClock => _timeClock;

  List<Map<String, dynamic>> get toDoList => _todoManager.todoList;


  Future<void> openDatabase() async {
    await _databaseManager.open();
    await loadTodoList();
  }

  Future<void> loadTodoList() async {
    final List<Map<String, dynamic>> todoList = await _databaseManager.getTodoList();
    _todoManager.clear();
    _todoManager.addAll(todoList);
    notifyListeners();
  }

  Future<void> saveTodoItem(Map<String, dynamic> item) async {
    await _databaseManager.insertTodoItem(item);
    await loadTodoList();
  }

  Future<void> deleteTodoItem(int id) async {
    await _databaseManager.deleteTodoItem(id);
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

  void updateSelectedDate(DateTime date){
    _selectedDay = date;
    notifyListeners();
  }

  void updateTimeSet(bool value) {
    _timeSet = value;
    notifyListeners();
  }

  void createListToDo() async {
    String safeColor = 'green';

    if (_nameToDo.isNotEmpty) {
      final item = {
        'name': _nameToDo,
        'mark': _selectedOptionPriority.isNotEmpty ? true : false,
        'colorMark': _selectedOptionPriority.isNotEmpty ? _selectedOptionPriority : safeColor,
        'remind': _selectedOptionRemind.isNotEmpty ? true : false,
        'stringRemind': _selectedOptionRemind,
        'time': timeSet,
        'timeClock': _timeClock,
        'done': 0,
        'date': _selectedDay.toString(),
      };
      _todoManager.addTodoItem(item);
      _nameToDo = '';
      _selectedOptionPriority = '';
      _selectedOptionRemind = '';
      _timeClock = '';
      _timeSet = false;
    }
    await saveTodoItem(_todoManager.todoList.last);
    notifyListeners();
  }

  void deleteListToDo(String value) async {
    _todoManager.deleteTodoItem(value);
    await _databaseManager.deleteTodoItemByName(value);
    notifyListeners();
  }

  void updateDoneToDo(String value) async {
    var itemIndex = _todoManager.todoList.indexWhere((item) => item['name'] == value);
    if (itemIndex != -1) {
      var item = _todoManager.todoList[itemIndex].cast<String, dynamic>();
      var updatedItem = {...item};

      updatedItem['done'] = updatedItem['done'] == 0 ? 1 : 0;

      await _databaseManager.deleteTodoItemByName(value);
      await saveTodoItem(updatedItem);
    }
  }

  Future<String> showJsonData() async {
    final todoListJson = await _databaseManager.getTodoListAsJson();
    return todoListJson;
  }

  Map<String, dynamic> getToDoItem(int index) {
    return _todoManager.todoList[index];
  }
}

