import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jagu_meet/model/note.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import '../utils/databasehelper_scheduled.dart';
import 'package:date_time_picker/date_time_picker.dart';
import '../theme/theme.dart';
import '../theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/classes/focusNode.dart';

class NoteScreen extends StatefulWidget {
  final Note2 note2;
  final personalId;
  NoteScreen(this.note2, this.personalId);

  @override
  State<StatefulWidget> createState() => new _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  DatabaseHelper2 db2 = new DatabaseHelper2();

  TextEditingController _titleController;
  TextEditingController _descriptionController;
  TextEditingController _dateController;
  TextEditingController _fromController;
  TextEditingController _toController;

  var _darkTheme;

  var chatEnabled;
  var liveEnabled;
  var recordEnabled;
  var raiseEnabled;
  var shareYtEnabled;
  var kickOutEnabled;

  var useId = false;
  var personalId;

  var repeat;

  @override
  void initState() {
    super.initState();
    _titleController = new TextEditingController(text: widget.note2.title2);
    _descriptionController = new TextEditingController(
      text: widget.note2.description2,
    );
    _dateController = new TextEditingController(text: widget.note2.date2);
    _fromController = new TextEditingController(text: widget.note2.from2);
    _toController = new TextEditingController(text: widget.note2.to2);
    repeat = widget.note2.repeat;
    chatEnabled = widget.note2.chatEnabled2;
    liveEnabled = widget.note2.liveEnabled2;
    recordEnabled = widget.note2.recordEnabled2;
    raiseEnabled = widget.note2.raiseEnabled2;
    shareYtEnabled = widget.note2.shareYtEnabled2;
    kickOutEnabled = widget.note2.kickOutEnabled2;
    personalId = widget.personalId;
    isEmpty();
  }

  bool _desError = false;
  bool _titleError = false;
  bool _dateError = false;
  bool _fromError = false;
  bool _toError = false;

  void check() {
    setState(() {
      _descriptionController.text.length >= 10
          ? _desError = false
          : _desError = true;
    });

    setState(() {
      _titleController.text.isNotEmpty
          ? _titleError = false
          : _titleError = true;
    });

    setState(() {
      _dateController.text.isNotEmpty ? _dateError = false : _dateError = true;
    });

    setState(() {
      _fromController.text.isNotEmpty ? _fromError = false : _fromError = true;
    });

    setState(() {
      _toController.text.isNotEmpty ? _toError = false : _toError = true;
    });
  }

  bool isButtonEnabled;
  isEmpty() {
    if ((_descriptionController.text.length >= 10) &&
        (_titleController.text != "") &&
        (_dateController.text != "") &&
        (_fromController.text != "") &&
        (_toController.text != "")) {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return MaterialApp(
      theme: themeNotifier.getTheme(),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xFF242424)
              : Colors.blue,
          elevation: 5,
          title: const Text(
            'Schedule a Meeting',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: (widget.note2.id2 != null)
                  ? Icon(
                      Icons.edit,
                      color:
                          isButtonEnabled ? Colors.white : Colors.transparent,
                    )
                  : Icon(
                      Icons.add,
                      color:
                          isButtonEnabled ? Colors.white : Colors.transparent,
                    ),
              onPressed: isButtonEnabled
                  ? () {
                      check();
                      if (widget.note2.id2 != null) {
                        if (_descriptionController.text.length >= 10) {
                          if (_titleController.text.isNotEmpty) {
                            if (_dateController.text.isNotEmpty) {
                              if (_fromController.text.isNotEmpty) {
                                if (_toController.text.isNotEmpty) {
                                  db2
                                      .updateNote2(Note2.fromMap({
                                    'id2': widget.note2.id2,
                                    'title2': _titleController.text,
                                    'description2': _descriptionController.text,
                                    'date2': _dateController.text,
                                    'from2': _fromController.text,
                                    'to2': _toController.text,
                                    'repeat': repeat,
                                    'chatEnabled2': chatEnabled,
                                    'liveEnabled2': liveEnabled,
                                    'recordEnabled2': recordEnabled,
                                    'raiseEnabled2': raiseEnabled,
                                    'shareYtEnabled': shareYtEnabled,
                                    'kickOutEnabled': kickOutEnabled
                                  }))
                                      .then((_) {
                                    Navigator.pop(context, 'update');
                                  });
                                  Fluttertoast.showToast(
                                      msg: 'Schedule Updated',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              }
                            }
                          }
                        }
                      } else {
                        check();
                        if (_descriptionController.text.length >= 10) {
                          if (_titleController.text.isNotEmpty) {
                            if (_dateController.text.isNotEmpty) {
                              if (_fromController.text.isNotEmpty) {
                                if (_toController.text.isNotEmpty) {
                                  db2
                                      .saveNote2(Note2(
                                    _titleController.text,
                                    _descriptionController.text,
                                    _dateController.text,
                                    _fromController.text,
                                    _toController.text,
                                    repeat,
                                    chatEnabled,
                                    liveEnabled,
                                    recordEnabled,
                                    raiseEnabled,
                                    shareYtEnabled,
                                    kickOutEnabled,
                                  ))
                                      .then((_) {
                                    Navigator.pop(context, 'save');
                                  });
                                  Fluttertoast.showToast(
                                      msg: 'Meeting Scheduled',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  : null,
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            height: double.maxFinite,
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.grey),
                      controller: _descriptionController,
                      enableInteractiveSelection: false,
                      focusNode: AlwaysDisabledFocusNode(),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        counterText: '',
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
                        errorText: _desError ? 'Invalid Meeting Id' : null,
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: "Meeting Id",
                        labelStyle: TextStyle(color: Colors.blue),
                        hintText: 'Meeting Id',
                        fillColor: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF191919)
                            : Color(0xFFf9f9f9),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: (widget.note2.id2 != null) ? false : true,
                    child: ListTile(
                      title: Text(
                        "Use Personal Meeting ID",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle: Text(personalId),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: useId,
                          onChanged: onIdChanged,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: (widget.note2.id2 != null) ? true : false,
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: TextField(
                      controller: _titleController,
                      autofocus: false,
                      onChanged: (val) {
                        isEmpty();
                      },
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        counterText: '',
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
                        errorText:
                            _titleError ? 'Meeting Topic is mandatory' : null,
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: "Meeting Topic",
                        labelStyle: TextStyle(color: Colors.blue),
                        hintText: 'Meeting Topic',
                        fillColor: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF191919)
                            : Color(0xFFf9f9f9),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: DateTimePicker(
                      controller: _dateController,
                      type: DateTimePickerType.date,
                      initialDatePickerMode: DatePickerMode.day,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2022),
                      calendarTitle: 'Meeting Date',
                      onChanged: (value) {
                        isEmpty();
                        setState(() {
                          _dateController.text = value;
                        });
                      },
                      onSaved: (value) {
                        setState(() {
                          _dateController.text = value;
                        });
                      },
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
                        errorText:
                            _dateError ? 'Meeting Date is mandatory' : null,
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: 'Meeting Date',
                        labelStyle: TextStyle(color: Colors.blue),
                        hintText: 'Meeting Date',
                        fillColor: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF191919)
                            : Color(0xFFf9f9f9),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  ListTile(
                    title: Text(
                      "Repeat",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String value) {
                        setState(() {
                          repeat = value;
                        });
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Never',
                          child: Text('Never'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Daily',
                          child: Text('Every Day'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Weekly',
                          child: Text('Every Week'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Monthly',
                          child: Text('Every Month'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Yearly',
                          child: Text('Every Year'),
                        ),
                      ],
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(repeat),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        )
                      ]),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      'Meeting Time',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: DateTimePicker(
                              controller: _fromController,
                              type: DateTimePickerType.time,
                              calendarTitle: 'From',
                              dateMask: 'hh:mm a',
                              use24HourFormat: false,
                              onChanged: (value) {
                                isEmpty();
                                setState(() {
                                  _fromController.text = value;
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _fromController.text = value;
                                });
                              },
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 2.0),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                isDense: true,
                                filled: true,
                                contentPadding: const EdgeInsets.only(
                                    top: 12.0, bottom: 12, left: 10),
                                errorText: _fromError
                                    ? 'Meeting Time is mandatory'
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: 'From',
                                labelStyle: TextStyle(color: Colors.blue),
                                hintText: 'From',
                                fillColor: themeNotifier.getTheme() == darkTheme
                                    ? Color(0xFF191919)
                                    : Color(0xFFf9f9f9),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: DateTimePicker(
                              controller: _toController,
                              type: DateTimePickerType.time,
                              calendarTitle: 'To',
                              dateMask: 'hh:mm a',
                              use24HourFormat: false,
                              onChanged: (value) {
                                isEmpty();
                                setState(() {
                                  _toController.text = value;
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _toController.text = value;
                                });
                              },
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 2.0),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                isDense: true,
                                filled: true,
                                contentPadding: const EdgeInsets.only(
                                    top: 12.0, bottom: 12, left: 10),
                                errorText: _toError
                                    ? 'Meeting Time is mandatory'
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: 'To',
                                labelStyle: TextStyle(color: Colors.blue),
                                hintText: 'To',
                                fillColor: themeNotifier.getTheme() == darkTheme
                                    ? Color(0xFF191919)
                                    : Color(0xFFf9f9f9),
                              ),
                            ),
                          ),
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 5,
                    ),
                    child: Text(
                      'Meeting Settings',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  ListTile(
                    tileColor: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF191919)
                        : Color(0xFFf9f9f9),
                    title: Text(
                      "Chat",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    subtitle: Text('Allow participants to chat in meeting'),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: chatEnabled == 0 ? false : true,
                        onChanged: onChatChanged,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  ListTile(
                    tileColor: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF191919)
                        : Color(0xFFf9f9f9),
                    title: Text(
                      "Raise Hand",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    subtitle: Text('Allow participants to raise hand'),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: raiseEnabled == 0 ? false : true,
                        onChanged: onRaiseChanged,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  ListTile(
                    tileColor: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF191919)
                        : Color(0xFFf9f9f9),
                    title: Text(
                      "Share YouTube Video",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                        'Allow participants to share YouTube video in meeting'),
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: shareYtEnabled == 0 ? false : true,
                        onChanged: onYtChanged,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  ListTile(
                    tileColor: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF191919)
                        : Color(0xFFf9f9f9),
                    title: Text(
                      "Record Meeting",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    subtitle: Text('Allow Participants to record meeting'),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: recordEnabled == 0 ? false : true,
                        onChanged: onRecordChanged,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  ListTile(
                    tileColor: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF191919)
                        : Color(0xFFf9f9f9),
                    title: Text(
                      "Live streaming",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('Allow participants to live stream meeting'),
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: liveEnabled == 0 ? false : true,
                        onChanged: onLiveChanged,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  ListTile(
                    tileColor: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF191919)
                        : Color(0xFFf9f9f9),
                    title: Text(
                      "Kick Out",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                        'Allow participants to kick ou each other in meeting'),
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: kickOutEnabled == 0 ? false : true,
                        onChanged: onKickChanged,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //     SizedBox(
                  //       height: 50.0,
                  //       width: double.maxFinite,
                  //       child:
                  //         RaisedButton(
                  //           color: Colors.blue,
                  //           disabledColor: themeNotifier.getTheme() == darkTheme? Color(0xFF242424) : Colors.grey,
                  //           elevation: 5,
                  //           disabledElevation: 0,
                  //           disabledTextColor: themeNotifier.getTheme() == darkTheme? Colors.grey : Colors.white,
                  //           textColor: Colors.white,
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(18.0),
                  //           ),
                  //           child: (widget.note2.id2 != null) ? Text('Update', style: TextStyle(fontSize: 18,
                  //               fontWeight: FontWeight.bold),) : Text('Schedule', style: TextStyle(fontSize: 18,
                  //               fontWeight: FontWeight.bold),),
                  //           onPressed: isButtonEnabled? () {
                  //             check();
                  //             if (widget.note2.id2 != null) {
                  //               if (_descriptionController.text.length >= 10) {
                  //                 if (_titleController.text.isNotEmpty) {
                  //                   if (_dateController.text.isNotEmpty) {
                  //                     if (_fromController.text.isNotEmpty) {
                  //                       if (_toController.text.isNotEmpty) {
                  //                         db2.updateNote2(Note2.fromMap({
                  //                           'id2': widget.note2.id2,
                  //                           'title2': _titleController.text,
                  //                           'description2': _descriptionController.text,
                  //                           'date2': _dateController.text,
                  //                           'from2': _fromController.text,
                  //                           'to2': _toController.text,
                  //                           'repeat': repeat,
                  //                           'chatEnabled2': chatEnabled,
                  //                           'liveEnabled2': liveEnabled,
                  //                           'recordEnabled2': recordEnabled,
                  //                           'raiseEnabled2': raiseEnabled,
                  //                           'shareYtEnabled': shareYtEnabled,
                  //                           'kickOutEnabled': kickOutEnabled
                  //                         })).then((_) {
                  //                           Navigator.pop(context, 'update');
                  //                         });
                  //                         Fluttertoast.showToast(
                  //                             msg: 'Schedule Updated',
                  //                             toastLength: Toast.LENGTH_SHORT,
                  //                             gravity: ToastGravity.SNACKBAR,
                  //                             timeInSecForIosWeb: 1,
                  //                             backgroundColor: Colors.black,
                  //                             textColor: Colors.white,
                  //                             fontSize: 16.0
                  //                         );
                  //                       }
                  //                     }
                  //                   }
                  //                 }
                  //               }
                  //             }else {
                  //               check();
                  //               if (_descriptionController.text.length >= 10) {
                  //                 if (_titleController.text.isNotEmpty) {
                  //                   if (_dateController.text.isNotEmpty) {
                  //                     if (_fromController.text.isNotEmpty) {
                  //                       if (_toController.text.isNotEmpty) {
                  //                         db2.saveNote2(Note2(
                  //                         _titleController.text,
                  //                         _descriptionController.text,
                  //                         _dateController.text,
                  //                         _fromController.text,
                  //                         _toController.text,
                  //                         repeat,
                  //                         chatEnabled,
                  //                         liveEnabled,
                  //                         recordEnabled,
                  //                         raiseEnabled,
                  //                             shareYtEnabled,
                  //                             kickOutEnabled,)).then((_) {
                  //                         Navigator.pop(context, 'save');
                  //                         });
                  //                         Fluttertoast.showToast(
                  //                             msg: 'Meeting Scheduled',
                  //                             toastLength: Toast.LENGTH_SHORT,
                  //                             gravity: ToastGravity.SNACKBAR,
                  //                             timeInSecForIosWeb: 1,
                  //                             backgroundColor: Colors.black,
                  //                             textColor: Colors.white,
                  //                             fontSize: 16.0
                  //                         );
                  //                       }
                  //                     }
                  //                   }
                  //                 }
                  //               }
                  //             }
                  // } : null,
                  //         ),
                  //     ),
                  //         SizedBox(
                  //           height: 20,
                  //         )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  onIdChanged(bool value) {
    setState(() {
      useId = value;
      if (useId == true) {
        _descriptionController.text = personalId;
      } else {
        _descriptionController.text = widget.note2.description2;
      }
    });
  }

  onChatChanged(bool value) {
    setState(() {
      chatEnabled = value;
      if (value == false) {
        setState(() {
          chatEnabled = 0;
        });
      } else {
        setState(() {
          chatEnabled = 1;
        });
      }
    });
  }

  onYtChanged(bool value) {
    setState(() {
      shareYtEnabled = value;
      if (value == false) {
        setState(() {
          shareYtEnabled = 0;
        });
      } else {
        setState(() {
          shareYtEnabled = 1;
        });
      }
    });
  }

  onKickChanged(bool value) async {
    if (kickOutEnabled == false) {
      final action = await Dialogs.yesAbortDialog(
          context,
          'Not Recommended',
          'Allowing participants to kick out each other in meeting is not recommended by Just Meet. Do you still want to allow?',
          'Allow',
          'No');
      if (action == DialogAction.yes) {
        setState(() {
          kickOutEnabled = value;
          if (value == false) {
            setState(() {
              kickOutEnabled = 0;
            });
          } else {
            setState(() {
              kickOutEnabled = 1;
            });
          }
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        kickOutEnabled = value;
        if (value == false) {
          setState(() {
            kickOutEnabled = 0;
          });
        } else {
          setState(() {
            kickOutEnabled = 1;
          });
        }
      });
    }
  }

  onLiveChanged(bool value) async {
    if (liveEnabled == false) {
      final action = await Dialogs.yesAbortDialog(
          context,
          'Not Recommended',
          'Allowing participants to live stream meeting is not recommended by Just Meet. Do you still want to allow?',
          'Allow',
          'No');
      if (action == DialogAction.yes) {
        setState(() {
          liveEnabled = value;
          if (value == false) {
            setState(() {
              liveEnabled = 0;
            });
          } else {
            setState(() {
              liveEnabled = 1;
            });
          }
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        liveEnabled = value;
        if (value == false) {
          setState(() {
            liveEnabled = 0;
          });
        } else {
          setState(() {
            liveEnabled = 1;
          });
        }
      });
    }
  }

  onRecordChanged(bool value) async {
    if (recordEnabled == false) {
      final action = await Dialogs.yesAbortDialog(
          context,
          'Not Recommended',
          'Allowing participants to record meeting is not recommended by Just Meet. Do you still want to allow?',
          'Allow',
          'No');
      if (action == DialogAction.yes) {
        if (value == false) {
          setState(() {
            recordEnabled = 0;
          });
        } else {
          setState(() {
            recordEnabled = 1;
          });
        }
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        recordEnabled = value;
        if (value == false) {
          setState(() {
            recordEnabled = 0;
          });
        } else {
          setState(() {
            recordEnabled = 1;
          });
        }
      });
    }
  }

  onRaiseChanged(bool value) {
    setState(() {
      raiseEnabled = value;
      if (value == false) {
        setState(() {
          raiseEnabled = 0;
        });
      } else {
        setState(() {
          raiseEnabled = 1;
        });
      }
    });
  }
}
