import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/cupertinoSwitchListTile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class joinSettings extends StatefulWidget {
  @override
  _joinSettingsState createState() => _joinSettingsState();
}

class _joinSettingsState extends State<joinSettings> {
  var useAvatar = true;
  var lowMode = true;

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        useAvatar = prefs.getBool('useAvatar') ?? true;
        lowMode = prefs.getBool('lowMode') ?? true;
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
    return MaterialApp(
      theme: themeNotifier.getTheme(),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
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
                    CupertinoSwitchListTile(
                      title: Text(
                        "Use Profile Picture",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle:
                      Text('Use profile picture as avatar in meeting'),
                      dense: true,
                      value: useAvatar,
                      onChanged: onAvatarChanged,
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
                        "Low Bandwidth Mode",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                          'Automatically enabled Low Bandwidth mode when needed', overflow: TextOverflow.ellipsis,),
                      dense: true,
                      value: lowMode,
                      onChanged: onLowChanged,
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

  onLowChanged(bool value) {
    setState(() {
      lowMode = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('lowMode', value);
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
