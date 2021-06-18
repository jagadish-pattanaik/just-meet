import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:jagu_meet/screens/others/webview.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

class Notify extends StatefulWidget {
  Notify({Key key}) : super(key: key);

  @override
  _NotifyState createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  bool visible = true;

  final InAppReview inAppReview = InAppReview.instance;

  var version;
  getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  reviewAvailabled() async {
    if (await inAppReview.isAvailable()) {
      setState(() {
        visible = true;
      });
    } else {
      setState(() {
        visible = false;
      });
    }
  }

  launchurl(String Url) async {
    var url = Url;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  launchWebView(var url, var title) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => AppWebView(
                  url: url,
                  title: title,
                )));
  }

  requestReview() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  @override
  void initState() {
    super.initState();
    reviewAvailabled();
    requestReview();
    getAppInfo();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return OverlaySupport(
      child: MaterialApp(
        title: 'Just Meet',
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.getTheme(),
        home: Scaffold(
          resizeToAvoidBottomInset: false,
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
                : Color(0xFFFFFFFF),
            elevation:  0,
            bottom: PreferredSize(
                child: Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ?  Color(0xFF303030) : Colors.black12
                ),
                preferredSize: Size(double.infinity, 0.0)),
            title: Text(
              'Notifications',
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
                        SizedBox(
                          height: 10,
                        ),
                        Card(
                          color: themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF242424)
                              : Colors.white,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: SafeArea(
                            child: ListTile(
                              onTap: () {
                                launchWebView(
                                    'https://justmeetpolicies.blogspot.com/p/just-meet-release-note-version-200.html',
                                    'Release Notes');
                              },
                              leading: SizedBox.fromSize(
                                  size: const Size(40, 40),
                                  child: ClipOval(
                                      child:
                                          Icon(Icons.notification_important))),
                              title: Text('New Update!'),
                              subtitle: Text(
                                  'New version $version! Make sure all participants have it.', overflow: TextOverflow.ellipsis,),
                              trailing: Icon(Icons.arrow_forward_ios),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Card(
                          color: themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF242424)
                              : Colors.white,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: SafeArea(
                            child: ListTile(
                              onTap: () {
                                launchurl(
                                    'https://join.slack.com/t/jaguweb/shared_invite/zt-jv4hn24h-ZrJQZ3PmjH8wbM1Qy59DEw');
                              },
                              leading: SizedBox.fromSize(
                                  size: const Size(40, 40),
                                  child: ClipOval(child: Icon(Icons.comment))),
                              title: Text('Join Our Slack Community'),
                              subtitle: Text(
                                  'There is a slack community which can help you with Just Meet!', overflow: TextOverflow.ellipsis,),
                              trailing: Icon(Icons.arrow_forward_ios),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        visible ?
                        Card(
                          color: themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF242424)
                              : Colors.white,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: SafeArea(
                            child: ListTile(
                              onTap: () {
                                launchurl(
                                    'https://play.google.com/store/apps/details?id=com.jaguweb.jagu_meet');
                              },
                              leading: SizedBox.fromSize(
                                  size: const Size(40, 40),
                                  child: ClipOval(
                                      child: Icon(Icons.thumb_up_alt_sharp))),
                              title: Text('Rate Us'),
                              subtitle: Text(
                                  'Rate Just Meet in play store and give a review!', overflow: TextOverflow.ellipsis,),
                              trailing: Icon(Icons.arrow_forward_ios),
                            ),
                          ),
                        ) : Container(),
                        visible ? SizedBox(
                          height: 10,
                        ) : Container(),
                        Card(
                          color: themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF242424)
                              : Colors.white,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: SafeArea(
                            child: ListTile(
                              onTap: () {
                                launchWebView(
                                    'https://knowaboutjagadish.blogspot.com/p/jagadish-prasad-pattanaik.html',
                                    'Developer');
                              },
                              leading: SizedBox.fromSize(
                                  size: const Size(40, 40),
                                  child: ClipOval(
                                      child: Icon(Icons.code))),
                              title: Text('Know about the Developer'),
                              subtitle: Text(
                                  'Know about the person who developed Just Meet for you with love!', overflow: TextOverflow.ellipsis,),
                              trailing: Icon(Icons.arrow_forward_ios),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ),
    );
  }
}
