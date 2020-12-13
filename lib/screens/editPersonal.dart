import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jagu_meet/classes/focusNode.dart';

class editPersonal extends StatefulWidget {
  final chat;
  final live;
  final record;
  final raise;
  final id;
  final name;
  final ytshare;
  final kick;
  editPersonal(
      {Key key,
      @required this.chat,
      this.live,
      this.record,
      this.raise,
      this.id,
      this.name,
      this.ytshare,
      this.kick})
      : super(key: key);

  @override
  _editPersonalState createState() =>
      _editPersonalState(chat, live, record, raise, id, name, ytshare, kick);
}

class _editPersonalState extends State<editPersonal> {
  final chat;
  final live;
  final record;
  final raise;
  final id;
  final name;
  final ytshare;
  final kick;
  _editPersonalState(this.chat, this.live, this.record, this.raise, this.id,
      this.name, this.ytshare, this.kick);

  var _darkTheme;
  var chatEnabled = true;
  var shareYtEnabled = true;
  var liveEnabled = false;
  var recordEnabled = false;
  var raiseEnabled = true;
  var personalId = '.';
  var personalName = '.';
  var kickOutEnabled = false;

  bool isEdited = false;

  onEdit() {
    setState(() {
      isEdited = true;
    });
  }

  final meetingText = TextEditingController();
  final meetingName = TextEditingController();

  getInfo() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        chatEnabled = chat;
        liveEnabled = live;
        recordEnabled = record;
        raiseEnabled = raise;
        shareYtEnabled = ytshare;
        personalId = id;
        personalName = name;
        kickOutEnabled = kick;
      });
    });
    Future.delayed(Duration(milliseconds: 500), () {});
  }

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    meetingText.text = personalId;
    meetingName.text = personalName;
    return MaterialApp(
      title: 'Just Meet',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.getTheme(),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit,
                  color: isEdited ? Colors.white : Colors.transparent),
              onPressed: isEdited
                  ? () {
                      onSaved();
                    }
                  : null,
            ),
          ],
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xFF242424)
              : Colors.blue,
          elevation: 5,
          title: Text(
            'Personal Meeting ID',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
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
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: Colors.grey),
                        focusNode: AlwaysDisabledFocusNode(),
                        enableInteractiveSelection: false,
                        autofocus: false,
                        maxLength: 11,
                        controller: meetingText,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.blue, width: 1.0),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          counterText: '',
                          isDense: true,
                          filled: true,
                          contentPadding: const EdgeInsets.only(
                              top: 12.0, bottom: 12, left: 10),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "Personal Meeting Id",
                          labelStyle: TextStyle(color: Colors.blue),
                          hintText: 'Meeting Id',
                          fillColor: themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF191919)
                              : Color(0xFFf9f9f9),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: TextField(
                        autofocus: false,
                        controller: meetingName,
                        onChanged: (val) {
                          setState(() {
                            isEdited = true;
                          });
                        },
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.blue, width: 1.0),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          isDense: true,
                          filled: true,
                          contentPadding: const EdgeInsets.only(
                              top: 12.0, bottom: 12, left: 10),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "Personal Meeting Topic",
                          labelStyle: TextStyle(color: Colors.blue),
                          hintText: 'Meeting Topic',
                          fillColor: themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF191919)
                              : Color(0xFFf9f9f9),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 15, left: 5, bottom: 5),
                      child: Text(
                        'Personal Meeting Settings',
                        style: TextStyle(color: Colors.teal),
                      ),
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
                          value: chatEnabled,
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
                          value: raiseEnabled,
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
                          value: shareYtEnabled,
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
                          value: recordEnabled,
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
                      subtitle:
                          Text('Allow participants to live stream meeting'),
                      dense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: liveEnabled,
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
                          'Allow participants to kick out each other in meeting'),
                      dense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: kickOutEnabled,
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
                    // SizedBox(
                    //     height: 50.0,
                    //     width: double.maxFinite,
                    //     child:
                    // RaisedButton(
                    //     color: Colors.blue,
                    //     disabledColor: themeNotifier.getTheme() == darkTheme? Color(0xFF242424) : Colors.grey,
                    //     elevation: 5,
                    //     disabledElevation: 0,
                    //     disabledTextColor: themeNotifier.getTheme() == darkTheme? Colors.grey : Colors.white,
                    //     textColor: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(18.0),
                    //     ),
                    //   onPressed: isEdited ? () {
                    //       onSaved();
                    //   } : null,
                    //   child: Text('Save Changes', style: TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: 18,
                    //   ),),
                    // ),
                    // ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  onSaved() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('personalMeet', personalName);
      prefs.setBool('PchatEnabled', chatEnabled);
      prefs.setBool('PliveEnabled', liveEnabled);
      prefs.setBool('PrecordEnabled', recordEnabled);
      prefs.setBool('PraiseEnabled', raiseEnabled);
      prefs.setBool('PshareYtEnabled', shareYtEnabled);
      prefs.setBool('PKickOutEnabled', kickOutEnabled);
    });
    Navigator.pop(context);
  }

  onChatChanged(bool value) {
    setState(() {
      chatEnabled = value;
    });
    onEdit();
  }

  onYtChanged(bool value) {
    setState(() {
      shareYtEnabled = value;
    });
    onEdit();
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
        });
        onEdit();
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        liveEnabled = value;
      });
      onEdit();
    }
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
        });
        onEdit();
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        kickOutEnabled = value;
      });
      onEdit();
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
        setState(() {
          recordEnabled = value;
        });
        onEdit();
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        recordEnabled = value;
      });
      onEdit();
    }
  }

  onRaiseChanged(bool value) {
    setState(() {
      raiseEnabled = value;
    });
    onEdit();
  }
}
