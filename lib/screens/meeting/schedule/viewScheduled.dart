import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:jagu_meet/model/note.dart';
import 'package:jagu_meet/utils/databasehelper_scheduled.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:package_info/package_info.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme.dart';
import '../../theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'NoteScreen.dart';
import 'package:intl/intl.dart';
//import 'package:jagu_meet/sever_db/host meets db/host controller.dart';
//import 'package:jagu_meet/sever_db/host meets db/host meet db.dart';
import 'package:flutter/foundation.dart';

class viewScheduled extends StatefulWidget {
  final num;
  final name;
  final email;
  final PhotoUrl;
  final uid;
  List items;
  viewScheduled(
      {Key key,
      @required this.num,
      @required this.items,
      this.name,
      this.email,
      this.PhotoUrl,
      this.uid})
      : super(key: key);

  @override
  _viewScheduledState createState() => _viewScheduledState();
}

class _viewScheduledState extends State<viewScheduled> {
  DatabaseHelper2 db2 = new DatabaseHelper2();
  var name;
  var useAvatar;
  var copyEnabled;
  var isAudioOnly;
  var isAudioMuted;
  var isVideoMuted;
  var timerEnabled;
  var meetNameEnabled;

  final serverText = TextEditingController();

  var webLink = 'meet.jit.si/';

  List<Note2> items2 = [];

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

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isAudioOnly = prefs.getBool('isAudioOnly') ?? true;
        isAudioMuted = prefs.getBool('isAudioMuted') ?? true;
        isVideoMuted = prefs.getBool('isVideoMuted') ?? true;
        timerEnabled = prefs.getBool('timerEnabled') ?? true;
        meetNameEnabled = prefs.getBool('meetNameEnabled') ?? true;

        copyEnabled = prefs.getBool('copyEnabled') ?? true;
        useAvatar = prefs.getBool('useAvatar') ?? true;
      });
    });
  }

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
    }
  }

  //final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  //Position _currentPosition;
  //String _currentAddress;

  //_getCurrentLocation() {
  //geolocator
  //.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
  //.then((Position position) {
  //setState(() {
  //_currentPosition = position;
  //});
//
  //_getAddressFromLatLng();
  //}).catchError((e) {
  //print(e);
  //});
  //}

  //_getAddressFromLatLng() async {
  //try {
  //List<Placemark> p = await geolocator.placemarkFromCoordinates(
  //_currentPosition.latitude, _currentPosition.longitude);
//
  //Placemark place = p[0];
//
  //setState(() {
  //_currentAddress =
  //"${place.locality}, ${place.postalCode}, ${place.country}";
  //});
  //} catch (e) {
  //print(e);
  //}
  //}

  //Future<void> _submitMeetingData(String meetid, String meettopic) async {
  //String external = await FlutterIp.externalIP;
  //String internal = await FlutterIp.internalIP;
  //_getCurrentLocation();
  //HostMeetingsDb hostMeetingsDb = HostMeetingsDb(meetid, meettopic,
  //widget.email, name, _currentAddress, internal, external);
//
  //HostServerController hostServerController =
  //HostServerController((String response) {
  //print(response);
  //});
  //hostServerController.submitHostData(hostMeetingsDb);
  //}

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
                    ? Color(0xff0184dc)
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
                          'user id: ${widget.uid} .  '
                          '\n'
                          'email: ${widget.email} .  '
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

  getList() async {
    setState(() {
      items2 = widget.items;
    });
  }

  getInfo() {
    setState(() {
      name = widget.name;
    });
  }

  final now = DateTime.now();
  var dateFormat = new DateFormat('dd, MMM yyyy');

  @override
  void initState() {
    super.initState();
    getList();
    getSettings();
    getInfo();
    getDevice();
    getAppInfo();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    getList();
    var time = DateFormat.jm()
        .format(DateFormat("hh:mm").parse(items2[widget.num].from2));
    var timeTo = DateFormat.jm()
        .format(DateFormat("hh:mm").parse(items2[widget.num].to2));
    DateTime tomorrow = now.add(Duration(days: 1));
    DateTime daytomorrow = now.add(Duration(days: 2));
    String formattedDate =
        dateFormat.format(DateTime.parse(items2[widget.num].date2));
    var finalDate;
    if (DateTime.parse(items2[widget.num].date2).day == now.day &&
        DateTime.parse(items2[widget.num].date2).month == now.month &&
        DateTime.parse(items2[widget.num].date2).year == now.year) {
      finalDate = 'Today';
    } else if ((DateTime.parse(items2[widget.num].date2).day == tomorrow.day &&
        DateTime.parse(items2[widget.num].date2).month == tomorrow.month &&
        DateTime.parse(items2[widget.num].date2).year == tomorrow.year)) {
      finalDate = 'Tomorrow';
    } else if ((DateTime.parse(items2[widget.num].date2).day ==
            daytomorrow.day &&
        DateTime.parse(items2[widget.num].date2).month == daytomorrow.month &&
        DateTime.parse(items2[widget.num].date2).year == daytomorrow.year)) {
      finalDate = 'Day After Tomorrow';
    } else {
      finalDate = formattedDate;
    }
    return MaterialApp(
      theme: themeNotifier.getTheme(),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xFF242424)
              : Colors.blue,
          elevation: 5,
          title: const Text(
            'Meeting Details',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  _deleteNote2(context, items2[widget.num], widget.num);
                  Navigator.pop(context);
                })
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 5,
          onPressed: () => _navigateToNote(context, items2[widget.num]),
          label: Text('Edit',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          icon: Icon(Icons.edit,
              color: Colors.white),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xff0184dc)
              : Colors.blue,
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
                      trailing: Text(items2[widget.num].description2),
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
                      trailing: Text(items2[widget.num].title2),
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
                      title: Text('When'),
                      trailing: Text(finalDate),
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
                      title: Text('From'),
                      trailing: Text(time),
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
                      title: Text('To'),
                      trailing: Text(timeTo),
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
                      title: Text('Repeat'),
                      trailing: Text(items2[widget.num].repeat),
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
                          color: themeNotifier.getTheme() == darkTheme
                              ? Color(0xff0184dc)
                              : Colors.blue,
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
                              ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
                            } else {
                              var dynamicLink = await createDynamicLink(
                                meet: items2[widget.num].description2.replaceAll(
                                    RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                    ""),
                                sub: '${items2[widget.num].title2}',
                                ch: items2[widget.num].chatEnabled2.toString(),
                                rh: items2[widget.num].raiseEnabled2.toString(),
                                rm: items2[widget.num]
                                    .recordEnabled2
                                    .toString(),
                                ls: items2[widget.num].liveEnabled2.toString(),
                                yt: items2[widget.num]
                                    .shareYtEnabled2
                                    .toString(),
                                ko: items2[widget.num]
                                    .kickOutEnabled2
                                    .toString(),
                                host: widget.email,
                              );
                              var dynamicWeb = webLink +
                                  items2[widget.num].description2.replaceAll(
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
                                _shareScheduledMeeting(
                                    '${items2[widget.num].description2}',
                                    '${items2[widget.num].title2}',
                                    dynamicLink.toString(),
                                    dynamicWeb,
                                    finalDate,
                                    time,
                                    timeTo);
                              }
                              if (action == DialogAction.no) {
                                useAvatar == true
                                    ? _hostScheduledMeeting()
                                    : _hostScheduledMeetingNoAvatar();
                              }
                            }
                          },
                          child: Text(
                            'Start Meeting',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          )),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width * 0.90,
                      child: RaisedButton(
                          color: themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF242424)
                              : Colors.grey,
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
                                  msg: 'No Internet Connection!',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.SNACKBAR,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else {
                              var dynamicLink = await createDynamicLink(
                                meet: items2[widget.num].description2.replaceAll(
                                    RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                    ""),
                                sub: '${items2[widget.num].title2}',
                                ch: items2[widget.num].chatEnabled2.toString(),
                                rh: items2[widget.num].raiseEnabled2.toString(),
                                rm: items2[widget.num]
                                    .recordEnabled2
                                    .toString(),
                                ls: items2[widget.num].liveEnabled2.toString(),
                                yt: items2[widget.num]
                                    .shareYtEnabled2
                                    .toString(),
                                ko: items2[widget.num]
                                    .kickOutEnabled2
                                    .toString(),
                                host: widget.email,
                              );
                              var dynamicWeb = webLink +
                                  items2[widget.num].description2.replaceAll(
                                      RegExp(
                                          r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                      "");
                              _shareScheduledMeeting(
                                  '${items2[widget.num].description2}',
                                  '${items2[widget.num].title2}',
                                  dynamicLink.toString(),
                                  dynamicWeb,
                                  finalDate,
                                  time,
                                  timeTo);
                            }
                          },
                          child: Text(
                            'Invite Others',
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

  _hostScheduledMeeting() async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        FeatureFlagEnum.PIP_ENABLED: false,
        //FeatureFlagEnum. = FeatureFlagVideoResolution.HD_RESOLUTION,
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
      if (items2[widget.num].chatEnabled2 == false) {
        featureFlags[FeatureFlagEnum.CHAT_ENABLED] = false;
      }

      //if (timerEnabled == false) {
      //  featureFlag.conferenceTimerEnabled = false;
      //}
      if (meetNameEnabled == false) {
        featureFlags[FeatureFlagEnum.MEETING_NAME_ENABLED] = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: items2[widget.num]
          .description2
          .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = items2[widget.num].title2
        ..userDisplayName = widget.name
        ..userEmail = widget.email
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..userAvatarURL = widget.PhotoUrl
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": items2[widget.num].description2,
          "width": "100%",
          "height": "100%",
          "enableWelcomePage": false,
          "chromeExtensionBanner": null,
          "userInfo": {"displayName": widget.name}
        };

      debugPrint("JitsiMeetingOptions: $options");
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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
                ch: items2[widget.num].chatEnabled2.toString(),
                rh: items2[widget.num].raiseEnabled2.toString(),
                rm: items2[widget.num].recordEnabled2.toString(),
                ls: items2[widget.num].liveEnabled2.toString(),
                yt: items2[widget.num].shareYtEnabled2.toString(),
                ko: items2[widget.num].kickOutEnabled2.toString(),
                host: widget.email,
              );
              var dynamicWeb = webLink +
                  options.room.replaceAll(
                      RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "");
              final textshare =
                  "${widget.name.text} is inviting you to join a Just Meet meeting.  "
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
            //_submitMeetingData(
            //   items2[widget.num].description2, items2[widget.num].title2);
            debugPrint("${options.room} joined with message: $message");
          }, onConferenceTerminated: (message) {
            Fluttertoast.showToast(
                msg: 'Meeting Ended By You',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
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

  _hostScheduledMeetingNoAvatar() async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        FeatureFlagEnum.PIP_ENABLED: false,
        //FeatureFlagEnum. = FeatureFlagVideoResolution.HD_RESOLUTION,
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
      if (items2[widget.num].chatEnabled2 == false) {
        featureFlags[FeatureFlagEnum.CHAT_ENABLED] = false;
      }

      //if (timerEnabled == false) {
      //  featureFlag.conferenceTimerEnabled = false;
      //}
      if (meetNameEnabled == false) {
        featureFlags[FeatureFlagEnum.MEETING_NAME_ENABLED] = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: items2[widget.num]
          .description2
          .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = items2[widget.num].title2
        ..userDisplayName = widget.name
        ..userEmail = widget.email
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..userAvatarURL = widget.PhotoUrl
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": items2[widget.num].description2,
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
                ch: items2[widget.num].chatEnabled2.toString(),
                rh: items2[widget.num].raiseEnabled2.toString(),
                rm: items2[widget.num].recordEnabled2.toString(),
                ls: items2[widget.num].liveEnabled2.toString(),
                yt: items2[widget.num].shareYtEnabled2.toString(),
                ko: items2[widget.num].kickOutEnabled2.toString(),
                host: widget.email,
              );
              var dynamicWeb = webLink +
                  options.room.replaceAll(
                      RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "");
              final textshare =
                  "${widget.name.text} is inviting you to join a Just Meet meeting.  "
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
            // _submitMeetingData(
            //    items2[widget.num].description2, items2[widget.num].title2);
            debugPrint("${options.room} joined with message: $message");
          }, onConferenceTerminated: (message) {
            Fluttertoast.showToast(
                msg: 'Meeting Ended By You',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
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

  copyInvite(inviteText) {
    Clipboard.setData(new ClipboardData(text: inviteText)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('Copied invite link to clipboard',)));
    });
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

  _shareScheduledMeeting(String roomids, String topics, String androidUrl,
      String url, String date, String from, String to) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
    } else {
      final textshare =
          "$name is inviting you to join a scheduled Just Meet meeting.  "
          "\n"
          "\n"
          "Time: $date, from $from to $to"
          "\n"
          "\n"
          "Meeting Id: $roomids.  "
          "\n"
          "\n"
          "Meeting Topic: $topics.  "
          "\n"
          "\n"
          "Android Meeting URL: $androidUrl  "
          "\n"
          "\n"
          "iOS and PC Meeting URL: $url ";
      final RenderBox box = context.findRenderObject();
      Share.share(textshare,
          subject: "$name is inviting you to join a Just Meet meeting.  "
              "\n"
              "\n"
              "Time: $date, from $from to $to"
              "\n"
              "\n"
              "Meeting Id: $roomids.  "
              "\n"
              "\n"
              "Meeting Topic: $topics.  "
              "\n"
              "\n"
              "Android Meeting URL: $androidUrl  "
              "\n"
              "\n"
              "iOS and PC Meeting URL: $url ",
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  void _deleteNote2(BuildContext context, Note2 note2, int position) async {
    db2.deleteNote2(note2.id2).then((notes2) {
      setState(() {
        items2.removeAt(position);
      });
    });
  }

  void _navigateToNote(BuildContext context, Note2 note2) async {
    String result = await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => NoteScreen(note2)),
    );

    if (result == 'update') {
      db2.getAllNotes2().then((notes2) {
        setState(() {
          items2.clear();
          notes2.forEach((note2) {
            items2.add(Note2.fromMap(note2));
          });
        });
      });
    }
  }
}
