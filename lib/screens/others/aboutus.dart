import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:jagu_meet/screens/others/webview.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/sign_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({Key key}) : super(key: key);

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  String version = '.';
  AppUpdateInfo _updateInfo;

  Future<void> checkVersion() async {
    _updateInfo?.updateAvailability ==
        UpdateAvailability.updateAvailable
        ?
      InAppUpdate.performImmediateUpdate()
          .catchError((e) => print(e))
        : Fluttertoast.showToast(
        msg: 'Just Meet is up to date',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }
  final InAppReview inAppReview = InAppReview.instance;
  review() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
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
  void initState() {
    if (!kIsWeb) {
      getAppInfo();
      review();
    }
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
          bottom: PreferredSize(
              child: Divider(
                  height: 1,
                  color: themeNotifier.getTheme() == darkTheme
                      ?  Color(0xFF303030) : Colors.black12
              ),
              preferredSize: Size(double.infinity, 0.0)),
          title: Text(
            'About',
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
                    !kIsWeb == true ? ListTile(
                      tileColor: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF191919)
                          : Color(0xFFf9f9f9),
                      onTap: () => checkVersion(),
                      title: Text(
                        'Version',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            version,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ) : Container(),
                    !kIsWeb == true ? Divider(
                      height: 1,
                      color: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF303030)
                          : Colors.black12,
                      indent: 15,
                      endIndent: 0,
                    ) : Container(),
                    ListTile(
                      tileColor: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF191919)
                          : Color(0xFFf9f9f9),
                      onTap: () => launchWebView(
                          'https://justmeetpolicies.blogspot.com/p/just-meet-privacy-policy.html',
                          'Privacy Policy'),
                      title: Text(
                        'Privacy Policy',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
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
                      onTap: () => launchWebView(
                          'https://justmeetpolicies.blogspot.com/p/just-meet-terms-conditions.html',
                          'Terms & Conditions'),
                      title: Text(
                        'Terms & Conditions',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
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
                      onTap: () async {
                        var url = 'https://justmeetpolicies.blogspot.com/';
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
                      },
                      title: Text(
                        'Blog',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
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
                      onTap: () => launchWebView(
                          'https://knowaboutjagadish.blogspot.com/p/jagadish-prasad-pattanaik.html',
                          'Developer'),
                      title: Text(
                        'Developer',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
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
                      onTap: () async {
                        var url = 'https://github.com/jagadish-pattanaik/just-meet-public';
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
                      },
                      title: Text(
                        'Open Source Software',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
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
                    ),
                    Divider(
                      height: 1,
                      color: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF303030)
                          : Colors.black12,
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SignInButton.mini(
                          buttonType: ButtonType.github,
                          onPressed: () async {
                            var url = 'https://github.com/jagadish-pattanaik/';
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
                          },
                        ),
                        SignInButton.mini(
                          buttonType: ButtonType.facebook,
                          btnColor: Colors.transparent,
                          onPressed: () async {
                            var url = 'https://www.facebook.com/justtechteam';
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
                          },
                        ),
                        SignInButton.mini(
                          buttonType: ButtonType.linkedin,
                          btnColor: Colors.transparent,
                          onPressed: () async {
                            var url = 'https://www.linkedin.com/in/jagadish-pattanaik/';
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
                          },
                        ),
                        SignInButton.mini(
                          buttonType: ButtonType.youtube,
                          btnColor: Colors.transparent,
                          onPressed: () async {
                            var url = 'https://www.youtube.com/channel/UCgdd03ctC4odnUCNlPBSdUg';
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
                          },
                        ),
                      ],
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
