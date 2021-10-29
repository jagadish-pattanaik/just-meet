import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/firebase/ads/admobAds.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:jagu_meet/screens/meeting/settings/hostingSettings.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/cupertinoSwitchListTile.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
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
import 'details/recentHosted.dart';

class HostPage extends StatefulWidget {
  final name;
  final email;
  final uid;
  final url;

  HostPage(
      {Key key,
      @required this.name,
      this.email,
      this.uid,
      this.url,})
      : super(key: key);

  @override
  _HostPageState createState() => _HostPageState(name, email, uid, url);
}

class _HostPageState extends State<HostPage> with SingleTickerProviderStateMixin {
  final name;
  final email;
  final uid;
  final url;

  _HostPageState(this.name, this.email, this.uid, this.url);

  FocusNode myFocusNode3 = FocusNode();
  DatabaseService databaseService = new DatabaseService();
  AdHelper adHelper = new AdHelper();

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

  bool isEnabled;
  bool inMeeting = false;

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
    });
  }

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
    rateMyApp.showStarRateDialog(
      context,
      title: 'How was your meeting?',
      // The dialog title.
      message: 'Would you like to share how was you meeting?:',
      dialogStyle: DialogStyle(
        dialogShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xff0184dc)
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
                          'app version: $version.  '
                          '\n'
                          '\n'
                          'What Went Wrong: ');
                } else if (stars <= 5) {
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
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: themeNotifier.getTheme() == darkTheme
                    ? Color(0xff0184dc)
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
      'https://play-lh.googleusercontent.com/7ZrxSsCqSNb86h57pPlJ3budCKTTZrCDSB3aq1F-srZnhO4M1iNtCXaM7fvxuJU3Yg=s180-rw');
  Future<Uri> createDynamicLink(
      {@required String meet,}) async {
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
    final Uri longLink = await parameters.buildUrl();
    final ShortDynamicLink shortDynamicLink = await DynamicLinkParameters.shortenUrl(Uri.parse(longLink.toString() + "&ofl=https://jmeet-8e163.web.app/"));
    final Uri dynamicUrl = shortDynamicLink.shortUrl;
    return dynamicUrl;
  }

  @override
  void initState() {
    super.initState();
    adHelper.interstitialAdload();
    adHelper.rewardedAdLoad();
    getInfo();
    getSettings();
    getAppInfo();
    getDevice();
    isEmptyHost();
  }

  bool hateError = false;
  List<String> hateSpeech = [
    'Bitch',
    'Fuck',
    'Anal',
    'Fuck',
    'sex',
    'Vaginal',
    'Piss',
    'Rascal',
    'Bastard',
    'Xxx',
    'Porn',
    'Terrorism',
    'Idiot',
    'F*ck',
    'Vagina',
    'F**k',
    'Shit',
    'fucker',
    'Chudai',
    'Dick',
    'Asshole',
    'asshole',
    '****',
    '***',
    'Madarchod',
    'Behenchod',
    'Maa ki',
    'Maaki',
    'Maki',
    'Lund',
    'Chut',
    'Chutad',
    'Bhosdike',
    'Bsdk',
    'Betichod',
    'Chutiya',
    'Harami',
    'chut',
    'Haramkhor'
  ];

  hateDetect(final TextEditingController controller) {
    for (var i = 0; i < hateSpeech.length; i++) {
      if (controller.text.contains(hateSpeech[i])) {
        setState(() {
          hateError = true;
        });
      } else if (controller.text.toLowerCase().contains(hateSpeech[i])) {
        setState(() {
          hateError = true;
        });
      } else if (controller.text.toUpperCase().contains(hateSpeech[i])) {
        setState(() {
          hateError = true;
        });
      } else if (controller.text.isEmpty) {
        setState(() {
          hateError = false;
        });
      }else if (!controller.text.contains(hateSpeech[i])) {
        setState(() {
          hateError = false;
        });
      } else if (!controller.text.toLowerCase().contains(hateSpeech[i])) {
        setState(() {
          hateError = false;
        });
      } else if (!controller.text.toUpperCase().contains(hateSpeech[i])) {
        setState(() {
          hateError = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    nameText.text = _userName;
    emailText.text = _userEmail;
    getSettings();
    return Theme(
      data: themeNotifier.getTheme(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.clear,
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
            'Start a Meeting',
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
                      focusNode: AlwaysDisabledFocusNode(),
                      enableInteractiveSelection: false,
                      autofocus: false,
                      controller: hostRoomText,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12,),
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF191919)
                            : Color(0xFFf9f9f9),
                      ),
                    ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
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
                      focusNode: myFocusNode3,
                      autofocus: false,
                      controller: hostSubjectText,
                      textAlign: TextAlign.center,
                      onChanged: (val) {
                        isEmptyHost();
                        istyping(hostSubjectText);
                        hateDetect(hostSubjectText);
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 45),
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
                        errorText: hateError ? 'Hate speech detected!' : null,
                        border: InputBorder.none,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        hintText: 'Meeting Topic',
                        fillColor: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF191919)
                            : Color(0xFFf9f9f9),
                      ),
                    ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
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
                  CupertinoSwitchListTile(
                    title: Text(
                      "Chat",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    value: chatEnabled,
                    onChanged: _onChatChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Raise Hand",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    value: raiseEnabled,
                    onChanged: _onRaiseChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Record Meeting",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    value: recordEnabled,
                    onChanged: _onRecordChanged,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  ),
                  CupertinoSwitchListTile(
                    title: Text(
                      "Live streaming",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    dense: true,
                    value: liveEnabled,
                    onChanged: _onLiveChanged,
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
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => hostingSettings())),
                    title: Text(
                      'More Settings',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('Share YouTube video, Kick out, Show name when participants join', overflow: TextOverflow.ellipsis,),
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
                      onPressed: inMeeting
                          ? null
                          : isEnabled
                          ? () async {
                              if (hostRoomText.text.length >= 10) {
                                if (hostSubjectText.text.isNotEmpty) {
                                  var connectivityResult = await (Connectivity()
                                      .checkConnectivity());
                                  if (connectivityResult ==
                                      ConnectivityResult.none) {
                                    Fluttertoast.showToast(
                                        msg: 'No internet connection',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.SNACKBAR,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  } else {
                                    int totalHosted = await databaseService.getAllHosted(_userUid);
                                    if (totalHosted >= 5) {
                                      final action = await Dialogs.redAlertDialog(
                                          context,
                                          'Meetings holding limit reached!',
                                          'Please release a meeting or watch an Ad to increase your holding limit',
                                          'Release',
                                          'Watch Ad');
                                      if (action == DialogAction.yes) {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    RecentHosted(
                                                      name: _userName,
                                                      email: _userEmail,
                                                      uid: _userUid,
                                                      url: _userPhotoUrl,
                                                    )));
                                      }
                                      if (action == DialogAction.no) {
                                        watchNdStart() async {
                                          var dynamicLink = await createDynamicLink(
                                            meet: hostRoomText.text.replaceAll(
                                                RegExp(
                                                    r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                                ""),
                                          );
                                          var dynamicWeb = webLink +
                                              hostRoomText.text.replaceAll(
                                                  RegExp(
                                                      r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                                  "");
                                          final action = await Dialogs.yesAbortDialog(
                                              context,
                                              'Start Meeting',
                                              'Invite Others to the meeting',
                                              'Start',
                                              'Invite');
                                          if (action == DialogAction.yes) {
                                            _hostMeeting();
                                          }
                                          if (action == DialogAction.no) {
                                            _shareMeeting(
                                                hostRoomText.text,
                                                hostSubjectText.text,
                                                dynamicLink.toString(),
                                                dynamicWeb);
                                          }
                                        }
                                        adHelper.showRewardedAd(
                                          watchNdStart()
                                        );
                                      }
                                    } else {
                                      var dynamicLink = await createDynamicLink(
                                        meet: hostRoomText.text.replaceAll(
                                            RegExp(
                                                r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                            ""),
                                      );
                                      var dynamicWeb = webLink +
                                          hostRoomText.text.replaceAll(
                                              RegExp(
                                                  r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                              "");
                                      final action = await Dialogs
                                          .yesAbortDialog(
                                          context,
                                          'Start Meeting',
                                          'Invite Others to the meeting',
                                          'Start',
                                          'Invite');
                                      if (action == DialogAction.yes) {
                                        _hostMeeting();
                                      }
                                      if (action == DialogAction.no) {
                                        _shareMeeting(
                                            hostRoomText.text,
                                            hostSubjectText.text,
                                            dynamicLink.toString(),
                                            dynamicWeb);
                                      }
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

    try {
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        //featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
        FeatureFlagEnum.PIP_ENABLED: false,
      };

      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
        featureFlags[FeatureFlagEnum.INVITE_ENABLED] = false;
        featureFlags[FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
      if (chatEnabled == false) {
        featureFlags[FeatureFlagEnum.CHAT_ENABLED] = false;
      }

      //if (timerEnabled == false) {
      //  featureFlag.conferenceTimerEnabled = false;
      //}
      if (meetNameEnabled == false) {
        featureFlags[FeatureFlagEnum.MEETING_NAME_ENABLED] = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: hostRoomText.text.replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = hostSubjectText.text
        ..userDisplayName = _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..userAvatarURL = _userPhotoUrl
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": JitsiMeetingOptions(room: hostRoomText.text.replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "")).room,
          "width": "100%",
          "height": "100%",
          "enableWelcomePage": false,
          "chromeExtensionBanner": null,
          "userInfo": {"displayName": _userName}
        };

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
              listener: JitsiMeetingListener(onConferenceWillJoin: (message) {
                Fluttertoast.showToast(
                    msg: 'Starting your meeting...',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                debugPrint("${options.room} will join with message: $message");
              }, onConferenceJoined: (message) async {
                databaseService.updateHosted(_userUid, options.room, options.subject, chatEnabled, liveEnabled, recordEnabled, raiseEnabled, shareYtEnabled, kickEnabled, _userEmail, DateTime.now(), true);
                setState(() {
                  inMeeting = true;
                });
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
                  );
                  final textshare =
                      "${nameText.text} is inviting you to join a Just Meet meeting.  "
                      "\n"
                      "\n"
                      "Meeting Id - ${options.room}  "
                      "\n"
                      "Meeting Topic - ${options.subject}.  "
                      "\n"
                      "\n"
                      "Meeting URL - $dynamicLink  ";
                  copyInvite(textshare);
                } else {}
                debugPrint("${options.room} joined with message: $message");
              }, onConferenceTerminated: (message) {
                databaseService.updateHosted(_userUid, options.room, options.subject, chatEnabled, liveEnabled, recordEnabled, raiseEnabled, shareYtEnabled, kickEnabled, _userEmail, DateTime.now(), false);
                setState(() {
                  inMeeting = false;
                  hostRoomText.text = randomNumeric(11);
                  hostSubjectText.clear();
                });
                Fluttertoast.showToast(
                    msg: 'Meeting Ended By You',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                isEmptyHost();
                adHelper.showInterstitialAd();
                Navigator.pop(context);
                meetFeedback();
                debugPrint("${options.room} terminated with message: $message");
              }, onPictureInPictureWillEnter: (message) {
                Fluttertoast.showToast(
                    msg: 'To return to meeting, open Just Meet',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                debugPrint(
                    "${options.room} entered PIP mode with message: $message");
              }, onPictureInPictureTerminated: (message) {
                debugPrint(
                    "${options.room} exited PIP mode with message: $message");
              }, genericListeners: [
                  JitsiGenericListener(
                  eventName: 'readyToClose',
                  callback: (dynamic message) {
                    debugPrint("readyToClose callback");
                  }),
                ]));
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
          msg: 'Copied invite link to clipboard',
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
              msg: 'No internet connection',
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
              "Meeting URL - $androidUrl  ";
          final RenderBox box = context.findRenderObject();
          Share.share(textshare,
              subject:
                  "${nameText.text} is inviting you to join a Just Meet meeting.  ",
              sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
        }
      }
    }
  }
}
