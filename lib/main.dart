import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
//import 'package:jagu_meet/screens/agora/hostLive.dart';
//import 'package:jagu_meet/screens/agora/join.dart';
import 'package:jagu_meet/screens/meeting/globalLiveDetails.dart';
import 'package:jagu_meet/screens/meeting/host.dart';
import 'package:jagu_meet/screens/meeting/meetDetails.dart';
import 'package:jagu_meet/screens/others/app_feedback.dart';
import 'package:jagu_meet/screens/others/covAwarness.dart';
import 'package:jagu_meet/screens/others/infoPage.dart';
import 'package:jagu_meet/screens/others/report_abuse.dart';
import 'package:jagu_meet/screens/others/notifyPage.dart';
import 'package:jagu_meet/screens/user/profilePage.dart';
import 'package:jagu_meet/screens/meeting/settings/AdvancedSettings.dart';
import 'package:jagu_meet/screens/meeting/settings/generalSettings.dart';
import 'package:jagu_meet/screens/meeting/settings/joiningSettings.dart';
import 'package:jagu_meet/screens/meeting/settings/meetingSettings.dart';
import 'package:jagu_meet/screens/meeting/schedule/viewScheduled.dart';
import 'package:jagu_meet/screens/others/webview.dart';
import 'package:jagu_meet/widgets/cupertinoSwitchListTile.dart';
import 'package:jagu_meet/widgets/quiet_box.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
//import 'package:jagu_meet/sever_db/feedbacks%20db/feedbacks_db_controller.dart';
//import 'package:jagu_meet/sever_db/feedbacks%20db/feeedbacks_db.dart';
//import 'package:jagu_meet/sever_db/meetings%20db/meetings_db.dart';
//import 'package:jagu_meet/sever_db/meetings%20db/servere_db_controller.dart';
//import 'model/live.dart';
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
import 'utils/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:jagu_meet/model/note.dart';
import 'utils/databasehelper_scheduled.dart';
import 'screens/meeting/schedule/NoteScreen.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:badges/badges.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
//import 'package:jagu_meet/sever_db/host meets db/host controller.dart';
//import 'package:jagu_meet/sever_db/host meets db/host meet db.dart';
import 'package:jagu_meet/screens/others/fullImage.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:jagu_meet/model/liveMeetModel.dart';
import 'dart:async';
import 'package:url_strategy/url_strategy.dart';

//jagadish_android_apps

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences.getInstance().then((prefs) {
    var darkModeOn = prefs.getBool('darkMode') ?? SchedulerBinding.instance.window.platformBrightness == Brightness.dark ? true : false;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    //  statusBarIconBrightness: darkModeOn ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: darkModeOn
          ? Color(0xff0d0d0d)
          : Color(0xFFFFFFFF),
     // systemNavigationBarIconBrightness: darkModeOn ? Brightness.dark : Brightness.dark,
    ));
    setPathUrlStrategy();
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
  @override
  _MyAppState createState() => _MyAppState();
}

final liveMeetReference = FirebaseDatabase.instance.reference().child('liveMeet');

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  List<Note> items = [];
  List<Note2> items2 = [];
  DatabaseHelper db = new DatabaseHelper();
  DatabaseHelper2 db2 = new DatabaseHelper2();

  //final FlareControls flareControls = FlareControls();
  //final databaseReference = FirebaseFirestore.instance;
  //List<Live> list =[];
  //bool ready =false;
  //Live liveUser;
  //var image ='https://nichemodels.co/wp-content/uploads/2019/03/user-dummy-pic.png';

  List<LiveMeet> liveMeets = [];
  StreamSubscription _onMeetAddedSubscription;
  StreamSubscription _onMeetChangedSubscription;
  StreamSubscription _onMeetDeletedSubscription;

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
  FocusNode myFocusNode1 = FocusNode();

  PageController _controller = PageController(
    initialPage: 0,
    keepPage: true,
  );

  RefreshController _refreshController =
  RefreshController(initialRefresh: true);

  final serverText = TextEditingController();
  final roomText = TextEditingController();
  final subjectText = TextEditingController();
  final nameText = TextEditingController();
  final emailText = TextEditingController();

  final liveMeetTopic = TextEditingController();

  //AnimationController animecontroller;

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

  bool isButtonEnabled;
  bool isEnabled;

  bool searchState = false;

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
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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
      statusBarColor: Colors.transparent,
     // statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: darkModeOn
          ? Color(0xff0d0d0d)
          : Color(0xFFFFFFFF),
     // systemNavigationBarIconBrightness: Brightness.dark,
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

  AnimationController _animationController;

  @override
  void initState() {
    _getUserAuth();
    getSettings();
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
    _onMeetAddedSubscription = liveMeetReference.onChildAdded.listen(_onMeetAdded);
    _onMeetChangedSubscription = liveMeetReference.onChildChanged.listen(_onMeetUpdated);
    _onMeetDeletedSubscription = liveMeetReference.onChildRemoved.listen(_onMeetRemoved);
    //list = [];
    //liveUser = new Live(username: _userName,me: true,image: _userPhotoUrl );
    //setState(() {
    //  list.add(liveUser);
    //});
   // dbChangeListen();
    _animationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    getGlobalSettings();
    isEmpty();
    getDevice();
    getAppInfo();
    checkConnection();
    Future.delayed(Duration(milliseconds: 500), () {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('Signed in as ' + _userName,)));
    });
    review();
    super.initState();
  }

  //void dbChangeListen(){
   // databaseReference.collection('liveuser').orderBy("time",descending: true)
   //     .snapshots()
  //      .listen((result) {   // Listens to update in appointment collection
//
  //    setState(() {
  //      list = [];
  //      liveUser = new Live(username: _userName ,me: true,image: _userPhotoUrl );
  //      list.add(liveUser);
  //    });
  //    result.docs.forEach((result) {
  //      setState(() {
   //       list.add(new Live(username: result.data()['name'],image: result.data()['image'],channelId:result.data()['channel'],me: false));
//
   //     });
  //    });
   // });
//
  //}

  review() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  _onMeetRemoved(Event event) {
    setState(() {
      liveMeets.remove(LiveMeet.fromSnapshot(event.snapshot));
    });
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
                    ? Color(0xff0184dc)
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

  @override
  void dispose() {
    JitsiMeet.removeAllListeners();
    _onMeetAddedSubscription.cancel();
    _onMeetChangedSubscription.cancel();
    _onMeetDeletedSubscription.cancel();
    _animationController.dispose();
    super.dispose();
    //animecontroller.dispose();
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
                          ? Color(0xff0184dc)
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
                          ? Color(0xff0184dc)
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
        appBarTitle = 'Live';
      });
    } else if (index == 3) {
      setState(() {
        appBarTitle = 'Settings';
      });
    } else if (index == 4) {
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

  onSignOut() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('signStatus', false);
    });
  }

  List restrictedTopics = [
    'Just Meet',
    'just Meet',
    'Just meet',
    'just meet',
    'JustMeet',
    'justMeet',
    'Justmeet',
    'justmeet',
  ];

  List restrictedIds = [
    '99999999999',
    '88888888888',
    '77777777777',
    '66666666666',
    '55555555555',
    '44444444444',
    '33333333333',
    '22222222222',
    '11111111111',
    '12345678900',
    '12345678910',
    '01234567890',
  ];

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


  bool hateError = false;
  bool restrcitedTopicError =  false;
  bool restrcitedIdError =  false;
  restrictedTopicDetect(final TextEditingController controller) {
    for (var i = 0; i < restrictedTopics.length; i++) {
      if (controller.text.contains(restrictedTopics[i])) {
        setState(() {
          restrcitedTopicError = true;
        });
      } else if (controller.text.toLowerCase().contains(restrictedTopics[i])) {
        setState(() {
          restrcitedTopicError = true;
        });
      } else if (controller.text.toUpperCase().contains(restrictedTopics[i])) {
        setState(() {
          restrcitedTopicError = true;
        });
      } else if (controller.text.isEmpty) {
        setState(() {
          restrcitedTopicError = false;
        });
      }else if (!controller.text.contains(restrictedTopics[i])) {
        setState(() {
          restrcitedTopicError = false;
        });
      } else if (!controller.text.toLowerCase().contains(restrictedTopics[i])) {
        setState(() {
          restrcitedTopicError = false;
        });
      } else if (!controller.text.toUpperCase().contains(restrictedTopics[i])) {
        setState(() {
          restrcitedTopicError = false;
        });
      }
    }
  }

  restrictedIdDetect(final TextEditingController controller) {
    for (var i = 0; i < restrictedIds.length; i++) {
      if (controller.text.contains(restrictedIds[i])) {
        setState(() {
          restrcitedIdError = true;
        });
      } else if (controller.text.toLowerCase().contains(restrictedIds[i])) {
        setState(() {
          restrcitedIdError = true;
        });
      } else if (controller.text.toUpperCase().contains(restrictedIds[i])) {
        setState(() {
          restrcitedIdError = true;
        });
      } else if (controller.text.isEmpty) {
        setState(() {
          restrcitedIdError = false;
        });
      }else if (!controller.text.contains(restrictedIds[i])) {
        setState(() {
          restrcitedIdError = false;
        });
      } else if (!controller.text.toLowerCase().contains(restrictedIds[i])) {
        setState(() {
          restrcitedIdError = false;
        });
      } else if (!controller.text.toUpperCase().contains(restrictedIds[i])) {
        setState(() {
          restrcitedIdError = false;
        });
      }
    }
  }

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
      } else if (!controller.text.contains(hateSpeech[i])) {
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

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.videocam_outlined),
        activeIcon: Icon(Icons.videocam),
        label: 'Meet',
      ),
      BottomNavigationBarItem(
        icon: items2.length == 0
            ? Icon(Icons.schedule_outlined)
            : Badge(
          toAnimate: true,
          animationType: BadgeAnimationType.scale,
          badgeContent: Text("${items2.length}",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white)),
          child: Icon(Icons.schedule_outlined),
        ),
        label: 'Meetings',
      ),
      BottomNavigationBarItem(
        icon: liveMeets.isEmpty ? Icon(Icons.live_tv_outlined) :  Stack(
            children: <Widget>[
              Icon(Icons.live_tv_outlined),
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
        ),
        label: 'Live',
      ),
      BottomNavigationBarItem(
    activeIcon: Icon(Icons.settings),
        icon: new Icon(Icons.settings_outlined),
        label: 'Settings',
      ),
      BottomNavigationBarItem(
    activeIcon: CachedNetworkImage(
      imageUrl: _userPhotoUrl,
      placeholder: (context, url) => Icon(Icons.person),
      errorWidget: (context, url, error) => Icon(Icons.person),
      imageBuilder: (context, imageProvider) => Container(
          width: 23,
          height: 23,
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
              //onChanged: (text) {
             //   searchMethod(text);
             // },
             // decoration: InputDecoration(icon: Icon(Icons.search), hintText: 'Search global meetings...', hintStyle: TextStyle(color: Colors.white)),),
            actions: [
         //     bottomSelectedIndex == 2 ? !searchState ? IconButton(icon: Icon(Icons.search, color: Colors.white,), onPressed: () {
           //     setState(() {
           //       searchState = !searchState;
           //     });
          //    }) : IconButton(icon: Icon(Icons.clear, color: Colors.white,), onPressed: () {
            //    setState(() {
           //       searchState = !searchState;
            //    });
           //   }) : Container(),
              inMeeting == false
                  ? IconButton(
                  icon: Icon(
                    Icons.add,
              color: Colors.white),
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
                }
              ) : Container(),
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
      iconSize: 25,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedFontSize: 10,
      unselectedFontSize: 10,
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
    nameText.text = _userName;
    emailText.text = _userEmail;
    getSettings();
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Scaffold(
      floatingActionButton: showFab
                  ? inMeeting == false
          ? FloatingActionButton.extended(
                      heroTag: "Random Meet",
                      elevation: 5,
                      onPressed: () => inMeeting ? null : _joinRandomMeeting(),
                      icon: Icon(
                        Icons.shuffle_outlined,
                        color: Colors.white,
                      ),
                      label: Text('Random Meet',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      backgroundColor:themeNotifier.getTheme() == darkTheme
                              ? Color(0xff0184dc)
                              : Colors.blue,
                    ) : Container()
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
                              restrictedIdDetect(roomText);
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
                                errorText:
                                    restrcitedIdError ? 'Invalid Meeting Id' : null,
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              leading: Icon(Icons.share_outlined),
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
                Icons.thumb_up_alt_outlined,
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
                  subtitle: Text('Version, Dark mode, Diagnostic info', overflow: TextOverflow.ellipsis,),
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
                  subtitle: Text('Joining, Hosting, Global meet, Random meet settings', overflow: TextOverflow.ellipsis,),
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
                    'Copyright ©2020 Just Technologies. All rights reserved.',
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
                    ? Color(0xFF191919)
                    : Colors.white,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.keyboard_arrow_down_rounded),
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
                        ? Colors.white : Colors.black54,
                  ),
                ),
              ),
              body: SafeArea(
                child: Container(
                  child: items.isEmpty
                      ? QuietBox(
                    heading: "This is where all your recently joined meetings are listed",
                    subtitle:
                    "There are no recently joined meetings, join one now",
                  )
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
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => meetDetails(db: 'join', num: position, name: _userName, email: _userEmail, PhotoUrl: _userPhotoUrl, uid: _userUid, items: items,)));
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
        child: items2.isEmpty
            ? Container(
        child: QuietBox(
          heading: "This is where all your scheduled meetings are listed",
          subtitle:
          "There are no schedule a meetings, schedule one for future now",
        )
        )
            : Container(
          height: double.maxFinite,
            child: Column(
                  children: <Widget>[
               ListView.separated(
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
                                child: Text(
                                        finalDate,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                    : Container(height: 0,),
              ]),
            ),
          ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: themeNotifier.getTheme() == darkTheme
            ? Color(0xff0184dc)
            : Colors.blue,
        elevation: 5,
        heroTag: "Schedule",
        icon: Icon(
          Icons.schedule_outlined,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () => _createNewNote(context),
        label: Text(
          'Schedule',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget liveMeeting() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Scaffold(
      floatingActionButton: showFab
          ? inMeeting == false
          ? FloatingActionButton.extended(
        heroTag: "Global Meet",
        elevation: 5,
        onPressed:  ()
    {
      liveMeetTopic.clear();
      _displayDialog();
    },
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
        label: Text('Global Meet',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        backgroundColor: themeNotifier.getTheme() == darkTheme
            ? Color(0xff0184dc)
            : Colors.blue,
      ) : Container()
          : Container(),
        body: SafeArea(
        child: liveMeets.isEmpty
        ?
            Container(
        child: QuietBox(
        heading: "This is where you can find all global live meetings",
        subtitle:
        "There are no global meetings live now, host one and let people join you",
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
            itemCount: liveMeets.length,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 10,); },
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
                title: Text(liveMeets[position].topic),
                subtitle: liveMeets[position].host != _userName ? Text( 'Hosted by ' + liveMeets[position].host + ', ' + 'started at ' + liveMeets[position].started) : Text('Hosted by You at ' + liveMeets[position].started),
                contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 10),
                onTap:  () {
                  if (inMeeting == false) {
                      if (liveMeets[position].host != _userEmail) {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>
                                    LiveDetails(id: liveMeets[position].meetId,
                                      topic: liveMeets[position].topic,
                                      host: liveMeets[position].host,
                                      name: _userName,
                                      uid: _userUid,
                                      email: _userEmail,
                                      PhotoUrl: _userPhotoUrl,
                                      ch: liveMeets[position].chatEnabled,
                                      raise: liveMeets[position].raiseEnabled,
                                      record: liveMeets[position].recordEnabled,
                                      live: liveMeets[position].liveEnabled,
                                      yt: liveMeets[position].shareYtEnabled,
                                      kick: liveMeets[position].kickEnabled,
                                      started: liveMeets[position].started,)));
                      }
                  }  else {
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
    ),
        ),
    );
  }

  Widget profile() {
    final GoogleSignIn _gSignIn = GoogleSignIn();
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
                  trailing: GestureDetector(
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
                  trailing: Text(_userEmail),
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
                  trailing: Text(_userName),
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
                  title: Text('Plan'),
                  subtitle: Text('Free'),
                  onTap: () =>  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => Information(
                            text: 'Completely free and unlimited plan. Neither ads are shown nor your user data is sold for profit. Your love and support is our greatest motivation.',
                            title: 'Plan',
                          ))),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.grey,
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
                  subtitle: Text('Unlimited Time and Participants'),
                  onTap: () =>  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => Information(
                            text: "You have been given unlimited meeting time and participants number without compromising quality and security. Your meetings are encrypted even Just Meet can't see them. So enjoy your unlimited free meetings.",
                            title: 'License',
                          ))),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.grey,
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
                      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('Signed Out',)));
                    }
                    if (action == DialogAction.abort) {}
                  },
                  title: Text(
                    'Sign Out',
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

  _displayDialog() async {
    bool start = false;
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return showDialog(
        context: context,
        builder: (context) {
          return Theme(
            data: themeNotifier.getTheme(),
            child: StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text('New Global Live Meeting'),
                    elevation: 5,
                    content: TextField(
                      controller: liveMeetTopic,
                      textInputAction: TextInputAction.go,
                      textAlign: TextAlign.center,
                      onChanged: (val) {
                        restrictedTopicDetect(liveMeetTopic);
                        hateDetect(liveMeetTopic);
                        if (liveMeetTopic.text.length > 3) {
                          setState(() {
                            start = true;
                          });
                        } else if (liveMeetTopic.text.length < 3) {
                          setState(() {
                            start = false;
                          });
                        }
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(hintText: "Meeting Topic",
                          errorText: restrcitedTopicError ? "Can't use this meeting topic" : hateError ? 'Hate speech detected!' : null),
                    ),
                    actions: <Widget>[
                      new TextButton(
                        child: new Text('Start',
                          style: TextStyle(color: start
                              ? Colors.blue
                              : Colors.grey),),
                        onPressed: start ? () {
                          var mid = randomNumeric(11);
                          Navigator.pop(context);
                          _hostLiveMeeting(
                              mid, liveMeetTopic.text, liveMeets.length);
                        } : null,
                      )
                    ],
                  );
                }
            ),
          );
        });
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
    setState(() {
      liveMeets = [];
    });
    _onMeetAddedSubscription.cancel();
    _onMeetChangedSubscription.cancel();
    _onMeetAddedSubscription = liveMeetReference.onChildAdded.listen(_onMeetAdded);
    _onMeetChangedSubscription = liveMeetReference.onChildChanged.listen(_onMeetUpdated);
    if(mounted)
      setState(() {

      });
    _refreshController.loadComplete();
  }

  _launchPlay() async {
    var url =
        'https://play.google.com/store/apps/details?id=com.jaguweb.jagu_meet';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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
          ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('Scheduled meeting has expired',)));
        } else {}
      } else {}
    }
  }

  void _onMeetAdded(Event event) {
    setState(() {
      liveMeets.add(new LiveMeet.fromSnapshot(event.snapshot));
    });
  }

  void _onMeetUpdated(Event event) {
    var oldMeetValue = liveMeets.singleWhere((meets) => meets.id == event.snapshot.key);
    setState(() {
      liveMeets[liveMeets.indexOf(oldMeetValue)] = new LiveMeet.fromSnapshot(event.snapshot);
    });
  }

  void _deleteLiveMeet(BuildContext context, LiveMeet meets, int position) async {
    await liveMeetReference.child(meets.id).remove().then((_) {
      setState(() {
        liveMeets.removeAt(position);
      });
    });
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
      ),
    ));

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
      'https://play-lh.googleusercontent.com/7ZrxSsCqSNb86h57pPlJ3budCKTTZrCDSB3aq1F-srZnhO4M1iNtCXaM7fvxuJU3Yg=s180-rw');
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
      iosParameters: IosParameters(
        bundleId: '...',
        fallbackUrl: Uri.parse('https://jmeet-8e163.web.app/'),
        ipadFallbackUrl: Uri.parse('https://jmeet-8e163.web.app/'),
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
                  'Just Meet',
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

  _hostLiveMeeting(String id, String topic, int position) async {
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

      // Define meetings options here
      var options = JitsiMeetingOptions(room: id)
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
          "roomName": JitsiMeetingOptions(room: id),
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
            liveMeetReference.push().set({
              'meetId': id,
              'topic': liveMeetTopic.text,
              'host': _userName,
              'chat': GchatEnabled,
              'raise': GraiseEnabled,
              'record': GrecordEnabled,
              'live': GliveEnabled,
              'yt': GshareYtEnabled,
              'started': DateFormat.jm().format(DateTime.now()).toString(),
              //'country': await getCountryName(),
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
          }, onConferenceTerminated: (message) {
            setState(() {
              inMeeting = false;
            });
            _deleteLiveMeet(context, liveMeets[position], position);
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

  _joinRandomMeeting() async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    var anonymous;
    var gender;
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        anonymous = prefs.getBool('anonymous') ?? false;
        gender = prefs.getString('Agender') ?? 'None';
      });
    });

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

      var options = JitsiMeetingOptions(room: gender == 'None' ? anonymous == true ?  'randomjustmeetroomnoneUse' : 'randomjustmeetroomnone' : gender == 'Female' ? anonymous == true ? 'randomjustmeetroomfemaleUse' : 'randomjustmeetroomfemale' : anonymous == true ? 'randomjustmeetroommaleUse' : 'randomjustmeetroommale')
        ..serverURL = serverUrl
        ..subject = 'Random Meet'
        ..userDisplayName = anonymous ? 'Anonymous' : _userName
        ..userEmail = _userEmail
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..featureFlags.addAll(featureFlags)
        ..webOptions = {
        //(randommeets.toList()..shuffle()).first).room
          "roomName": JitsiMeetingOptions(room: gender == 'None' ? anonymous == true ?  'randomjustmeetroomnoneUse' : 'randomjustmeetroomnone' : gender == 'Female' ? anonymous == true ? 'randomjustmeetroomfemaleUse' : 'randomjustmeetroomfemale' : anonymous == true ? 'randomjustmeetroommaleUse' : 'randomjustmeetroommale'),
          "width": "100%",
          "height": "100%",
          "enableWelcomePage": false,
          "chromeExtensionBanner": null,
          "userInfo": {"displayName": anonymous ? 'Anonymous' : _userName}
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
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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

  _joinMeetingNoAvatar() async {
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
          ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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
