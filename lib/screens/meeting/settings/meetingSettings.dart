import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:jagu_meet/screens/meeting/settings/globalLiveSettings.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'hostingSettings.dart';
import 'joiningSettings.dart';

class meetingSettings extends StatefulWidget {
  @override
  _meetingSettingsState createState() => _meetingSettingsState();
}

class _meetingSettingsState extends State<meetingSettings> {
  @override
  void initState() {
    super.initState();
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
          bottom:  PreferredSize(
              child: Divider(
                  height: 1,
                  color: themeNotifier.getTheme() == darkTheme
                      ?  Color(0xFF303030) : Colors.black12
              ),
              preferredSize: Size(double.infinity, 0.0)),
          title: Text(
            'Meeting Settings',
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
                    ListTile(
                      tileColor: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF191919)
                          : Color(0xFFf9f9f9),
                      title: Text(
                        "Joining Settings",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('Settings and preferences for all meetings you join', overflow: TextOverflow.ellipsis,),
                      dense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.grey,
                          )
                        ],
                      ),
                      onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => joinSettings())),
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
                        "Hosting Settings",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('Settings and customization for all meetings you host', overflow: TextOverflow.ellipsis,),
                      dense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Colors.grey,
                        )
                      ],
                    ),
                      onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => hostingSettings())),
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
                        "Conference Settings",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text('Settings and customization for conferences you host', overflow: TextOverflow.ellipsis,),
                      dense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.grey,
                          )
                        ],
                      ),
                      onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => GlobalSettings())),
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
