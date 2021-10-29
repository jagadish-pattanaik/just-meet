import 'package:flutter/material.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';

class ParticipantDetails extends StatefulWidget {
  final name;
  final email;
  final joined;
  final left;
  const ParticipantDetails({
    this.name,
    this.email,
    this.joined,
    this.left,
    Key key}) : super(key: key);

  @override
  _ParticipantDetailsState createState() => _ParticipantDetailsState();
}

class _ParticipantDetailsState extends State<ParticipantDetails> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Theme(
      data: themeNotifier.getTheme(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
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
            'Participant Details',
            style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white : Colors.black54,
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
            height: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
              ListTile(
              tileColor: themeNotifier.getTheme() == darkTheme
                  ? Color(0xFF191919)
                  : Color(0xFFf9f9f9),
              title: Text('Name'),
              trailing: Text(widget.name),
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
              title: Text('Email'),
              trailing: Text(widget.email),
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
              title: Text('Joined at'),
              trailing: Text(widget.joined),
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
              title: Text('Left at'),
              trailing: Text(widget.left),
            ),
            Divider(
              height: 1,
              color: themeNotifier.getTheme() == darkTheme
                  ? Color(0xFF303030)
                  : Colors.black12,
            ),
            SizedBox(
              height: 20,
            ),
    ]),
    ),
    ),
    ),
    ),
    );
  }
}
