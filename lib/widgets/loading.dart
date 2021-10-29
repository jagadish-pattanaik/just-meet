import 'package:flutter/material.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Scaffold(
      backgroundColor: themeNotifier.getTheme() == darkTheme
          ? Color(0xff0d0d0d)
          : Color(0xffffffff),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}