import 'package:connectivity/connectivity.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/screens/meeting/search/searchUser.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class ShareInviteBlock extends StatefulWidget {
  final name;
  final email;
  final photoUrl;
  final uid;
  final meetId;
  final meetName;

  const ShareInviteBlock({
    this.uid,
    this.email,
    this.name,
    this.photoUrl,
    this.meetId,
    this.meetName,
    Key key}) : super(key: key);

  @override
  _ShareInviteBlockState createState() => _ShareInviteBlockState();
}

class _ShareInviteBlockState extends State<ShareInviteBlock> {
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
          bottom:  PreferredSize(
              child: Divider(
                  height: 1,
                  color: themeNotifier.getTheme() == darkTheme
                      ?  Color(0xFF303030) : Colors.black12
              ),
              preferredSize: Size(double.infinity, 0.0)),
          title: Text(
            'Invite',
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
                    Divider(
                      height: 1,
                      color: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF303030)
                          : Colors.black12,
                    ),
                    ListTile(
                      tileColor: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF191919)
                          : Color(0xFFf9f9f9),
                      leading: Icon(Icons.group),
                      title: Text(
                        "Invite Participant",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
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
                      onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => SearchUsersScreen(name: widget.name, email: widget.email, PhotoUrl: widget.photoUrl, uid: widget.uid, meetId: widget.meetId, meetName: widget.meetName, type: 'invite',))),
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
                      title: Text(
                        "Invite Co-Host",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      leading: Icon(Icons.supervised_user_circle_outlined),
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
                      onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => SearchUsersScreen(name: widget.name, email: widget.email, PhotoUrl: widget.photoUrl, uid: widget.uid, meetId: widget.meetId, meetName: widget.meetName, type: 'cohost',))),
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
                      leading: Icon(Icons.block),
                      title: Text(
                        "Block",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      dense: true,
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
                      onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => SearchUsersScreen(name: widget.name, email: widget.email, PhotoUrl: widget.photoUrl, uid: widget.uid, meetId: widget.meetId, meetName: widget.meetName, type: 'block',))),
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
                    Divider(
                      height: 1,
                      color: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF303030)
                          : Colors.black12,
                    ),
                    ListTile(
                      tileColor: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF191919)
                          : Color(0xFFf9f9f9),
                      title: Text(
                        "Share link",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      leading: Icon(Icons.link_sharp),
                      dense: true,
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
                      onTap: () async {
                        var connectivityResult =
                        await (Connectivity().checkConnectivity());
                        if (connectivityResult ==
                            ConnectivityResult.none) {
                          Fluttertoast.showToast(
                              msg: 'No Internet Connection!',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.SNACKBAR,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          var dynamicLink = await createDynamicLink(
                              meet: widget.meetId.replaceAll(
                                  RegExp(
                                      r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                  "")
                          );
                          var dynamicWeb = 'https://jmeet-8e163.web.app/';
                          _shareMeeting(widget.meetId, widget.meetName, dynamicLink.toString(), dynamicWeb);
                        }
                      }
                    ),
                    Divider(
                      height: 1,
                      color: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF303030)
                          : Colors.black12,
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  _shareMeeting(
      String roomids, String topics, String androidUrl, String url) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
          msg: 'No internet connection',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      final textshare =
          "${widget.name} is inviting you to join a Just Meet meeting.  "
          "\n"
          "\n"
          "Meeting Id - $roomids.  "
          "\n"
          "Meeting Topic - $topics.  "
          "\n"
          "\n"
          "Meeting URL - $androidUrl  ";
      final RenderBox box = context.findRenderObject();
      Share.share(textshare,
          subject:
          "${widget.name} is inviting you to join a Just Meet meeting.  ",
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  var linkImageUrl = Uri.parse(
      'https://play-lh.googleusercontent.com/7ZrxSsCqSNb86h57pPlJ3budCKTTZrCDSB3aq1F-srZnhO4M1iNtCXaM7fvxuJU3Yg=s180-rw');
  Future<Uri> createDynamicLink(
      {@required String meet}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://jagumeet.page.link',
      link: Uri.parse(
          'https://www.jaguweb.jmeet.com/meet?id=$meet'),
      androidParameters: AndroidParameters(
        packageName: 'com.jaguweb.jagu_meet',
        minimumVersion: int.parse(packageInfo.buildNumber),
      ),
      iosParameters: IosParameters(
          fallbackUrl: Uri.parse('https://jmeet-8e163.web.app/'),
          ipadFallbackUrl: Uri.parse('https://jmeet-8e163.web.app/'),
          bundleId: ''),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'Video Conference',
        medium: 'Social',
        source: 'Just Meet',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Join Just Meet Video Conference',
        imageUrl: linkImageUrl,
        description:
        'Just Meet is the leader in video conferences, with easy, secured, encrypted and reliable video and audio conferencing, chat, screen sharing and webinar across mobile and desktop. Unlimited participants and time with low bandwidth mode. Join Just Meet Video Conference now and enjoy high quality video conferences with security like no other. Stay Safe and Stay Connected with Just Meet. Developed in India with love.',
      ),
    );
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri dynamicUrl = shortDynamicLink.shortUrl;
    return dynamicUrl;
  }
}
