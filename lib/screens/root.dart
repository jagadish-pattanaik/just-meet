import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'package:jagu_meet/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class root extends StatefulWidget {
  @override
  _rootState createState() => _rootState();
}

enum AuthStatus {
  notSignedIn,
  SignedIn,
}

class _rootState extends State<root> {
  AuthStatus authStatus;
  var signStatus;

  @override
  initState() {
    super.initState();
    _getUserAuth();
  }

  _getUserAuth() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.getBool('signStatus') ?? false;
      setState(() {
        signStatus = prefs.getBool('signStatus') ?? false;
        authStatus =
            signStatus == true ? AuthStatus.SignedIn : AuthStatus.notSignedIn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.SignedIn:
        return MyApp();
      case AuthStatus.notSignedIn:
        return LoginScreen();
    }
    return Container(
      height: 0,
      width: 0,
    );
  }
}
