import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class hostingSettings extends StatefulWidget {
  @override
  _hostingSettingsState createState() => _hostingSettingsState();
}

class _hostingSettingsState extends State<hostingSettings> {
  var _darkTheme;
  var chatEnabled = true;
  var liveEnabled = false;
  var recordEnabled = false;
  var raiseEnabled = true;
  var kickEnabled = false;
  var shareYtEnabled = true;
  var showName = true;

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        chatEnabled = prefs.getBool('chatEnabled') ?? true;
        liveEnabled = prefs.getBool('liveEnabled') ?? false;
        recordEnabled = prefs.getBool('recordEnabled') ?? false;
        raiseEnabled = prefs.getBool('raiseEnabled') ?? true;
        kickEnabled = prefs.getBool('kickEnabled') ?? false;
        shareYtEnabled = prefs.getBool('shareYtEnabled') ?? true;
        showName = prefs.getBool('showName') ?? true;
      });
    });
    Future.delayed(Duration(milliseconds: 500), () {});
  }

  @override
  void initState() {
    super.initState();
    getSettings();
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
          title: Text(
            'Hosting Settings',
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
                    ),ListTile(
                      tileColor: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF191919)
                          : Color(0xFFf9f9f9),
                      title: Text(
                        "Show Name when Participants Join",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                          'Show name of participants when they join your meeting'),
                      dense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: showName,
                          onChanged: onShowChanged,
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
                      subtitle:
                      Text('Allow participants to kick out each other'),
                      dense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: kickEnabled,
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

                  ]),
            ),
          ),
        ),
      ),
    );
  }


  onChatChanged(bool value) {
    setState(() {
      chatEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('chatEnabled', value);
    });
  }

  onYtChanged(bool value) {
    setState(() {
      shareYtEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('shareYtEnabled', value);
    });
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
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('liveEnabled', value);
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        liveEnabled = value;
      });
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('liveEnabled', value);
      });
    }
  }

  onKickChanged(bool value) async {
    if (kickEnabled == false) {
      final action = await Dialogs.yesAbortDialog(
          context,
          'Not Recommended',
          'Allowing participants to kick out each other is not recommended by Just Meet. Do you still want to allow?',
          'Allow',
          'No');
      if (action == DialogAction.yes) {
        setState(() {
          kickEnabled = value;
        });
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('kickEnabled', value);
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        kickEnabled = value;
      });
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('kickEnabled', value);
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
        setState(() {
          recordEnabled = value;
        });
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('recordEnabled', value);
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        recordEnabled = value;
      });
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('recordEnabled', value);
      });
    }
  }

  onRaiseChanged(bool value) {
    setState(() {
      raiseEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('raiseEnabled', value);
    });
  }

  onShowChanged(bool value) {
    setState(() {
      showName = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('showName', value);
    });
  }

}
