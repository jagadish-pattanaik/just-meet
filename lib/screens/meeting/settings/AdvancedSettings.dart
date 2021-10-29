import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/cupertinoSwitchListTile.dart';
import 'package:jagu_meet/widgets/modaltile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class advancedSettings extends StatefulWidget {
  @override
  _advancedSettingsState createState() => _advancedSettingsState();
}

class _advancedSettingsState extends State<advancedSettings> {
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
            'Advanced Settings',
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
                    CupertinoSwitchListTile(
                      title: Text(
                        "Show meeting topic",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle:
                          Text('Show meeting topic at the top in meeting'),
                      value: meetNameEnabled,
                      onChanged: onMeetNameChanged,
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
                        "Show meeting time",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle: Text('Show meeting time at the top in meeting', overflow: TextOverflow.ellipsis,),
                      value: timerEnabled,
                      onChanged: ontimerChanged,
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
                        "Auto-Copy Invite Link",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle: Text(
                          'Automatically copy invite link once meeting starts', overflow: TextOverflow.ellipsis,),
                      value: copyEnabled,
                      onChanged: onCopyChanged,
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
                        "Enhance My Voice",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle: Text('Enhance my original voice in meeting', overflow: TextOverflow.ellipsis,),
                      value: enhanceSound,
                      onChanged: onSoundChanged,
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
                        "Enhance My Skin Tone",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle:
                          Text('Enhance my original skin tone in meeting'),
                      value: skinTone,
                      onChanged: onSkinChanges,
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
                        "Enhance Lighting",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle:
                          Text('Enhance my background lighting in meeting'),
                      value: enhanceLight,
                      onChanged: onEnhanceLight,
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
                        "Mirror My Video",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle: Text('Mirror my video when using front camera', overflow: TextOverflow.ellipsis,),
                      value: mirrorVideo,
                      onChanged: onMirrorVideoChanged,
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
                        "Show Non-Video Participants",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      subtitle: Text(
                          'Show avatar of non-video participants in Tile-View', overflow: TextOverflow.ellipsis,),
                      value: nonVideoUsers,
                      onChanged: onNonVideoChanged,
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
                        onTap: () => showActionSheet(context),
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
                      subtitle: Text(quality == 'Auto' ? 'Auto' : quality == '1080p' ? 'High' : 'Low', overflow: TextOverflow.ellipsis,),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing:
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_down,
                            size: 20,
                            color: Colors.grey,
                            ),
                            onPressed: () => showActionSheet(context),
                          )
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

  showActionSheet(context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    showModalBottomSheet(
        context: context,
        elevation: 10,
        isScrollControlled: true,
        backgroundColor: themeNotifier.getTheme() == darkTheme
            ? Color(0xFF191919)
            : Color(0xFFf9f9f9),
        builder: (context) {
          return Container(
            child: SingleChildScrollView(
              child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          FlatButton(
                            child: Icon(
                              Icons.close,
                              color: themeNotifier.getTheme() == darkTheme
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Meeting video quality",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Color(0xff272c35),
                    ),
                    ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        ModalTile(
                          title: "Higher video quality",
                          subtitle: "Use more data",
                          onTap: () {
                            setState(() {
                              quality = '1080p';
                            });
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString('quality', quality);
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ModalTile(
                          title: "Data Saver",
                          subtitle: "Lower video quality",
                          onTap: () {
                            setState(() {
                              quality = '720p';
                            });
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString('quality', quality);
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ModalTile(
                          title: "Auto (recommended)",
                          subtitle: "Adjusts to give you best experience for your conditions",
                          onTap: () {
                            setState(() {
                              quality = 'Auto';
                            });
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString('quality', quality);
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ]),
            ),
          );
        });
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
