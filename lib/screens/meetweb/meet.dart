import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:provider/provider.dart';

class Meet extends StatefulWidget {
  final id;
  final topic;
  final name;
  final email;
  final url;
  final uid;
  final type;

  const Meet({Key key,
    this.id,
    this.topic,
    this.name,
    this.email,
    this.url,
    this.uid,
    this.type,
  }) : super(key: key);

  @override
  _MeetState createState() => _MeetState();
}

class _MeetState extends State<Meet> {
  final serverText = TextEditingController();
  bool inMeeting = false;

  DatabaseService databaseService = new DatabaseService();

  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
    Future.delayed(Duration(milliseconds: 500), () {}).then((_) {
      if (widget.type == 'join') {
        _joinMeeting();
    } else if (widget.type == 'host') {
      _hostMeeting();
      } else if (widget.type == 'live') {
        _hostLiveMeeting(widget.id, widget.topic);
      } else {

      }
    });
  }

  @override
  void dispose() {
    JitsiMeet.removeAllListeners();
    //adHelper.adsDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Theme(
      data: themeNotifier.getTheme(),
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            iconTheme: IconThemeData(color: themeNotifier.getTheme() == darkTheme
                ? Colors.white : Colors.black54),
            toolbarHeight: inMeeting == false ? 50 : 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
            icon: Icon(
            Icons.arrow_back_ios_sharp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
          ),
    body: Container(
    child:
      Container(
        width: double.maxFinite,
        child:Card(
              color: Colors.transparent,
              child: SizedBox(
                width: double.maxFinite,
                height: double.maxFinite,
                child: JitsiMeetConferencing(
                  extraJS: [
                    // extraJs setup example
                    '<script>function echo(){console.log("echo!!!")};</script>',
                    '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                  ],
                ),
              )),
        ),
        ),
    ),
    );
  }

  _joinMeeting() async {
    String serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

    setState(() {
      inMeeting = true;
    });

    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };

    var options = JitsiMeetingOptions(room: widget.id)
      ..serverURL = serverUrl
      ..subject = widget.topic
      ..userDisplayName = widget.name
      ..userEmail = widget.email
      ..audioOnly = true
      ..audioMuted = true
      ..videoMuted = true
      ..userAvatarURL = widget.url
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": widget.id,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": '${widget.name}'}
      };

    debugPrint("JitsiMeetingOptions: $options");
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
            Fluttertoast.showToast(
                msg: 'Connecting You to your meeting...',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
            databaseService.addMyJoined(options.room, widget.uid, options.subject, DateTime.now().subtract(Duration(seconds: 2)), widget.name, widget.email, widget.url, 'join');
            Fluttertoast.showToast(
                msg: 'Joined Meeting',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
          },
          onConferenceTerminated: (message) {
            databaseService.participantLeft(widget.uid, options.room);
            debugPrint("${options.room} terminated with message: $message");
            setState(() {
              inMeeting = false;
            });
            Fluttertoast.showToast(
                msg: 'Meeting ended',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),
    );
  }

  _hostMeeting() async {
    String serverUrl =
    serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        ////featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
        FeatureFlagEnum.PIP_ENABLED: false,
      };

      // Define meetings options here
      var options = JitsiMeetingOptions(room: widget.id)
        ..serverURL = serverUrl
        ..subject = widget.topic
        ..userDisplayName = widget.name
        ..userEmail = widget.email
        ..audioOnly = true
        ..audioMuted = true
        ..videoMuted = true
        ..userAvatarURL = widget.url
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": widget.id,
          "width": "100%",
          "height": "100%",
          "enableWelcomePage": false,
          "chromeExtensionBanner": null,
          "userInfo": {"displayName": '${widget.name}'}
        };

      debugPrint("JitsiMeetingOptions: $options");
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
                  databaseService.updateHosted(widget.uid, options.room, options.subject, true, false, false, true, false, false, widget.email, DateTime.now(), true);
                }});

            } catch (e) {
              print(e);
            }
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
            debugPrint("${options.room} joined with message: $message");
          }, onConferenceTerminated: (message) async {
            try {
              await FirebaseFirestore.instance.doc("Users/${widget.uid}/Scheduled/${options.room}").get().then((doc) {
                if (doc.exists) {
                  databaseService.startScheduledHosted(options.room, false);
                } else {
                  databaseService.updateHosted(widget.uid, options.room, options.subject, true, false, false, true, false, false, widget.email, DateTime.now(), false);
                }});

            } catch (e) {
              print(e);
            }
            setState(() {
              inMeeting = false;
            });
            Fluttertoast.showToast(
                msg: 'Meeting Ended By You',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            debugPrint("${options.room} terminated with message: $message");
          }, genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),);
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

  _hostLiveMeeting(String id, String topic) async {
    String serverUrl =
    serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        ////featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
        FeatureFlagEnum.PIP_ENABLED: false,
      };

      var options = JitsiMeetingOptions(room: id)
        ..serverURL = serverUrl
        ..subject = topic
        ..userDisplayName = widget.name
        ..userEmail = widget.email
        ..audioOnly = false
        ..audioMuted = true
        ..videoMuted = true
        ..userAvatarURL = widget.url
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": JitsiMeetingOptions(room: id),
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
            databaseService.addLive(id, widget.email, widget.name, options.subject);
            Fluttertoast.showToast(
                msg: 'Meeting Started',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            debugPrint("${options.room} joined with message: $message");
          }, onConferenceTerminated: (message) {
            databaseService.removeLive(id);
            Fluttertoast.showToast(
                msg: 'Meeting Ended By You',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            debugPrint("${options.room} terminated with message: $message");
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

  _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted");
  }

  _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted");
  }

  _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted");
  }

  _onError(error) {
    debugPrint("_onError broadcasted");
  }
}
