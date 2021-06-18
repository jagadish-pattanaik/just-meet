import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jagu_meet/model/note.dart';
import 'package:jagu_meet/widgets/cupertinoSwitchListTile.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import '../../../utils/databasehelper_scheduled.dart';
import 'package:date_time_picker/date_time_picker.dart';
import '../../../theme/theme.dart';
import '../../../theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/classes/focusNode.dart';

class NoteScreen extends StatefulWidget {
  final Note2 note2;
  NoteScreen(this.note2);

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

  var chatEnabled;
  var liveEnabled;
  var recordEnabled;
  var raiseEnabled;
  var shareYtEnabled;
  var kickOutEnabled;

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
    isEmpty();
  }

  bool _dateError = false;
  bool _fromError = false;
  bool _toError = false;

  bool hateError = false;
  List<String> hateSpeech = [
    'Bitch',
    'Fuck',
    'Anal',
    'Fuck',
    'sex',
    'Vaginal',
    'Piss',
    'Rascal',
    'Bastard',
    'Xxx',
    'Porn',
    'Terrorism',
    'Idiot',
    'F*ck',
    'Vagina',
    'F**k',
    'Shit',
    'fucker',
    'Chudai',
    'Dick',
    'Asshole',
    'asshole',
    '****',
    '***',
    'Madarchod',
    'Behenchod',
    'Maa ki',
    'Maaki',
    'Maki',
    'Lund',
    'Chut',
    'Chutad',
    'Bhosdike',
    'Bsdk',
    'Betichod',
    'Chutiya',
    'Harami',
    'chut',
    'Haramkhor'];

  hateDetect(final TextEditingController controller) {
    for (var i = 0; i < hateSpeech.length; i++) {
      if (controller.text.contains(hateSpeech[i])) {
        setState(() {
          hateError = true;
        });
      } else if (controller.text.toLowerCase().contains(hateSpeech[i])) {
        setState(() {
          hateError = true;
        });
      } else if (controller.text.toUpperCase().contains(hateSpeech[i])) {
        setState(() {
          hateError = true;
        });
      } else if (controller.text.isEmpty) {
        setState(() {
          hateError = false;
        });
      }else if (!controller.text.contains(hateSpeech[i])) {
        setState(() {
          hateError = false;
        });
      } else if (!controller.text.toLowerCase().contains(hateSpeech[i])) {
        setState(() {
          hateError = false;
        });
      } else if (!controller.text.toUpperCase().contains(hateSpeech[i])) {
        setState(() {
          hateError = false;
        });
      }
    }
  }

  void check() {
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
    return MaterialApp(
      theme: themeNotifier.getTheme(),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.clear,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          iconTheme: IconThemeData(color: themeNotifier.getTheme() == darkTheme
              ? Colors.white : Colors.black54),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xff0d0d0d)
              : Color(0xffffffff),
          elevation: 0,
          bottom: PreferredSize(
              child: Divider(
                  height: 1,
                  color: themeNotifier.getTheme() == darkTheme
                      ?  Color(0xFF303030) : Colors.black12
              ),
              preferredSize: Size(double.infinity, 0.0)),
          title: Text(
            'Schedule a Meeting',
            style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white : Colors.black54,
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
                                  ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('Schedule updated',)));
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
              Divider(
                height: 1,
                color: themeNotifier.getTheme() == darkTheme
                    ? Color(0xFF303030)
                    : Colors.black12,
              ),
              TextField(
                      controller: _descriptionController,
                      enableInteractiveSelection: false,
                      focusNode: AlwaysDisabledFocusNode(),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF191919)
                            : Color(0xFFf9f9f9),
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
              Divider(
                height: 1,
                color: themeNotifier.getTheme() == darkTheme
                    ? Color(0xFF303030)
                    : Colors.black12,
              ),
              TextField(
                      controller: _titleController,
                      autofocus: false,
                      onChanged: (val) {
                        hateDetect(_titleController);
                        isEmpty();
                      },
                textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
                        errorText:
                            hateError ? 'Hate speech detected!' : null,
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        hintText: 'Meeting Topic',
                        fillColor: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF191919)
                            : Color(0xFFf9f9f9),
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
              Divider(
                height: 1,
                color: themeNotifier.getTheme() == darkTheme
                    ? Color(0xFF303030)
                    : Colors.black12,
              ),
              DateTimePicker(
                      controller: _dateController,
                      type: DateTimePickerType.date,
                      initialDatePickerMode: DatePickerMode.day,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2022),
                      calendarTitle: 'Meeting Date',
                textAlign: TextAlign.center,
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
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
                        errorText:
                            _dateError ? 'Meeting Date is mandatory' : null,
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF191919)
                            : Color(0xFFf9f9f9),
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
                  ),Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  ListTile(
                    title: Text(
                      "Repeat",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    tileColor: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF191919)
                        : Color(0xFFf9f9f9),
                    onTap: () => showActionSheet(),
                    subtitle: Text(repeat, overflow: TextOverflow.ellipsis,),
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: IconButton(
                      icon: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                        ),
                      onPressed: () => showActionSheet(),
                  ),
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
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
                              textAlign: TextAlign.center,
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
                                isDense: true,
                                filled: true,
                                contentPadding: const EdgeInsets.only(
                                    top: 12.0, bottom: 12, left: 10),
                                errorText: _fromError
                                    ? 'Meeting Time is mandatory'
                                    : null,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: themeNotifier.getTheme() == darkTheme
                                          ? Color(0xFF303030)
                                          : Colors.black12,
                                      width: 1.0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
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
                              textAlign: TextAlign.center,
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
                                isDense: true,
                                filled: true,
                                contentPadding: const EdgeInsets.only(
                                    top: 12.0, bottom: 12, left: 10),
                                errorText: _toError
                                    ? 'Meeting Time is mandatory'
                                    : null,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: themeNotifier.getTheme() == darkTheme
                                          ? Color(0xFF303030)
                                          : Colors.black12,
                                      width: 1.0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
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
                  CupertinoSwitchListTile(
                    title: Text(
                      "Chat",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    subtitle: Text('Allow participants to chat in meeting', overflow: TextOverflow.ellipsis,),
                    value: chatEnabled == 0 ? false : true,
                    onChanged: onChatChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Raise Hand",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    subtitle: Text('Allow participants to raise hand', overflow: TextOverflow.ellipsis,),
                    value: raiseEnabled == 0 ? false : true,
                    onChanged: onRaiseChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Share YouTube Video",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                        'Allow participants to share YouTube video in meeting', overflow: TextOverflow.ellipsis,),
                    dense: true,
                    value: shareYtEnabled == 0 ? false : true,
                    onChanged: onYtChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Record Meeting",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    subtitle: Text('Allow Participants to record meeting', overflow: TextOverflow.ellipsis,),
                    value: recordEnabled == 0 ? false : true,
                    onChanged: onRecordChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Live streaming",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('Allow participants to live stream meeting', overflow: TextOverflow.ellipsis,),
                    dense: true,
                    value: liveEnabled == 0 ? false : true,
                    onChanged: onLiveChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Kick Out",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                        'Allow participants to kick ou each other in meeting', overflow: TextOverflow.ellipsis,),
                    dense: true,
                    value: kickOutEnabled == 0 ? false : true,
                    onChanged: onKickChanged,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showActionSheet() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
          actions: <Widget>[
      Container(
      color:themeNotifier.getTheme() == darkTheme
          ? Color(0xFF242424)
          : Colors.white,
        child: CupertinoActionSheetAction(
              child: Text('Daily',
                style: TextStyle(color: themeNotifier.getTheme() == darkTheme
                    ? Colors.white
                    : Colors.blue,),),
              isDefaultAction: true,
              onPressed: () {
                setState(() {
                  repeat = 'Daily';
                });
                Navigator.pop(context);
              },
            ),
      ),
    Container(
    color:themeNotifier.getTheme() == darkTheme
    ? Color(0xFF242424)
        : Colors.white,
    child: CupertinoActionSheetAction(
              child: Text('Weekly',
                style: TextStyle(color: themeNotifier.getTheme() == darkTheme
                    ? Colors.white
                    : Colors.blue,),),
              isDefaultAction: true,
              onPressed: () {
                setState(() {
                  repeat = 'Weekly';
                });
                Navigator.pop(context);
              },
            ),
    ),
    Container(
    color:themeNotifier.getTheme() == darkTheme
    ? Color(0xFF242424)
        : Colors.white,
    child: CupertinoActionSheetAction(
              child: Text('Monthly',
                style: TextStyle(color: themeNotifier.getTheme() == darkTheme
                    ? Colors.white
                    : Colors.blue,),),
              isDefaultAction: true,
              onPressed: () {
                setState(() {
                  repeat = 'Monthly';
                });
                Navigator.pop(context);
              },
            ),
    ),
    Container(
    color:themeNotifier.getTheme() == darkTheme
    ? Color(0xFF242424)
        : Colors.white,
    child: CupertinoActionSheetAction(
              child: Text('Never',
                style: TextStyle(color: themeNotifier.getTheme() == darkTheme
                    ? Colors.white
                    : Colors.blue,),),
              isDefaultAction: true,
              onPressed: () {
                setState(() {
                  repeat = 'Never';
                });
                Navigator.pop(context);
              },
            )
    ),
          ],
          cancelButton: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:themeNotifier.getTheme() == darkTheme
                    ? Color(0xFF242424)
                    : Colors.white,
              ),
              child: CupertinoActionSheetAction(
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold),),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      ),
    );
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
