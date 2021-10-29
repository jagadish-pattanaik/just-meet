import 'package:flutter/material.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';

class Information extends StatefulWidget {
  var text;
  var title;
  Information({Key key, @required this.title,@required this.text}) : super(key: key);

  @override
  _InformationState createState() => _InformationState();
}

class _InformationState extends State<Information> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Theme(
      data: themeNotifier.getTheme(),
      child: Scaffold(
      appBar: AppBar(
      title: Text(
      widget.title,
        style: TextStyle(color: themeNotifier.getTheme() == darkTheme
            ? Colors.white : Colors.black54,),
      ),
      centerTitle: true,
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
    ),
        body: SafeArea(
          child: Container(
            height: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
    children: <Widget>[
      SizedBox(height: 20,),
      Padding(padding: EdgeInsets.symmetric(horizontal: 10),
    child: Text(widget.text,
      style: TextStyle(
      fontSize: 15,
      color: themeNotifier.getTheme() == darkTheme
          ? Colors.white
          : Colors.black,
    )),)
               ]),
          ),
        ),
      ),
       ),
    );
  }
}
