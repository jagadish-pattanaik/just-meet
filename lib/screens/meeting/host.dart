import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/model/note.dart';
import 'package:jagu_meet/screens/meeting/settings/hostingSettings.dart';
//import 'package:jagu_meet/sever_db/host meets db/host controller.dart';
//import 'package:jagu_meet/sever_db/host meets db/host meet db.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/utils/host_db_helper.dart';
import 'package:jagu_meet/widgets/cupertinoSwitchListTile.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:jagu_meet/widgets/quiet_box.dart';
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
import 'package:timeago/timeago.dart' as timeago;

import 'meetDetails.dart';

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

  List<Note1> items1 = [];

  FocusNode myFocusNode2 = FocusNode();
  FocusNode myFocusNode3 = FocusNode();

  //AnimationController animecontroller;

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

  bool isEnabled;
  bool inMeeting = false;

  String _userName;
  String _userEmail;
  var _userUid;
  var _userPhotoUrl;

  var webLink = 'meet.jit.si/';

  String version = '.';

  DatabaseHelper1 db1 = new DatabaseHelper1();
  initDB() {
    db1.getAllNotes1().then((notes1) {
      setState(() {
        notes1.forEach((note1) {
          items1.add(Note1.fromMap(note1));
        });
      });
    });
  }

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
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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
              overflow: TextOverflow.ellipsis,
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
    initDB();
    isEmptyHost();
   // animecontroller =
  //      BottomSheet.createAnimationController(this);
   // animecontroller.duration = Duration(seconds: 1);
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
  //_userEmail, _userName, _currentAddress, internal, external);
//
  //HostServerController hostServerController =
  //HostServerController((String response) {
  //print(response);
  //});
  //hostServerController.submitHostData(hostMeetingsDb);
  //}

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    nameText.text = _userName;
    emailText.text = _userEmail;
    getSettings();
    return MaterialApp(
      title: 'Just Meet',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.getTheme(),
      home: Scaffold(
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
                        suffixIcon: IconButton(
                            onPressed: () {
                              FocusManager.instance.primaryFocus
                                  .unfocus();
                              showRecentHosted();
                            },
                            icon: Icon(Icons.keyboard_arrow_down,
                                size: 30, color: themeNotifier.getTheme() == darkTheme
                                    ? Colors.white : Colors.grey),
                          ),
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
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
                                    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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
                          ? Color(0xff0184dc)
                          : Colors.blue,
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

  void _deleteNote(BuildContext context, Note1 note1, int position) async {
    db1.deleteNote1(note1.id1).then((notes) {
      setState(() {
        items1.removeAt(position);
      });
    });
  }

  clearDB() async {
    for (var i = 0; i < items1.length; i++) {
      _deleteNote(context, items1[i], i);
    }
    await Future.delayed(Duration(milliseconds: 1000));
    _deleteNote(context, items1[0], 0);
  }

  showRecentHosted() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    showModalBottomSheet(
        context: context,
        enableDrag: true,
        isDismissible: true,
        elevation: 5,
        isScrollControlled: true,
        //transitionAnimationController: animecontroller,
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
                    ? Color(0xff0d0d0d)
                    : Color(0xFFFFFFFF),
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
                actions: [
                  items1.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      clearDB();
                    },
                    icon: Icon(
                      Icons.auto_delete_outlined,
                      color: Colors.red,
                    ),
                  )
                      : Container(),
                ],
                title: Text(
                  'Your Meetings',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: themeNotifier.getTheme() == darkTheme
                        ? Colors.white : Colors.black54,
                  ),
                ),
              ),
              body: SafeArea(
                child: Container(
                  child: items1.isEmpty
                      ? QuietBox(
                    heading: "This is where all your recently hosted meetings are listed",
                    subtitle:
                    "There are no recently hosted meetings, host one now",
                  )
                      : Container(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        ListView.separated(
                          shrinkWrap: true,
                          itemCount: items1.length,
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
                            return Dismissible(
                              background: Container(
                                color: Colors.blue,
                                child: Align(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Icon(
                                        Icons.videocam,
                                        color: Colors.white,
                                      ),
                                      Text(" Start",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                child: Align(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: <Widget>[
                                      Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        " Delete",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.centerRight,
                                ),
                              ),
                              key: Key(items1[position].description1),
                              onDismissed: (direction) {
                                if (direction ==
                                    DismissDirection.endToStart) {
                                  _deleteNote(
                                      context, items1[position], position);
                                } else {
                                  setState(() {
                                    hostRoomText.text =
                                    '${items1[position].description1}';
                                    hostSubjectText.text =
                                    '${items1[position].title1}';
                                  });
                                  isEmptyHost();
                                  Navigator.of(context,
                                      rootNavigator: true)
                                      .pop();
                                _hostRecentMeeting(
                                      items1[position].chatEnabled1 == 1
                                          ? true
                                          : false,
                                      items1[position].liveEnabled1 == 1
                                          ? true
                                          : false,
                                      items1[position].raiseEnabled1 ==
                                          1
                                          ? true
                                          : false,
                                      items1[position].recordEnabled1 ==
                                          1
                                          ? true
                                          : false,
                                      items1[position]
                                          .shareYtEnabled1 ==
                                          1
                                          ? true
                                          : false,
                                      items1[position]
                                          .kickOutEnabled1 ==
                                          1
                                          ? true
                                          : false,);
                                }
                              },
                              child: ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => meetDetails(db: 'host', num: position, name: widget.name, email: widget.email, PhotoUrl: widget.url, uid: widget.uid, items: items1,)));
                                },
                                visualDensity: VisualDensity(
                                    horizontal: 0, vertical: -4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(0),
                                        left: Radius.circular(0))),
                                trailing: Text(
                                  items1[position].title1 == ''
                                      ? ''
                                      : '${items1[position].description1}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: themeNotifier.getTheme() ==
                                        darkTheme
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  items1[position].title1 == ''
                                      ? '${items1[position].description1}'
                                      : '${items1[position].title1}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: themeNotifier.getTheme() ==
                                        darkTheme
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  timeago
                                      .format(DateTime.parse(
                                      items1[position].time1))
                                      .toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: themeNotifier.getTheme() ==
                                        darkTheme
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
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
                  ),
                ),
              ),
            ),
          );
        });
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
                for (var i = 0; i < items1.length; i++) {
                  if (items1[i].description1 != options.room) {
                  } else {
                    _deleteNote(context, items1[i], i);
                  }
                }
                db1.saveNote1(Note1(
                  hostSubjectText.text,
                  hostRoomText.text,
                  DateTime.now().toString(),
                  chatEnabled == true ? 1 : 0,
                  liveEnabled == true ? 1 : 0,
                  recordEnabled == true ? 1 : 0,
                  raiseEnabled == true ? 1 : 0,
                  shareYtEnabled == true ? 1 : 0,
                  kickEnabled == true ? 1 : 0,));
                db1.getAllNotes1().then((notes1) {
                  setState(() {
                    items1.clear();
                    notes1.forEach((note1) {
                      items1.add(Note1.fromMap(note1));
                    });
                  });
                });
                debugPrint("${options.room} joined with message: $message");
              }, onConferenceTerminated: (message) {
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
                isEmptyHost();
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
              // by default, plugin default constraints are used
              //roomNameConstraints: new Map(), // to disable all constraints
              //roomNameConstraints: customContraints, // to use your own constraint(s)
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

  _hostRecentMeeting(bool ch, bool live, bool raise, bool record, bool yt,
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
      var options = JitsiMeetingOptions(room: hostRoomText.text
          .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = hostSubjectText.text ?? 'Just Meet'
        ..userDisplayName = _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..userAvatarURL = _userPhotoUrl
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": JitsiMeetingOptions(room: hostRoomText.text
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
                  sub: options.subject,
                  ch: ch.toString(),
                  rh: raise.toString(),
                  rm: record.toString(),
                  ls: live.toString(),
                  yt: yt.toString(),
                  ko: kick.toString(),
                  host: _userEmail);
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
            for (var i = 0; i < items1.length; i++) {
              if (items1[i].description1 != options.room) {
              } else {
                _deleteNote(context, items1[i], i);
              }
            }
            db1.saveNote1(Note1(
              hostSubjectText.text,
              hostRoomText.text,
              DateTime.now().toString(),
              ch == true ? 1 : 0,
              live == true ? 1 : 0,
              record == true ? 1 : 0,
              raise == true ? 1 : 0,
              yt == true ? 1 : 0,
              kick == true ? 1 : 0,));
            db1.getAllNotes1().then((notes1) {
              setState(() {
                items1.clear();
                notes1.forEach((note1) {
                  items1.add(Note1.fromMap(note1));
                });
              });
            });
            debugPrint("${options.room} joined with message: $message");
          }, onConferenceTerminated: (message) {
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

  _hostMeetingNoAvatar() async {
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
      var options = JitsiMeetingOptions(room: hostRoomText.text
          .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = hostSubjectText.text
        ..userDisplayName = _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": JitsiMeetingOptions(room: hostRoomText.text
              .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "")).room,
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
                for (var i = 0; i < items1.length; i++) {
                  if (items1[i].description1 != options.room) {
                  } else {
                    _deleteNote(context, items1[i], i);
                  }
                }
                db1.saveNote1(Note1(
                  hostSubjectText.text,
                  hostRoomText.text,
                  DateTime.now().toString(),
                  chatEnabled == true ? 1 : 0,
                  liveEnabled == true ? 1 : 0,
                  recordEnabled == true ? 1 : 0,
                  raiseEnabled == true ? 1 : 0,
                  shareYtEnabled == true ? 1 : 0,
                  kickEnabled == true ? 1 : 0,));
                db1.getAllNotes1().then((notes1) {
                  setState(() {
                    items1.clear();
                    notes1.forEach((note1) {
                      items1.add(Note1.fromMap(note1));
                    });
                  });
                });
                debugPrint("${options.room} joined with message: $message");
              }, onConferenceTerminated: (message) {
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
                isEmptyHost();
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
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('Copied invite link to clipboard',)));
    });
  }

  _shareMeeting(
      String roomids, String topics, String androidUrl, String url) async {
    if (hostRoomText.text.isNotEmpty) {
      if (hostSubjectText.text.isNotEmpty) {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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
}
