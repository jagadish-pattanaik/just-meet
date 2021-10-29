import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/cupertinoSwitchListTile.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class hostingSettings extends StatefulWidget {
  @override
  _hostingSettingsState createState() => _hostingSettingsState();
}

class _hostingSettingsState extends State<hostingSettings> {
  var kickEnabled = false;
  var shareYtEnabled = true;
  var showName = true;

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
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
            'Hosting Settings',
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


  onYtChanged(bool value) {
    setState(() {
      shareYtEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('shareYtEnabled', value);
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

  onShowChanged(bool value) {
    setState(() {
      showName = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('showName', value);
    });
  }

}
