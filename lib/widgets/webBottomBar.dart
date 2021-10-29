import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key key}) : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      color: Colors.blueGrey[900],
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BottomBarColumn(
                heading: 'ABOUT',
                s1: 'Contact Us',
                s2: 'About',
                s3: 'Developer',
                sf1: '1',
                sf2: '1',
                sf3: '1',
              ),
              BottomBarColumn(
                heading: 'HELP',
                s1: 'FAQ',
                s2: 'Privacy Policy',
                s3: 'Terms & Conditions',
                sf1: '2',
                sf2: '2',
                sf3: '2',
              ),
              BottomBarColumn(
                heading: 'SOCIAL',
                s1: 'YouTube',
                s2: ' ',
                s3: ' ',
                sf1: '3',
              ),
              Container(
                color: Colors.blueGrey,
                width: 2,
                height: 150,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoText(
                    type: 'Email',
                    text: 'jaguweb1234@gmail.com',
                  ),
                ],
              ),
            ],
          ),
          Divider(
            color: Colors.blueGrey,
          ),
          SizedBox(height: 20),
          Text(
            'Copyright © 2021 | Just Technologies. All rights reserved',
            style: TextStyle(
              color: Colors.blueGrey[300],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomBarColumn extends StatefulWidget {
  final String heading;
  final String s1;
  final String s2;
  final String s3;
  final String sf1;
  final String sf2;
  final String sf3;

  BottomBarColumn({
    this.heading,
    this.s1,
    this.s2,
    this.s3,
    this.sf1,
    this.sf2,
    this.sf3,
  });

  @override
  _BottomBarColumnState createState() => _BottomBarColumnState();
}

class _BottomBarColumnState extends State<BottomBarColumn> {
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

  launchTab(String url) async {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.heading,
            style: TextStyle(
              color: Colors.blueGrey[300],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              if (widget.sf1 == '1') {
                _launchURL(
                    'jaguweb1234@gmail.com',
                    'Just Meet Support',
                    'We are here to help you, feel free to contact us'
                        "\r\n"
                        "\n");
              } else if (widget.sf1 == '2') {
                launchTab('https://justmeetpolicies.blogspot.com/p/just-meet-faqs.html');
              } else {
                launchTab('https://www.youtube.com/channel/UCgdd03ctC4odnUCNlPBSdUg');
              }
            },
          child:
          Text(
            widget.s1,
            style: TextStyle(
              color: Colors.blueGrey[100],
              fontSize: 14,
            ),
          ),
          ),
          SizedBox(height: 5),
      GestureDetector(
        onTap: () {
          if (widget.sf2 == '1') {
            launchTab('https://justmeetpolicies.blogspot.com/p/about-us.html');

          } else {
            launchTab('https://justmeetpolicies.blogspot.com/p/just-meet-privacy-policy.html');
          }
        },
        child:
          Text(
            widget.s2,
            style: TextStyle(
              color: Colors.blueGrey[100],
              fontSize: 14,
            ),
          ),
      ),
          SizedBox(height: 5),
      GestureDetector(
        onTap: () {
          if (widget.sf2 == '1') {
            launchTab('https://knowaboutjagadish.blogspot.com/p/jagadish-prasad-pattanaik.html');
          } else {
            launchTab('https://justmeetpolicies.blogspot.com/p/just-meet-terms-conditions.html');
          }
        },
        child:
          Text(
            widget.s3,
            style: TextStyle(
              color: Colors.blueGrey[100],
              fontSize: 14,
            ),
          ),
      ),
        ],
      ),
    );
  }
}

class InfoText extends StatelessWidget {
  final String type;
  final String text;

  InfoText({this.type, this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$type: ',
          style: TextStyle(
            color: Colors.blueGrey[300],
            fontSize: 16,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.blueGrey[100],
            fontSize: 16,
          ),
        )
      ],
    );
  }
}