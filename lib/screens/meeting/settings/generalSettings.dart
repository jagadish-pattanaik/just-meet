import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/cupertinoSwitchListTile.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class generalSettings extends StatefulWidget {
  @override
  _generalSettingsState createState() => _generalSettingsState();
}

class _generalSettingsState extends State<generalSettings> {
  var _darkTheme;
  String version = '.';
  AppUpdateInfo _updateInfo;
  var diagnostic = true;
  static const PLAY_STORE_URL =
      'https://play.google.com/store/apps/details?id=com.jaguweb.jagu_meet';

  Future<void> checkVersion() async {
    _updateInfo?.updateAvailability == UpdateAvailability.updateAvailable
        ? InAppUpdate.performImmediateUpdate()
        : ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('Just Meet is up to date!',)));
  }

  getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

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
      //systemNavigationBarIconBrightness: Brightness.dark,
    ));
    // setBgColor(themeNotifier);
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      getAppInfo();
    }
    getSettings();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return MaterialApp(
      title: 'Just Meet',
      theme: themeNotifier.getTheme(),
      home: Scaffold(
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
    !kIsWeb == true ? ListTile(
                      tileColor: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF191919)
                          : Color(0xFFf9f9f9),
                      onTap: () => checkVersion(),
                      title: Text(
                        'Version',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('Your current app version', overflow: TextOverflow.ellipsis,),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            version,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ) : Container(),
                    !kIsWeb == true ? Divider(
                      height: 1,
                      color: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF303030)
                          : Colors.black12,
                      indent: 15,
                      endIndent: 0,
                    ) : Container(),
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
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
