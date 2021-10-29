import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jagu_meet/firebase/ads/admobAds.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:jagu_meet/screens/meeting/people/invcoblockshare.dart';
import 'package:jagu_meet/screens/meeting/people/participants.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:jagu_meet/widgets/loading.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;

class meetDetails extends StatefulWidget {
  final db;
  final id;
  final name;
  final email;
  final PhotoUrl;
  final uid;
  final time;
  meetDetails(
      {Key key,
        @required
        this.db,
        this.id,
        this.name,
        this.email,
        this.PhotoUrl,
        this.uid,
      this.time,})
      : super(key: key);

  @override
  _meetDetailsState createState() => _meetDetailsState();
}

class _meetDetailsState extends State<meetDetails> {
  final serverText = TextEditingController();

  var copyEnabled;
  var isAudioOnly;
  var isAudioMuted;
  var isVideoMuted;
  var timerEnabled;
  var meetNameEnabled;

  bool inMeeting = false;

  DatabaseService databaseService = new DatabaseService();
  AdHelper adHelper = new AdHelper();

  @override
  void initState() {
    super.initState();
    getSettings();
    adHelper.interstitialAdload();
    getDevice();
    getAppInfo();
  }

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isAudioOnly = prefs.getBool('isAudioOnly') ?? true;
        isAudioMuted = prefs.getBool('isAudioMuted') ?? true;
        isVideoMuted = prefs.getBool('isVideoMuted') ?? true;
        timerEnabled = prefs.getBool('timerEnabled') ?? true;
        meetNameEnabled = prefs.getBool('meetNameEnabled') ?? true;

        copyEnabled = prefs.getBool('copyEnabled') ?? true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Theme(
      data: themeNotifier.getTheme(),
      child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Meetings').doc(widget.id).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Loading();
            }
            if (snapshot.hasError) {
              return Loading();
            }
            var meetDoc = snapshot.data;
            var id = meetDoc['id'];
            var topic = meetDoc['meetName'];
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_sharp,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                iconTheme: IconThemeData(
                    color: themeNotifier.getTheme() == darkTheme
                        ? Colors.white : Colors.black54),
                backgroundColor: themeNotifier.getTheme() == darkTheme
                    ? Color(0xff0d0d0d)
                    : Color(0xffffffff),
                elevation: 0,
                bottom: PreferredSize(
                    child: Divider(
                        height: 1,
                        color: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF303030) : Colors.black12
                    ),
                    preferredSize: Size(double.infinity, 0.0)),
                title: Text(
                  'Meeting Details',
                  style: TextStyle(
                    color: themeNotifier.getTheme() == darkTheme
                        ? Colors.white : Colors.black54,
                  ),
                ),
                actions: [
                  widget.db == 'host'
                      ? IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.share,
                        color: themeNotifier.getTheme() == darkTheme
                            ? Colors.white : Colors.black54,
                      ),
                      onPressed: () async {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => ShareInviteBlock(uid: widget.uid, email: widget.email, name: widget.name, photoUrl: widget.PhotoUrl, meetId: widget.id, meetName: topic,)));
                      }) : Container(),
                ],
              ),
              body: SafeArea(
                child: Container(
                  height: double.maxFinite,
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          ListTile(
                            tileColor: themeNotifier.getTheme() == darkTheme
                                ? Color(0xFF191919)
                                : Color(0xFFf9f9f9),
                            title: Text('Meeting Id'),
                            trailing: Text(id),
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
                            title: Text('Meeting Topic'),
                            trailing: Text(topic),
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
                            title: Text(widget.db == 'host'
                                ? 'Hosted'
                                : 'Joined'),
                            trailing: Text(timeago
                                .format(DateTime.parse(widget.time))
                                .toString(),
                              overflow: TextOverflow.ellipsis,),
                          ),
                          Divider(
                            height: 1,
                            color: themeNotifier.getTheme() == darkTheme
                                ? Color(0xFF303030)
                                : Colors.black12,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: 50.0,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.90,
                            child: RaisedButton(
                                color: Color(0xff0184dc),
                                disabledColor: themeNotifier.getTheme() ==
                                    darkTheme
                                    ? Color(0xFF242424)
                                    : Colors.grey,
                                elevation: 5,
                                disabledElevation: 0,
                                disabledTextColor:
                                themeNotifier.getTheme() == darkTheme
                                    ? Colors.grey
                                    : Colors.white,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                onPressed: () async {
                                  var connectivityResult =
                                  await (Connectivity().checkConnectivity());
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
                                    if (widget.db == 'host') {
                                        _hostRecentMeeting(
                                      id, topic,
                                        meetDoc['chat'],
                                        meetDoc['live'],
                                        meetDoc['raise'],
                                        meetDoc['record'],
                                        meetDoc['yt'],
                                        meetDoc['kick']);
                                        } else {
    await FirebaseFirestore.instance.doc("Meetings/$id").get().then((doc) async {
    if (doc.exists) {
                                      if (meetDoc['hasStarted'] == true) {
                                      _joinRecentMeeting(
                                        id, topic,
                                        meetDoc['chat'],
                                      meetDoc['live'],
                                      meetDoc['raise'],
                                      meetDoc['record'],
                                      meetDoc['yt'],
                                      meetDoc['kick'],);
            } else {
                                        _notStarted(id, topic, meetDoc['chat'],
                                            meetDoc['live'],
                                            meetDoc['record'],
                                            meetDoc['raise'],
                                            meetDoc['yt'],
                                            meetDoc['kick']);
                                      }
                                  }
    });
            }
                                }
    },
                                child: Text(
                                  widget.db == 'host'
                                      ? 'Start Meeting'
                                      : 'Rejoin',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          widget.db == 'host'
                              ?
                          SizedBox(
                            height: 50.0,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.90,
                            child: OutlineButton(
                                color: Colors.transparent,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                borderSide: BorderSide(
                                  color: Color(0xff0184dc),
                                ),
                                onPressed: () async {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => Participants(uid: widget.uid, name: widget.name, email: widget.email, id: id, topic: topic,)));
                                  },
                                child: Text(
                                  'Participants',
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Color(0xff0184dc),
                                      fontWeight: FontWeight.bold),
                                )),
                          ) : Container(),
                          widget.db == 'host' ? SizedBox(
                            height: 30,
                          ) : SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 50.0,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.90,
                            child: RaisedButton(
                                color: Colors.red,
                                disabledColor: themeNotifier.getTheme() ==
                                    darkTheme
                                    ? Color(0xFF242424)
                                    : Colors.grey,
                                elevation: 5,
                                disabledElevation: 0,
                                disabledTextColor:
                                themeNotifier.getTheme() == darkTheme
                                    ? Colors.grey
                                    : Colors.white,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                onPressed: () async {
                                  if (widget.db == 'host') {
                                  final action = await Dialogs.redAlertDialog(
                                      context,
                                      'Release Meeting',
                                      'Do you really want to release your meeting? Your meeting will be deleted forever and you will no more own it',
                                      'Release',
                                      'Cancel');
                                  if (action == DialogAction.yes) {
                                    databaseService.removeMyHosted(id, widget.uid);
                                    adHelper.showInterstitialAd();
                                    Navigator.of(context).pop();
                                  }
                                  if (action == DialogAction.abort) {}
                                  } else {
                                    final action = await Dialogs.redAlertDialog(
                                        context,
                                        'Delete Meeting',
                                        'Do You Really want to delete this meeting from your recent joined list?',
                                        'Delete',
                                        'Cancel');
                                    if (action == DialogAction.yes) {
                                      databaseService.removeMyJoined(id, widget.uid);
                                      adHelper.showInterstitialAd();
                                      Navigator.of(context).pop();
                                    }
                                    if (action == DialogAction.abort) {}
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(
                                  widget.db == 'host' ? 'Release' : 'Delete',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                        ]),
                  ),
                ),
              ),
            );
          }),
    );
  }

  void _notStarted(id, topic, ch, live, record, raise, yt, kick) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        FirebaseFirestore.instance.collection('Meetings').doc(id).snapshots().listen((querySnapshot) {
          if (querySnapshot.data()['hasStarted'] == true) {
            Navigator.pop(context);
            _joinRecentMeeting(id, topic, ch, live, record, raise, yt, kick);
          } else {}
        });
        final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
        return Theme(
          data: themeNotifier.getTheme(),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 50,
            insetPadding: EdgeInsets.all(20),
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

  _joinRecentMeeting(id, topic, bool ch, bool live, bool raise, bool record, bool yt,
      bool kick) async {
    String serverUrl =
    serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        //featureFlag.kickOutEnabled = false;
        //featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
        FeatureFlagEnum.PIP_ENABLED: false,
      };

      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
        featureFlags[FeatureFlagEnum.INVITE_ENABLED] = false;
        featureFlags[FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE] = false;
        featureFlags[FeatureFlagEnum.MEETING_PASSWORD_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
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

      //if (timerEnabled == false) {
      //  featureFlag.conferenceTimerEnabled = false;
      //}
      if (meetNameEnabled == false) {
        featureFlags[FeatureFlagEnum.MEETING_NAME_ENABLED] = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: id
          .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = topic
        ..userDisplayName = widget.name
        ..userEmail = widget.email
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..userAvatarURL = widget.PhotoUrl
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": JitsiMeetingOptions(room: id
              .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "")).room,
          "width": "100%",
          "height": "100%",
          "enableWelcomePage": false,
          "chromeExtensionBanner": null,
          "userInfo": {"displayName": widget.name}
        };

      debugPrint("JitsiMeetingOptions: $options");
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
            databaseService.addMyJoined(options.room, widget.uid, options.subject, DateTime.now().subtract(Duration(seconds: 2)), widget.name, widget.email, widget.PhotoUrl, 'join');
            setState(() {
              inMeeting = true;
            });
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
            setState(() {
              inMeeting = false;
            });
            Fluttertoast.showToast(
                msg: 'Meeting Disconnected',
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

  _hostRecentMeeting(id, topic, bool ch, bool live, bool raise, bool record, bool yt,
      bool kick) async {
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
      var options = JitsiMeetingOptions(room: id
          .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = topic
        ..userDisplayName = widget.name
        ..userEmail = widget.email
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..userAvatarURL = widget.PhotoUrl
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": JitsiMeetingOptions(room: id
              .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "")).room,
          "width": "100%",
          "height": "100%",
          "enableWelcomePage": false,
          "chromeExtensionBanner": null,
          "userInfo": {"displayName": widget.name}
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
            setState(() {
              inMeeting = true;
            });
            try {
              await FirebaseFirestore.instance.doc("Users/${widget.uid}/Scheduled/${options.room}").get().then((doc) {
                if (doc.exists) {
                  databaseService.startScheduledHosted(options.room, true);
                  databaseService.addMyHosted(options.room, options.subject, widget.uid, DateTime.now());
                } else {
                  databaseService.updateHosted(widget.uid, options.room, options.subject, ch, live, record, raise, yt, kick, widget.email, DateTime.now(), true);
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
                  "${widget.name} is inviting you to join a Just Meet meeting.  "
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
            setState(() {
              inMeeting = false;
            });
            try {
              await FirebaseFirestore.instance.doc("Users/${widget.uid}/Scheduled/${options.room}").get().then((doc) {
                if (doc.exists) {
                  databaseService.startScheduledHosted(options.room, false);
                } else {
                  databaseService.updateHosted(widget.uid, options.room, options.subject, ch, live, record, raise, yt, kick, widget.email, DateTime.now(), false);
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

  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 2,
    minLaunches: 5,
    remindDays: 5,
    remindLaunches: 10,
    googlePlayIdentifier: 'com.jaguweb.jagu_meet',
  );

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
                          'app version: $version .  '
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
