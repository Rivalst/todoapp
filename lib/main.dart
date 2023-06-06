import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorBlue = Color(0xFF8280FF);
    const greyColor = Color(0xFFB4B4C6);

    return ChangeNotifierProvider(
      create: (context) => AppStateChange(),
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

class AppStateChange extends ChangeNotifier {
  String _nameToDo = '';
  String _selectedOptionRemind = '';
  String _selectedOptionPriority = '';

  final List _toDo = [];

  get selectedOptionRemind => _selectedOptionRemind;

  get selectedOptionPriority => _selectedOptionPriority;

  get lengthToDoList => _toDo.length;

  get toDoList => _toDo;

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

  void createListToDo() {
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
      });
      _nameToDo = '';
      _selectedOptionPriority = '';
      _selectedOptionRemind = '';
    }
    notifyListeners();
  }

  void deleteListToDo(String value) {
    _toDo.removeWhere((item) => item['name'] == value);
    notifyListeners();
  }

  Map toDoItem(int index) {
    return _toDo[index];
  }
}
