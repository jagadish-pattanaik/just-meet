import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/firebase/ads/admobAds.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveDetails extends StatefulWidget {
  final id;
  final topic;
  final host;
  final ch;
  final raise;
  final record;
  final live;
  final yt;
  final kick;
  final started;
  final name;
  final email;
  final PhotoUrl;
  final uid;

  LiveDetails(
      {Key key,
        @required
        this.id,
        this.topic,
        this.host,
        this.ch,
        this.raise,
        this.record,
        this.live,
        this.yt,
        this.kick,
        this.started,
        this.name,
        this.email,
        this.PhotoUrl,
        this.uid,})
      : super(key: key);

  @override
  _LiveDetailsState createState() => _LiveDetailsState();
}

class _LiveDetailsState extends State<LiveDetails> {
  AdHelper adHelper = new AdHelper();

  final serverText = TextEditingController();

  var isAudioOnly;
  var isAudioMuted;
  var isVideoMuted;
  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isAudioOnly = prefs.getBool('isAudioOnly') ?? true;
        isAudioMuted = prefs.getBool('isAudioMuted') ?? true;
        isVideoMuted = prefs.getBool('isVideoMuted') ?? true;
      });
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

  @override
  void initState() {
    getSettings();
    adHelper.interstitialAdload();
    getDevice();
    getAppInfo();
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
            'Meeting Details',
            style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white : Colors.black54,
            ),
          ),
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
                      title: Text('Meeting Topic'),
                      trailing: Text(widget.topic)),
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
                      title: Text('Hosted by'),
                      trailing: Text(widget.host)),
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
                      title: Text('Started at'),
                      trailing: Text(widget.started + ' UTC',
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
                      width: MediaQuery.of(context).size.width * 0.90,
                      child: RaisedButton(
                          color: Color(0xff0184dc),
                          disabledColor: themeNotifier.getTheme() == darkTheme
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
                              _joinLiveMeeting(widget.id, widget.topic, widget.ch, widget.raise, widget.record, widget.live, widget.yt, widget.kick);
                            }
                          },
                          child: Text('Join',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          )),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ]),
            ),
          ),
        ),
    ),
    );
  }

  _joinLiveMeeting(String id, String topic, bool ch, bool raise, bool record, bool live, bool yt,
      bool kick,) async {
    String serverUrl =
    serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    Map<FeatureFlagEnum, bool> featureFlags = {};
    try {
      if (Platform.isAndroid) {
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
        featureFlags[FeatureFlagEnum.INVITE_ENABLED] = false;
        featureFlags[FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE] = false;
        featureFlags[FeatureFlagEnum.MEETING_PASSWORD_ENABLED] = false;
        featureFlags[FeatureFlagEnum.MEETING_NAME_ENABLED] = true;
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

      if (widget.email == 'jaguweb1234@gmail.com' ||
          widget.email == 'jagadish.pr.pattanaik@gmail.com') {
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
        featureFlags[FeatureFlagEnum.CHAT_ENABLED] = true;
        featureFlags[FeatureFlagEnum.LIVE_STREAMING_ENABLED] = true;
        featureFlags[FeatureFlagEnum.RAISE_HAND_ENABLED] = true;
        featureFlags[FeatureFlagEnum.RECORDING_ENABLED] = false;
        //featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
        //featureFlag.kickOutEnabled = false;
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: id)
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
          "roomName": id,
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
                msg: 'Connecting You to your meeting...',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            debugPrint("${options.room} will join with message: $message");
          }, onConferenceJoined: (message) async {
            //_submitMeetingData(
            //   JitsiMeetingOptions().room, JitsiMeetingOptions().subject);
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
            Fluttertoast.showToast(
                msg: 'Meeting Disconnected',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            adHelper.showInterstitialAd();
            Navigator.of(context).pop();
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

}
