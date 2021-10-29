import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/firebase/ads/admobAds.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:jagu_meet/screens/meeting/settings/joiningSettings.dart';
import 'package:jagu_meet/screens/others/app_feedback.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/cupertinoSwitchListTile.dart';
import 'package:jagu_meet/widgets/loading.dart';
import 'package:jagu_meet/widgets/quiet_box.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;
import 'details/meetDetails.dart';

class Join extends StatefulWidget {
  final name;
  final email;
  final uid;
  final url;
  final id;

  const Join({Key key,
    @required this.name,
    this.email,
    this.uid,
    this.url,
  this.id}) : super(key: key);

  @override
  _JoinState createState() => _JoinState();
}

class _JoinState extends State<Join> {
  final serverText = TextEditingController();
  final roomText = TextEditingController();
  final subjectText = TextEditingController();
  final nameText = TextEditingController();
  final emailText = TextEditingController();

  FocusNode myFocusNode = FocusNode();

  DatabaseService databaseService = new DatabaseService();
  AdHelper adHelper = new AdHelper();

  var isAudioOnly = true;
  var isAudioMuted = true;
  var isVideoMuted = true;
  var timerEnabled = true;
  var meetNameEnabled = true;
  var copyEnabled = true;

  bool isButtonEnabled;

  String _userName;
  String _userEmail;
  var _userUid;
  var _userPhotoUrl;
  getInfo() {
    setState(() {
      _userName = widget.name;
      _userEmail = widget.email;
      _userUid = widget.uid;
      _userPhotoUrl = widget.url;
    });
  }

  isEmpty() {
    if (roomText.text.length >= 10) {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
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
        // Custom dialog styles.
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
                // _submitFeedbackData(stars.toString());
                Navigator.pop(context);
                if (stars <= 3) {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => AppFeedback(
                              userid: _userUid,
                              email: _userEmail,
                              name: _userName)));
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
                color: Color(0xff0184dc)
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

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        timerEnabled = prefs.getBool('timerEnabled') ?? true;
        meetNameEnabled = prefs.getBool('meetNameEnabled') ?? true;
        isAudioOnly = prefs.getBool('isAudioOnly') ?? true;
        isAudioMuted = prefs.getBool('isAudioMuted') ?? true;
        isVideoMuted = prefs.getBool('isVideoMuted') ?? true;
        copyEnabled = prefs.getBool('copyEnabled') ?? true;
      });
    });
    Future.delayed(Duration(milliseconds: 500), () {});
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
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri dynamicUrl = shortDynamicLink.shortUrl;
    return dynamicUrl;
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

  @override
  void initState() {
    isEmpty();
    getInfo();
    adHelper.interstitialAdload();
    if (widget.id != null || widget.id != '') {
      setState(() {
        roomText.text = widget.id;
      });
    }
    super.initState();
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
          'Join a Meeting',
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
                  focusNode: myFocusNode,
                  keyboardType: TextInputType.number,
                  autofocus: false,
                  onChanged: (val) {
                    isEmpty();
                    istyping(roomText);
                    //restrictedIdDetect(roomText);
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp('[0-9]')),
                  ],
                  maxLength: 11,
                  controller: roomText,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      isDense: true,
                      filled: true,
                      contentPadding: const EdgeInsets.only(
                          top: 12.0, bottom: 12, left: 10),
                      suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Visibility(
                              visible: isTyping ? false : true,
                              child: IconButton(
                                onPressed: () {
                                  FocusManager.instance.primaryFocus
                                      .unfocus();
                                  showRecentJoined();
                                },
                                icon: Icon(Icons.keyboard_arrow_down,
                                    size: 30, color: themeNotifier.getTheme() == darkTheme
                                        ? Colors.white : Colors.grey),
                              ),
                            ),
                            Visibility(
                              visible: isTyping,
                              child: IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    roomText.clear();
                                    isEmpty();
                                    istyping(roomText);
                                  }),
                            ),
                          ]),
                    //  errorText:
                    //  restrcitedIdError ? 'Invalid Meeting Id' : null,
                      floatingLabelBehavior:
                      FloatingLabelBehavior.never,
                      fillColor: themeNotifier.getTheme() == darkTheme
                          ? Color(0xFF191919)
                          : Color(0xFFf9f9f9),
                      hintText: 'Meeting Id'),
                ),
                Divider(
                  height: 1,
                  color: themeNotifier.getTheme() == darkTheme
                      ? Color(0xFF303030)
                      : Colors.black12,
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      'Join Options',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ]),
                SizedBox(
                  height: 10.0,
                ),
                Divider(
                  height: 1,
                  color: themeNotifier.getTheme() == darkTheme
                      ? Color(0xFF303030)
                      : Colors.black12,
                ),
                CupertinoSwitchListTile(
                  title: Text(
                    "Audio Muted",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  dense: true,
                  value: isAudioMuted,
                  onChanged: _onAudioMutedChanged,
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
                    "Video Muted",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  dense: true,
                  value: isVideoMuted,
                  onChanged: _onVideoMutedChanged,
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
                  onTap: () => Navigator.push(context,
                      CupertinoPageRoute(builder: (context) => joinSettings())),
                  title: Text(
                    'More Settings',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('Profile picture, Low bandwidth mode', overflow: TextOverflow.ellipsis,),
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
                    onPressed:
                         isButtonEnabled
                        ? () async {
                      String roomTopic;
                      String host;
    bool ch;
    bool rh;
    bool rm;
    bool ls;
    bool yt;
    bool Ko;
    try{
    await FirebaseFirestore.instance.doc("Meetings/${roomText.text}").get().then((doc) async {
    if (doc.exists) {
    await FirebaseFirestore.instance.collection('Meetings').doc(roomText.text).get().then((snapshot) {
    setState(() {
    roomTopic = snapshot.data()['meetName'];
    host = snapshot.data()['host'];
    ch = snapshot.data()['chat'];
    rh = snapshot.data()['raise'];
    rm = snapshot.data()['record'];
    ls = snapshot.data()['live'];
    yt = snapshot.data()['yt'];
    Ko = snapshot.data()['kick'];
    });
    if (host == _userEmail) {
    _hostMeeting(roomTopic, ch, ls, rm, rh, yt, Ko);
    } else {
    if (snapshot.data()['hasStarted'] == true) {
    _joinMeeting(roomTopic, ch, ls, rm, rh, yt, Ko);
    } else {
    _notStarted(roomText.text, roomTopic, ch, ls, rm, rh, yt, Ko);
    }
    }
    });
    } else {
    noMeeting();
    }});
    } catch (e) {
    }
                    } : null,
                    child: Text(
                      "Join",
                      style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xff0184dc)
                        : Colors.blue,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    'If you received an invitation link, tap on the link to join the meeting',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                ]),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  void _notStarted(id, topic, ch, live, record, raise, yt, kick,) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        FirebaseFirestore.instance.collection('Meetings').doc(id).snapshots().listen((querySnapshot) {
          if (querySnapshot.data()['hasStarted'] == true) {
            Navigator.pop(context);
            _joinMeeting(topic, ch, live, record, raise, yt, kick);
          } else {}
        });
        final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
        return Theme(
          data: themeNotifier.getTheme(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 50,
            title: Text("Waiting for the host to start the meeting...",),
            content: CupertinoActivityIndicator(animating: true,),
            actions: [
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.transparent,
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xff0184dc),
                  ),),
              )
            ],
          ),
        );
      },
    );
  }

  void noMeeting() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
        return Theme(
          data: themeNotifier.getTheme(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 25,
            insetPadding: EdgeInsets.all(20),
            title: Text('Invalid meeting ID'),
            content: Text('Please check and try again'),
            actions: [
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.transparent,
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Ok',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xff0184dc),
                  ),),
              )
            ],
          ),
        );
      },
    );
  }

  showRecentJoined() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    goToJoin() {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) =>
                  Join(
                    name: _userName,
                    email: _userEmail,
                    uid: _userUid,
                    url: _userPhotoUrl,
                  )));
    }
    showModalBottomSheet(
        context: context,
        enableDrag: true,
        isDismissible: true,
        elevation: 5,
        isScrollControlled: true,
        backgroundColor: themeNotifier.getTheme() == darkTheme
            ? Color(0xFF242424)
            : Colors.white,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.80,
            decoration: BoxDecoration(
              color: themeNotifier.getTheme() == darkTheme
                  ? Color(0xFF242424)
                  : Colors.white,
            ),
            child: Scaffold(
              backgroundColor: themeNotifier.getTheme() == darkTheme
                  ? Color(0xFF191919)
                  : Colors.white,
              appBar: AppBar(
                iconTheme: themeNotifier.getTheme() == darkTheme
                    ? IconThemeData(color: Colors.white)
                    : IconThemeData(color: Colors.black),
                backgroundColor: themeNotifier.getTheme() == darkTheme
                    ? Color(0xFF191919)
                    : Colors.white,
                elevation: 0,
                bottom: PreferredSize(
                    child: Divider(
                        height: 1,
                        color: themeNotifier.getTheme() == darkTheme
                            ?  Color(0xFF303030) : Colors.black12
                    ),
                    preferredSize: Size(double.infinity, 0.0)) ,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.keyboard_arrow_down_rounded),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  'Recent Meetings',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: themeNotifier.getTheme() == darkTheme
                        ? Colors.white : Colors.black54,
                  ),
                ),
              ),
              body: SafeArea(
                child: Container(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('Users')
                          .doc(_userUid)
                          .collection('Joined').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Loading();
                        }
                        if (snapshot.hasError) {
                          return Loading();
                        }
                        return snapshot.data.docs.length == 0
                            ? QuietBox(
                          heading: "Join",
                          subtitle:
                          "There are no recent joined meetings, join one now",
                          fun: goToJoin,
                        )
                            : Container(
                          height: double.maxFinite,
                          width: double.maxFinite,
                          child: SingleChildScrollView(
                            child: Column(children: [
                              ListView.separated(
                                shrinkWrap: true,
                                itemCount: snapshot.data.docs.length,
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Divider(
                                    height: 1,
                                    color: themeNotifier.getTheme() == darkTheme
                                        ? Color(0xFF242424)
                                        : Colors.black12,
                                    indent: 15,
                                    endIndent: 0,
                                  );
                                },
                                itemBuilder:
                                    (BuildContext context, int position) {
                                  return ListTile(
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    meetDetails(db: 'join',
                                                      id: snapshot.data
                                                          .docs[position]["id"],
                                                      name: widget.name,
                                                      email: widget.email,
                                                      PhotoUrl: widget.url,
                                                      uid: widget.uid,
                                                      time: snapshot.data
                                                          .docs[position]["time"].toDate().toString(),)));
                                      },
                                      visualDensity: VisualDensity(
                                          horizontal: 0, vertical: -4),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.horizontal(
                                              right: Radius.circular(0),
                                              left: Radius.circular(0))),
                                      trailing: Text(
                                        snapshot.data.docs[position]["id"],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: themeNotifier.getTheme() ==
                                              darkTheme
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                      title: Text(
                                        snapshot.data.docs[position]["meetName"],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: themeNotifier.getTheme() ==
                                              darkTheme
                                              ? Colors.white
                                              : Colors.black54,
                                        ),
                                      ),
                                      subtitle: Text(
                                        timeago
                                            .format(DateTime.parse(
                                            snapshot.data.docs[position]["time"].toDate().toString())),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: themeNotifier.getTheme() ==
                                              darkTheme
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                  );
                                },
                              ),
                              Divider(
                                height: 1,
                                color: themeNotifier.getTheme() == darkTheme
                                    ? Color(0xFF303030)
                                    : Colors.black12,
                              ),
                            ]),
                          ),
                        );
                      }),
                ),
              ),
            ),
          );
        });
  }

  _onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isAudioMuted', value);
    });
  }

  _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isVideoMuted', value);
    });
  }
  _joinMeeting(topic, ch, live, record, raise, yt, kick,) async {
    String serverUrl =
    serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    Map<FeatureFlagEnum, bool> featureFlags = {};
    try {
      if (Platform.isAndroid) {
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
        featureFlags[FeatureFlagEnum.INVITE_ENABLED] = false;
        featureFlags[FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE] = false;
        featureFlags[FeatureFlagEnum.MEETING_PASSWORD_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }

      // if (timerEnabled == false) {
      // featureFlag.conferenceTimerEnabled = false;
      //},

      if (meetNameEnabled == false) {
        featureFlags[FeatureFlagEnum.MEETING_NAME_ENABLED] = false;
      }
      if (_userEmail == 'jaguweb1234@gmail.com' ||
          _userEmail == 'jagadish.pr.pattanaik@gmail.com') {
        featureFlags[FeatureFlagEnum.WELCOME_PAGE_ENABLED] = false;
        //featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
        //FeatureFlagEnum.kickOutEnabled = true;
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = true;
        //featureFlag.videoShareButtonEnabled = false;
        featureFlags[FeatureFlagEnum.RAISE_HAND_ENABLED] = true;
        featureFlags[FeatureFlagEnum.RECORDING_ENABLED] = true;
        featureFlags[FeatureFlagEnum.MEETING_PASSWORD_ENABLED] = true;
        featureFlags[FeatureFlagEnum.LIVE_STREAMING_ENABLED] = true;
        featureFlags[FeatureFlagEnum.CHAT_ENABLED] = true;
        if (Platform.isAndroid) {
          featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
          featureFlags[FeatureFlagEnum.INVITE_ENABLED] = false;
          featureFlags[FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE] = false;
        } else if (Platform.isIOS) {
          featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
        }
      } else {
        featureFlags[FeatureFlagEnum.WELCOME_PAGE_ENABLED] = false;
        //featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
        //featureFlag.kickOutEnabled = false;
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }

      if (ch == false) {
        featureFlags[FeatureFlagEnum.CHAT_ENABLED] = false;
      }
      if (live == false) {
        featureFlags[FeatureFlagEnum.LIVE_STREAMING_ENABLED] = false;
      }
      if (record == false) {
        featureFlags[FeatureFlagEnum.RECORDING_ENABLED] = false;
      }
      if (raise == false) {
        featureFlags[FeatureFlagEnum.RAISE_HAND_ENABLED] = false;
      }

      if (yt == false) {
        //featureFlag.videoShareButtonEnabled = false;
      }

      if (kick == true) {
        //featureFlag.kickOutEnabled = true;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: roomText.text
          .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = topic
        ..userDisplayName = _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..userAvatarURL = _userPhotoUrl
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": roomText.text,
          "width": "100%",
          "height": "100%",
          "enableWelcomePage": false,
          "chromeExtensionBanner": null,
          "userInfo": {"displayName": _userName}
        };

      debugPrint("JitsiMeetingOptions: $options");
      if (roomText.text.length >= 10) {
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
                  msg: 'Connecting You to your meeting...',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.SNACKBAR,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
              debugPrint("${options.room} will join with message: $message");
            }, onConferenceJoined: (message) async {
              databaseService.addMyJoined(options.room, widget.uid, options.subject, DateTime.now().subtract(Duration(seconds: 2)), widget.name, widget.email, widget.url, 'join');
              Fluttertoast.showToast(
                  msg: 'Joined Meeting',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.SNACKBAR,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
              debugPrint("${options.room} joined with message: $message");
            }, onConferenceTerminated: (message) {
              databaseService.participantLeft(widget.uid, options.room);
              Fluttertoast.showToast(
                  msg: 'Meeting Disconnected',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.SNACKBAR,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
              isEmpty();
              adHelper.showInterstitialAd();
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
              Fluttertoast.showToast(
                  msg: 'To return to meeting, open Just Meet',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.SNACKBAR,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }, onPictureInPictureTerminated: (message) {
              debugPrint(
                  "${options.room} exited PIP mode with message: $message");
            }, genericListeners: [
              JitsiGenericListener(
                  eventName: 'readyToClose',
                  callback: (dynamic message) {
                    debugPrint("readyToClose callback");
                  }),
            ]),);
        }
      }
    } catch (error) {
      Fluttertoast.showToast(
          msg: "Couldn't Connect You to Your Meeting",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      debugPrint("error: $error");
    }
  }

  _hostMeeting(topic, ch, live, record, raise, yt, kick,) async {
    String serverUrl =
    serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        ////featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
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
      if (ch == false) {
        featureFlags[FeatureFlagEnum.CHAT_ENABLED] = false;
      }

      //if (timerEnabled == false) {
      //  featureFlag.conferenceTimerEnabled = false;
      //}

      if (meetNameEnabled == false) {
        featureFlags[FeatureFlagEnum.MEETING_NAME_ENABLED] = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: roomText.text
          .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = topic
        ..userDisplayName = _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..userAvatarURL = _userPhotoUrl
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": JitsiMeetingOptions(room: roomText.text
              .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "")).room,
          "width": "100%",
          "height": "100%",
          "enableWelcomePage": false,
          "chromeExtensionBanner": null,
          "userInfo": {"displayName": _userName}
        };

      debugPrint("JitsiMeetingOptions: $options");
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
            try {
              await FirebaseFirestore.instance.doc("Users/${widget.uid}/Scheduled/${options.room}").get().then((doc) {
                if (doc.exists) {
                  databaseService.startScheduledHosted(options.room, true);
                } else {
                  databaseService.updateHosted(_userUid, options.room, options.subject, ch, live, record, raise, yt, kick, _userEmail, DateTime.now(), true);
                }});

            } catch (e) {
              print(e);
            }
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
                      RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""),);
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
          }, onConferenceTerminated: (message) async {
            try {
              await FirebaseFirestore.instance.doc("Users/${widget.uid}/Scheduled/${options.room}").get().then((doc) {
                if (doc.exists) {
                  databaseService.startScheduledHosted(options.room, false);
                } else {
                  databaseService.updateHosted(_userUid, options.room, options.subject, ch, live, record, raise, yt, kick, _userEmail, DateTime.now(), false);
                }});

            } catch (e) {
              print(e);
            }
            Fluttertoast.showToast(
                msg: 'Meeting Ended By You',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            adHelper.showInterstitialAd();
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
          ]),);
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
}
