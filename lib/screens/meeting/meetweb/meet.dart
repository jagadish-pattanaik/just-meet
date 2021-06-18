import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  const Meet({Key key,
    this.id,
    this.topic,
    this.name,
    this.email,
    this.url
  }) : super(key: key);

  @override
  _MeetState createState() => _MeetState();
}

class _MeetState extends State<Meet> {
  final serverText = TextEditingController();
  bool inMeeting = false;

  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
    Future.delayed(Duration(milliseconds: 500), () {}).then((_) => _joinMeeting());
  }

  @override
  void dispose() {
    JitsiMeet.removeAllListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return MaterialApp(
      title: 'Just Meet | Meeting',
        theme: themeNotifier.getTheme(),
        home: Scaffold(
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
