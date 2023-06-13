import 'main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToDoContainer extends StatefulWidget {
  final String todo;
  final String timeAlarm;
  final String stringRemind;
  final bool notifi;
  final bool mark;
  final bool remind;
  bool done;
  final String selectMark;
  final AppStateChange appState;

  ToDoContainer(
    this.appState, {
    Key? key,
    required this.todo,
    this.timeAlarm = '',
    this.stringRemind = '',
    this.notifi = false,
    this.mark = false,
    this.remind = false,
    this.selectMark = 'green',
    required this.done,
  }) : super(key: key);

  @override
  State<ToDoContainer> createState() => _ToDoContainerState();
}

class _ToDoContainerState extends State<ToDoContainer> {
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var colorsMap = {
      'green': greenColor,
      'orange': orangeColor,
      'red': redColor,
    };

    Color selectColor = colorsMap[widget.selectMark]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Dismissible(
        key: Key(widget.todo),
        onDismissed: (_) {
          widget.appState.deleteListToDo(widget.todo);
        },
        confirmDismiss: (_) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm Deletion"),
                content:
                    const Text("Are you sure you want to delete this To Do?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("CANCEL"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("DELETE"),
                  ),
                ],
              );
            },
          );
        },
        background: Container(
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: redColorOpacity,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(
              Icons.delete,
              color: redColor,
            ),
          ),
        ),
        direction: DismissDirection.endToStart,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: 360,
          height: widget.done ? 40 : 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
                color: widget.done
                    ? orangeColor.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                width: 1.0),
            boxShadow: [
              BoxShadow(
                color: widget.done
                    ? orangeColorOpacity.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.done = !widget
                          .done; // Toggle the 'done' value in the widget state
                    });
                    widget.appState.updateDoneToDo(widget.todo);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    alignment: Alignment.center,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.done ? orangeColor : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: widget.done ? Colors.white : Colors.grey,
                          width: 1.5),
                    ),
                    child: Icon(
                      Icons.done,
                      color: widget.done ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.todo,
                    style: GoogleFonts.ubuntu(
                      color: widget.done ? greyColor : blackColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0,
                    ),
                  ),
                  if (widget.notifi)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      width: widget.done ? 0 : 100,
                      height: widget.done ? 0 : 20,
                      child: Text(
                        widget.timeAlarm,
                        style: GoogleFonts.ubuntu(
                          color: greyColor,
                          fontWeight: FontWeight.w500,
                          // fontSize: widget.done ? 5.0 : 14.0,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              if (widget.mark && widget.done != true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.circle, size: 15.0, color: selectColor),
                ),
              if (widget.remind && widget.done != true)
                Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 16.0),
                    child: IconButton(
                        onPressed: () {
                          final snackBar = SnackBar(
                            content: Text(
                                widget.stringRemind,
                              style: const TextStyle(
                                color: blueColorOpacity
                              ),
                            ),
                            action: SnackBarAction(
                              label: 'Close',
                              textColor: blueColorOpacity,
                              onPressed: () {
                                // Some code to undo the change.
                              },
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        icon: const Icon(Icons.notifications),
                        color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
