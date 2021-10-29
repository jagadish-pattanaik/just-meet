import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:jagu_meet/screens/meeting/details/globalLiveDetails.dart';
import 'package:jagu_meet/screens/meetweb/webFeedback.dart';
import 'package:jagu_meet/screens/meetweb/webHost.dart';
import 'package:jagu_meet/screens/meetweb/webJoin.dart';
import 'package:jagu_meet/screens/meetweb/webLive.dart';
import 'package:jagu_meet/screens/meetweb/webReport.dart';
import 'package:jagu_meet/screens/meetweb/webUpcoming.dart';
import 'package:jagu_meet/screens/meeting/schedule/NoteScreen.dart';
import 'package:jagu_meet/screens/meeting/schedule/viewScheduled.dart';
import 'package:jagu_meet/widgets/loading.dart';
import 'package:jagu_meet/widgets/quiet_box.dart';
import 'package:jagu_meet/widgets/webAppBar.dart';
import 'package:jagu_meet/widgets/webBottomBar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:random_string/random_string.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jagu_meet/screens/user/profilePage.dart';
import 'package:jagu_meet/screens/meeting/settings/AdvancedSettings.dart';
import 'package:jagu_meet/screens/meeting/settings/generalSettings.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jagu_meet/screens/user/loginPage.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:jagu_meet/screens/others/fullImage.dart';
import 'dart:async';
import '../meeting/search/searchMeetings.dart';
import '../meeting/startLive.dart';
import 'package:intl/intl.dart';

//flutter run --debug -d chrome --web-port 5000

class MyWeb extends StatefulWidget {
  @override
  _MyWebState createState() => _MyWebState();
}

class _MyWebState extends State<MyWeb> with SingleTickerProviderStateMixin {
  DatabaseService databaseService = new DatabaseService();
  int bottomSelectedIndex = 0;
  AnimationController _animationController;

  FocusNode myFocusNode = FocusNode();
  FocusNode myFocusNode1 = FocusNode();

  RefreshController _refreshController =
  RefreshController(initialRefresh: true);

  RefreshController _refreshController1 =
  RefreshController(initialRefresh: true);

  final serverText = TextEditingController();
  final roomText = TextEditingController();
  final subjectText = TextEditingController();
  final nameText = TextEditingController();
  final emailText = TextEditingController();

  final liveMeetTopic = TextEditingController();

  var isAudioOnly = true;
  var isAudioMuted = true;
  var isVideoMuted = true;

  String _userName = '...';
  String _userEmail = '...';
  var _userUid = '...';
  var _userPhotoUrl = ' ';

  bool isButtonEnabled;
  bool isEnabled;

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

  @override
  void initState() {
    _getUserAuth();
    isEmpty();
    checkConnection();
    Future.delayed(Duration(milliseconds: 500), () {
      Fluttertoast.showToast(
          msg: 'Signed in as ' +  _userName,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    });
    _animationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    super.initState();
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
                      color: Color(0xff0184dc)
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

  PageController _controller = PageController(
    initialPage: 0,
    keepPage: true,
  );
  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      _controller.animateToPage(index,
          duration: Duration(milliseconds: 800), curve: Curves.easeInOut);
    });
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
                return Icon(Icons.live_tv_outlined);
              }
              if (snapshot.hasError) {
                return Icon(Icons.live_tv_outlined);
              }
              return snapshot.data.docs.length == 0
                  ? FaIcon(FontAwesomeIcons.globeAsia) : Stack(
                  children: <Widget>[
                    FaIcon(FontAwesomeIcons.globeAsia),
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

  bool inMeeting = false;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return WillPopScope(
      onWillPop: exitConf,
      child: MaterialApp(
        title: 'Just Meet',
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.getTheme(),
        home: ResponsiveBuilder(
        builder: (context, sizingInformation) => Scaffold(
          appBar: sizingInformation.deviceScreenType == DeviceScreenType.mobile || sizingInformation.deviceScreenType == DeviceScreenType.tablet
              ? AppBar(
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
            title: Text(
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
          ) : null,
          resizeToAvoidBottomInset: false,
          drawer: sizingInformation.deviceScreenType == DeviceScreenType.mobile || sizingInformation.deviceScreenType == DeviceScreenType.tablet
              ? mainDrawer() : null,
          bottomNavigationBar: sizingInformation.deviceScreenType == DeviceScreenType.mobile || sizingInformation.deviceScreenType == DeviceScreenType.tablet
              ? Container(
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
        ) : null,
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
              child: sizingInformation.deviceScreenType == DeviceScreenType.mobile || sizingInformation.deviceScreenType == DeviceScreenType.tablet
                  ? Container(
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
                  )) : SingleChildScrollView(
    physics: ClampingScrollPhysics(),
    child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  WebAppBar(url: _userPhotoUrl, uid: _userUid, name: _userName, email: _userEmail,),
                  SizedBox(
                    height: 10,
                  ),
                  WebhomeScreen(),
                  SizedBox(
                    height: 30,
                  ),
                  BottomBar(),
                ],
              ),
            ),
            ),
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
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
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
                                        settings: RouteSettings(name: '/join'),
                                        builder: (context) =>
                                            WebJoin(
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
                                        settings: RouteSettings(name: '/host'),
                                        builder: (context) =>
                                            WebHost(
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
                              child: FaIcon(FontAwesomeIcons.globeAsia, color: Color(0xff0184dc),),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget WebhomeScreen() {
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
    return Row(
      children: [
        Expanded(
          flex: 10,
          child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Unlimited participants and time, high-quality and enhanced encrypted secured video meetings', style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              )),
              SizedBox(
                height: 25,
              ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
              children: [
              Text("We're here to help you connect, communicate, and express your ideas so you can get more done together."),
              ]),
                SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50.0,
                    width: 250,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(
                            color: Color(0xff0184dc),
                            width: 0.8,
                          )
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              settings: RouteSettings(name: '/upcoming'),
                                builder: (context) =>
                                    WebUpcoming(name: _userName, email: _userEmail, url: _userPhotoUrl, uid: _userUid,)));
                      },
                      child: Text(
                        "My Meetings",
                        style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xff00b6f3), Color(0xff0184dc)],
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft),
                    ),
                    height: 50.0,
                    width: 250,
                    child: RaisedButton(
                      elevation: 5,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                settings: RouteSettings(name: '/join'),
                                builder: (context) =>
                                    WebJoin(
                                      name: _userName,
                                      email: _userEmail,
                                      url: _userPhotoUrl,
                                      uid:  _userUid,
                                    )));
                      },
                      child: Text(
                        "Join Meeting",
                        style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Conferences', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              Container(
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                      Text(
                        'There are no global meetings live now, host one and let people join you',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      )
                      ]
                          )
                          : ListView.separated(
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
                                                  snapshot.data.docs[position]["time"]) : Text(
                                              'Hosted by You at ' +
                                                  snapshot.data.docs[position]["time"]),
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
                              }
                      );
                    }),
              ),
          SizedBox(
            height: 30.0,
          ),
              SizedBox(
                height: 50.0,
                width: double.maxFinite,
                child:
                RaisedButton(
                  onPressed: ()
                  {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            settings: RouteSettings(name: '/global'),
                            builder: (context) => WebLive(
                              uid: _userUid,
                              email: _userEmail,
                              name: _userName,
                              url: _userPhotoUrl,)));
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.all(10),
                  color: Color(0xff0184dc),
                  child: Text('Start Conference', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
              ),
            ],
          ),
        ),
      ],
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
                    settings: RouteSettings(name: '/profile'),
                    builder: (context) => profilePage(
                      name: _userName,
                      email: _userEmail,
                      photoURL: _userPhotoUrl,
                    ))),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 85,
              padding: EdgeInsets.only(top: 0, left: 10),
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
              leading: Icon(Icons.feedback_outlined),
              title: Text(
                'Send Feedback',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      settings: RouteSettings(name: '/feedback'),
                      builder: (context) => WebFeedback()))),
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
                      settings: RouteSettings(name: '/report'),
                      builder: (context) => WebReport()))),
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
            onTap: () async {
              _launchURL(
                  'jaguweb1234@gmail.com',
                  'Just Meet Support',
                  'We are here to help you, feel free to contact us'
                      "\r\n"
                      "\n");
    }),
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
                                    settings: RouteSettings(name: '/login'),
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
                                          snapshot.data.docs[position]["time"]) : Text(
                                      'Hosted by You at ' +
                                          snapshot.data.docs[position]["time"]),
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
                          settings: RouteSettings(name: '/settings/general'),
                          builder: (context) => generalSettings())),
                  title: Text(
                    'General Settings',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('Dark mode, Diagnostic info, Ads', overflow: TextOverflow.ellipsis,),
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
                          settings: RouteSettings(name: '/settings/advance'),
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
                  onTap: () async { var url =
                      'https://justmeetpolicies.blogspot.com/p/about-us.html';
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
                  }},
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
                  indent: 15,
                  endIndent: 0,
                ),
                ListTile(
                  tileColor: themeNotifier.getTheme() == darkTheme
                      ? Color(0xFF191919)
                      : Color(0xFFf9f9f9),
                  onTap: () async {
                    var url =
                'https://justmeetpolicies.blogspot.com/p/just-meet-privacy-policy.html';
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
                }},
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
                  onTap: () async {
                    var url =
                        'https://justmeetpolicies.blogspot.com/p/just-meet-terms-conditions.html';
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
                    }},
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

  void _createNewNote() {
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
}
