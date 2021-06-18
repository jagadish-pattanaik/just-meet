import 'package:jagu_meet/screens/meeting/meetweb/webFeedback.dart';
import 'package:jagu_meet/screens/meeting/meetweb/webHost.dart';
import 'package:jagu_meet/screens/meeting/meetweb/webJoin.dart';
import 'package:jagu_meet/screens/meeting/meetweb/webReport.dart';
import 'package:jagu_meet/widgets/slider.dart';
import 'package:jagu_meet/widgets/webAppBar.dart';
import 'package:jagu_meet/widgets/webBottomBar.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jagu_meet/screens/others/covAwarness.dart';
import 'package:jagu_meet/screens/others/infoPage.dart';
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
import 'meet.dart';

//flutter run --debug -d chrome --web-port 5000

class MyWeb extends StatefulWidget {
  @override
  _MyWebState createState() => _MyWebState();
}

class _MyWebState extends State<MyWeb> with SingleTickerProviderStateMixin {
  int bottomSelectedIndex = 0;

  FocusNode myFocusNode = FocusNode();
  FocusNode myFocusNode1 = FocusNode();

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
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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

  @override
  void initState() {
    _getUserAuth();
    isEmpty();
    checkConnection();
    Future.delayed(Duration(milliseconds: 500), () {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('Signed in as ' + _userName,)));
    });
    super.initState();
  }

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.videocam_outlined),
        activeIcon: Icon(Icons.videocam),
        label: 'Meet',
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
                      //scheduleMeeting(),
                      //liveMeeting(),
                      Settings(),
                      profile(),
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
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Scaffold(
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
        heroTag: "New Meeting",
        elevation: 5,
        onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(
                settings: RouteSettings(name: '/host'),
                builder: (context) =>
                    WebHost(
                      name: _userName,
                      email: _userEmail,
                      url: _userPhotoUrl,
                    ))),
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text('New Meeting',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        backgroundColor:themeNotifier.getTheme() == darkTheme
            ? Color(0xff0184dc)
            : Colors.blue,
      ) : Container(),
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
                    onPressed: isButtonEnabled
                        ? () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              settings: RouteSettings(name: '/join'),
                              builder: (context) =>
                                  Meet(
                                    id: roomText.text,
                                    topic: 'Just Meet',
                                    name: _userName,
                                    email: _userEmail,
                                    url: _userPhotoUrl,
                                  )));
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget WebhomeScreen() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
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
                              settings: RouteSettings(name: '/host'),
                                builder: (context) =>
                                    WebHost(name: _userName, email: _userEmail, url: _userPhotoUrl,)));
                      },
                      child: Text(
                        "New Meeting",
                        style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                  ),
                  SizedBox(
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
                                    )));
                      },
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
                ],
              ),
            ],
          ),
        ),
        ),
        Expanded(
          flex: 5,
          child: CustomSlider(isWeb: true,),
        ),
      ],
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
                CupertinoPageRoute(settings: RouteSettings(name: '/cov19'), builder: (context) => InfoScreen())),
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
                  subtitle: Text('Dark mode, Diagnostic info', overflow: TextOverflow.ellipsis,),
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
                  ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
                  }},
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
                  onTap: () async {
                    var url =
                'https://justmeetpolicies.blogspot.com/p/just-meet-privacy-policy.html';
                if (await canLaunch(url)) {
                await launch(url);
                } else {
                ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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
                      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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
                            settings: RouteSettings(name: '/photo'),
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
                          settings: RouteSettings(name: '/plan'),
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
                          settings: RouteSettings(name: '/license'),
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
                            settings: RouteSettings(name: '/login'),
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
}
