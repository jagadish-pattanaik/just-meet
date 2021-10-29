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
  var lowMode = true;

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
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
          elevation:  0,
          bottom: PreferredSize(
              child: Divider(
                  height: 1,
                  color: themeNotifier.getTheme() == darkTheme
                      ?  Color(0xFF303030) : Colors.black12
              ),
              preferredSize: Size(double.infinity, 0.0)),
          title: Text(
            'Joining Settings',
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

}
