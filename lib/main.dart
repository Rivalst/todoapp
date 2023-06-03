import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color _blackColor = Color(0xFF474747);
  Color _greyColor = Color(0xFFB4B4C6);


  Widget data(String name, String number) {
    return Column(
      children: [
        Text(name,
            style: GoogleFonts.ubuntu(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
            )),
        SizedBox(
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
      {String timeAlarm = '', bool notifi = false, bool mark = false}) {
    return Padding(
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
            Spacer(),
            if (mark) Icon(Icons.circle, size: 15.0, color: Color(0xFF4AD991)),
            if (notifi)
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(Icons.notifications, color: Colors.grey)),
          ],
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
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
      children: [
        SafeArea(
          child: Container(
            height: 135,
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10.0)),
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
                child: ListView(children: [
                  todoContainer('Meet Ann', timeAlarm: '8:00', notifi: true),
                  todoContainer('Buy The Cook'),
                  todoContainer('Call mom'),
                  todoContainer('Make an appointment',
                      timeAlarm: '11:00 PM', notifi: true, mark: true),
                  todoContainerDone('Visit the University campus '),
                  todoContainerDone('Buy fruits'),
                ]),
              ),
              Positioned(
                bottom: 10,
                right: 0,
                left: 0,
                child: SlidingUpPanel(
                    minHeight: 50,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16.0)),
                    color: Colors.white,
                    panel: Column(
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
                        const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 50.0),
                            child: Card(
                              elevation: 5.0,
                              child: SizedBox(
                                  width: 360,
                                  height: 40,
                                  child: TextField(
                                      decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'What do you need to do?',
                                  ))),
                            ))
                      ],
                    ),
                    collapsed: Align(
                      alignment: Alignment.center,
                      child: Text('Drag for add ToDo',
                          style: GoogleFonts.ubuntu(
                              color: _blackColor, fontWeight: FontWeight.bold)),
                    )),
              )
            ],
          ),
        )),
      ],
    ));
  }
}
