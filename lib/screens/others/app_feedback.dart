import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:jagu_meet/sever_db/app_feedback/app_db_controller.dart';
//import 'package:jagu_meet/sever_db/app_feedback/app_feedback_db.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFeedback extends StatefulWidget {
  final userid;
  final email;
  final name;

  AppFeedback({Key key, @required this.userid, this.email, this.name})
      : super(key: key);

  @override
  _AppFeedbackState createState() => _AppFeedbackState();
}

class _AppFeedbackState extends State<AppFeedback> {
  var _darkTheme;
  FocusNode myFocusNode = FocusNode();
  final reportText = TextEditingController();

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
          msg: 'Failed...Please check your internet connection',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  bool isButtonEnabled = false;
  isEmpty() {
    if (reportText.text.length >= 5) {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  //void _submitFeedbackData(String email, String name, String feedback,) {
  //AppFeedbacksDb appfeedbacksDb  = AppFeedbacksDb(email, name, feedback);
//
  //FeedbackServerController feedServerController = FeedbackServerController(
  //(String response) {
  //print(response);
  //}
  //);
  //feedServerController.submitAppFeedback(appfeedbacksDb);
  //}

  var version;
  getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  var deviceData;
  getDevice() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      deviceData = androidInfo.model;
    });
  }

  @override
  void initState() {
    super.initState();
    getDevice();
    getAppInfo();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return MaterialApp(
      title: 'Just Meet',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.getTheme(),
      home: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xFF242424)
              : Colors.blue,
          elevation: 5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Feedback',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButton: showFab
            ?  FloatingActionButton.extended(
          heroTag: "Contact Us",
          elevation: 5,
          onPressed: () => _launchURL(
              'jaguweb1234@gmail.com',
              'Feedback Just Meet',
              'Please Write your feedback here it will help us a lot in improving.'
                  "\r\n"
                  "\n"
                  'User Details:'
                  '\n'
                  'Running on device: $deviceData'
                  '\n'
                  'app version: $version.  '
                  '\n'
                  'user id: ${widget.userid}'
                  '\n'
                  'email: ${widget.email}'),
          label: Text('Contact Us',
              style: TextStyle(
                  color: themeNotifier.getTheme() == darkTheme
                      ? Colors.blueAccent
                      : Colors.white,
                  fontWeight: FontWeight.bold)),
          icon: Icon(Icons.add,
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.blueAccent
                  : Colors.white),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xFF242424)
              : Colors.blue,
        ) : Container(),
        body: SafeArea(
          child: Container(
            height: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: TextField(
                      focusNode: myFocusNode,
                      autofocus: false,
                      maxLength: 11,
                      controller: reportText,
                      onChanged: (val) {
                        isEmpty();
                      },
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.blue, width: 1.0),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          counterText: '',
                          isDense: true,
                          filled: true,
                          contentPadding: const EdgeInsets.only(
                              top: 12.0, bottom: 12, left: 10),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "Feedback",
                          labelStyle: TextStyle(
                            color: Colors.blue,
                          ),
                          fillColor: themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF191919)
                              : Color(0xFFf9f9f9),
                          hintText: 'Please write your feedback here'),
                    ),
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  SizedBox(
                    height: 45.0,
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: RaisedButton(
                      disabledColor: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF242424)
                          : Colors.grey,
                      elevation: 5,
                      disabledElevation: 0,
                      disabledTextColor: themeNotifier.getTheme() == darkTheme
                          ? Colors.grey
                          : Colors.white,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      onPressed: isButtonEnabled
                          ? () async {
                              // _submitFeedbackData(widget.email, widget.name, reportText.text);
                              Fluttertoast.showToast(
                                  msg: 'Thank You for your feedback!',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.SNACKBAR,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              reportText.clear();
                            }
                          : null,
                      child: Text(
                        "Submit Feedback",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      color: themeNotifier.getTheme() == darkTheme
                          ? Colors.blueAccent
                          : Colors.blue,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
