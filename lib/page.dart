import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'main.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool isKeyboardVisible = false;
  late TextEditingController _controller;
  Timer? _debounceTimer;
  TimeOfDay _selectedTime = TimeOfDay.now();
  late String timeClock;

  Future<void> _show() async {
    final TimeOfDay? result = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: false,
              ),
              child: child!);
        });
    if (result != null) {
      setState(() {
        _selectedTime = result;
        updateTimeClock();
      });
    }
  }

  void updateTimeClock() {
    timeClock =
        '${_selectedTime.hourOfPeriod}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period.index == 0 ? 'AM' : 'PM'}';
  }

  static const Color greenColor = Color(0xFF4AD911);
  static const Color greenColorOpacity = Color(0xFFDAF7E8);
  static const Color redColor = Color(0xFFFF7285);
  static const Color redColorOpacity = Color(0xFFFFE2E6);
  static const Color orangeColorOpacity = Color(0xFFFFF4E5);
  static const Color orangeColor = Color(0xFFFFCA83);
  static const Color blueColorOpacity = Color(0xFFE8E7FF);
  static const Color blueColor = Color(0xFF8280FF);
  static const Color greyColor = Color(0xFFB4B4C6);
  static const Color blackColor = Color(0xFF474747);

  TextStyle fontsStyleSmall() {
    return GoogleFonts.ubuntu(color: blackColor, fontWeight: FontWeight.w500);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    updateTimeClock();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget dateBar() {
    // Widget for select and view date and mouth.
    return SafeArea(
      child: Container(
        height: 145,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('To do',
                      style: GoogleFonts.ubuntu(
                          color: blackColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 32.0)),
                  Row(
                    children: [
                      Text('Tuesday, March 12',
                          style: GoogleFonts.ubuntu(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 14.0)),
                      const Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Icon(Icons.calendar_month,
                            color: Color(0xFF8390FF)),
                      )
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    data('S', '10'),
                    data('M', '11'),
                    data('T', '12'),
                    data('W', '13'),
                    data('T', '14'),
                    data('F', '15'),
                    data('S', '16'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget data(String name, String number) {
    //Widgets for view day
    return Column(
      children: [
        Text(name,
            style: GoogleFonts.ubuntu(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
            )),
        const SizedBox(
          height: 3.0,
        ),
        Text(
          number,
          style: GoogleFonts.ubuntu(
              color: blackColor, fontWeight: FontWeight.w600, fontSize: 20.0),
        )
      ],
    );
  }

  Widget toDoListWidgets() {
    // Widget for view and CRUD To Do
    var appState = context.watch<AppStateChange>();

    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Stack(
        children: [
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              )),
          Padding(
              padding: const EdgeInsets.all(4.0),
              child: appState.lengthToDoList == 0
                  ? Center(
                      child: Text(
                      'Today not ToDo yet.',
                      style: fontsStyleSmall(),
                    ))
                  : ListView.builder(
                      itemCount: appState.lengthToDoList,
                      itemBuilder: (context, index) {
                        var reversedItems = appState.toDoList.reversed.toList();
                        var item = reversedItems[index];
                        String name = item['name'];
                        String selectColor = item['colorMark'];
                        String timeClock = item['timeClock'];
                        bool mark = item['mark'] == 0 ? false : true;
                        bool remind = item['remind'] == 0 ? false : true;
                        bool notify = item['time'] == 0 ? false : true;
                        return todoContainer(name,
                            mark: mark,
                            selectMark: selectColor,
                            remind: remind,
                          notifi: notify,
                          timeAlarm: timeClock,
                        );
                      },
                    )),
          Positioned(bottom: 10, right: 0, left: 0, child: sliderPanel())
        ],
      ),
    ));
  }

  Widget todoContainer(String todo, //Main widgets for view To Do
      {String timeAlarm = '',
      bool notifi = false,
      bool mark = false,
      bool remind = false,
      String selectMark = 'green'}) {
    var appState = context.watch<AppStateChange>();
    var colorsMap = {
      'green': greenColor,
      'orange': orangeColor,
      'red': redColor,
    };

    Color selectColor = colorsMap[selectMark]!;

    return Dismissible(
      key: Key(todo),
      onDismissed: (_) {
        appState.deleteListToDo(todo);
      },
      background: Card(
        color: redColorOpacity,
        child: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: const Icon(
            Icons.delete,
            color: redColor,
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 360,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  alignment: Alignment.center,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.done,
                    color: Colors.grey,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    todo,
                    style: GoogleFonts.ubuntu(
                      color: blackColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                    ),
                  ),
                  if (notifi)
                    Text(
                      timeAlarm,
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (mark)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.circle, size: 15.0, color: selectColor),
                ),
              if (remind)
                const Padding(
                    padding: EdgeInsets.only(left: 4.0, right: 16.0),
                    child: Icon(Icons.notifications, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget sliderPanel() {
    // Widget for add To Do
    var appState = context.watch<AppStateChange>();
    return SlidingUpPanel(
        minHeight: 50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
        color: Colors.white,
        panel: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  width: 55,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: blackColor,
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 8.0),
                  child: Card(
                    elevation: 5.0,
                    shadowColor: blueColor,
                    color: Colors.white,
                    child: SizedBox(
                        width: 360,
                        height: 40,
                        child: TextField(
                            controller: _controller,
                            onChanged: (value) {
                              if (_debounceTimer?.isActive ?? false) {
                                _debounceTimer?.cancel();
                              }

                              _debounceTimer =
                                  Timer(const Duration(milliseconds: 500), () {
                                appState.updateNameToDo(value);
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'What do you need to do?',
                            ))),
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Icon(
                              Icons.alarm,
                              color: greyColor,
                            ),
                            const SizedBox(width: 10),
                            Text(timeClock, style: fontsStyleSmall())
                          ],
                        ),
                        Switch(
                            value: appState.timeSet,
                            activeColor: Colors.green,
                            onChanged: (bool value) {
                              setState(() {
                                appState.updateTimeSet(value);
                              });
                            })
                      ],
                    ),
                    if (appState.timeSet)
                      TextButton(
                        onPressed: () {
                          _show();
                        },
                        child: Text(
                          'Select Time',
                          style: GoogleFonts.ubuntu(
                              color: blueColor,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications,
                            color: greyColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Remind me',
                            style: fontsStyleSmall(),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildSelectRemind('In 24 hours'),
                        buildSelectRemind('An hour before'),
                        buildSelectRemind('15 minute before')
                      ],
                    )
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: greyColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Priority',
                      style: fontsStyleSmall(),
                    ),
                    const Spacer(),
                    buildSelectPriority('green'),
                    buildSelectPriority('orange'),
                    buildSelectPriority('red'),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: 360,
                  height: 40,
                  child: ElevatedButton(
                      onPressed: () {
                        if(appState.nameToDo != ''){
                        appState.updateTimeClock(timeClock);
                        appState.createListToDo();
                        _controller.clear();
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context){
                                Timer(const Duration(seconds: 3), () {
                                  Navigator.of(context).pop();
                                });

                                return const AlertDialog(
                                  title: Text('Warning'),
                                  content: Text('Your todo can not be empty'),
                                );
                              }
                          );
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(blueColor),
                          overlayColor: MaterialStateProperty.all<Color>(
                              blueColorOpacity)),
                      child: Text('SAVE',
                          style: GoogleFonts.ubuntu(color: Colors.white)
                      )
                  ),
                ),
              )
            ],
          ),
        ),
        collapsed: Align(
          alignment: Alignment.center,
          child: Text('Drag for add ToDo',
              style: GoogleFonts.ubuntu(
                  color: blackColor, fontWeight: FontWeight.bold)),
        ));
  }

  Widget buildSelectRemind(String option) {
    // Widgets for set remind for To Do
    var appState = context.watch<AppStateChange>();
    final isSelected = appState.selectedOptionRemind == option;
    final color = isSelected ? blueColor : Colors.grey[300];
    final colorText = isSelected ? Colors.white : blackColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          appState.updateSelectedOptionRemind(option);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.linear,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
            child: Text(
              option,
              style: TextStyle(color: colorText, fontSize: 12.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSelectPriority(String option) {
    // Widgets for set Priority for To Do
    var appState = context.watch<AppStateChange>();
    final isSelected = appState.selectedOptionPriority == option;

    var colorsMap = {
      'green': greenColor,
      'orange': orangeColor,
      'red': redColor,
    };

    var colorsMapOpacity = {
      'green': greenColorOpacity,
      'orange': orangeColorOpacity,
      'red': redColorOpacity,
    };

    Color selectColor = isSelected ? colorsMap[option]! : Colors.grey;
    Color selectColorOpacity =
        isSelected ? colorsMapOpacity[option]! : Colors.white;

    return InkWell(
      onTap: () {
        appState.updateSelectedOptionPriority(option);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
          height: 20,
          width: 20,
          decoration: BoxDecoration(
              color: selectColorOpacity,
              shape: BoxShape.circle,
              border: Border.all(color: selectColor)),
          child: Center(
            child: Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                  color: colorsMap[option], shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }

  Widget todoContainerDone(String todo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 360,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(
              color: const Color(0xFFFFCA83).withOpacity(0.3), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFCA83).withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 26.0),
              child: Icon(Icons.done, color: Color(0xFFFFCA83)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  todo,
                  style: GoogleFonts.ubuntu(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Main Build
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [dateBar(), toDoListWidgets()],
          ),
        ));
  }
}
