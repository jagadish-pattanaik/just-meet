import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/jitsi_meeting_listener.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:random_string/random_string.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:jagu_meet/classes/focusNode.dart';

class HostPage extends StatefulWidget {
  final name;
  final email;
  final uid;
  final url;
  final pmeet;
  final linkNName;

  HostPage(
      {Key key,
      @required this.name,
      this.email,
      this.uid,
      this.url,
      this.pmeet,
      this.linkNName})
      : super(key: key);

  @override
  _HostPageState createState() => _HostPageState(name, email, uid, url, pmeet);
}

class _HostPageState extends State<HostPage> {
  final name;
  final email;
  final uid;
  final url;
  final pmeet;

  _HostPageState(this.name, this.email, this.uid, this.url, this.pmeet);

  var _darkTheme;

  FocusNode myFocusNode2 = FocusNode();
  FocusNode myFocusNode3 = FocusNode();

  var isAudioOnly = true;
  var isAudioMuted = true;
  var isVideoMuted = true;
  var timerEnabled = true;
  var meetNameEnabled = true;

  var chatEnabled = true;
  var liveEnabled = false;
  var recordEnabled = false;
  var raiseEnabled = true;
  var kickEnabled = false;
  var shareYtEnabled = true;

  var copyEnabled = true;
  var useAvatar = true;

  var PmeetingId;

  bool isEnabled;
  bool _hostValidateError = false;
  bool _hostIdError = false;

  String _userName;
  String _userEmail;
  var _userUid;
  var _userPhotoUrl;

  var webLink = 'meet.jit.si/';

  String version = '.';

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

  getInfo() {
    setState(() {
      _userName = name;
      _userEmail = email;
      _userUid = uid;
      _userPhotoUrl = url;
      PmeetingId = pmeet;
    });
  }

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

  final serverText = TextEditingController();
  final nameText = TextEditingController();
  final emailText = TextEditingController();
  final hostRoomText = TextEditingController(text: randomNumeric(11));
  final hostSubjectText = TextEditingController();

  bool isTyping2 = false;
  istyping2(final TextEditingController controller) {
    if (controller.text.length > 0) {
      setState(() {
        isTyping2 = true;
      });
    } else {
      setState(() {
        isTyping2 = false;
      });
    }
  }

  bool isTyping = false;
  istyping(final TextEditingController controller) {
    if (controller.text.length > 0) {
      setState(() {
        isTyping = true;
      });
    } else {
      setState(() {
        isTyping = false;
      });
    }
  }

  bool isTyping3 = false;
  istyping3(final TextEditingController controller) {
    if (controller.text.length > 0) {
      setState(() {
        isTyping3 = true;
      });
    } else {
      setState(() {
        isTyping3 = false;
      });
    }
  }

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        chatEnabled = prefs.getBool('chatEnabled') ?? true;
        liveEnabled = prefs.getBool('liveEnabled') ?? false;
        recordEnabled = prefs.getBool('recordEnabled') ?? false;
        raiseEnabled = prefs.getBool('raiseEnabled') ?? true;
        kickEnabled = prefs.getBool('kickEnabled') ?? false;
        shareYtEnabled = prefs.getBool('shareYtEnabled') ?? true;

        isAudioOnly = prefs.getBool('isAudioOnly') ?? true;
        isAudioMuted = prefs.getBool('isAudioMuted') ?? true;
        isVideoMuted = prefs.getBool('isVideoMuted') ?? true;
        copyEnabled = prefs.getBool('copyEnabled') ?? true;
        timerEnabled = prefs.getBool('timerEnabled') ?? true;
        meetNameEnabled = prefs.getBool('meetNameEnabled') ?? true;
        useAvatar = prefs.getBool('useAvatar') ?? true;
      });
    });
  }

  isEmptyHost() {
    if ((hostRoomText.text.length >= 10) && (hostSubjectText.text != "")) {
      setState(() {
        isEnabled = true;
      });
    } else {
      setState(() {
        isEnabled = false;
      });
    }
  }

  onSignOut() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('signStatus', false);
    });
  }

  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 2,
    minLaunches: 5,
    remindDays: 5,
    remindLaunches: 10,
    googlePlayIdentifier: 'com.jaguweb.jagu_meet',
  );

  void meetFeedback() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    rateMyApp.showStarRateDialog(
      context,
      title: 'How was your meeting?',
      // The dialog title.
      message: 'Would you like to share how was you meeting?:',
      dialogStyle: DialogStyle(
        dialogShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleAlign: TextAlign.center,
        messageAlign: TextAlign.center,
        messagePadding: EdgeInsets.only(bottom: 20),
      ),
      actionsBuilder: (context, stars) {
        return [
          FlatButton(
            color: Colors.transparent,
            child: Text(
              'Submit',
              style: TextStyle(
                color: themeNotifier.getTheme() == darkTheme
                    ? Colors.blueAccent
                    : Colors.blue,
              ),
            ),
            onPressed: () {
              if (stars != 0) {
                Navigator.pop(context);
                if (stars <= 3) {
                  _launchURL(
                      'jaguweb1234@gmail.com',
                      'Meeting Feedback Just Meet',
                      'Please write what went wrong so that we can improve. '
                          '\n'
                          '\n'
                          'User Details: '
                          '\n'
                          'Running on device: $deviceData.  '
                          '\n'
                          'user id: $_userUid.  '
                          '\n'
                          'email: $_userEmail.  '
                          '\n'
                          '\n'
                          'app version: $version.  '
                          '\n'
                          '\n'
                          'What Went Wrong: ');
                } else if (stars <= 5) {
                  Fluttertoast.showToast(
                      msg: 'Thank You for your feedback',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.SNACKBAR,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              } else {
                Navigator.pop(context);
              }
            },
          ),
          FlatButton(
            color: Colors.transparent,
            child: Text(
              'Not Now',
              style: TextStyle(
                color: themeNotifier.getTheme() == darkTheme
                    ? Colors.blueAccent
                    : Colors.blue,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ];
      },
      starRatingOptions: StarRatingOptions(),
    );
  }

  var linkImageUrl = Uri.parse(
      'https://play-lh.googleusercontent.com/1UPWJehjpgF1SfEccYtNzxHY7U9WAeCqwKx_UnRh-DrrP-NcN2bmjQMI5Ig1o-5xZRTT=s180-rw');
  Future<Uri> createDynamicLink(
      {@required String meet,
      @required String sub,
      @required String ch,
      @required String rh,
      @required String rm,
      @required String ls,
      @required String yt,
      @required String ko,
      @required String host}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://jagumeet.page.link',
      link: Uri.parse(
          'https://www.jaguweb.jmeet.com/meet?id=$meet&pwd=$sub&ch=$ch&rh=$rh&rm=$rm&ls=$ls&yt=$yt&ko=$ko&host=$host'),
      androidParameters: AndroidParameters(
        packageName: 'com.jaguweb.jagu_meet',
        minimumVersion: int.parse(packageInfo.buildNumber),
      ),
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

  @override
  void initState() {
    super.initState();
    getInfo();
    getSettings();
    getAppInfo();
    getDevice();
    isEmptyHost();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    nameText.text = _userName;
    emailText.text = _userEmail;
    String invitation = _userName + "'s Just Meet Meeting";
    getSettings();
    return MaterialApp(
      title: 'Just Meet',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.getTheme(),
      home: Scaffold(
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
            'Start a Meeting',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
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
                      focusNode: AlwaysDisabledFocusNode(),
                      enableInteractiveSelection: false,
                      autofocus: false,
                      controller: hostRoomText,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        counterText: '',
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
                        errorText: _hostIdError ? 'Invalid Meeting Id' : null,
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: "Meeting Id",
                        labelStyle: TextStyle(color: Colors.blue),
                        hintText: "My Unique Meeting Id",
                        fillColor: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF191919)
                            : Color(0xFFf9f9f9),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: TextField(
                      focusNode: myFocusNode3,
                      autofocus: false,
                      controller: hostSubjectText,
                      onChanged: (val) {
                        isEmptyHost();
                        istyping(hostSubjectText);
                      },
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.0),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        counterText: '',
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
                        suffixIcon: Visibility(
                          visible: isTyping3,
                          child: IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                hostSubjectText.clear();
                                istyping(hostSubjectText);
                              }),
                        ),
                        //fillColor: Colors.white,
                        errorText: _hostValidateError
                            ? 'Meeting Topic is mandatory'
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                          borderSide: BorderSide(width: 1),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: "Meeting Topic",
                        labelStyle: TextStyle(color: Colors.blue),
                        hintText: invitation,
                        fillColor: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF191919)
                            : Color(0xFFf9f9f9),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5, bottom: 10),
                      child: Text(
                        'Allow Participants to',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ]),
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
                      "Chat",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: chatEnabled,
                        onChanged: _onChatChanged,
                      ),
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
                    title: Text(
                      "Raise Hand",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: raiseEnabled,
                        onChanged: _onRaiseChanged,
                      ),
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
                    title: Text(
                      "Record Meeting",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: recordEnabled,
                        onChanged: _onRecordChanged,
                      ),
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
                    title: Text(
                      "Live streaming",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: liveEnabled,
                        onChanged: _onLiveChanged,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
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
                      onPressed: isEnabled
                          ? () async {
                              setState(() {
                                hostSubjectText.text.isEmpty
                                    ? _hostValidateError = true
                                    : _hostValidateError = false;
                              });

                              setState(() {
                                hostRoomText.text.length >= 10
                                    ? _hostIdError = false
                                    : _hostIdError = true;
                              });
                              if (hostRoomText.text.length >= 10) {
                                if (hostSubjectText.text.isNotEmpty) {
                                  var connectivityResult = await (Connectivity()
                                      .checkConnectivity());
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
                                      meet: hostRoomText.text.replaceAll(
                                          RegExp(
                                              r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                          ""),
                                      sub: hostSubjectText.text,
                                      ch: chatEnabled.toString(),
                                      rh: raiseEnabled.toString(),
                                      rm: recordEnabled.toString(),
                                      ls: liveEnabled.toString(),
                                      yt: shareYtEnabled.toString(),
                                      ko: kickEnabled.toString(),
                                      host: _userEmail,
                                    );
                                    var dynamicWeb = webLink +
                                        hostRoomText.text.replaceAll(
                                            RegExp(
                                                r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                            "");
                                    final action = await Dialogs.yesAbortDialog(
                                        context,
                                        'Invite Others',
                                        'Invite Others to the meeting',
                                        'Invite Others',
                                        'Start Meeting');
                                    if (action == DialogAction.yes) {
                                      _shareMeeting(
                                          hostRoomText.text,
                                          hostSubjectText.text,
                                          dynamicLink.toString(),
                                          dynamicWeb);
                                    }
                                    if (action == DialogAction.no) {
                                      useAvatar == true
                                          ? _hostMeeting()
                                          : _hostMeetingNoAvatar();
                                    }
                                  }
                                }
                              }
                            }
                          : null,
                      child: Text(
                        "Start Meeting",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult == ConnectivityResult.none) {
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
                              meet: widget.linkNName.replaceAll(
                                  RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                  ""),
                              sub: "$name's personal link meeting",
                              ch: chatEnabled.toString(),
                              rh: raiseEnabled.toString(),
                              rm: recordEnabled.toString(),
                              ls: liveEnabled.toString(),
                              yt: shareYtEnabled.toString(),
                              ko: kickEnabled.toString(),
                              host: _userEmail,
                            );
                            var dynamicWeb = webLink +
                                hostRoomText.text.replaceAll(
                                    RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                    "");
                            final action = await Dialogs.yesAbortDialog(
                                context,
                                'Invite Others',
                                'Invite Others to the meeting',
                                'Invite Others',
                                'Start Meeting');
                            if (action == DialogAction.yes) {
                              _shareLinkMeeting(
                                  dynamicLink.toString(), dynamicWeb);
                            }
                            if (action == DialogAction.no) {
                              _hostLinkMeeting();
                            }
                          }
                        },
                        child: Text(
                          'Start Personal Link Meeting',
                          style: TextStyle(
                              color: themeNotifier.getTheme() == darkTheme
                                  ? Colors.blueAccent
                                  : Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _onChatChanged(bool value) {
    setState(() {
      chatEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('chatEnabled', value);
    });
  }

  _onLiveChanged(bool value) async {
    if (liveEnabled == false) {
      final action = await Dialogs.yesAbortDialog(
          context,
          'Not Recommended',
          'Allowing participants to live stream meeting is not recommended by Just Meet. Do you still want to allow?',
          'Allow',
          'No');
      if (action == DialogAction.yes) {
        setState(() {
          liveEnabled = value;
        });
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('liveEnabled', value);
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        liveEnabled = value;
      });
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('liveEnabled', value);
      });
    }
  }

  _onRecordChanged(bool value) async {
    if (recordEnabled == false) {
      final action = await Dialogs.yesAbortDialog(
          context,
          'Not Recommended',
          'Allowing participants to record meeting is not recommended by Just Meet. Do you still want to allow?',
          'Allow',
          'No');
      if (action == DialogAction.yes) {
        setState(() {
          recordEnabled = value;
        });
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('recordEnabled', value);
        });
      }
      if (action == DialogAction.abort) {}
    } else {
      setState(() {
        recordEnabled = value;
      });
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('recordEnabled', value);
      });
    }
  }

  _onRaiseChanged(bool value) {
    setState(() {
      raiseEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('raiseEnabled', value);
    });
  }

  _hostMeeting() async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    setState(() {
      hostSubjectText.text.isEmpty
          ? _hostValidateError = true
          : _hostValidateError = false;
    });

    setState(() {
      hostRoomText.text.length >= 10
          ? _hostIdError = false
          : _hostIdError = true;
    });

    try {
      FeatureFlag featureFlag = FeatureFlag();
      featureFlag.welcomePageEnabled = false;
      featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
      featureFlag.pipEnabled = false;

      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlag.callIntegrationEnabled = false;
        featureFlag.inviteEnabled = false;
        featureFlag.toolboxAlwaysVisible = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlag.pipEnabled = false;
      }
      if (chatEnabled == false) {
        featureFlag.chatEnabled = false;
      }

      if (timerEnabled == false) {
        featureFlag.conferenceTimerEnabled = false;
      }

      if (meetNameEnabled == false) {
        featureFlag.meetingNameEnabled = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions()
        ..room = hostRoomText.text
            .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "")
        ..serverURL = serverUrl
        ..subject = hostSubjectText.text
        ..userDisplayName = _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..userAvatarURL = _userPhotoUrl
        ..featureFlag = featureFlag;

      debugPrint("JitsiMeetingOptions: $options");
      if (hostRoomText.text.length >= 10) {
        if (hostSubjectText.text.isNotEmpty) {
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (connectivityResult == ConnectivityResult.none) {
            Fluttertoast.showToast(
                msg: 'No Internet Connection!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
          } else {
            await JitsiMeet.joinMeeting(
              options,
              listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
                Fluttertoast.showToast(
                    msg: 'Starting your meeting...',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                debugPrint("${options.room} will join with message: $message");
              }, onConferenceJoined: ({message}) async {
                Fluttertoast.showToast(
                    msg: 'Meeting Started',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                if (copyEnabled == true) {
                  var dynamicLink = await createDynamicLink(
                    meet: options.room.replaceAll(
                        RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""),
                    sub: options.subject,
                    ch: chatEnabled.toString(),
                    rh: raiseEnabled.toString(),
                    rm: recordEnabled.toString(),
                    ls: liveEnabled.toString(),
                    yt: shareYtEnabled.toString(),
                    ko: kickEnabled.toString(),
                    host: _userEmail,
                  );
                  var dynamicWeb = webLink +
                      options.room.replaceAll(
                          RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "");
                  final textshare =
                      "${nameText.text} is inviting you to join a Just Meet meeting.  "
                      "\n"
                      "\n"
                      "Meeting Id - ${options.room}  "
                      "\n"
                      "Meeting Topic - ${options.subject}.  "
                      "\n"
                      "\n"
                      "Android Meeting URL - $dynamicLink  "
                      "\n"
                      "\n"
                      "IOS and PC Meeting URL - $dynamicWeb "
                      "\n"
                      "\n"
                      "Meeting Password - Host will share separately. ";
                  copyInvite(textshare);
                } else {}
                debugPrint("${options.room} joined with message: $message");
              }, onConferenceTerminated: ({message}) {
                Fluttertoast.showToast(
                    msg: 'Meeting Ended By You',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                isEmptyHost();
                meetFeedback();
                debugPrint("${options.room} terminated with message: $message");
              }, onPictureInPictureWillEnter: ({message}) {
                debugPrint(
                    "${options.room} entered PIP mode with message: $message");
              }, onPictureInPictureTerminated: ({message}) {
                debugPrint(
                    "${options.room} exited PIP mode with message: $message");
              }),
              // by default, plugin default constraints are used
              //roomNameConstraints: new Map(), // to disable all constraints
              //roomNameConstraints: customContraints, // to use your own constraint(s)
            );
          }
        }
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: "Couldn't Start Your Meeting",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      debugPrint("error: $error");
    }
  }

  _hostLinkMeeting() async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      FeatureFlag featureFlag = FeatureFlag();
      featureFlag.welcomePageEnabled = false;
      featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
      featureFlag.pipEnabled = false;

      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlag.callIntegrationEnabled = false;
        featureFlag.inviteEnabled = false;
        featureFlag.toolboxAlwaysVisible = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlag.pipEnabled = false;
      }
      if (chatEnabled == false) {
        featureFlag.chatEnabled = false;
      }

      if (timerEnabled == false) {
        featureFlag.conferenceTimerEnabled = false;
      }

      if (meetNameEnabled == false) {
        featureFlag.meetingNameEnabled = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions()
        ..room = widget.linkNName
            .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "")
        ..serverURL = serverUrl
        ..subject = 'Personal Link Meeting'
        ..userDisplayName = _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..userAvatarURL = _userPhotoUrl
        ..featureFlag = featureFlag;

      debugPrint("JitsiMeetingOptions: $options");
      if (hostRoomText.text.length >= 10) {
        if (hostSubjectText.text.isNotEmpty) {
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (connectivityResult == ConnectivityResult.none) {
            Fluttertoast.showToast(
                msg: 'No Internet Connection!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
          } else {
            await JitsiMeet.joinMeeting(
              options,
              listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
                Fluttertoast.showToast(
                    msg: 'Starting your meeting...',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                debugPrint("${options.room} will join with message: $message");
              }, onConferenceJoined: ({message}) async {
                Fluttertoast.showToast(
                    msg: 'Meeting Started',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                if (copyEnabled == true) {
                  var dynamicLink = await createDynamicLink(
                    meet: options.room.replaceAll(
                        RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""),
                    sub: options.subject,
                    ch: chatEnabled.toString(),
                    rh: raiseEnabled.toString(),
                    rm: recordEnabled.toString(),
                    ls: liveEnabled.toString(),
                    yt: shareYtEnabled.toString(),
                    ko: kickEnabled.toString(),
                    host: _userEmail,
                  );
                  var dynamicWeb = webLink +
                      options.room.replaceAll(
                          RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "");
                  final textshare =
                      "${nameText.text} is inviting you to join a Just Meet meeting.  "
                      "\n"
                      "\n"
                      "Personal Link Name: ${widget.linkNName}"
                      "\n"
                      "\n"
                      "Android Meeting URL - $dynamicLink  "
                      "\n"
                      "\n"
                      "IOS and PC Meeting URL - $dynamicWeb "
                      "\n"
                      "\n"
                      "Meeting Password - Host will share separately. ";
                  copyInvite(textshare);
                } else {}
                debugPrint("${options.room} joined with message: $message");
              }, onConferenceTerminated: ({message}) {
                Fluttertoast.showToast(
                    msg: 'Meeting Ended By You',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                isEmptyHost();
                meetFeedback();
                debugPrint("${options.room} terminated with message: $message");
              }, onPictureInPictureWillEnter: ({message}) {
                debugPrint(
                    "${options.room} entered PIP mode with message: $message");
              }, onPictureInPictureTerminated: ({message}) {
                debugPrint(
                    "${options.room} exited PIP mode with message: $message");
              }),
              // by default, plugin default constraints are used
              //roomNameConstraints: new Map(), // to disable all constraints
              //roomNameConstraints: customContraints, // to use your own constraint(s)
            );
          }
        }
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: "Couldn't Start Your Meeting",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      debugPrint("error: $error");
    }
  }

  _hostMeetingNoAvatar() async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    setState(() {
      hostSubjectText.text.isEmpty
          ? _hostValidateError = true
          : _hostValidateError = false;
    });

    setState(() {
      hostRoomText.text.length >= 10
          ? _hostIdError = false
          : _hostIdError = true;
    });

    try {
      FeatureFlag featureFlag = FeatureFlag();
      featureFlag.welcomePageEnabled = false;
      featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
      featureFlag.pipEnabled = false;

      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlag.callIntegrationEnabled = false;
        featureFlag.inviteEnabled = false;
        featureFlag.toolboxAlwaysVisible = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlag.pipEnabled = false;
      }
      if (chatEnabled == false) {
        featureFlag.chatEnabled = false;
      }

      if (timerEnabled == false) {
        featureFlag.conferenceTimerEnabled = false;
      }

      if (meetNameEnabled == false) {
        featureFlag.meetingNameEnabled = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions()
        ..room = hostRoomText.text
            .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "")
        ..serverURL = serverUrl
        ..subject = hostSubjectText.text
        ..userDisplayName = _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..featureFlag = featureFlag;

      debugPrint("JitsiMeetingOptions: $options");
      if (hostRoomText.text.length >= 10) {
        if (hostSubjectText.text.isNotEmpty) {
          var connectivityResult = await (Connectivity().checkConnectivity());
          if (connectivityResult == ConnectivityResult.none) {
            Fluttertoast.showToast(
                msg: 'No Internet Connection!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
          } else {
            await JitsiMeet.joinMeeting(
              options,
              listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
                Fluttertoast.showToast(
                    msg: 'Starting your meeting...',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                debugPrint("${options.room} will join with message: $message");
              }, onConferenceJoined: ({message}) async {
                Fluttertoast.showToast(
                    msg: 'Meeting Started',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                if (copyEnabled == true) {
                  var dynamicLink = await createDynamicLink(
                    meet: options.room.replaceAll(
                        RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""),
                    sub: options.subject,
                    ch: chatEnabled.toString(),
                    rh: raiseEnabled.toString(),
                    rm: recordEnabled.toString(),
                    ls: liveEnabled.toString(),
                    yt: shareYtEnabled.toString(),
                    ko: kickEnabled.toString(),
                    host: _userEmail,
                  );
                  var dynamicWeb = webLink +
                      options.room.replaceAll(
                          RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "");
                  final textshare =
                      "${nameText.text} is inviting you to join a Just Meet meeting.  "
                      "\n"
                      "\n"
                      "Meeting Id - ${options.room}  "
                      "\n"
                      "Meeting Topic - ${options.subject}.  "
                      "\n"
                      "\n"
                      "Android Meeting URL - $dynamicLink  "
                      "\n"
                      "\n"
                      "IOS and PC Meeting URL - $dynamicWeb "
                      "\n"
                      "\n"
                      "Meeting Password - Host will share separately. ";
                  copyInvite(textshare);
                } else {}
                debugPrint("${options.room} joined with message: $message");
              }, onConferenceTerminated: ({message}) {
                Fluttertoast.showToast(
                    msg: 'Meeting Ended By You',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                isEmptyHost();
                meetFeedback();
                debugPrint("${options.room} terminated with message: $message");
              }, onPictureInPictureWillEnter: ({message}) {
                debugPrint(
                    "${options.room} entered PIP mode with message: $message");
              }, onPictureInPictureTerminated: ({message}) {
                debugPrint(
                    "${options.room} exited PIP mode with message: $message");
              }),
              // by default, plugin default constraints are used
              //roomNameConstraints: new Map(), // to disable all constraints
              //roomNameConstraints: customContraints, // to use your own constraint(s)
            );
          }
        }
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: "Couldn't Start Your Meeting",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      debugPrint("error: $error");
    }
  }

  copyInvite(inviteText) {
    Clipboard.setData(new ClipboardData(text: inviteText)).then((_) {
      Fluttertoast.showToast(
          msg: 'Copied Invite link to clipboard',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  _shareMeeting(
      String roomids, String topics, String androidUrl, String url) async {
    if (hostRoomText.text.isNotEmpty) {
      if (hostSubjectText.text.isNotEmpty) {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          Fluttertoast.showToast(
              msg: 'No Internet Connection!',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.SNACKBAR,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          final textshare =
              "${nameText.text} is inviting you to join a Just Meet meeting.  "
              "\n"
              "\n"
              "Meeting Id - $roomids.  "
              "\n"
              "Meeting Topic - $topics.  "
              "\n"
              "\n"
              "Android Meeting URL - $androidUrl  "
              "\n"
              "\n"
              "IOS and PC Meeting URL - $url "
              "\n"
              "\n"
              "Meeting Password - Host will share separately. ";
          final RenderBox box = context.findRenderObject();
          Share.share(textshare,
              subject:
                  "${nameText.text} is inviting you to join a Just Meet meeting.  ",
              sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
        }
      }
    }
  }

  _shareLinkMeeting(String androidUrl, String url) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
          msg: 'No Internet Connection!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      final textshare =
          "${nameText.text} is inviting you to join a Just Meet meeting.  "
          "\n"
          "\n"
          "Personal Link Name: ${widget.linkNName}"
          "\n"
          "\n"
          "Android Meeting URL - $androidUrl  "
          "\n"
          "\n"
          "IOS and PC Meeting URL - $url "
          "\n"
          "\n"
          "Meeting Password - Host will share separately. ";
      final RenderBox box = context.findRenderObject();
      Share.share(textshare,
          subject:
              "${nameText.text} is inviting you to join a Just Meet meeting.  ",
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }
}
