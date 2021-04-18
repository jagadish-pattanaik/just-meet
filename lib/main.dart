import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:jagu_meet/screens/host.dart';
import 'package:jagu_meet/screens/others/app_feedback.dart';
import 'package:jagu_meet/screens/others/covAwarness.dart';
import 'package:jagu_meet/screens/others/report_abuse.dart';
import 'package:jagu_meet/screens/others/notifyPage.dart';
import 'package:jagu_meet/screens/profilePage.dart';
import 'package:jagu_meet/screens/settings/AdvancedSettings.dart';
import 'package:jagu_meet/screens/settings/generalSettings.dart';
import 'package:jagu_meet/screens/settings/joiningSettings.dart';
import 'package:jagu_meet/screens/settings/meetingSettings.dart';
import 'package:jagu_meet/screens/schedule/viewScheduled.dart';
import 'package:jagu_meet/screens/others/webview.dart';
//import 'package:jagu_meet/sever_db/feedbacks%20db/feedbacks_db_controller.dart';
//import 'package:jagu_meet/sever_db/feedbacks%20db/feeedbacks_db.dart';
//import 'package:jagu_meet/sever_db/meetings%20db/meetings_db.dart';
//import 'package:jagu_meet/sever_db/meetings%20db/servere_db_controller.dart';
import 'screens/root.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'screens/loginPage.dart';
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
import 'utils/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:jagu_meet/model/note.dart';
import 'utils/databasehelper_scheduled.dart';
import 'screens/schedule/NoteScreen.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:badges/badges.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/editPersonal.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
//import 'package:jagu_meet/sever_db/host meets db/host controller.dart';
//import 'package:jagu_meet/sever_db/host meets db/host meet db.dart';
import 'package:jagu_meet/screens/others/fullImage.dart';
import 'package:flutter/foundation.dart';

//jagadish_android_apps

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool('darkMode') ?? false;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: darkModeOn ? Colors.black : Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (_) => ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
        child: MaterialApp(
          home: root(),
        ),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  //final UserDetails detailsUser;
  //MyApp({Key key, this.detailsUser}) : super(key : key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  //final UserDetails detailsUser;
  // _MyAppState(this.detailsUser);

  List<Note> items = new List();
  // List<Note1> items1 = new List();
  List<Note2> items2 = new List();
  DatabaseHelper db = new DatabaseHelper();
  // DatabaseHelper1 db1 = new DatabaseHelper1();
  DatabaseHelper2 db2 = new DatabaseHelper2();

  int bottomSelectedIndex = 0;

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
        icon: new Icon(Icons.videocam),
        label: 'Meet',
      ),
      BottomNavigationBarItem(
        icon: items2.length == 0
            ? Icon(Icons.event)
            : Badge(
                toAnimate: true,
                animationType: BadgeAnimationType.scale,
                badgeContent: Text("${items2.length}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white)),
                child: Icon(Icons.event),
              ),
        label: 'Meetings',
      ),
      BottomNavigationBarItem(
        icon: new Icon(Icons.settings),
        label: 'Settings',
      ),
      BottomNavigationBarItem(
        icon: CachedNetworkImage(
          imageUrl: _userPhotoUrl,
          placeholder: (context, url) => Icon(Icons.person),
          errorWidget: (context, url, error) => Icon(Icons.person),
          imageBuilder: (context, imageProvider) => Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.scaleDown,
                  ))),
        ),
        label: 'Profile',
      )
    ];
  }

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
  FocusNode myFocusNode1 = FocusNode();

  PageController _controller = PageController(
    initialPage: 0,
    keepPage: true,
  );

  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );

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

  var webLink = 'meet.jit.si/';

  final hostRoomText = TextEditingController();
  final hostSubjectText = TextEditingController();
  var chatEnabled = true;
  var liveEnabled = false;
  var recordEnabled = false;
  var raiseEnabled = true;
  var kickEnabled = false;
  var shareYtEnabled = true;

  var copyEnabled = true;
  var useAvatar = true;

  var diagnostic;

  var quality;

  var PchatEnabled;
  var PliveEnabled;
  var PrecordEnabled;
  var PraiseEnabled;
  var PshareYtEnabled;
  var PKickOutEnabled;

  var PmeetingId = '...';
  var PmeetName;

  var SchatEnabled;
  var SliveEnabled;
  var SrecordEnabled;
  var SraiseEnabled;
  var SshareYtEnabled;
  var SKickOutEnabled;

  var linkchatEnabled;
  var linkliveEnabled;
  var linkrecordEnabled;
  var linkraiseEnabled;
  var linkYtEnabled = true;
  var linkKick;
  var linkHost = '';

  var _darkTheme;

  bool _idError = false;
  bool isButtonEnabled;
  bool isEnabled;

  final now = DateTime.now();
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
        useAvatar = prefs.getBool('useAvatar') ?? true;
      });
    });
    Future.delayed(Duration(milliseconds: 500), () {});
  }

  getPInfo() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        PchatEnabled = prefs.getBool('PchatEnabled') ?? true;
        PliveEnabled = prefs.getBool('PliveEnabled') ?? false;
        PrecordEnabled = prefs.getBool('PrecordEnabled') ?? false;
        PraiseEnabled = prefs.getBool('PraiseEnabled') ?? true;
        PshareYtEnabled = prefs.getBool('PshareYtEnabled') ?? true;
        PKickOutEnabled = prefs.getBool('PKickOutEnabled') ?? false;
      });
    });
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
          msg: 'No Internet Connection!',
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

  void _handleDeepLink(PendingDynamicLinkData data) {
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
      String linkroomid = deepLink.queryParameters['id'];
      String linkroomtopic = deepLink.queryParameters['pwd'];
      String linkch = deepLink.queryParameters['ch'];
      String linkrh = deepLink.queryParameters['rh'];
      String linkrm = deepLink.queryParameters['rm'];
      String linkls = deepLink.queryParameters['ls'];
      String linkyt = deepLink.queryParameters['yt'];
      String linkKo = deepLink.queryParameters['ko'];
      String host = deepLink.queryParameters['host'];
      setState(() {
        roomText.text = linkroomid;
        subjectText.text = linkroomtopic;
      });
      if (linkch == 'false') {
        setState(() {
          linkchatEnabled = false;
        });
      } else {
        setState(() {
          linkchatEnabled = true;
        });
      }
      if (linkrh == 'false') {
        setState(() {
          linkraiseEnabled = false;
        });
      } else {
        setState(() {
          linkraiseEnabled = true;
        });
      }
      if (linkrm == 'false') {
        setState(() {
          linkrecordEnabled = false;
        });
      } else {
        setState(() {
          linkrecordEnabled = true;
        });
      }
      if (linkls == 'false') {
        setState(() {
          linkliveEnabled = false;
        });
      } else {
        setState(() {
          linkliveEnabled = true;
        });
      }
      if (linkyt == 'false') {
        setState(() {
          linkYtEnabled = false;
        });
      } else {
        setState(() {
          linkYtEnabled = true;
        });
      }
      if (linkKo == 'false') {
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
      host == _userEmail ? _hostMeeting() : _joinLinkMeeting();
      print('Correct link');
    }
  }

  void onThemeChangedStart(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
    var darkModeOn = prefs.getBool('darkMode');
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: darkModeOn ? Colors.black : Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  var linkName = '...';
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
    setState(() {
      linkName = '${_userName[0]}' +
          '${_userUid.substring(1, 9)}' +
          '${_userName.substring(_userName.length - 1)}';
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

  initDataBase() {
    db.getAllNotes().then((notes) {
      setState(() {
        notes.forEach((note) {
          items.add(Note.fromMap(note));
        });
      });
    });
    db2.getAllNotes2().then((notes2) {
      setState(() {
        notes2.forEach((note2) {
          items2.add(Note2.fromMap(note2));
        });
      });
    });
  }

  Future<void> checkVersion() async {
    if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
      InAppUpdate.performImmediateUpdate();
    }
  }

  handleQuickActions() {
    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      setState(() {
        if (shortcutType != null) shortcut = shortcutType;
      });
      if (shortcutType == 'action_schedule') {
        _createNewNote(context);
      }
      if (shortcutType == 'action_random') {
        _joinRandomMeeting();
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
                      pmeet: PmeetingId,
                    )));
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
          type: 'action_schedule',
          localizedTitle: 'Schedule Meeting',
          icon: 'schedule'),
      const ShortcutItem(
          type: 'action_new', localizedTitle: 'New Meeting', icon: 'plus'),
      const ShortcutItem(
          type: 'action_random',
          localizedTitle: 'Random Meeting',
          icon: 'shuffle'),
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

  pmeetdetails() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        PmeetingId =
            prefs.getString('personalMeetId') ?? randomNumeric(11).toString();
        PmeetName = prefs.getString('personalMeet') ??
            _userName + "'s" + ' personal Just Meet meeting';
      });
    });
    Future.delayed(Duration(milliseconds: 500), () {});
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('personalMeetId', PmeetingId);
    });
    Future.delayed(Duration(milliseconds: 500), () {});
  }

  final ValueNotifier<bool> joinlinkname = ValueNotifier<bool>(false);
  joinchanged() async {
    roomText.clear();
    FocusManager.instance.primaryFocus.unfocus();
    joinlinkname.value = !joinlinkname.value;
    await Future.delayed(Duration(milliseconds: 500), () {});
    myFocusNode.requestFocus();
    istyping(roomText);
  }

  @override
  void initState() {
    super.initState();
    _getUserAuth();
    getSettings();
    getPInfo();
    pmeetdetails();
    handleDynamicLinks();
    handleQuickActions();
    initDataBase();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onPictureInPictureWillEnter: _onPictureInPictureWillEnter,
        onPictureInPictureTerminated: _onPictureInPictureTerminated,
        onError: _onError));
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
  }

  review() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

 // void _submitFeedbackData(
  //  String rating,
  //) {
    //FeedbacksDb feedbacksData = FeedbacksDb(_userEmail, _userName, rating);

  //  ServerController2 serverController2 = ServerController2((String response) {
   //   print(response);
   // });
   // serverController2.submitData2(feedbacksData);
  //}

  void meetFeedback() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
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
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: themeNotifier.getTheme() == darkTheme
                    ? Colors.blueAccent
                    : Colors.blue,
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
                  Fluttertoast.showToast(
                      msg: 'We are sorry for that...',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.SNACKBAR,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else if (stars <= 5) {
                  Fluttertoast.showToast(
                      msg: 'Thank You for your feedback!',
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
              overflow: TextOverflow.ellipsis,
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

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  Future<bool> exitConf() async {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return showDialog(
        context: context,
        builder: (context) {
          return Theme(
            data: themeNotifier.getTheme(),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
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
                      color: themeNotifier.getTheme() == darkTheme
                          ? Colors.blueAccent
                          : Colors.blue,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  color: Colors.transparent,
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: themeNotifier.getTheme() == darkTheme
                          ? Colors.blueAccent
                          : Colors.blue,
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
        appBarTitle = 'Settings';
      });
    } else if (index == 3) {
      setState(() {
        appBarTitle = 'Profile';
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

  void _onRefresh() async {
    setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  onSignOut() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('signStatus', false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: exitConf,
      child: MaterialApp(
        title: 'Just Meet',
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.getTheme(),
        home: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: themeNotifier.getTheme() == darkTheme
                ? Color(0xFF242424)
                : Colors.blue,
            elevation: 5,
            centerTitle: true,
            title: Text(
              appBarTitle,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.add,
              color: inMeeting
                  ? Colors.grey
                  : themeNotifier.getTheme() == darkTheme
                  ? Colors.blueAccent
                  : Colors.white),
                onPressed: () => inMeeting
                    ? null
                    : Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => HostPage(
                          name: _userName,
                          email: _userEmail,
                          uid: _userUid,
                          url: _userPhotoUrl,
                          pmeet: PmeetingId,
                          linkNName: linkName,
                        ))),
              ),
            ],
          ),
          resizeToAvoidBottomInset: false,
          drawer: mainDrawer(),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            unselectedItemColor: Colors.grey,
            backgroundColor: themeNotifier.getTheme() == darkTheme
                ? Color(0xFF242424)
                : Color(0xFFf9f9f9),
            selectedItemColor: themeNotifier.getTheme() == darkTheme
                ? Colors.blueAccent
                : Colors.blue,
            currentIndex: bottomSelectedIndex,
            onTap: (index) {
              bottomTapped(index);
            },
            items: buildBottomNavBarItems(),
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
                      Settings(),
                      profile(),
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
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    nameText.text = _userName;
    emailText.text = _userEmail;
    getSettings();
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Scaffold(
      floatingActionButton: showFab
                  ? FloatingActionButton.extended(
                      heroTag: "Random Meet",
                      elevation: 5,
                      onPressed: () => inMeeting ? null : _joinRandomMeeting(),
                      icon: Icon(
                        Icons.people_outline,
                        color: inMeeting
                            ? themeNotifier.getTheme() == darkTheme
                                ? Colors.grey
                                : Colors.white
                            : themeNotifier.getTheme() == darkTheme
                                ? Colors.blueAccent
                                : Colors.white,
                      ),
                      label: Text('Random Meet',
                          style: TextStyle(
                              color: inMeeting
                                  ? themeNotifier.getTheme() == darkTheme
                                      ? Colors.grey
                                      : Colors.white
                                  : themeNotifier.getTheme() == darkTheme
                                      ? Colors.blueAccent
                                      : Colors.white,
                              fontWeight: FontWeight.bold)),
                      backgroundColor: inMeeting
                          ? themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF242424)
                              : Colors.grey
                          : themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF242424)
                              : Colors.blue,
                    )
                  : Container(),
      body: SafeArea(
        child: Container(
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 15.0,
                ),
                ValueListenableBuilder(
                    valueListenable: joinlinkname,
                    builder: (BuildContext context, bool value, Widget child) {
                      return Column(children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: TextField(
                            focusNode: myFocusNode,
                            keyboardType: joinlinkname.value
                                ? TextInputType.text
                                : TextInputType.phone,
                            autofocus: false,
                            onChanged: (val) {
                              isEmpty();
                              istyping(roomText);
                            },
                            inputFormatters: [
                              joinlinkname.value
                                  ? FilteringTextInputFormatter.allow(
                                      RegExp('[a-zA-Z0-9]'))
                                  : FilteringTextInputFormatter.allow(
                                      RegExp('[0-9]')),
                            ],
                            maxLength: 11,
                            controller: roomText,
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 1.0),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
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
                                              size: 30, color: Colors.blue),
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
                                errorText:
                                    _idError ? 'Invalid Meeting Id' : null,
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelText: joinlinkname.value
                                    ? 'Personal Link Name'
                                    : "Meeting Id",
                                labelStyle: TextStyle(
                                  color: Colors.blue,
                                ),
                                fillColor: themeNotifier.getTheme() == darkTheme
                                    ? Color(0xFF191919)
                                    : Color(0xFFf9f9f9),
                                hintText: joinlinkname.value
                                    ? 'Personal Link Name'
                                    : 'Meeting Id'),
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
                              onTap: () {
                                joinchanged();
                              },
                              child: Text(
                                joinlinkname.value
                                    ? 'Join with Meeting ID'
                                    : 'Join with Personal Link Name',
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
                      ]);
                    }),
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
                ListTile(
                  tileColor: themeNotifier.getTheme() == darkTheme
                      ? Color(0xFF191919)
                      : Color(0xFFf9f9f9),
                  title: Text(
                    "Audio Only",
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
                      value: isAudioOnly,
                      onChanged: _onAudioOnlyChanged,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  title: Text(
                    "Audio Muted",
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
                        value: isAudioMuted,
                        onChanged: _onAudioMutedChanged,
                      )),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  focusColor: Colors.blue,
                  title: Text(
                    "Video Muted",
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
                      value: isVideoMuted,
                      onChanged: _onVideoMutedChanged,
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
                  onTap: () => Navigator.push(context,
                      CupertinoPageRoute(builder: (context) => joinSettings())),
                  title: Text(
                    'More Settings',
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
                    onPressed: inMeeting
                        ? null
                        : isButtonEnabled
                            ? () async {
                                useAvatar == true
                                    ? _joinMeeting()
                                    : _joinMeetingNoAvatar();
                              }
                            : null,
                    child: Text(
                      "Join Meeting",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    color: themeNotifier.getTheme() == darkTheme
                        ? Colors.blueAccent
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
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget mainDrawer() {
    final GoogleSignIn _gSignIn = GoogleSignIn();
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
                          pmeet: PmeetingId,
                          photoURL: _userPhotoUrl,
                          linkName: linkName,
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
                          CircularProgressIndicator(),
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            leading: Stack(
              children: [
                Icon(Icons.notifications),
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
              'Notifications',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            onTap: () {
              Navigator.push(
                  context, CupertinoPageRoute(builder: (context) => Notify()));
            },
          ),
          ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              leading: Icon(Icons.feedback),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              leading: Icon(Icons.report),
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            leading: Icon(Icons.help),
            title: Text(
              'Help',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            onTap: () => launchWebView(
                'https://justmeetpolicies.blogspot.com/p/just-meet-faqs.html',
                'FAQ'),
          ),
          ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              leading: Icon(Icons.share),
              title: Text(
                'Invite others to Just Meet',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              onTap: () {
                _share();
              }),
          ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              leading: Icon(
                Icons.thumb_up_alt_sharp,
              ),
              title: Text(
                'Rate Just Meet',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              onTap: () => _launchPlay()),
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            leading: Icon(
              Icons.coronavirus_outlined,
            ),
            title: Text(
              'COVID-19 Information Center',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            onTap: () => Navigator.push(context,
                CupertinoPageRoute(builder: (context) => InfoScreen())),
          ),
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  bottomRight: Radius.circular(30))),
                          leading: Text(
                            'Sign Out',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.normal),
                          ),
                          onTap: () async {
                            final action = await Dialogs.yesAbortDialog(
                                context,
                                'Sign Out',
                                'Do You Really want to sign out?',
                                'Sign Out',
                                'No');
                            if (action == DialogAction.yes) {
                              _gSignIn.signOut();
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
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
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
                  onTap: () => launchWebView(
                      'https://justmeetpolicies.blogspot.com/p/about-us.html',
                      'About Us'),
                  title: Text(
                    'About Us',
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
                  indent: 15,
                  endIndent: 0,
                ),
                ListTile(
                  tileColor: themeNotifier.getTheme() == darkTheme
                      ? Color(0xFF191919)
                      : Color(0xFFf9f9f9),
                  onTap: () => launchWebView(
                      'https://justmeetpolicies.blogspot.com/p/just-meet-privacy-policy.html',
                      'Privacy Policy'),
                  title: Text(
                    'Privacy Policy',
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
                  indent: 15,
                  endIndent: 0,
                ),
                ListTile(
                  tileColor: themeNotifier.getTheme() == darkTheme
                      ? Color(0xFF191919)
                      : Color(0xFFf9f9f9),
                  onTap: () => launchWebView(
                      'https://justmeetpolicies.blogspot.com/p/just-meet-terms-conditions.html',
                      'Terms & Conditions'),
                  title: Text(
                    'Terms & Conditions',
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
                    'Copyright ©2020 Jagadish Prasad Pattanaik. All rights reserved.',
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

  showRecentJoined() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    showModalBottomSheet(
        context: context,
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
                elevation: 5,
                leading: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  items.isNotEmpty
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
                  'Recent Meetings',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: themeNotifier.getTheme() == darkTheme
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
              body: SafeArea(
                child: Container(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Image(
                                  image: AssetImage('assets/images/clock.png')),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'No Recent Meetings',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              )
                            ]))
                      : Container(
                          height: double.maxFinite,
                          width: double.maxFinite,
                          child: SingleChildScrollView(
                            child: Column(children: [
                              ListView.separated(
                                shrinkWrap: true,
                                itemCount: items.length,
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
                                            Text(
                                              items[position].host == _userEmail
                                                  ? " Start"
                                                  : " Rejoin",
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
                                    key: Key(items[position].description),
                                    onDismissed: (direction) {
                                      if (direction ==
                                          DismissDirection.endToStart) {
                                        _deleteNote(
                                            context, items[position], position);
                                      } else {
                                        setState(() {
                                          roomText.text =
                                              '${items[position].description}';
                                          subjectText.text =
                                              '${items[position].title}';
                                        });
                                        isEmpty();
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        items[position].host == _userEmail
                                            ? _hostRecentMeeting(
                                                items[position].chatEnabled == 1
                                                    ? true
                                                    : false,
                                                items[position].liveEnabled == 1
                                                    ? true
                                                    : false,
                                                items[position].raiseEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position].recordEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position]
                                                            .shareYtEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position]
                                                            .kickOutEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position].host)
                                            : _joinRecentMeeting(
                                                items[position].chatEnabled == 1
                                                    ? true
                                                    : false,
                                                items[position].liveEnabled == 1
                                                    ? true
                                                    : false,
                                                items[position].raiseEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position].recordEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position]
                                                            .shareYtEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position]
                                                            .kickOutEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position].host);
                                      }
                                    },
                                    child: ListTile(
                                      onTap: () {
                                        setState(() {
                                          roomText.text =
                                              '${items[position].description}';
                                          subjectText.text =
                                              '${items[position].title}';
                                        });
                                        isEmpty();
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        items[position].host == _userEmail
                                            ? _hostRecentMeeting(
                                                items[position].chatEnabled == 1
                                                    ? true
                                                    : false,
                                                items[position].liveEnabled == 1
                                                    ? true
                                                    : false,
                                                items[position].raiseEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position].recordEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position]
                                                            .shareYtEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position]
                                                            .kickOutEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position].host)
                                            : _joinRecentMeeting(
                                                items[position].chatEnabled == 1
                                                    ? true
                                                    : false,
                                                items[position].liveEnabled == 1
                                                    ? true
                                                    : false,
                                                items[position].raiseEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position].recordEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position]
                                                            .shareYtEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position]
                                                            .kickOutEnabled ==
                                                        1
                                                    ? true
                                                    : false,
                                                items[position].host);
                                      },
                                      visualDensity: VisualDensity(
                                          horizontal: 0, vertical: -4),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.horizontal(
                                              right: Radius.circular(0),
                                              left: Radius.circular(0))),
                                      trailing: Text(
                                        items[position].title == ''
                                            ? ''
                                            : '${items[position].description}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: themeNotifier.getTheme() ==
                                                  darkTheme
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                      title: Text(
                                        items[position].title == ''
                                            ? '${items[position].description}'
                                            : '${items[position].title}',
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
                                                items[position].time))
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

  Widget scheduleMeeting() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    getPInfo();
    db2.getAllNotes2().then((notes2) {
      setState(() {
        items2.clear();
        notes2.forEach((note2) {
          items2.add(Note2.fromMap(note2));
        });
      });
    });
    checkInvalid();
    return Scaffold(
      body: SafeArea(
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropMaterialHeader(
            color: Colors.white,
            backgroundColor: themeNotifier.getTheme() == darkTheme
                ? Color(0xFF242424)
                : Colors.blue,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: Container(
                      padding: EdgeInsets.all(0),
                      height: 120,
                      width: double.maxFinite,
                      //color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Personal Meeting ID',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                PmeetingId,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    //color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RaisedButton(
                                elevation: 5,
                                color: inMeeting
                                    ? themeNotifier.getTheme() == darkTheme
                                        ? Color(0xFF121212)
                                        : Colors.grey
                                    : themeNotifier.getTheme() == darkTheme
                                        ? Color(0xFF242424)
                                        : Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  'Start',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                        inMeeting ? Colors.grey : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: inMeeting
                                    ? null
                                    : () async {
                                        var connectivityResult =
                                            await (Connectivity()
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
                                          var dynamicLink =
                                              await createDynamicLink(
                                                  meet: PmeetingId,
                                                  sub: PmeetName,
                                                  ch: PchatEnabled.toString(),
                                                  rh: PraiseEnabled.toString(),
                                                  rm: PrecordEnabled.toString(),
                                                  ls: PliveEnabled.toString(),
                                                  yt: PshareYtEnabled
                                                      .toString(),
                                                  ko: PKickOutEnabled
                                                      .toString(),
                                                  host: _userEmail);
                                          var dynamicWeb = webLink + PmeetingId;
                                          final action =
                                              await Dialogs.yesAbortDialog(
                                                  context,
                                                  'Invite Others',
                                                  'Invite Others to the meeting',
                                                  'Invite Others',
                                                  'Start Meeting');
                                          if (action == DialogAction.yes) {
                                            _sharePMI(
                                                PmeetingId,
                                                PmeetName,
                                                dynamicLink.toString(),
                                                dynamicWeb);
                                          }
                                          if (action == DialogAction.no) {
                                            useAvatar == true
                                                ? _hostPersonalMeeting()
                                                : _hostPersonalMeetingNoAvatar();
                                          }
                                        }
                                      },
                              ),
                              RaisedButton(
                                  elevation: 5,
                                  color: themeNotifier.getTheme() == darkTheme
                                      ? Color(0xFF242424)
                                      : Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    'Send Invitation',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () async {
                                    var connectivityResult =
                                        await (Connectivity()
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
                                          meet: PmeetingId,
                                          sub: PmeetName,
                                          ch: PchatEnabled.toString(),
                                          rh: PraiseEnabled.toString(),
                                          rm: PrecordEnabled.toString(),
                                          ls: PliveEnabled.toString(),
                                          yt: PshareYtEnabled.toString(),
                                          ko: PKickOutEnabled.toString(),
                                          host: _userEmail);
                                      var dynamicWeb = webLink + PmeetingId;
                                      print("Dynamic Link: $dynamicLink");
                                      _sharePMI(PmeetingId, PmeetName,
                                          dynamicLink.toString(), dynamicWeb);
                                    }
                                  }),
                              RaisedButton(
                                  elevation: 5,
                                  color: themeNotifier.getTheme() == darkTheme
                                      ? Color(0xFF242424)
                                      : Colors.deepOrange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    'Edit',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    getPInfo();
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) => editPersonal(
                                                chat: PchatEnabled,
                                                live: PliveEnabled,
                                                record: PrecordEnabled,
                                                raise: PraiseEnabled,
                                                id: PmeetingId,
                                                name: PmeetName,
                                                ytshare: PshareYtEnabled,
                                                kick: PKickOutEnabled)));
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: themeNotifier.getTheme() == darkTheme
                      ? Color(0xFF303030)
                      : Colors.black12,
                ),
                items2.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image(
                                  image:
                                      AssetImage('assets/images/schedule.png')),
                              Text(
                                'No Scheduled Meetings',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              )
                            ]))
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: items2.length,
                        itemBuilder: (BuildContext context, int position) {
                          SchatEnabled =
                              items2[position].chatEnabled2 == 1 ? true : false;
                          SliveEnabled =
                              items2[position].liveEnabled2 == 1 ? true : false;
                          SrecordEnabled = items2[position].recordEnabled2 == 1
                              ? true
                              : false;
                          SraiseEnabled = items2[position].raiseEnabled2 == 1
                              ? true
                              : false;
                          SshareYtEnabled =
                              items2[position].shareYtEnabled2 == 1
                                  ? true
                                  : false;
                          SKickOutEnabled =
                              items2[position].kickOutEnabled2 == 1
                                  ? true
                                  : false;

                          var dateFormat = new DateFormat('dd, MMM yyyy');
                          DateTime tomorrow = now.add(Duration(days: 1));
                          DateTime daytomorrow = now.add(Duration(days: 2));
                          DateTime yesterday = now.subtract(Duration(days: 1));
                          String formattedDate = dateFormat
                              .format(DateTime.parse(items2[position].date2));
                          var finalDate;
                          if (DateTime.parse(items2[position].date2).day ==
                                  now.day &&
                              DateTime.parse(items2[position].date2).month ==
                                  now.month &&
                              DateTime.parse(items2[position].date2).year ==
                                  now.year) {
                            finalDate = 'Today';
                          } else if ((DateTime.parse(items2[position].date2)
                                      .day ==
                                  tomorrow.day &&
                              DateTime.parse(items2[position].date2).month ==
                                  tomorrow.month &&
                              DateTime.parse(items2[position].date2).year ==
                                  tomorrow.year)) {
                            finalDate = 'Tomorrow';
                          } else if ((DateTime.parse(items2[position].date2)
                                      .day ==
                                  daytomorrow.day &&
                              DateTime.parse(items2[position].date2).month ==
                                  daytomorrow.month &&
                              DateTime.parse(items2[position].date2).year ==
                                  daytomorrow.year)) {
                            finalDate = 'Day After Tomorrow';
                          } else if ((DateTime.parse(items2[position].date2)
                                      .day ==
                                  yesterday.day &&
                              DateTime.parse(items2[position].date2).month ==
                                  yesterday.month &&
                              DateTime.parse(items2[position].date2).year ==
                                  yesterday.year)) {
                            finalDate = 'Yesterday';
                          } else {
                            finalDate = formattedDate;
                          }
                          var time = DateFormat.jm().format(DateFormat("hh:mm")
                              .parse(items2[position].from2));
                          var timeTo = DateFormat.jm().format(
                              DateFormat("hh:mm").parse(items2[position].to2));
                          return Dismissible(
                            background: Container(
                              color: Colors.red,
                              child: Align(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              child: Align(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
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
                            key: Key(items2[position].description2),
                            onDismissed: (direction) {
                              _deleteNote2(context, items2[position], position);
                            },
                            child: ListTile(
                              onTap: () => _navigateToViewNote(
                                  context, items2[position], position),
                              onLongPress: () => _navigateToViewNote(
                                  context, items2[position], position),
                              contentPadding: EdgeInsets.all(0),
                              dense: true,
                              leading: Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 12),
                                    )),
                              ),
                              trailing: Padding(
                                padding: EdgeInsets.only(right: 5),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        finalDate,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 70, // specific value
                                        child: RaisedButton(
                                          elevation: 3,
                                          textColor: Colors.white,
                                          color: inMeeting
                                              ? themeNotifier.getTheme() ==
                                                      darkTheme
                                                  ? Color(0xFF121212)
                                                  : Colors.grey
                                              : themeNotifier.getTheme() ==
                                                      darkTheme
                                                  ? Color(0xFF242424)
                                                  : Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          onLongPress: () => null,
                                          onPressed: inMeeting
                                              ? null
                                              : () async {
                                                  var connectivityResult =
                                                      await (Connectivity()
                                                          .checkConnectivity());
                                                  if (connectivityResult ==
                                                      ConnectivityResult.none) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'No Internet Connection!',
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity: ToastGravity
                                                            .SNACKBAR,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.black,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  } else {
                                                    var dynamicLink =
                                                        await createDynamicLink(
                                                            meet:
                                                                items2[position]
                                                                    .description2
                                                                    .replaceAll(
                                                                        RegExp(
                                                                            r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                                                        ""),
                                                            sub:
                                                                '${items2[position].title2}',
                                                            ch: SchatEnabled
                                                                .toString(),
                                                            rh: SraiseEnabled
                                                                .toString(),
                                                            rm: SrecordEnabled
                                                                .toString(),
                                                            ls: SliveEnabled
                                                                .toString(),
                                                            yt: SshareYtEnabled
                                                                .toString(),
                                                            ko: SKickOutEnabled
                                                                .toString(),
                                                            host: _userEmail);
                                                    var dynamicWeb = webLink +
                                                        items2[position]
                                                            .description2
                                                            .replaceAll(
                                                                RegExp(
                                                                    r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                                                "");
                                                    final action = await Dialogs
                                                        .yesAbortDialog(
                                                            context,
                                                            'Invite Others',
                                                            'Invite Others to the meeting',
                                                            'Invite Others',
                                                            'Start Meeting');
                                                    if (action ==
                                                        DialogAction.yes) {
                                                      _shareScheduledMeeting(
                                                          '${items2[position].description2}',
                                                          '${items2[position].title2}',
                                                          dynamicLink
                                                              .toString(),
                                                          dynamicWeb,
                                                          finalDate,
                                                          time,
                                                          timeTo);
                                                    }
                                                    if (action ==
                                                        DialogAction.no) {
                                                      setState(() {
                                                        hostRoomText.text =
                                                            '${items2[position].description2}';
                                                        hostSubjectText.text =
                                                            '${items2[position].title2}';
                                                      });
                                                      useAvatar == true
                                                          ? _hostScheduledMeeting()
                                                          : _hostScheduledMeetingNoAvatar();
                                                    }
                                                  }
                                                },
                                          child: Text(
                                            'Start',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: inMeeting
                                                    ? Colors.grey
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                              title: Text(
                                '${items2[position].title2}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    //color: Colors.black,
                                    fontSize: 16),
                              ),
                              subtitle: Text(
                                '${items2[position].description2}',
                                overflow: TextOverflow.ellipsis,
                              ),
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
                items2.length >= 1
                    ? Divider(
                        height: 1,
                        color: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF242424)
                            : Colors.black12,
                      )
                    : Container(),
              ]),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: themeNotifier.getTheme() == darkTheme
            ? Color(0xFF242424)
            : Colors.blue,
        elevation: 5,
        heroTag: "Schedule",
        icon: Icon(
          Icons.add,
          color: themeNotifier.getTheme() == darkTheme
              ? Colors.blueAccent
              : Colors.white,
          size: 30,
        ),
        onPressed: () => _createNewNote(context),
        label: Text(
          'Schedule',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.blueAccent
                  : Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget profile() {
    final GoogleSignIn _gSignIn = GoogleSignIn();
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
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
                  trailing: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                fullImage(url: _userPhotoUrl))),
                    child: CachedNetworkImage(
                      imageUrl: _userPhotoUrl,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.person),
                      imageBuilder: (context, imageProvider) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.scaleDown,
                              ))),
                    ),
                  ),
                  title: Text(
                    'Profile Photo',
                    overflow: TextOverflow.ellipsis,
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
                  title: Text('Account'),
                  trailing: Text(
                    _userEmail,
                    overflow: TextOverflow.ellipsis,
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
                  title: Text('Display Name'),
                  trailing: Text(
                    _userName,
                    overflow: TextOverflow.ellipsis,
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
                  onLongPress: () =>
                      Clipboard.setData(new ClipboardData(text: PmeetingId))
                          .then((_) {
                    Fluttertoast.showToast(
                        msg: 'PMI copied to clipboard',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.SNACKBAR,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }),
                  title: Text(
                    'Personal Meeting ID',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          PmeetingId,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () => Clipboard.setData(
                                  new ClipboardData(text: PmeetingId))
                              .then((_) {
                            Fluttertoast.showToast(
                                msg: 'PMI copied to clipboard',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.SNACKBAR,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }),
                          child: Icon(
                            Icons.copy_outlined,
                            size: 15,
                          ),
                        ),
                      ]),
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
                  onLongPress: () =>
                      Clipboard.setData(new ClipboardData(text: linkName))
                          .then((_) {
                    Fluttertoast.showToast(
                        msg: 'Personal Link Name copied to clipboard',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.SNACKBAR,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }),
                  tileColor: themeNotifier.getTheme() == darkTheme
                      ? Color(0xFF191919)
                      : Color(0xFFf9f9f9),
                  title: Text(
                    'Personal Link Name',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          linkName,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () => Clipboard.setData(
                                  new ClipboardData(text: linkName))
                              .then((_) {
                            Fluttertoast.showToast(
                                msg: 'Personal Link Name copied to clipboard',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.SNACKBAR,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }),
                          child: Icon(
                            Icons.copy_outlined,
                            size: 15,
                          ),
                        ),
                      ]),
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
                  title: Text(
                    'Plan',
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    'Free',
                    overflow: TextOverflow.ellipsis,
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
                  title: Text('License'),
                  trailing: Text(
                    'Unlimited Time and Participants',
                    overflow: TextOverflow.ellipsis,
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
                  onTap: () async {
                    final action = await Dialogs.yesAbortDialog(
                        context,
                        'Sign Out ?',
                        'Do you want to Sign Out from this account?',
                        'Sign Out',
                        'No');
                    if (action == DialogAction.yes) {
                      _gSignIn.signOut();
                      onSignOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        CupertinoPageRoute(
                            builder: (BuildContext context) => LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                      Fluttertoast.showToast(
                          msg: 'Signed Out',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.SNACKBAR,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                    if (action == DialogAction.abort) {}
                  },
                  title: Text(
                    'Sign Out',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
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
              ],
            ),
          ),
        ),
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
        "Download from Play Store: https://play.google.com/store/apps/details?id=com.jaguweb.jagu_meet"
        "\n"
        "See you on Just Meet..."
        "\n"
        "\n"
        "Developed in India with love..."
        "\n"
        "Stay Safe, Stay Connected with Just Meet...";
    final RenderBox box = context.findRenderObject();
    Share.share(textshare,
        subject: "$_userName is referring you to Join Just Meet",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  _launchPlay() async {
    var url =
        'https://play.google.com/store/apps/details?id=com.jaguweb.jagu_meet';
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

  clearDB() async {
    for (var i = 0; i < items.length; i++) {
      _deleteNote(context, items[i], i);
    }
    await Future.delayed(Duration(milliseconds: 1000));
    _deleteNote(context, items[0], 0);
  }

  checkInvalid() {
    DateTime now = DateTime.now();
    //if (_controller)
    for (var i = 0; i < items2.length; i++) {
      final date = DateTime.parse(items2[i].date2).add(const Duration(days: 2));
      if (items2[i].repeat == 'Never') {
        if (date.isBefore(now)) {
          _deleteNote2(context, items2[i], i);
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
  }

  void _deleteNote(BuildContext context, Note note, int position) async {
    db.deleteNote(note.id).then((notes) {
      setState(() {
        items.removeAt(position);
      });
    });
  }

  void _deleteNote2(BuildContext context, Note2 note2, int position) async {
    db2.deleteNote2(note2.id2).then((notes2) {
      setState(() {
        items2.removeAt(position);
      });
    });
  }

  void _navigateToViewNote(BuildContext context, Note2 note2, int pos) async {
    String result = await Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => viewScheduled(
                personalId: PmeetingId,
                items: items2,
                num: pos,
                name: _userName,
                email: _userEmail,
                PhotoUrl: _userPhotoUrl,
                uid: _userUid,
              )),
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

  void _createNewNote(BuildContext context) async {
    String result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => NoteScreen(
            Note2(
                '',
                randomNumeric(11),
                new DateFormat('yyyy-MM-dd').format(now).toString(),
                '',
                '',
                'Never',
                1,
                0,
                0,
                1,
                1,
                0),
            PmeetingId),
      ),
    );

    if (result == 'save') {
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
      'https://play-lh.googleusercontent.com/1UPWJehjpgF1SfEccYtNzxHY7U9WAeCqwKx_UnRh-DrrP-NcN2bmjQMI5Ig1o-5xZRTT=s180-rw');
  var urlLinkTitle = 'Join Just Meet Video Conference';
  var urlLinkDescription =
      'Just Meet is the leader in video conferences, with easy, secured, encrypted and reliable video and audio conferencing, chat, screen sharing and webinar across mobile and desktop. Unlimited participants and time with low bandwidth mode. Join Just Meet Video Conference now and enjoy high quality video conferences with security like no other. Stay Safe and Stay Connected with Just Meet. Developed in India with love.';

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
        imageUrl: linkImageUrl,
        title: urlLinkTitle,
        description: urlLinkDescription,
      ),
    );
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
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

  _onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isAudioOnly', value);
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
  //MeetingsDb meetingsData = MeetingsDb(meetid, meettopic, _userEmail,
  //_userName, _currentAddress, internal, external);
//
  //ServerController serverController = ServerController((String response) {
  //print(response);
  //});
  //serverController.submitData(meetingsData);
  //}

  //Future<void> _submitHostMeetingData(String meetid, String meettopic) async {
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

  _joinMeeting() async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    setState(() {
      roomText.text.length >= 10 ? _idError = false : _idError = true;
    });
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

      // Define meetings options here
      var options = JitsiMeetingOptions(room: roomText.text
          .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = 'Just Meet'
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
              //_submitMeetingData(
              //   JitsiMeetingOptions().room, JitsiMeetingOptions().subject);
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
              for (var i = 0; i < items.length; i++) {
                if (items[i].description != options.room) {
                } else {
                  _deleteNote(context, items[i], i);
                }
              }
              db.saveNote(Note(
                  '',
                  roomText.text,
                  DateTime.now().subtract(Duration(seconds: 2)).toString(),
                  1,
                  0,
                  0,
                  1,
                  1,
                  0,
                  ''));
              db.getAllNotes().then((notes) {
                setState(() {
                  items.clear();
                  notes.forEach((note) {
                    items.add(Note.fromMap(note));
                  });
                });
              });
              debugPrint("${options.room} joined with message: $message");
            }, onConferenceTerminated: (message) {
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
              meetFeedback();
              debugPrint("${options.room} terminated with message: $message");
            }, onPictureInPictureWillEnter: (message) {
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

  _joinRandomMeeting() async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    Map<FeatureFlagEnum, bool> featureFlags = {};

    try {
      if (_userEmail == 'jaguweb1234@gmail.com' ||
          _userEmail == 'jagadish.pr.pattanaik@gmail.com') {
        featureFlags[FeatureFlagEnum.WELCOME_PAGE_ENABLED] = false;
        //featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION;
        //FeatureFlagEnum. = true;
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

        if (Platform.isAndroid) {
          featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
          featureFlags[FeatureFlagEnum.INVITE_ENABLED] = false;
          featureFlags[FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE] = false;
          featureFlags[FeatureFlagEnum.MEETING_PASSWORD_ENABLED] = false;
        } else if (Platform.isIOS) {
          // Disable PIP on iOS as it looks weird
          featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
        }

        //if (timerEnabled == false) {
        // featureFlag.conferenceTimerEnabled = false;
        // }

        if (meetNameEnabled == false) {
          featureFlags[FeatureFlagEnum.MEETING_NAME_ENABLED] = false;
        }
      }

      List randommeets = [
        'randomjustmeetroom0001',
        'randomjustmeetroom0002',
        'randomjustmeetroom0003',
        'randomjustmeetroom0004'
      ];

      // Define meetings options here
      var options = JitsiMeetingOptions(room: (randommeets.toList()..shuffle()).first)
        ..serverURL = serverUrl
        ..subject = 'Random Meet'
        ..userDisplayName = _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..userAvatarURL = _userPhotoUrl
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": JitsiMeetingOptions(room: (randommeets.toList()..shuffle()).first).room,
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
                msg: 'Connecting You to a random meeting...',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            debugPrint("${options.room} will join with message: $message");
          }, onConferenceJoined: (message) async {
          //  _submitMeetingData(
            //    JitsiMeetingOptions().room, JitsiMeetingOptions().subject);
            setState(() {
              inMeeting = true;
            });
            Fluttertoast.showToast(
                msg: 'Joined Random Meeting',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            debugPrint("${options.room} joined with message: $message");
          }, onConferenceTerminated: (message) {
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
            meetFeedback();
            debugPrint("${options.room} terminated with message: $message");
          }, onPictureInPictureWillEnter: (message) {
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
          msg: "Couldn't Connect You any Random Meeting",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      debugPrint("error: $error");
    }
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
            //_submitHostMeetingData(
            //    JitsiMeetingOptions().room, JitsiMeetingOptions().subject);
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
                  ch: linkchatEnabled.toString(),
                  rh: linkraiseEnabled.toString(),
                  rm: linkrecordEnabled.toString(),
                  ls: linkliveEnabled.toString(),
                  yt: linkYtEnabled.toString(),
                  ko: linkKick.toString(),
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
            for (var i = 0; i < items.length; i++) {
              if (items[i].description != options.room) {
              } else {
                _deleteNote(context, items[i], i);
              }
            }
            db.saveNote(Note(
                subjectText.text,
                roomText.text,
                DateTime.now().toString(),
                linkchatEnabled == true ? 1 : 0,
                linkliveEnabled == true ? 1 : 0,
                linkrecordEnabled == true ? 1 : 0,
                linkraiseEnabled == true ? 1 : 0,
                linkYtEnabled == true ? 1 : 0,
                linkKick == true ? 1 : 0,
                linkHost));
            db.getAllNotes().then((notes) {
              setState(() {
                items.clear();
                notes.forEach((note) {
                  items.add(Note.fromMap(note));
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

  _joinLinkMeeting() async {
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
           // _submitMeetingData(
            //    JitsiMeetingOptions().room, JitsiMeetingOptions().subject);
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
            for (var i = 0; i < items.length; i++) {
              if (items[i].description != options.room) {
              } else {
                _deleteNote(context, items[i], i);
              }
            }
            db.saveNote(Note(
                subjectText.text,
                roomText.text,
                DateTime.now().toString(),
                linkchatEnabled == true ? 1 : 0,
                linkliveEnabled == true ? 1 : 0,
                linkrecordEnabled == true ? 1 : 0,
                linkraiseEnabled == true ? 1 : 0,
                linkYtEnabled == true ? 1 : 0,
                linkKick == true ? 1 : 0,
                linkHost));
            db.getAllNotes().then((notes) {
              setState(() {
                items.clear();
                notes.forEach((note) {
                  items.add(Note.fromMap(note));
                });
              });
            });
            debugPrint("${options.room} joined with message: $message");
          }, onConferenceTerminated: (message) {
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
            meetFeedback();
            debugPrint("${options.room} terminated with message: $message");
          }, onPictureInPictureWillEnter: (message) {
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

  _joinRecentMeeting(bool ch, bool live, bool raise, bool record, bool yt,
      bool kick, String host) async {
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
      var options = JitsiMeetingOptions(room: roomText.text
          .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = subjectText.text ?? 'Just Meet'
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
                msg: 'Connecting You to your meeting...',
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
                msg: 'Joined Meeting',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.SNACKBAR,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
            for (var i = 0; i < items.length; i++) {
              if (items[i].description != options.room) {
              } else {
                _deleteNote(context, items[i], i);
              }
            }
            db.saveNote(Note(
                subjectText.text,
                roomText.text,
                DateTime.now().toString(),
                ch == true ? 1 : 0,
                live == true ? 1 : 0,
                record == true ? 1 : 0,
                raise == true ? 1 : 0,
                yt == true ? 1 : 0,
                kick == true ? 1 : 0,
                host));
            db.getAllNotes().then((notes) {
              setState(() {
                items.clear();
                notes.forEach((note) {
                  items.add(Note.fromMap(note));
                });
              });
            });
            debugPrint("${options.room} joined with message: $message");
          }, onConferenceTerminated: (message) {
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
            meetFeedback();
            debugPrint("${options.room} terminated with message: $message");
          }, onPictureInPictureWillEnter: (message) {
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

  _hostRecentMeeting(bool ch, bool live, bool raise, bool record, bool yt,
      bool kick, String host) async {
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
      var options = JitsiMeetingOptions(room: roomText.text
          .replaceAll(RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = subjectText.text ?? 'Just Meet'
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
            for (var i = 0; i < items.length; i++) {
              if (items[i].description != options.room) {
              } else {
                _deleteNote(context, items[i], i);
              }
            }
            db.saveNote(Note(
                subjectText.text,
                roomText.text,
                DateTime.now().toString(),
                ch == true ? 1 : 0,
                live == true ? 1 : 0,
                record == true ? 1 : 0,
                raise == true ? 1 : 0,
                yt == true ? 1 : 0,
                kick == true ? 1 : 0,
                host));
            db.getAllNotes().then((notes) {
              setState(() {
                items.clear();
                notes.forEach((note) {
                  items.add(Note.fromMap(note));
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

  _hostPersonalMeeting() async {
    getPInfo();
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
      if (PchatEnabled == false) {
        featureFlags[FeatureFlagEnum.CHAT_ENABLED] = false;
      }

      //if (timerEnabled == false) {
      //  featureFlag.conferenceTimerEnabled = false;
      //}
      if (meetNameEnabled == false) {
        featureFlags[FeatureFlagEnum.MEETING_NAME_ENABLED] = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: PmeetingId.replaceAll(
          RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = PmeetName
        ..userDisplayName = _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..userAvatarURL = _userPhotoUrl
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": JitsiMeetingOptions(room: PmeetingId.replaceAll(
              RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "")).room,
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
           // _submitHostMeetingData(
           //     JitsiMeetingOptions().room, JitsiMeetingOptions().subject);
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
                  ch: PchatEnabled.toString(),
                  rh: PraiseEnabled.toString(),
                  rm: PrecordEnabled.toString(),
                  ls: PliveEnabled.toString(),
                  yt: PshareYtEnabled.toString(),
                  ko: PKickOutEnabled.toString(),
                  host: _userEmail);
              var dynamicWeb = webLink +
                  options.room.replaceAll(
                      RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "");
              final textshare =
                  "${nameText.text} is inviting you to join a Personal Just Meet meeting.  "
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

  _hostScheduledMeeting() async {
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
      if (SchatEnabled == false) {
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
              //  _submitHostMeetingData(
               //     JitsiMeetingOptions().room, JitsiMeetingOptions().subject);
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
                      ch: SchatEnabled.toString(),
                      rh: SraiseEnabled.toString(),
                      rm: SrecordEnabled.toString(),
                      ls: SliveEnabled.toString(),
                      yt: SshareYtEnabled.toString(),
                      ko: SKickOutEnabled.toString(),
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
                hostRoomText.clear();
                hostSubjectText.clear();
                meetFeedback();
                debugPrint("${options.room} terminated with message: $message");
              }, onPictureInPictureWillEnter: (message) {
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

  _joinMeetingNoAvatar() async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    setState(() {
      roomText.text.length >= 10 ? _idError = false : _idError = true;
    });

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

        if (Platform.isAndroid) {
          featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
          featureFlags[FeatureFlagEnum.INVITE_ENABLED] = false;
          featureFlags[FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE] = false;
          featureFlags[FeatureFlagEnum.MEETING_PASSWORD_ENABLED] = false;
        } else if (Platform.isIOS) {
          // Disable PIP on iOS as it looks weird
          featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
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
        ..subject = 'Just Meet'
        ..userDisplayName = _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
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
              //_submitMeetingData(
              //   JitsiMeetingOptions().room, JitsiMeetingOptions().subject);
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
              for (var i = 0; i < items.length; i++) {
                if (items[i].description != options.room) {
                } else {
                  _deleteNote(context, items[i], i);
                }
              }
              db.saveNote(Note(
                  '',
                  roomText.text,
                  DateTime.now().subtract(Duration(seconds: 2)).toString(),
                  1,
                  0,
                  0,
                  1,
                  1,
                  0,
                  ''));
              db.getAllNotes().then((notes) {
                setState(() {
                  items.clear();
                  notes.forEach((note) {
                    items.add(Note.fromMap(note));
                  });
                });
              });
              debugPrint("${options.room} joined with message: $message");
            }, onConferenceTerminated: (message) {
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
              meetFeedback();
              debugPrint("${options.room} terminated with message: $message");
            }, onPictureInPictureWillEnter: (message) {
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

  _hostPersonalMeetingNoAvatar() async {
    getPInfo();
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
      if (PchatEnabled == false) {
        featureFlags[FeatureFlagEnum.CHAT_ENABLED] = false;
      }

      //if (timerEnabled == false) {
      //  featureFlag.conferenceTimerEnabled = false;
      //}
      if (meetNameEnabled == false) {
        featureFlags[FeatureFlagEnum.MEETING_NAME_ENABLED] = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: PmeetingId.replaceAll(
          RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""))
        ..serverURL = serverUrl
        ..subject = PmeetName
        ..userDisplayName = _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
          "roomName": JitsiMeetingOptions(room: PmeetingId.replaceAll(
              RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "")).room,
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
           // _submitHostMeetingData(
           //     JitsiMeetingOptions().room, JitsiMeetingOptions().subject);
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
            // db1.saveNote1(Note1('Personal Meeting', PmeetingId));
            // db1.getAllNotes1().then((notes1) {
            //   setState(() {
            //     items1.clear();
            //     notes1.forEach((note1) {
            //       items1.add(Note1.fromMap(note1));
            //     });
            //   });
            // });
            if (copyEnabled == true) {
              var dynamicLink = await createDynamicLink(
                  meet: options.room.replaceAll(
                      RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), ""),
                  sub: options.subject,
                  ch: PchatEnabled.toString(),
                  rh: PraiseEnabled.toString(),
                  rm: PrecordEnabled.toString(),
                  ls: PliveEnabled.toString(),
                  yt: PshareYtEnabled.toString(),
                  ko: PKickOutEnabled.toString(),
                  host: _userEmail);
              var dynamicWeb = webLink +
                  options.room.replaceAll(
                      RegExp(r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'), "");
              final textshare =
                  "${nameText.text} is inviting you to join a Personal Just Meet meeting.  "
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
      if (SchatEnabled == false) {
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
                //_submitHostMeetingData(
                //    JitsiMeetingOptions().room, JitsiMeetingOptions().subject);
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
                      ch: SchatEnabled.toString(),
                      rh: SraiseEnabled.toString(),
                      rm: SrecordEnabled.toString(),
                      ls: SliveEnabled.toString(),
                      yt: SshareYtEnabled.toString(),
                      ko: PKickOutEnabled.toString(),
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
                hostRoomText.clear();
                hostSubjectText.clear();
                meetFeedback();
                debugPrint("${options.room} terminated with message: $message");
              }, onPictureInPictureWillEnter: (message) {
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

  _sharePMI(
      String roomids, String topics, String androidUrl, String url) async {
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
          "${nameText.text} is inviting you to join a Personal Just Meet meeting.  "
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
          subject:
              "${nameText.text} is inviting you to join a Just Meet Personal meeting.  ",
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }

  _shareScheduledMeeting(String roomids, String topics, String androidUrl,
      String url, String date, String from, String to) async {
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
          "${nameText.text} is inviting you to join a scheduled Just Meet meeting.  "
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
          subject:
              "${nameText.text} is inviting you to join a Just Meet meeting.  "
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
}
