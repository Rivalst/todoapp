import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => appStateChange(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const MyHomePage(),
      ),
    );
  }
}

class appStateChange extends ChangeNotifier{
  String _nameToDo = '';
  String _selectedOptionRemind = '';
  String _selectedOptionPriority = '';

  get selectedOptionRemind => _selectedOptionRemind;
  get selectedOptionPriority => _selectedOptionPriority;

  void updateNameToDo(String value){
    _nameToDo = value;
    notifyListeners();
  }

  void updateSelectedOptionRemind(String value){
    _selectedOptionRemind = value;
    notifyListeners();
  }

  void updateSelectedOptionPriority(String value){
    _selectedOptionPriority = value;
    notifyListeners();
  }
}

