import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class joinSettings extends StatefulWidget {
  @override
  _joinSettingsState createState() => _joinSettingsState();
}

class _joinSettingsState extends State<joinSettings> {
  var _darkTheme;

  var isAudioOnly = true;
  var isAudioMuted = true;
  var isVideoMuted = true;
  var useAvatar = true;
  var lowMode = true;

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        useAvatar = prefs.getBool('useAvatar') ?? true;
        lowMode = prefs.getBool('lowMode') ?? true;
        isAudioOnly = prefs.getBool('isAudioOnly') ?? true;
        isAudioMuted = prefs.getBool('isAudioMuted') ?? true;
        isVideoMuted = prefs.getBool('isVideoMuted') ?? true;
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
            'Joining Settings',
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
                        "Audio Only",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('Join with Audio Only'),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      dense: true,
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: isAudioOnly,
                          onChanged: onAudioOnlyChanged,
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
                        "Audio Muted",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('Join with audio muted'),
                      dense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: isAudioMuted,
                          onChanged: onAudioMutedChanged,
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
                        "Video Muted",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('Join with video muted'),
                      dense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: isVideoMuted,
                          onChanged: onVideoMutedChanged,
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
                        "Use Profile Picture",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle:
                      Text('Use profile picture as avatar in meeting'),
                      dense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: useAvatar,
                          onChanged: onAvatarChanged,
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
                        "Low Bandwidth Mode",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                          'Automatically enabled Low Bandwidth mode when needed'),
                      dense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: lowMode,
                          onChanged: onLowChanged,
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
                      height: 8,
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isAudioOnly', value);
    });
  }

  onLowChanged(bool value) {
    setState(() {
      lowMode = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('lowMode', value);
    });
  }

  onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isAudioMuted', value);
    });
  }

  onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isVideoMuted', value);
    });
  }

  onAvatarChanged(bool value) {
    setState(() {
      useAvatar = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('useAvatar', value);
    });
  }
}
