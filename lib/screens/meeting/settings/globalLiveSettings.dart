import 'package:flutter/material.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/cupertinoSwitchListTile.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalSettings extends StatefulWidget {
  @override
  _GlobalSettingsState createState() => _GlobalSettingsState();
}

class _GlobalSettingsState extends State<GlobalSettings> {
  var kickEnabled = false;
  var shareYtEnabled = true;
  var showName = true;
  var chatEnabled = true;
  var liveEnabled = false;
  var recordEnabled = false;
  var raiseEnabled =  true;

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        chatEnabled = prefs.getBool('GchatEnabled') ?? true;
        liveEnabled = prefs.getBool('GliveEnabled') ?? false;
        recordEnabled = prefs.getBool('GrecordEnabled') ?? false;
        raiseEnabled = prefs.getBool('GraiseEnabled') ?? true;
        kickEnabled = prefs.getBool('GkickEnabled') ?? false;
        shareYtEnabled = prefs.getBool('GshareYtEnabled') ?? true;
        showName = prefs.getBool('GshowName') ?? true;
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
    return Theme(
      data: themeNotifier.getTheme(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
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
            'Conference Settings',
            style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white : Colors.black54,
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
                    CupertinoSwitchListTile(
                      title: Text(
                        "Chat",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('Allow participants to chat in meeting', overflow: TextOverflow.ellipsis,),
                      dense: true,
                      value: chatEnabled,
                      onChanged: _onChatChanged,
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
                      subtitle: Text('Allow participants to raise hand and notify you in meeting', overflow: TextOverflow.ellipsis,),
                      value: raiseEnabled,
                      onChanged: _onRaiseChanged,
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
                      subtitle: Text('Allow participants to record the meeting', overflow: TextOverflow.ellipsis,),
                      dense: true,
                      value: recordEnabled,
                      onChanged: _onRecordChanged,
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
                      dense: true,
                      subtitle: Text('Allow participants to live stream the meeting', overflow: TextOverflow.ellipsis,),
                      value: liveEnabled,
                      onChanged: _onLiveChanged,
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
                      value: shareYtEnabled,
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
                        "Show Name when Participants Join",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Show name of participants when they join your meeting', overflow: TextOverflow.ellipsis,),
                      dense: true,
                      value: showName,
                      onChanged: onShowChanged,
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
                      subtitle:
                      Text('Allow participants to kick out each other'),
                      dense: true,
                      value: kickEnabled,
                      onChanged: onKickChanged,
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

  _onChatChanged(bool value) {
    setState(() {
      chatEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('GchatEnabled', value);
    });
  }

  _onLiveChanged(bool value) async {
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
          prefs.setBool('GliveEnabled', value);
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        liveEnabled = value;
      });
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('GliveEnabled', value);
      });
    }
  }

  _onRecordChanged(bool value) async {
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
          prefs.setBool('GrecordEnabled', value);
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        recordEnabled = value;
      });
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('GrecordEnabled', value);
      });
    }
  }

  _onRaiseChanged(bool value) {
    setState(() {
      raiseEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('GraiseEnabled', value);
    });
  }

  onYtChanged(bool value) {
    setState(() {
      shareYtEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('GshareYtEnabled', value);
    });
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
          prefs.setBool('GkickEnabled', value);
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        kickEnabled = value;
      });
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('GkickEnabled', value);
      });
    }
  }

  onShowChanged(bool value) {
    setState(() {
      showName = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('GshowName', value);
    });
  }
}
