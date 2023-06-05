import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  Color _blackColor = Color(0xFF474747);
  Color _greyColor = Color(0xFFB4B4C6);
  bool isKeyboardVisible = false;
  bool light = true;
  late TextEditingController _controller;
  FocusNode _focusNode = FocusNode();

  static const Color greenColor = Color(0xFF4AD911);
  static const Color greenColorOpacity = const Color(0xFFDAF7E8);
  static const Color redColor = const Color(0xFFFF7285);
  static const Color redColorOpacity = const Color(0xFFFFE2E6);
  static const Color orangeColorOpacity = const Color(0xFFFFF4E5);
  static const Color orangeColor = const Color(0xFFFFCA83);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildSelectRemind(String option) {
    var appState = context.watch<appStateChange>();
    final isSelected = appState.selectedOptionRemind == option;
    final color = isSelected ? Colors.blue : Colors.grey;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          appState.updateSelectedOptionRemind(option);
        },
        child: Container(
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
            child: Text(
              option,
              style: TextStyle(color: Colors.white, fontSize: 12.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSelectPriority(String option) {
    var appState = context.watch<appStateChange>();
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
        child: Container(
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

  Widget data(String name, String number) {
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
              color: _blackColor, fontWeight: FontWeight.w600, fontSize: 20.0),
        )
      ],
    );
  }

  Widget todoContainer(String todo,
      {String timeAlarm = '',
      bool notifi = false,
      bool mark = false,
      bool remind = false,
      String selectMark = 'green'}) {
    var appState = context.watch<appStateChange>();
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
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
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
                offset: Offset(0, 1),
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
                      color: _blackColor,
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
              if (mark) Padding(
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
    var appState = context.watch<appStateChange>();
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
                    color: _blackColor,
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 8.0),
                  child: Card(
                    elevation: 5.0,
                    child: SizedBox(
                        width: 360,
                        height: 40,
                        child: TextField(
                            controller: _controller,
                            onChanged: (value) {
                              appState.updateNameToDo(value);
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'What do you need to do?',
                            ))),
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [Icon(Icons.alarm), Text('10:00 PM')],
                    ),
                    Switch(
                        value: light,
                        activeColor: Colors.green,
                        onChanged: (bool value) {
                          setState(() {
                            light = value;
                          });
                        })
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.notifications),
                          Text('Remind me')
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
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded),
                    const Text('Priority'),
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
                child: Container(
                  width: 360,
                  height: 40,
                  child: ElevatedButton(
                      onPressed: () {
                        appState.createListToDo();
                        _controller.clear();
                      },
                      child: Text('SAVE')),
                ),
              )
            ],
          ),
        ),
        collapsed: Align(
          alignment: Alignment.center,
          child: Text('Drag for add ToDo',
              style: GoogleFonts.ubuntu(
                  color: _blackColor, fontWeight: FontWeight.bold)),
        ));
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
          border:
              Border.all(color: Color(0xFFFFCA83).withOpacity(0.3), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFFCA83).withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 1),
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
    var appState = context.watch<appStateChange>();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              SafeArea(
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
                        offset: Offset(0, 3),
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
                                    color: _blackColor,
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
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Stack(
                  children: [
                    Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        )),
                    Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ListView.builder(
                          itemCount: appState.lengthToDoList,
                          itemBuilder: (context, index) {
                            var reversedItems = appState.toDoList.reversed.toList();
                            var item = reversedItems[index];
                            String name = item['name'];
                            String selectColor = item['colorMark'];
                            bool mark = item['mark'];
                            bool remind = item['remind'];
                            return todoContainer(
                                name,
                                mark: mark,
                                selectMark: selectColor,
                                remind: remind
                            );
                          },
                        )),
                    Positioned(
                        bottom: 10, right: 0, left: 0, child: sliderPanel())
                  ],
                ),
              )),
            ],
          ),
        ));
  }
}
