import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:jagu_meet/firebase/databases/appCloudDb.dart';
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
  FocusNode myFocusNode = FocusNode();
  final reportText = TextEditingController();
  AppCloudService appService  = new AppCloudService();

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
          msg: 'No internet connection',
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
  final InAppReview inAppReview = InAppReview.instance;
  review() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

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
    review();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Feedback',
            style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white : Colors.black54,
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
                  'app version: $version.  '),
          label: Text('Contact Us',
              style: TextStyle(
                  color:  Colors.white,
                  fontWeight: FontWeight.bold)),
          icon: Icon(Icons.mail_outline,
              color: Colors.white),
          backgroundColor: Color(0xff0184dc)
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
              Divider(
                height: 1,
                color: themeNotifier.getTheme() == darkTheme
                    ? Color(0xFF303030)
                    : Colors.black12,
              ),
              TextField(
                      focusNode: myFocusNode,
                      autofocus: false,
                      maxLength: 11,
                      controller: reportText,
                      onChanged: (val) {
                        isEmpty();
                      },
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          counterText: '',
                          isDense: true,
                          filled: true,
                          contentPadding: const EdgeInsets.only(
                              top: 12.0, bottom: 12, left: 10),
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          fillColor: themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF191919)
                              : Color(0xFFf9f9f9),
                          hintText: 'Please write your feedback here'),
                    ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  SizedBox(
                    height: 50.0,
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
                              appService.addFeedback(widget.userid, widget.email, reportText.text);
                        Fluttertoast.showToast(
                            msg: 'Thank you for your feedback',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.SNACKBAR,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0);
                              reportText.clear();
                              isEmpty();
                            }
                          : null,
                      child: Text(
                        "Submit Feedback",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      color: Color(0xff0184dc)
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
