import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class advancedSettings extends StatefulWidget {
  @override
  _advancedSettingsState createState() => _advancedSettingsState();
}

class _advancedSettingsState extends State<advancedSettings> {
  var _darkTheme;

  var copyEnabled = true;
  var skinTone = true;
  var nonVideoUsers = true;
  var enhanceSound = true;
  var mirrorVideo = true;
  var enhanceLight = true;
  var quality = '.';
  var timerEnabled = true;
  var meetNameEnabled = true;

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        copyEnabled = prefs.getBool('copyEnabled') ?? true;
        skinTone = prefs.getBool('skinTone') ?? true;
        nonVideoUsers = prefs.getBool('nonVideoUsers') ?? true;
        enhanceSound = prefs.getBool('enhanceSound') ?? true;
        mirrorVideo = prefs.getBool('mirrorVideo') ?? true;
        enhanceLight = prefs.getBool('enhanceLight') ?? true;
        timerEnabled = prefs.getBool('timerEnabled') ?? true;
        meetNameEnabled = prefs.getBool('meetNameEnabled') ?? true;
        quality = prefs.getString('quality') ?? 'Auto';
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
            'Advanced Settings',
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
                    ListTile(
                      tileColor: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF191919)
                          : Color(0xFFf9f9f9),
                      title: Text(
                        "Show meeting topic",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle:
                          Text('Show meeting topic at the top in meeting'),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: meetNameEnabled,
                          onChanged: onMeetNameChanged,
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
                        "Show meeting time",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle: Text('Show meeting time at the top in meeting'),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: timerEnabled,
                          onChanged: ontimerChanged,
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
                        "Auto-Copy Invite Link",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle: Text(
                          'Automatically copy invite link once meeting starts'),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: copyEnabled,
                          onChanged: onCopyChanged,
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
                        "Enhance My Voice",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle: Text('Enhance my original voice in meeting'),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: enhanceSound,
                          onChanged: onSoundChanged,
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
                        "Enhance My Skin Tone",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle:
                          Text('Enhance my original skin tone in meeting'),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: skinTone,
                          onChanged: onSkinChanges,
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
                        "Enhance Lighting",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle:
                          Text('Enhance my background lighting in meeting'),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: enhanceLight,
                          onChanged: onEnhanceLight,
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
                        "Mirror My Video",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle: Text('Mirror my video when using front camera'),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: mirrorVideo,
                          onChanged: onMirrorVideoChanged,
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
                        "Show Non-Video Participants",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle: Text(
                          'Show avatar of non-video participants in Tile-View'),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          value: nonVideoUsers,
                          onChanged: onNonVideoChanged,
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
                        "Video Quality",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle: Text('Video quality in meeting'),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String value) {
                          setState(() {
                            quality = value;
                          });
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setString('quality', value);
                          });
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: '1080p',
                            child: Text('1080p'),
                          ),
                          const PopupMenuItem<String>(
                            value: '720p',
                            child: Text('720p'),
                          ),
                          const PopupMenuItem<String>(
                            value: '480p',
                            child: Text('480p'),
                          ),
                          const PopupMenuItem<String>(
                            value: '360p',
                            child: Text('360p'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Auto',
                            child: Text('Auto'),
                          ),
                        ],
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(quality),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                          )
                        ]),
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

  ontimerChanged(bool value) {
    setState(() {
      timerEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('timerEnabled', value);
    });
  }

  onMeetNameChanged(bool value) {
    setState(() {
      meetNameEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('meetNameEnabled', value);
    });
  }

  onCopyChanged(bool value) {
    setState(() {
      copyEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('copyEnabled', value);
    });
  }

  onSoundChanged(bool value) {
    setState(() {
      enhanceSound = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('enhanceSound', value);
    });
  }

  onMirrorVideoChanged(bool value) {
    setState(() {
      mirrorVideo = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('mirrorVideo', value);
    });
  }

  onSkinChanges(bool value) {
    setState(() {
      skinTone = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('skinTone', value);
    });
  }

  onEnhanceLight(bool value) {
    setState(() {
      enhanceLight = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('enhanceLight', value);
    });
  }

  onNonVideoChanged(bool value) {
    setState(() {
      nonVideoUsers = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('nonVideoUsers', value);
    });
  }
}
