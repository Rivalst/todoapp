import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:table_calendar/table_calendar.dart';
import 'main.dart';
import 'dart:async';
import 'widgets.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool isKeyboardVisible = false;
  late TextEditingController _controller;
  Timer? _debounceTimer;
  Timer? _clockTimer;
  TimeOfDay _selectedTime = TimeOfDay.now();
  late String timeClock;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  double _heightCalendar = 200;

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

    if (_clockTimer?.isActive ?? false) {
      _clockTimer?.cancel();
    }

    _clockTimer = Timer(const Duration(milliseconds: 500), () {
      if (result != null) {
        setState(() {
          _selectedTime = result;
          updateTimeClock();
        });
      }
    });
  }

  void updateTimeClock() {
    timeClock =
        '${_selectedTime.hourOfPeriod}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period.index == 0 ? 'AM' : 'PM'}';
  }


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
    _clockTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget dateBar() {
    // Widget for select and view date and mouth.
    var appState = context.watch<AppStateChange>();
    var selectedDate = appState.selectedDate;
    DateFormat formatter = DateFormat('EEEE, MMMM d');
    String date = formatter.format(selectedDate);

    final today = DateTime.now();
    final firstDay = DateTime(today.year, today.month - 3, today.day);
    final lastDay = DateTime(today.year, today.month + 3, today.day);

    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        height: _heightCalendar,
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
                      Text(date,
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
                padding: const EdgeInsets.only(top: 0.0),
                child: TableCalendar(
                  firstDay: firstDay,
                  lastDay: lastDay,
                  availableCalendarFormats: const {
                    CalendarFormat.week: 'ThoWeeks',
                    CalendarFormat.month: 'Week',
                    CalendarFormat.twoWeeks: 'Month'
                  },

                  formatAnimationDuration: const Duration(milliseconds: 500),
                  formatAnimationCurve: Curves.easeInOut,

                  focusedDay: appState.selectedDate,
                  selectedDayPredicate: (day) {
                    return isSameDay(appState.selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    appState.updateSelectedDate(selectedDay);
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarFormat: _calendarFormat,
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                      color: blueColor,
                      shape: BoxShape.circle
                    ),
                   defaultTextStyle: fontsStyleSmall(),
                    weekendTextStyle: fontsStyleSmall(),
                    todayDecoration: BoxDecoration(
                      color: blueColor.withOpacity(0.6),
                      shape: BoxShape.circle
                    )
                  ),

                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                        if (_calendarFormat == CalendarFormat.week) {
                          _heightCalendar = 200;
                        } else if (_calendarFormat == CalendarFormat.twoWeeks) {
                          _heightCalendar = 270;
                        } else {
                          _heightCalendar = 420;
                        }
                      });
                    }
                  },
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
    var selectedDate = appState.selectedDate;

    var reversedItems = appState.toDoList.reversed.toList();
    var selectedDayList = [];
    for (int i = 0; i < reversedItems.length; i++) {
      var element = reversedItems[i];
      var date = DateTime.parse(element['date']);
      if (date.day.toString() == selectedDate.day.toString()) {
        selectedDayList.add(element);
      }
    }

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
              padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 60.0),
              child: selectedDayList.isEmpty
                  ? Center(
                      child: Text(
                        'There not todo yet.',
                        style: fontsStyleSmall(),
                      ),

                    )
                  : ListView.builder(
                      itemCount: selectedDayList.length,
                      itemBuilder: (context, index) {
                        var item = selectedDayList[index];
                        String name = item['name'];
                        String selectColor = item['colorMark'];
                        String timeClock = item['timeClock'];
                        String stringRemind = item['stringRemind'];
                        bool mark = item['mark'] == 0 ? false : true;
                        bool remind = item['remind'] == 0 ? false : true;
                        bool notify = item['time'] == 0 ? false : true;
                        bool done = item['done'] == 0 ? false : true;
                        return ToDoContainer(
                          appState,
                          done: done,
                          todo: name,
                          mark: mark,
                          selectMark: selectColor,
                          stringRemind: stringRemind,
                          remind: remind,
                          notifi: notify,
                          timeAlarm: timeClock,
                          // done: done,
                        );
                      },
                    )),
          Positioned(bottom: 10, right: 0, left: 0, child: sliderPanel())
        ],
      ),
    ));
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
                            maxLength: 25,
                            decoration: const InputDecoration(
                              labelText: 'What do you need to do?',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15.0),
                              counterText: '',
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
                                if (appState.timeSet == false) {
                                  appState.updateSelectedOptionRemind('');
                                }
                              });
                            })
                      ],
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      height: appState.timeSet ? 50 : 0,
                      child: TextButton(
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
                        if (appState.nameToDo != '') {
                          appState.updateTimeClock(timeClock);
                          appState.createListToDo();
                          _controller.clear();
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                Timer(const Duration(seconds: 3), () {
                                  Navigator.of(context).pop();
                                });

                                return const AlertDialog(
                                  title: Text('Warning'),
                                  content: Text('Your todo can not be empty'),
                                );
                              });
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(blueColor),
                          overlayColor: MaterialStateProperty.all<Color>(
                              blueColorOpacity)),
                      child: Text('SAVE',
                          style: GoogleFonts.ubuntu(color: Colors.white))),
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
          appState.timeSet
              ? appState.updateSelectedOptionRemind(option)
              : showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      content: Text('For set remind you ned to on time'),
                    );
                  });
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
