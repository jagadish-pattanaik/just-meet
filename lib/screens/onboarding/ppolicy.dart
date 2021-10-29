import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/screens/user/loginPage.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jagu_meet/screens/others/webview.dart';
import '../../main.dart';

class PriPolicy extends StatefulWidget {
  @override
  _PriPolicyState createState() => _PriPolicyState();
}

class _PriPolicyState extends State<PriPolicy> {
  bool permisions = false;

  checkPermissions() async {
    var status = await Permission.camera.status;
    var stat = await Permission.microphone.status;
    //var locStatus = await Permission.location.status;
    if (status.isGranted && stat.isGranted) {
      setState(() {
        permisions = true;
      });
    } else {
      setState(() {
        permisions = false;
      });
    }
  }

  var signStatus;
  _getUserAuth() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.getBool('signStatus') ?? false;
      setState(() {
        signStatus = prefs.getBool('signStatus') ?? false;
      });
    });
  }

  setPref() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('introStatus', true);
      prefs.setBool('intoStatus', true);
    });
  }

  @override
  void initState() {
    super.initState();
    checkPermissions();
    _getUserAuth();
  }

  launchWebView(var URL, var TITLE) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => AppWebView(
                  url: URL,
                  title: TITLE,
                )));
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    TextStyle linkStyle = TextStyle(color: Colors.blue, fontSize: 16,);
    return Theme(
      data: themeNotifier.getTheme(),
      child: Scaffold(
        appBar: AppBar(
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
          centerTitle: true,
          title: Text(
            'Welcome to Just Meet',
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
              child: Column(children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                          text:
                              'Thank you for using choosing Just Meet. We have wrote this',
                          style: TextStyle(
                            fontSize: 15,
                            color: themeNotifier.getTheme() == darkTheme
                                ? Colors.white
                                : Colors.black,
                          )),
                      TextSpan(
                          text: ' Policy ',
                          style: linkStyle,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchWebView(
                                  'https://justmeetpolicies.blogspot.com/p/just-meet-privacy-policy.html',
                                  'Privacy Policy');
                            }),
                      TextSpan(
                          text: 'and',
                          style: TextStyle(
                            fontSize: 15,
                            color: themeNotifier.getTheme() == darkTheme
                                ? Colors.white
                                : Colors.black,
                          )),
                      TextSpan(
                          text: ' Terms of Service ',
                          style: linkStyle,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchWebView(
                                  'https://justmeetpolicies.blogspot.com/p/just-meet-terms-conditions.html',
                                  'Terms & Conditions');
                            }),
                      TextSpan(
                          text:
                              'to help you understand about what information we collect, '
                              'how we use it and what choices you have. Your data is collected only for your safety and security purpose. '
                              'To protect you and our community from cyber crime. Your data is encrypted and kept securely in Just Meet database. '
                              'We collect only your meeting details, your meetings and chats are still private. We respect your privacy more than '
                              'anything and we do not sell your data to anyone neither Just Meet can see them. Also you will have to grant some permissions'
                              'to continue using Just Meet smoothly.',
                          style: TextStyle(
                            fontSize: 15,
                            color: themeNotifier.getTheme() == darkTheme
                                ? Colors.white
                                : Colors.black,
                          )),
                    ]),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: RichText(
                          text: TextSpan(children: <TextSpan>[
                            TextSpan(
                                text: 'By tapping agree you accept all the',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: themeNotifier.getTheme() == darkTheme
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            TextSpan(
                                text: ' Terms & Conditions ',
                                style: linkStyle,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchWebView(
                                        'https://justmeetpolicies.blogspot.com/p/just-meet-terms-conditions.html',
                                        'Terms & Conditions');
                                  }),
                            TextSpan(
                                text: 'and that you have read our',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: themeNotifier.getTheme() == darkTheme
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            TextSpan(
                                text: ' Privacy Policy.',
                                style: linkStyle,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchWebView(
                                        'https://justmeetpolicies.blogspot.com/p/just-meet-privacy-policy.html',
                                        'Privacy Policy');
                                  }),
                            TextSpan(
                                text:
                                    '. You will have to accept these to use Just Meet. You can also visit',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: themeNotifier.getTheme() == darkTheme
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            TextSpan(
                                text: ' Help Center ',
                                style: linkStyle,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchWebView(
                                        'https://justmeetpolicies.blogspot.com/p/just-meet-faqs.html',
                                        'FAQ');
                                  }),
                            TextSpan(
                                text:
                                    'and collect more information about our privacy policy and terms & conditions. '
                                    'You can also ask your questions there.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: themeNotifier.getTheme() == darkTheme
                                      ? Colors.white
                                      : Colors.black,
                                )),
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(
                        height: 1,
                        color: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF303030)
                            : Colors.black12,
                      ),
                    ]),
                SizedBox(
                  height: 10,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  RaisedButton(
                      onPressed: () async {
                        var status = await Permission.camera.status;
                        var stat = await Permission.microphone.status;
                       // var locStatus = await Permission.location.status;
                        if (status.isGranted && stat.isGranted) {
                          if (signStatus == true) {
                            setPref();
                            Future.delayed(Duration(milliseconds: 1000), () {});
                            Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                  builder: (BuildContext context) => MyApp(),
                                ));
                          } else {
                            setPref();
                            Future.delayed(Duration(milliseconds: 1000), () {});
                            Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginScreen(),
                                ));
                          }
                        } else {
                          if (status.isDenied) {
                            Map<Permission, PermissionStatus> statuses = await [
                              Permission.camera,
                              Permission.microphone,
                              //Permission.location,
                            ].request();
                            checkPermissions();
                          } else if (status.isPermanentlyDenied) {
                            openAppSettings();
                            checkPermissions();
                          } else if (status.isRestricted) {
                            openAppSettings();
                            checkPermissions();
                          } else {
                            if (stat.isDenied) {
                              Map<Permission, PermissionStatus> statuses =
                                  await [
                                Permission.camera,
                                Permission.microphone,
                                //    Permission.location,
                              ].request();
                              checkPermissions();
                            } else if (stat.isPermanentlyDenied) {
                              openAppSettings();
                              checkPermissions();
                            } else if (stat.isRestricted) {
                              openAppSettings();
                              checkPermissions();
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'Permission not granted',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.SNACKBAR,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          }
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      elevation: 10,
                      color: Colors.green,
                      child: Text(
                        permisions ? 'Agree' : 'Allow Just Meet',
                        style: TextStyle(
                            color: Colors.white, fontSize: 16,),
                      )),
                  SizedBox(
                    width: 20,
                  )
                ]),
                //    ),
                // ),
                // ),
                //   ),
                // Padding(
                //    padding: EdgeInsets.only(bottom: 10),
                // )
              ]),
              // ]
            ),
          ),
        ),
      ),
      // ),
    );
  }
}
