import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jagu_meet/screens/meetweb/landingPage.dart';
import 'package:jagu_meet/screens/onboarding/ppolicy.dart';
import '../user/loginPage.dart';
import 'package:jagu_meet/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class root extends StatefulWidget {
  @override
  _rootState createState() => _rootState();
}

class _rootState extends State<root> {
  var signStatus;
  var onBoardingStatus;

  @override
  initState() {
    super.initState();
    _getUserAuth();
    _getUserIntro();
  }

  _getUserIntro() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.getBool('intoStatus') ?? false;
      setState(() {
        onBoardingStatus = prefs.getBool('introStatus') ?? false;
        //introStatus = onBoardingStatus == true ? IntroStatus.introduced : IntroStatus.fresher;
      });
    });
  }

  _getUserAuth() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.getBool('signStatus') ?? false;
      setState(() {
        signStatus = prefs.getBool('signStatus') ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      if (onBoardingStatus == true) {
        if (signStatus == true) {
          return MyApp();
        } else {
          return LoginScreen();
        }
      } else {
        return PriPolicy();
      }
    } else {
      //if (Platform.isAndroid) {
     //   return OpenApp();
     // } else {
        return LandingPage();
     // }
    }
  }
}