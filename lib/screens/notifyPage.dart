import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:jagu_meet/screens/webview.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

class Notify extends StatefulWidget {
  Notify({Key key}) : super(key: key);

  @override
  _NotifyState createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  bool visible = true;
  var _darkTheme;
  RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  final InAppReview inAppReview = InAppReview.instance;

  void _onRefresh() async {
    setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) setState(() {});
    _refreshController.loadComplete();
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

  launchWebView(var URL, var TITLE) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AppWebView(
                  url: URL,
                  title: TITLE,
                )));
  }

  @override
  void initState() {
    super.initState();
    //reviewAvailabled();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
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
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: themeNotifier.getTheme() == darkTheme
                ? Color(0xFF242424)
                : Colors.blue,
            elevation: 5,
            title: Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          body: SafeArea(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: WaterDropMaterialHeader(
                color: Colors.white,
                backgroundColor: themeNotifier.getTheme() == darkTheme
                    ? Color(0xFF242424)
                    : Colors.blue,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
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
                              title: Text('Breaking Changes'),
                              subtitle: Text(
                                  'New version 2.1.0! Make sure all participants have it.'),
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
                                  'There is a slack community which can help you with Just Meet!'),
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
                                    'https://play.google.com/store/apps/details?id=com.jaguweb.jagu_meet');
                              },
                              leading: SizedBox.fromSize(
                                  size: const Size(40, 40),
                                  child: ClipOval(
                                      child: Icon(Icons.thumb_up_alt_sharp))),
                              title: Text('Rate Us'),
                              subtitle: Text(
                                  'Rate Just Meet in play store and give a review!'),
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
                                    'https://www.youtube.com/channel/UCgdd03ctC4odnUCNlPBSdUg');
                              },
                              leading: SizedBox.fromSize(
                                  size: const Size(40, 40),
                                  child: ClipOval(
                                      child: Icon(Icons.ondemand_video))),
                              title: Text('Just Meet Tutorials'),
                              subtitle: Text(
                                  'Watch YouTube video and learn how to use Just Meet!'),
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
                                launchWebView(
                                    'https://knowaboutjagadish.blogspot.com/p/jagadish-prasad-pattanaik.html',
                                    'Developer');
                              },
                              leading: SizedBox.fromSize(
                                  size: const Size(40, 40),
                                  child: ClipOval(
                                      child: Icon(Icons.info_outline))),
                              title: Text('Know about the Developer'),
                              subtitle: Text(
                                  'Know about the person who developed Just Meet for you with love!'),
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
      ),
    );
  }
}
