import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:jagu_meet/firebase/ads/admobAds.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/cupertinoSwitchListTile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class generalSettings extends StatefulWidget {
  @override
  _generalSettingsState createState() => _generalSettingsState();
}

class _generalSettingsState extends State<generalSettings> {
  var _darkTheme;
  var diagnostic = true;

  AdHelper adHelper = new AdHelper();

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        diagnostic = prefs.getBool('diagnostic') ?? true;
      });
    });
  }

  void onThemeChangedStart(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
    var darkModeOn = prefs.getBool('darkMode');
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      //statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: darkModeOn
          ? Color(0xff0d0d0d)
          : Color(0xFFFFFFFF),
      systemNavigationBarIconBrightness: darkModeOn ? Brightness.light : Brightness.dark,

    ));
    // setBgColor(themeNotifier);
  }

  @override
  void initState() {
    super.initState();
    getSettings();
    adHelper.rewardedAdLoad();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
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
            'General Settings',
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
                        "Dark Mode",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(themeNotifier.getTheme() == darkTheme
                          ? 'On': 'Off', overflow: TextOverflow.ellipsis,),
                      dense: true,
                        value: _darkTheme,
                        onChanged: (val) {
                          setState(() {
                            _darkTheme = val;
                          });
                          onThemeChangedStart(val, themeNotifier);
                        }
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
                        "Send diagnostic info",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle:
                          Text('We can use this to make this product better'),
                      dense: true,
                        value: diagnostic,
                        onChanged: (val) {
                          setState(() {
                            diagnostic = val;
                          });
                        }
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
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                        title: Text(
                          "Ads",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        subtitle:
                        Text('Ads help us keep this service up and running'),
                        dense: true,
                      trailing: TextButton(
                        onPressed: () {
                          adHelper.showNoRewarded();
                        },
                        child: Text('Watch Ads'),
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
}
