import 'package:flutter/material.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';

class QuietBox extends StatelessWidget {
  final String heading;
  final String subtitle;
  final Function fun;

  QuietBox({
    @required this.heading,
    @required this.subtitle,
    @required this.fun,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: themeNotifier.getTheme() == darkTheme
                      ? Colors.white
                      : Colors.black54,
                ),
              ),
              SizedBox(height: 10),
              OutlineButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: Colors.transparent,
                borderSide: BorderSide(
                  color: Color(0xff0184dc),
                ),
                onPressed: () {
                  fun();
                },
                child: Text(heading,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff0184dc),
                  ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}