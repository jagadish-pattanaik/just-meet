import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jagu_meet/screens/meetweb/webFeedback.dart';
import 'package:jagu_meet/screens/meetweb/webHost.dart';
import 'package:jagu_meet/screens/meetweb/webReport.dart';
import 'package:jagu_meet/screens/meetweb/webSettings.dart';
import 'package:jagu_meet/screens/user/profilePage.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';

class WebAppBar extends StatelessWidget {
  final String url, email, name , uid;
  const WebAppBar({
    Key key,
    this.url,
    this.email,
    this.name,
    this.uid,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: themeNotifier.getTheme() == darkTheme
            ? Color(0xff0d0d0d)
            : Color(0xFFFFFFFF),
      ),
      child: Row(
        children: <Widget>[
          Image.asset(
            "assets/images/logo.png",
            height: 50,
            alignment: Alignment.topCenter,
          ),
          SizedBox(width: 5),
          Text(
            "Just Meet".toUpperCase(),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
    child: IconButton(
    icon: Icon(Icons.settings_outlined, semanticLabel: 'Settings',),
    onPressed: () {
      Navigator.push(
          context,
          CupertinoPageRoute(
              settings: RouteSettings(name: '/settings'),
              builder: (context) => webSettings()));
    },
    )
    ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: IconButton(
                icon: Icon(Icons.feedback_outlined, semanticLabel: 'Feedback'),
                onPressed: () {
    Navigator.push(
    context,
    CupertinoPageRoute(
        settings: RouteSettings(name: '/feedback'),
    builder: (context) => WebFeedback()));
    },
              )
          ),
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: IconButton(
    icon: Icon(Icons.report_outlined, semanticLabel: 'Report Abuse'),
    onPressed: () {
    Navigator.push(
    context,
    CupertinoPageRoute(
        settings: RouteSettings(name: '/report'),
    builder: (context) => WebReport(
    )));
    },
    )
    ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Semantics(
              label: 'Profile',
              child: IconButton(
              onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      settings: RouteSettings(name: '/profile'),
                      builder: (context) => profilePage(
                        name: name,
                        email: email,
                        photoURL: url,
                      ))),
              icon: CachedNetworkImage(
                useOldImageOnUrlChange: false,
              imageUrl: url,
              placeholder: (context, url) => Icon(Icons.person, semanticLabel: 'Profile'),
              errorWidget: (context, url, error) => Icon(Icons.person, semanticLabel: 'Profile'),
              imageBuilder: (context, imageProvider) => Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.scaleDown,
                      ))),
            ),
            ),
          ),
          ),
          DefaultButton(
            text: "New Meeting",
            press: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      settings: RouteSettings(name: '/host'),
                      builder: (context) =>
                          WebHost(name: name, email: email, url: url, uid: uid,)));

            },
          ),
        ],
      ),
    );
  }
}

class DefaultButton extends StatelessWidget {
  final String text;
  final Function press;
  const DefaultButton({
    Key key,
    this.text,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: FlatButton(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        color: Color(0xff0184dc),
        onPressed: press,
        child: Text(
          text.toUpperCase(),
        ),
      ),
    );
  }
}
