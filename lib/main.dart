import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:jagu_meet/screens/meeting/details/globalLiveDetails.dart';
import 'package:jagu_meet/screens/meeting/details/recentHosted.dart';
import 'package:jagu_meet/screens/meeting/details/recentJoined.dart';
import 'package:jagu_meet/screens/meeting/host.dart';
import 'package:jagu_meet/screens/meeting/join.dart';
import 'package:jagu_meet/screens/meeting/people/invites.dart';
import 'package:jagu_meet/screens/meetweb/meet.dart';
import 'package:jagu_meet/screens/meetweb/meetWeb.dart';
import 'package:jagu_meet/screens/meetweb/webFeedback.dart';
import 'package:jagu_meet/screens/meetweb/webHost.dart';
import 'package:jagu_meet/screens/meetweb/webJoin.dart';
import 'package:jagu_meet/screens/meetweb/webReport.dart';
import 'package:jagu_meet/screens/meetweb/webSettings.dart';
import 'package:jagu_meet/screens/meeting/search/searchMeetings.dart';
import 'package:jagu_meet/screens/meeting/startLive.dart';
import 'package:jagu_meet/screens/others/aboutus.dart';
import 'package:jagu_meet/screens/others/app_feedback.dart';
import 'package:jagu_meet/screens/others/report_abuse.dart';
import 'package:jagu_meet/screens/others/notifyPage.dart';
import 'package:jagu_meet/screens/user/profilePage.dart';
import 'package:jagu_meet/screens/meeting/settings/AdvancedSettings.dart';
import 'package:jagu_meet/screens/meeting/settings/generalSettings.dart';
import 'package:jagu_meet/screens/meeting/settings/meetingSettings.dart';
import 'package:jagu_meet/screens/meeting/schedule/viewScheduled.dart';
import 'package:jagu_meet/screens/others/webview.dart';
import 'package:jagu_meet/services/local_notification_service.dart';
import 'package:jagu_meet/widgets/loading.dart';
import 'package:jagu_meet/widgets/quiet_box.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'firebase/ads/admobAds.dart';
import 'screens/onboarding/root.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'screens/user/loginPage.dart';
import 'package:share/share.dart';
import 'widgets/dialogs.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:random_string/random_string.dart';
import 'theme/theme.dart';
import 'theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'screens/meeting/schedule/NoteScreen.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:badges/badges.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:jagu_meet/screens/others/fullImage.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:url_strategy/url_strategy.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//jagadish_android_apps

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  } else {}
  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool('darkMode') ?? true;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: darkModeOn
          ? Color(0xff0d0d0d)
          : Color(0xFFFFFFFF),
      systemNavigationBarIconBrightness: darkModeOn ? Brightness.light : Brightness.dark,
    ));
    setPathUrlStrategy();
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (_) => ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
        child: MaterialApp(
          home: root(),
          routes: {
            '/home': (_) => MyWeb(),
            '/join': (_) => WebJoin(),
            '/host': (_) => WebHost(),
            '/login': (_) => LoginScreen(),
            //'/profile': (_) => profilePage(),
            '/feedback': (_) => WebFeedback(),
            '/report': (_) => WebReport(),
            '/meeting': (_) => Meet(),
            '/settings': (_) => webSettings(),
            '/settings/general': (_) => generalSettings(),
            '/settings/advanced': (_) => advancedSettings(),
          },
        ),
      ),
    );
  });
}

Future<void> backgroundHandler(RemoteMessage message) async{
  print(message.data.toString());
  print(message.notification.title);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  DatabaseService databaseService = new DatabaseService();
  AdHelper adHelper = new AdHelper();

  int bottomSelectedIndex = 0;

  String shortcut = "no action set";

  final InAppReview inAppReview = InAppReview.instance;
  AppUpdateInfo _updateInfo;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  var deviceData;
  getDevice() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      deviceData = androidInfo.model;
    });
  }

  DateTime currentBackPressTime;

  FocusNode myFocusNode = FocusNode();

  PageController _controller = PageController(
    initialPage: 0,
    keepPage: true,
  );

  RefreshController _refreshController =
  RefreshController(initialRefresh: true);

  RefreshController _refreshController1 =
  RefreshController(initialRefresh: true);

  final serverText = TextEditingController();
  final roomText = TextEditingController();
  final subjectText = TextEditingController();
  final nameText = TextEditingController();
  final emailText = TextEditingController();

  var isAudioOnly = true;
  var isAudioMuted = true;
  var isVideoMuted = true;

  var timerEnabled = true;
  var meetNameEnabled = true;

  String _userName = '...';
  String _userEmail = '...';
  var _userUid = '...';
  var _userPhotoUrl = ' ';

  var chatEnabled = true;
  var liveEnabled = false;
  var recordEnabled = false;
  var raiseEnabled = true;
  var kickEnabled = false;
  var shareYtEnabled = true;

  var copyEnabled = true;

  var diagnostic;

  var quality;

  var linkchatEnabled;
  var linkliveEnabled;
  var linkrecordEnabled;
  var linkraiseEnabled;
  var linkYtEnabled = true;
  var linkKick;
  var linkHost = '';

  bool isButtonEnabled;
  bool isEnabled;

  final now = DateTime.now().toString();
  String version = '.';

  bool inMeeting = false;

  getSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        chatEnabled = prefs.getBool('chatEnabled') ?? true;
        liveEnabled = prefs.getBool('liveEnabled') ?? false;
        recordEnabled = prefs.getBool('recordEnabled') ?? false;
        raiseEnabled = prefs.getBool('raiseEnabled') ?? true;
        shareYtEnabled = prefs.getBool('shareYtEnabled') ?? true;

        timerEnabled = prefs.getBool('timerEnabled') ?? true;
        meetNameEnabled = prefs.getBool('meetNameEnabled') ?? true;

        isAudioOnly = prefs.getBool('isAudioOnly') ?? true;
        isAudioMuted = prefs.getBool('isAudioMuted') ?? true;
        isVideoMuted = prefs.getBool('isVideoMuted') ?? true;

        copyEnabled = prefs.getBool('copyEnabled') ?? true;

        diagnostic = prefs.getBool('diagnostic') ?? true;
        quality = prefs.getString('quality') ?? 'Auto';

        kickEnabled = prefs.getBool('kickEnabled') ?? false;
      });
    });
    Future.delayed(Duration(milliseconds: 500), () {});
  }

  var GkickEnabled = false;
  var GshareYtEnabled = true;
  var GshowName = true;
  var GchatEnabled = true;
  var GliveEnabled = false;
  var GrecordEnabled = false;
  var GraiseEnabled =  true;
  getGlobalSettings() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        GchatEnabled = prefs.getBool('GchatEnabled') ?? true;
        GliveEnabled = prefs.getBool('GliveEnabled') ?? false;
        GrecordEnabled = prefs.getBool('GrecordEnabled') ?? false;
        GraiseEnabled = prefs.getBool('GraiseEnabled') ?? true;
        GkickEnabled = prefs.getBool('GkickEnabled') ?? false;
        GshareYtEnabled = prefs.getBool('GshareYtEnabled') ?? true;
        GshowName = prefs.getBool('GshowName') ?? true;
      });
    });
    Future.delayed(Duration(milliseconds: 500), () {});
  }

  getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  checkConnection() async {
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
      checkVersion();
    }
  }

  String randomId = randomNumeric(11);

  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 2,
    minLaunches: 5,
    remindDays: 5,
    remindLaunches: 10,
    googlePlayIdentifier: 'com.jaguweb.jagu_meet',
  );

  Future handleDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(data);

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      // 3a. handle link that has been retrieved
      _handleDeepLink(dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      Fluttertoast.showToast(
          msg: 'Failed Joining Meeting',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

  void _handleDeepLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('_handleDeepLink | deeplink: $deepLink');
      Fluttertoast.showToast(
          msg: 'Connecting...',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      if (deepLink.queryParameters['id'] != null && deepLink.queryParameters['id'] != '' && deepLink.queryParameters.isNotEmpty == true) { ///TODO test
        String linkroomid = deepLink.queryParameters['id'];
        String linkroomtopic;
        String type;
        bool linkch;
        bool linkrh;
        bool linkrm;
        bool linkls;
        bool linkyt;
        bool linkKo;
        String host;
        try {
          await FirebaseFirestore.instance.doc("Invcoblocked/$linkroomid/Blocked/$_userUid")
              .get()
              .then((doc) async {
            if (doc.exists) {
              final action = await Dialogs.infoDialog(
                  context,
                  "You can't join this meeting",
                  'The host of the meeting has blocked you from joining the meeting',
                  'Ok');
            } else {
              try {
                await FirebaseFirestore.instance.doc("Meetings/$linkroomid")
                    .get()
                    .then((doc) async {
                  if (doc.exists) {
                    await FirebaseFirestore.instance.collection('Meetings').doc(
                        linkroomid).get().then((snapshot) async {
                      setState(() {
                        linkroomtopic = snapshot.data()['meetName'];
                        linkch = snapshot.data()['chat'];
                        linkrh = snapshot.data()['raise'];
                        linkrm = snapshot.data()['record'];
                        linkls = snapshot.data()['live'];
                        linkyt = snapshot.data()['yt'];
                        linkKo = snapshot.data()['kick'];
                        host = snapshot.data()['host'];
                      });
                      if (linkch == false) {
                        setState(() {
                          linkchatEnabled = false;
                        });
                      } else {
                        setState(() {
                          linkchatEnabled = true;
                        });
                      }
                      if (linkrh == false) {
                        setState(() {
                          linkraiseEnabled = false;
                        });
                      } else {
                        setState(() {
                          linkraiseEnabled = true;
                        });
                      }
                      if (linkrm == false) {
                        setState(() {
                          linkrecordEnabled = false;
                        });
                      } else {
                        setState(() {
                          linkrecordEnabled = true;
                        });
                      }
                      if (linkls == false) {
                        setState(() {
                          linkliveEnabled = false;
                        });
                      } else {
                        setState(() {
                          linkliveEnabled = true;
                        });
                      }
                      if (linkyt == false) {
                        setState(() {
                          linkYtEnabled = false;
                        });
                      } else {
                        setState(() {
                          linkYtEnabled = true;
                        });
                      }
                      if (linkKo == false) {
                        setState(() {
                          linkKick = false;
                        });
                      } else {
                        setState(() {
                          linkKick = true;
                        });
                      }
                      setState(() {
                        linkHost = host;
                      });
                      if (host == _userEmail) {
                        setState(() {
                          roomText.text = linkroomid;
                          subjectText.text = linkroomtopic;
                        });
                        _hostMeeting();
                      } else {
                        try {
                          await FirebaseFirestore.instance.doc(
                              "Invcoblocked/$linkroomid/Cohost/$_userUid")
                              .get()
                              .then((doc) async {
                            if (doc.exists) {
                              setState(() {
                                type = 'cohost';
                              });
                            } else {
                              await FirebaseFirestore.instance.doc(
                                  "Invcoblocked/$linkroomid/Invited/$_userUid")
                                  .get()
                                  .then((doc) async {
                                if (doc.exists) {
                                  setState(() {
                                    type = 'invited';
                                  });
                                } else {
                                  setState(() {
                                    type = 'join';
                                  });
                                }
                              });
                              }
                            });
                        } catch (e) {
                          print(e);
                        }
                        if (snapshot.data()['hasStarted'] == true) {
                          setState(() {
                            roomText.text = linkroomid;
                            subjectText.text = linkroomtopic;
                          });
                          _joinLinkMeeting(type);
                        } else {
                          _notStarted(linkroomid, linkroomtopic, type);
                        }
                      }
                    });
                  } else {
                    noMeeting();
                  }
                });
              } catch (e) {
                print(e);
              }
            }
            });
        } catch (e) {
          print(e);
        }
      } else {
        Fluttertoast.showToast(
            msg: 'Invalid meeting link',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.SNACKBAR,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);

      }
      print('Correct link');
    }
  }

  void _notStarted(id, topic, type) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        FirebaseFirestore.instance.collection('Meetings').doc(id).snapshots().listen((querySnapshot) {
          if (querySnapshot.data()['hasStarted'] == true) {
            setState(() {
              roomText.text = id;
              subjectText.text = topic;
            });
            Navigator.pop(context);
            _joinLinkMeeting(type);
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

  void onThemeChangedStart(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
    var darkModeOn = prefs.getBool('darkMode');
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
     // statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: darkModeOn
          ? Color(0xff0d0d0d)
          : Color(0xFFFFFFFF),
      systemNavigationBarIconBrightness: darkModeOn ? Brightness.light : Brightness.dark,

    ));
  }

  final User user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth auth = FirebaseAuth.instance;
  _getUserAuth() async {
    final User user = auth.currentUser;
    setState(() {
      _userPhotoUrl = user.photoURL;
      _userName = user.displayName;
      _userEmail = user.email;
      _userUid = user.uid;
    });
    Future.delayed(Duration(milliseconds: 1000), () {});
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

  Future<void> checkVersion() async {
    if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
      InAppUpdate.performImmediateUpdate()
          .catchError((e) => print(e));
    } else {}
  }

  handleQuickActions() {
    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      setState(() {
        if (shortcutType != null) shortcut = shortcutType;
      });
      if (shortcutType == 'action_schedule') {
        _createNewNote();
      }
      if (shortcutType == 'action_new') {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => HostPage(
                      name: _userName,
                      email: _userEmail,
                      uid: _userUid,
                      url: _userPhotoUrl,
                    )));
      }
      if (shortcutType == 'action_live') {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => StartLive(
                  email: _userEmail,
                  name: _userName,
                  url: _userPhotoUrl,)));
      }
      if (shortcutType == 'action_join') {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => Join(
                  name: _userName,
                  email: _userEmail,
                  uid: _userUid,
                  url: _userPhotoUrl,
                )));
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
          type: 'action_schedule',
          localizedTitle: 'Schedule',
          icon: 'schedule'),
      const ShortcutItem(
          type: 'action_new', localizedTitle: 'New', icon: 'ac_new'),
      const ShortcutItem(
          type: 'action_live',
          localizedTitle: 'Start Stage',
          icon: 'live'),
      const ShortcutItem(
          type: 'action_join',
          localizedTitle: 'Join',
          icon: 'join'),
    ]);
  }

  launchWebView(var URL, var TITLE) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => AppWebView(
                  url: URL,
                  title: TITLE,
                )));
  }

  AnimationController _animationController;

  @override
  void initState() {
    _getUserAuth();
    getSettings();
    handleDynamicLinks();
    handleQuickActions();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onPictureInPictureWillEnter: _onPictureInPictureWillEnter,
        onPictureInPictureTerminated: _onPictureInPictureTerminated,
        onError: _onError));

    LocalNotificationServices().initialize(context, _userName, _userEmail, _userUid, _userPhotoUrl);

    ///gives you the message on which user taps
    ///and it opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if(message != null){
        final routeFromMessage = message.data["route"];

        if (routeFromMessage == 'schedule') {
          _createNewNote();
        } else if (routeFromMessage == 'host') {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                      HostPage(
                        name: _userName,
                        email: _userEmail,
                        uid: _userUid,
                        url: _userPhotoUrl,
                      )));
        }  else if (routeFromMessage == 'join') {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => Join(
                    name: _userName,
                    email: _userEmail,
                    uid: _userUid,
                    url: _userPhotoUrl,
                  )));
        }  else if (routeFromMessage == 'live') {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => StartLive(
                    email: _userEmail,
                    name: _userName,
                    url: _userPhotoUrl,)));
        } else {

        }
      }
    });

    ///forground work
    FirebaseMessaging.onMessage.listen((message) {
      if(message.notification != null){
        print(message.notification.body);
        print(message.notification.title);
      }

      LocalNotificationServices.display(message);
    });

    ///When the app is in background but opened and user taps
    ///on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data["route"];

      if (routeFromMessage == 'schedule') {
        _createNewNote();
      } else if (routeFromMessage == 'host') {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) =>
                    HostPage(
                      name: _userName,
                      email: _userEmail,
                      uid: _userUid,
                      url: _userPhotoUrl,
                    )));
      } else {

      }
    });

    adHelper.interstitialAdload();
    _animationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    getGlobalSettings();
    isEmpty();
    getDevice();
    getAppInfo();
    checkConnection();
    Future.delayed(Duration(milliseconds: 500), () {
      Fluttertoast.showToast(
          msg: 'Signed in as ' + _userName,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    });
    review();
    super.initState();
  }

  review() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  void meetFeedback() {
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
                color: Color(0xff0184dc),
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
                color: Color(0xff0184dc),
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

  @override
  void dispose() {
    JitsiMeet.removeAllListeners();
    adHelper.adsDispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> exitConf() async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return showDialog(
        context: context,
        builder: (context) {
          return Theme(
            data: themeNotifier.getTheme(),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(
                'No More meetings?',
                overflow: TextOverflow.ellipsis,
              ),
              actions: <Widget>[
                FlatButton(
                  color: Colors.transparent,
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: Color(0xff0184dc),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  color: Colors.transparent,
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: Color(0xff0184dc)
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                )
              ],
            ),
          );
        });
  }

  String currentTitle;

  var appBarTitle = 'Just Meet';
  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
    if (index == 0) {
      setState(() {
        appBarTitle = 'Just Meet';
      });
    } else if (index == 1) {
      setState(() {
        appBarTitle = 'Meetings';
      });
    } else if (index == 2) {
      setState(() {
        appBarTitle = 'Conference';
      });
    } else if (index == 3) {
      setState(() {
        appBarTitle = 'Settings';
      });
    }
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      _controller.animateToPage(index,
          duration: Duration(milliseconds: 800), curve: Curves.easeInOut);
    });
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

  bool isTyping1 = false;
  istyping1(final TextEditingController controller) {
    if (controller.text.length > 0) {
      setState(() {
        isTyping1 = true;
      });
    } else {
      setState(() {
        isTyping1 = false;
      });
    }
  }

  onSignOut() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('signStatus', false);
    });
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  checkCopied() async {  ///TODO test
    String copied = await Clipboard.getData('text/plain').toString();
    if (copied.contains('https://www.jaguweb.jmeet.com/')) {
      final action = await Dialogs.yesAbortDialog(
          context,
          'Join with copied link?',
          'You have copied a link, do you want to join meeting with the copied link?',
          'Join',
          'Cancel');
      if (action == DialogAction.yes) {
        var url = copied;
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
      if (action == DialogAction.no) {
        Navigator.pop(context);
      }
    } else if (isNumeric(copied) == true && copied.length == 11) {
      final action = await Dialogs.yesAbortDialog(
          context,
          'Join with copied ID?',
          'You have copied a ID, do you want to join meeting with the copied ID?',
          'Join',
          'Cancel');
      if (action == DialogAction.yes) {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => Join(
                  name: _userName,
                  email: _userEmail,
                  uid: _userUid,
                  url: _userPhotoUrl,
                  id: copied,
                )));
      }
      if (action == DialogAction.no) {
        Navigator.pop(context);
      }
    } else if (copied.contains('https://www.jaguweb.jmeet.com/meet?id=')) {
      final action = await Dialogs.yesAbortDialog(
          context,
          'Join with copied link?',
          'You have copied a link, do you want to join meeting with the copied link?',
          'Join',
          'Cancel');
      if (action == DialogAction.yes) {
        var url = copied;
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
      if (action == DialogAction.no) {
        Navigator.pop(context);
      }
    }
  }

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.videocam_outlined),
        activeIcon: Icon(Icons.videocam),
        label: 'Meet',
      ),
      BottomNavigationBarItem(
        icon: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Users')
          .doc(_userUid)
          .collection('Scheduled').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return FaIcon(FontAwesomeIcons.calendarAlt,);
      }
      if (snapshot.hasError) {
        return FaIcon(FontAwesomeIcons.calendarAlt,);
      }
    return snapshot.data.docs.length == 0
    ? FaIcon(FontAwesomeIcons.calendarAlt,)
            : Badge(
          toAnimate: true,
          badgeColor: Colors.red,
          animationType: BadgeAnimationType.scale,
          badgeContent: Text(snapshot.data.docs.length.toString(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white)),
          child: FaIcon(FontAwesomeIcons.calendarAlt,),
        );
        }),
        label: 'Meetings',
      ),
      BottomNavigationBarItem(
        icon: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Live').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Icon(Icons.online_prediction_outlined,);
      }
      if (snapshot.hasError) {
        return Icon(Icons.online_prediction_outlined,);
      }
      return snapshot.data.docs.length == 0
          ? Icon(Icons.online_prediction_outlined) : Stack(
          children: <Widget>[
            Icon(Icons.online_prediction_outlined,),
            Positioned(
              top: 0,
              right: 0,
              child: FadeTransition(
                opacity: _animationController,
                child: Container(
                    decoration: new BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(
                          Radius.circular(
                              2.0) //         <--- border radius here
                      ),
                      gradient: LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight
                      ),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        'LIVE',
                        style: TextStyle(
                            fontSize: 6,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                ),
              ),
            ),
          ]
      );
    }),
        label: 'Conference',
      ),
      BottomNavigationBarItem(
    activeIcon: Icon(Icons.settings),
        icon: new Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return WillPopScope(
      onWillPop: exitConf,
      child: MaterialApp(
        title: 'Just Meet',
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.getTheme(),
        home: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: themeNotifier.getTheme() == darkTheme
                ? Colors.white : Colors.black54),
            centerTitle: true,
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
                preferredSize: Size(double.infinity, 0.0)),
            title: //!searchState ?
             Text(
              appBarTitle,
              style: TextStyle(
                color: themeNotifier.getTheme() == darkTheme
                    ? Colors.white : Colors.black54,
              ),
            ),//: TextField(
            actions: [
              IconButton(
                  onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => SearchScreen(
                        name: _userName,
                        email: _userEmail,
                        uid: _userUid,
                        PhotoUrl: _userPhotoUrl,
                      ))), icon: Icon(Icons.search_rounded)),
              IconButton(onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => profilePage(
                        name: _userName,
                        email: _userEmail,
                        photoURL: _userPhotoUrl,
                      ))),
                icon: CachedNetworkImage(
                  imageUrl: _userPhotoUrl,
                  placeholder: (context, url) => CupertinoActivityIndicator(animating: true, ),
                  errorWidget: (context, url, error) => Icon(Icons.person),
                  imageBuilder: (context, imageProvider) => Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: themeNotifier.getTheme() == darkTheme
                                ? Colors.white
                                : Colors.blue,
                          ),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.scaleDown,
                          ))),
                ),
              ),
            ],
          ),
          resizeToAvoidBottomInset: false,
          drawer: mainDrawer(),
          bottomNavigationBar: Container(
          decoration: BoxDecoration(
          color: themeNotifier.getTheme() == darkTheme
              ? Color(0xff0d0d0d)
              : Color(0xFFFFFFFF),
    boxShadow: [
    BoxShadow(
    color: themeNotifier.getTheme() == darkTheme
        ? Colors.grey
        : Color(0xFF242424)
    ),
    ],
    ),
    child: BottomNavigationBar(
      unselectedItemColor: Color(0xff909090),
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      showUnselectedLabels: true,
            backgroundColor: themeNotifier.getTheme() == darkTheme
                ? Color(0xff0d0d0d)
                : Color(0xFFFFFFFF),
            selectedItemColor: themeNotifier.getTheme() == darkTheme
                ? Colors.white
                : Colors.blue,
            currentIndex: bottomSelectedIndex,
            onTap: (index) {
              bottomTapped(index);
            },
            items: buildBottomNavBarItems(),
          ),
          ),
          body: SafeArea(
            child: OfflineBuilder(
              connectivityBuilder: (
                BuildContext context,
                ConnectivityResult connectivity,
                Widget child,
              ) {
                final bool connected = connectivity != ConnectivityResult.none;
                return new Stack(
                  fit: StackFit.expand,
                  children: [
                    child,
                    Positioned(
                      height: 24.0,
                      left: 0.0,
                      right: 0.0,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        color: connected ? null : Color(0xFFEE4400),
                        child: Center(
                          child: connected
                              ? null
                              : Text('You Are Offline!',
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                        ),
                      ),
                    ),
                  ],
                );
              },
              child: Container(
                  height: double.maxFinite,
                  child: PageView(
                    controller: _controller,
                    scrollDirection: Axis.horizontal,
                    pageSnapping: true,
                    allowImplicitScrolling: true,
                    onPageChanged: (index) {
                      pageChanged(index);
                    },
                    children: [
                      homeScreen(),
                      scheduleMeeting(),
                      liveMeeting(),
                      Settings(),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  Widget homeScreen() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                              height: 50.0,
                              width: 50,
                              child:
                      RaisedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => Join(
                                    name: _userName,
                                    email: _userEmail,
                                    uid: _userUid,
                                    url: _userPhotoUrl,
                                  )));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.all(10),
                        color: Color(0xff0184dc),
                        child: Icon(Icons.videocam, color: Colors.white,),
                      ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text('Join', style: TextStyle(fontSize: 10),)
                          ]),
                      Column(
                          children: [
                            SizedBox(
                              height: 50.0,
                              width: 50,
                              child:
                              OutlineButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              HostPage(
                                                name: _userName,
                                                email: _userEmail,
                                                uid: _userUid,
                                                url: _userPhotoUrl,
                                              )));
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: EdgeInsets.all(10),
                                borderSide: BorderSide(
                                  color: Color(0xff0184dc),
                                ),
                                color: Colors.transparent,
                                child: Icon(Icons.add, color: Color(0xff0184dc),),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text('New Meeting', style: TextStyle(fontSize: 10),)
                          ]),
                      Column(
                          children: [
                            SizedBox(
                              height: 50.0,
                              width: 50,
                              child:
                              OutlineButton(
                                onPressed: () {
                                  _createNewNote();
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: EdgeInsets.all(10),
                                borderSide: BorderSide(
                                  color: Color(0xff0184dc),
                                ),
                                color: Colors.transparent,
                                child: FaIcon(FontAwesomeIcons.calendarPlus, color: Color(0xff0184dc),),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text('Schedule', style: TextStyle(fontSize: 10),)
                          ]),
                      Column(
                          children: [
                            SizedBox(
                              height: 50.0,
                              width: 50,
                              child:
                              OutlineButton(
                                onPressed: ()
                                {
                                ///  MediationTest.presentTestSuite();
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                            builder: (context) => StartLive(
                                            email: _userEmail,
                                             name: _userName,
                                         url: _userPhotoUrl,)));
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: EdgeInsets.all(10),
                                borderSide: BorderSide(
                                  color: Color(0xff0184dc),
                                ),
                                color: Colors.transparent,
                                child: Icon(Icons.online_prediction_outlined, color: Color(0xff0184dc),),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text('Conference', style: TextStyle(fontSize: 10),)
                          ]),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF303030)
                        : Colors.grey,
                      ),
                      child: new IconButton(
                          icon: new Icon(Icons.star,color: Colors.white,),onPressed: null),
                    ),
                    tileColor: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF191919)
                        : Color(0xFFf9f9f9),
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                RecentHosted(
                                  name: _userName,
                                  email: _userEmail,
                                  uid: _userUid,
                                  url: _userPhotoUrl,
                                ))),
                    title: Text(
                      'My Meetings',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
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
                    indent: 15,
                    endIndent: 0,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF303030)
                            : Colors.grey,
                      ),
                      child: new IconButton(
                          icon: new Icon(Icons.schedule_outlined,color: Colors.white,),onPressed: null),
                    ),
                    tileColor: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF191919)
                        : Color(0xFFf9f9f9),
                    onTap: () =>  Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                RecentJoined(
                                  name: _userName,
                                  email: _userEmail,
                                  uid: _userUid,
                                  url: _userPhotoUrl,
                                ))),
                    title: Text(
                      'Recent Joined',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
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
                    indent: 15,
                    endIndent: 0,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030)
                        : Colors.black12,
                  ),
                  ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF303030)
                            : Colors.grey,
                      ),
                      child: new IconButton(
                          icon: new Icon(Icons.mail_sharp,color: Colors.white,),onPressed: null),
                    ),
                    tileColor: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF191919)
                        : Color(0xFFf9f9f9),
                    onTap: () =>  Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                Invites(
                                  name: _userName,
                                  email: _userEmail,
                                  uid: _userUid,
                                  url: _userPhotoUrl,
                                ))),
                    title: Text(
                      'Invites',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
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
    ]),
    ),
    ),
    ),
    );
  }

  Widget mainDrawer() {
    final GoogleSignIn _gSignIn = GoogleSignIn();
    final FirebaseAuth auth = FirebaseAuth.instance;
    return Drawer(
      elevation: 30,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => profilePage(
                          name: _userName,
                          email: _userEmail,
                          photoURL: _userPhotoUrl,
                        ))),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 85,
              padding: EdgeInsets.only(top: 10, left: 10),
              decoration: BoxDecoration(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                fullImage(url: _userPhotoUrl))),
                    child: CachedNetworkImage(
                      imageUrl: _userPhotoUrl,
                      placeholder: (context, url) =>
                          CupertinoActivityIndicator(animating: true, ),
                      errorWidget: (context, url, error) => Icon(Icons.person),
                      imageBuilder: (context, imageProvider) => Container(
                          width: 40,
                          height: 40,
                          margin: EdgeInsets.only(top: 15, right: 10),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.fill,
                              ))),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _userName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _userEmail,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(),
                              ),
                            ],
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
          Divider(
            color: Colors.black12,
            height: 1,
            thickness: 1,
          ),
          ListTile(
            leading: Stack(
              children: [
                Icon(Icons.notifications_none_outlined),
                Positioned(
                  left: 16,
                  child: Icon(
                    Icons.brightness_1,
                    color: Colors.red,
                    size: 9,
                  ),
                )
              ],
            ),
            title: Text(
              'Updates',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            onTap: () {
              Navigator.push(
                  context, CupertinoPageRoute(builder: (context) => Notify()));
            },
          ),
          ListTile(
              leading: Icon(Icons.feedback_outlined),
              title: Text(
                'Send Feedback',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => AppFeedback(
                          userid: _userUid,
                          email: _userEmail,
                          name: _userName)))),
          ListTile(
              leading: Icon(Icons.report_outlined),
              title: Text(
                'Report Abuse',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => Report(
                            userid: _userUid,
                            email: _userEmail,
                          )))),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text(
              'Support',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            onTap: () => launchWebView(
                'https://justmeetpolicies.blogspot.com/p/just-meet-faqs.html',
                'FAQ'),
          ),
          ListTile(
              leading: Icon(Icons.share_outlined),
              title: Text(
                'Invite others',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              onTap: () {
                _share();
              }),
          ListTile(
              leading: Icon(
                Icons.thumb_up_alt_outlined,
              ),
              title: Text(
                'Rate Us',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              onTap: () => _launchPlay()),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ListTile(
                          leading: Text(
                            'Sign Out',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.normal),
                          ),
                          onTap: () async {
                            final action = await Dialogs.redAlertDialog(
                                context,
                                'Sign Out',
                                'Do You Really want to sign out?',
                                'Sign Out',
                                'No');
                            if (action == DialogAction.yes) {
                              _gSignIn.signOut();
                              auth.signOut();
                              onSignOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                CupertinoPageRoute(
                                    builder: (BuildContext context) =>
                                        LoginScreen()),
                                (Route<dynamic> route) => false,
                              );
                            }
                            if (action == DialogAction.abort) {}
                          },
                        ),
                      ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget Settings() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  tileColor: themeNotifier.getTheme() == darkTheme
                      ? Color(0xFF191919)
                      : Color(0xFFf9f9f9),
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => generalSettings())),
                  title: Text(
                    'General Settings',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('Theme, Diagnostic info, Ads', overflow: TextOverflow.ellipsis,),
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
                          builder: (context) => meetingSettings())),
                  title: Text(
                    'Meeting Settings',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('Joining, Hosting, Conference settings', overflow: TextOverflow.ellipsis,),
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
                          builder: (context) => advancedSettings())),
                  title: Text(
                    'Advanced Settings',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('Enhance voice, Skin tone, Lighting, Video quality...', overflow: TextOverflow.ellipsis,),
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
                  height: 25,
                ),
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
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => AboutUs())),
                  title: Text(
                    'About',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
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
                  height: 20,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    'Copyright ©2021 Just Technologies. All rights reserved.',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget scheduleMeeting() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Users')
                .doc(_userUid)
                .collection('Scheduled').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              }
              if (snapshot.hasError) {
                return Loading();
              }
             return snapshot.data.docs.length == 0
                ? Container(
                    child: QuietBox(
                      heading: "Schedule",
                      subtitle:
                      "There are no upcoming meetings, schedule one for future now",
                      fun: _createNewNote,
                    )
                )
              : SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: false,
                      header: ClassicHeader(),
                      controller: _refreshController1,
                      onRefresh: _onRefresh1,
                      onLoading: _onLoading1,
                      child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (BuildContext context, int position) {
                            var dbDate = snapshot.data.docs[position]["date"];
                            var dateFormat = new DateFormat('dd, MMM yyyy');
                            final now = DateTime.now();
                            DateTime tomorrow = now.add(Duration(days: 1));
                            DateTime daytomorrow = now.add(Duration(days: 2));
                            DateTime yesterday = now.subtract(Duration(
                                days: 1));
                            String formattedDate = dateFormat
                                .format((DateTime.parse(dbDate)));
                            var finalDate;
                            if (DateTime
                                .parse(dbDate)
                                .day ==
                                now.day &&
                                DateTime
                                    .parse(dbDate)
                                    .month ==
                                    now.month &&
                                DateTime
                                    .parse(dbDate)
                                    .year ==
                                    now.year) {
                              finalDate = 'Today';
                            } else if ((DateTime
                                .parse(dbDate)
                                .day ==
                                tomorrow.day &&
                                DateTime
                                    .parse(dbDate)
                                    .month ==
                                    tomorrow.month &&
                                DateTime
                                    .parse(dbDate)
                                    .year ==
                                    tomorrow.year)) {
                              finalDate = 'Tomorrow';
                            } else if ((DateTime
                                .parse(dbDate)
                                .day ==
                                daytomorrow.day &&
                                DateTime
                                    .parse(dbDate)
                                    .month ==
                                    daytomorrow.month &&
                                DateTime
                                    .parse(dbDate)
                                    .year ==
                                    daytomorrow.year)) {
                              finalDate = 'Day After Tomorrow';
                            } else if ((DateTime
                                .parse(dbDate)
                                .day ==
                                yesterday.day &&
                                DateTime
                                    .parse(dbDate)
                                    .month ==
                                    yesterday.month &&
                                DateTime
                                    .parse(dbDate)
                                    .year ==
                                    yesterday.year)) {
                              finalDate = 'Yesterday';
                            } else {
                              finalDate = formattedDate;
                            }
                            var from = DateFormat.jm().format(DateFormat("hh:mm").parse(snapshot.data.docs[position]["from"])).toString();
                            for (var i = 0; i < snapshot.data.docs.length; i++) {
                              final date = DateTime.parse(dbDate);
                              if (snapshot.data.docs[position]["from"] == 'Never') {
                                if (date.isBefore(now)) {
                                  databaseService.removeMyScheduled(snapshot.data.docs[position]["id"], _userUid);
                                  Fluttertoast.showToast(
                                      msg: 'Scheduled meeting has expired',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {}
                              } else {}
                            }
                            return ListTile(
                                onTap: () => _navigateToViewNote(snapshot.data.docs[position]["id"]),
                                contentPadding: EdgeInsets.all(0),
                                dense: true,
                                leading: Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Text(from,
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 12),
                                      )),
                                ),
                                trailing: Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Text(
                                    finalDate,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                title: Text(snapshot.data.docs[position]["meetName"],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    //color: Colors.black,
                                      fontSize: 16),
                                ),
                                subtitle: Text(snapshot.data.docs[position]["id"],
                                  overflow: TextOverflow.ellipsis,
                                ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                              height: 1,
                              color: themeNotifier.getTheme() == darkTheme
                                  ? Color(0xFF242424)
                                  : Colors.black12,
                              indent: 15,
                              endIndent: 0,
                            );
                          },
                        ),
                      );
            }),
          ),
    );
  }

  Widget liveMeeting() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    goToLive() {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => StartLive(
                email: _userEmail,
                name: _userName,
                url: _userPhotoUrl,)));
    }
    return Scaffold(
        body: SafeArea(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Live').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                    child: QuietBox(
                      heading: "Start a Stage",
                      subtitle:
                      "There are no conferences live now, host one and let people join you",
                      fun: goToLive,
                    )
                );
              }
              if (snapshot.hasError) {
                return Loading();
              }
              return snapshot.data.docs.length == 0
                  ?
              Container(
                  child: QuietBox(
                    heading: "Start a Stage",
                    subtitle:
                    "There are no conferences live now, host one and let people join you",
                    fun: goToLive,
                  )
              )
                  : SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  header: ClassicHeader(),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: ListView.separated(
                      itemCount: snapshot.data.docs.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: 10,);
                      },
                      itemBuilder: (context, position) {
                        return
                          Card(
                            elevation: 0,
                            color: themeNotifier.getTheme() == darkTheme
                                ? Color(0xFF242424)
                                : Color(0xFFEFEFEF),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: SafeArea(
                              child:
                              ListTile(
                                  title: Text(snapshot.data.docs[position]["meetName"],),
                                  subtitle: snapshot.data.docs[position]["host"] != _userName ? Text(
                                      'Hosted by ' +
                                          snapshot.data.docs[position]["name"] + ', ' +
                                          'started at ' +
                                          snapshot.data.docs[position]["time"] + ' UTC') : Text(
                                      'Hosted by You at ' +
                                          snapshot.data.docs[position]["time"] + ' UTC'),
                                  contentPadding: EdgeInsets.only(
                                      top: 0, bottom: 0, left: 10),
                                  onTap: () {
                                    if (inMeeting == false) {
                                      if (snapshot.data.docs[position]["host"] !=
                                          _userEmail) {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    LiveDetails(
                                                      id: snapshot.data
                                                          .docs[position]["id"],
                                                      topic: snapshot.data
                                                          .docs[position]["meetName"],
                                                      host: snapshot.data
                                                          .docs[position]["host"],
                                                      name: _userName,
                                                      uid: _userUid,
                                                      email: _userEmail,
                                                      PhotoUrl: _userPhotoUrl,
                                                      started: snapshot.data
                                                          .docs[position]["time"])));
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: 'Already in a meeting',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.SNACKBAR,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white,
                                          fontSize: 16.0);
                                    }
                                  }
                              ),
                            ),
                          );
                      })
              );
            }),
              ),
    );
  }

  _share() {
    final textshare =
        "$_userName is already on Just Meet and is inviting you to join Just Meet."
        "\n"
        "\n"
        "Just Meet is leading in modern video communications, with easy, unlimited participants and time, low bandwidth mode, highly secured and reliable video and audio conferencing, screen sharing, chat etc fo schools, official meetings, webinars across mobile, desktop and IOS with high quality video and audio."
        "\n"
        "\n"
        "Download and Join Just Meet video conference now and enjoy quality and security like no other and never before."
        "\n"
        "Download from Play Store: https://play.google.com/store/apps/details?id=com.jaguweb.jagu_meet";
    final RenderBox box = context.findRenderObject();
    Share.share(textshare,
        subject: "$_userName is referring you to Join Just Meet",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    if(mounted)
      setState(() {

      });
    _refreshController.loadComplete();
  }

  void _onRefresh1() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController1.refreshCompleted();
  }

  void _onLoading1() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    if(mounted)
      setState(() {

      });
    _refreshController1.loadComplete();
  }

  _launchPlay() async {
    var url =
        'https://play.google.com/store/apps/details?id=com.jaguweb.jagu_meet';
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

  void _navigateToViewNote(String id) {
   Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => viewScheduled(
                id: id,
               name: _userName,
                email: _userEmail,
               PhotoUrl: _userPhotoUrl,
                uid: _userUid,
              )),
   );
  }

   _createNewNote() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => NoteScreen(
          _userUid,
               _userEmail,
               randomNumeric(11),
                '',
                new DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
                '',
                '',
                'Never',
               true,
                false,
               false,
                true,
               true,
               false,
      ),
    ));
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

  var linkImageUrl = Uri.parse(
      'https://play-lh.googleusercontent.com/7ZrxSsCqSNb86h57pPlJ3budCKTTZrCDSB3aq1F-srZnhO4M1iNtCXaM7fvxuJU3Yg=s180-rw');
  var urlLinkTitle = 'Join Just Meet Video Conference';
  var urlLinkDescription =
      'Just Meet is the leader in video conferences, with easy, secured, encrypted and reliable video and audio conferencing, chat, screen sharing and webinar across mobile and desktop. Unlimited participants and time with low bandwidth mode. Join Just Meet Video Conference now and enjoy high quality video conferences with security like no other. Stay Safe and Stay Connected with Just Meet. Developed in India with love.';

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
        imageUrl: linkImageUrl,
        title: urlLinkTitle,
        description: urlLinkDescription,
      ),
    );
    final Uri longLink = await parameters.buildUrl();
    final ShortDynamicLink shortDynamicLink = await DynamicLinkParameters.shortenUrl(Uri.parse(longLink.toString() + "&ofl=https://jmeet-8e163.web.app/"));
    final Uri dynamicUrl = shortDynamicLink.shortUrl;
    return dynamicUrl;
  }

  onChatChanged(bool value) {
    setState(() {
      chatEnabled = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('chatEnabled', value);
    });
  }

  onLiveChanged(bool value) async {
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

  onRecordChanged(bool value) async {
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

  onRaiseChanged(bool value) {
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
      if (linkchatEnabled == false) {
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
        ..subject = subjectText.text
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
              await FirebaseFirestore.instance.doc("Users/$_userUid/Scheduled/${options.room}").get().then((doc) {
                if (doc.exists) {
                  databaseService.startScheduledHosted(options.room, true);
                } else {
                  databaseService.updateHosted(_userUid, options.room, options.subject, chatEnabled, liveEnabled, recordEnabled, raiseEnabled, shareYtEnabled, kickEnabled, _userEmail, DateTime.now(), true);
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
              await FirebaseFirestore.instance.doc("Users/$_userUid/Scheduled/${options.room}").get().then((doc) {
                if (doc.exists) {
                  databaseService.startScheduledHosted(options.room, false);
                } else {
                  databaseService.updateHosted(_userUid, options.room, options.subject, chatEnabled, liveEnabled, recordEnabled, raiseEnabled, shareYtEnabled, kickEnabled, _userEmail, DateTime.now(), false);
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

  _joinLinkMeeting(type) async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    Map<FeatureFlagEnum, bool> featureFlags = {};

    try {
      if (_userEmail == 'jaguweb1234@gmail.com' ||
          _userEmail == 'jagadish.pr.pattanaik@gmail.com') {
        featureFlags[FeatureFlagEnum.WELCOME_PAGE_ENABLED] = false;
        //featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
        //featureFlag.kickOutEnabled = true;
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
          // Disable PIP on iOS as it looks weird
          featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
        }
      } else {
        featureFlags[FeatureFlagEnum.WELCOME_PAGE_ENABLED] = false;
        //featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
        //featureFlag.kickOutEnabled = false;
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;

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
        if (linkchatEnabled == false) {
          featureFlags[FeatureFlagEnum.CHAT_ENABLED] = false;
        }
        if (linkliveEnabled == false) {
          featureFlags[FeatureFlagEnum.LIVE_STREAMING_ENABLED] = false;
        }
        if (linkrecordEnabled == false) {
          featureFlags[FeatureFlagEnum.RECORDING_ENABLED] = false;
        }
        if (linkraiseEnabled == false) {
          featureFlags[FeatureFlagEnum.RAISE_HAND_ENABLED] = false;
        }

        if (linkYtEnabled == false) {
          //featureFlag.videoShareButtonEnabled = false;
        }

        if (linkKick == true) {
          //featureFlag.kickOutEnabled = true;
        }

        //if (timerEnabled == false) {
        //  featureFlag.conferenceTimerEnabled = false;
        // }

        if (meetNameEnabled == false) {
          featureFlags[FeatureFlagEnum.MEETING_NAME_ENABLED] = false;
        }
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: roomText.text
          .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = subjectText.text
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
            databaseService.addMyJoined(options.room, _userUid, options.subject, DateTime.now().subtract(Duration(seconds: 2)), _userName, _userEmail, _userPhotoUrl, type);
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
            databaseService.participantLeft(_userUid, options.room);
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

  _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted");
  }

  _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted");
  }

  _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted");
  }

  _onPictureInPictureWillEnter(message) {
    debugPrint(
        "_onPictureInPictureWillEnter broadcasted with message: $message");
  }

  _onPictureInPictureTerminated(message) {
    debugPrint(
        "_onPictureInPictureTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted");
  }
}
