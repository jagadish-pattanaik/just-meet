import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jagu_meet/main.dart';
import 'package:jagu_meet/screens/webview.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:connectivity/connectivity.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  CarouselController buttonCarouselController = CarouselController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  Future<User> _signIn(BuildContext context) async {
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
      Fluttertoast.showToast(
          msg: 'Signing In...',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);

      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication gsa = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: gsa.idToken, accessToken: gsa.accessToken);

      User user = (await _auth.signInWithCredential(credential)).user;

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MyApp(),
          ));
      onSignIn();
    }
    // return userDetails;
  }

  var connectivityResult;

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
    } else {}
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
    getBg();
  }

  getBg() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        darkModeOn = prefs.getBool('darkMode') ?? false;
      });
    });
    if (darkModeOn == false) {
      setState(() {
        bgColor = Colors.white;
        textColor = Colors.black;
      });
    } else {
      setState(() {
        bgColor = Color(0xFF212121);
        textColor = Colors.white;
      });
    }
  }

  onSignIn() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('signStatus', true);
    });
  }

  Color bgColor = Colors.white;
  Color textColor = Colors.black;
  var _darkTheme;
  var darkModeOn = false;
  double currentPage = 0.0;

  final List<Widget> scrolls = [
    Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Connect with Friends',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Start or join meeting on the go',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Image.asset(
            'assets/images/startjoin.jpg',
            height: 380,
          ),
        ],
      ),
    ),
    Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Chat With Your Team',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Chat while on meeting and share your content',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Image.asset(
            'assets/images/chat.jpg',
            height: 380,
          ),
        ],
      ),
    ),
    Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Unlimited time and participants',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'No more restrictions on long and group talks',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Image.asset(
            'assets/images/unlimited.jpg',
            height: 380,
          ),
        ],
      ),
    ),
    Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Low Bandwidth Mode',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Low Internet speed? no problem, Just Meet',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Image.asset(
            'assets/images/lowmode.jpg',
            height: 380,
          ),
        ],
      ),
    ),
    Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Enhanced Encryption and Security',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Your data is safe and encrypted',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Image.asset(
            'assets/images/secured.jpg',
            height: 380,
          ),
        ],
      ),
    ),
    Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Waiting Room',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Participants can join only after approval',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Image.asset(
            'assets/images/waiting.jpg',
            height: 380,
          ),
        ],
      ),
    ),
    Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Share YouTube Videos',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Share YouTube videos in meetings with ease',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Image.asset(
            'assets/images/youtube.jpg',
            height: 380,
          ),
        ],
      ),
    ),
    Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Protect with Password',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Protect your meetings with password',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Image.asset(
            'assets/images/password.jpg',
            height: 380,
          ),
        ],
      ),
    ),
    Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Available on all platforms',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Available on Android, iOS and PC',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Image.asset(
            'assets/images/multiple.jpg',
            height: 380,
          ),
        ],
      ),
    ),
    Container(
      //  decoration: BoxDecoration(
      //  shape: BoxShape.rectangle,
      //  borderRadius: BorderRadius.circular(40),
      // ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Stay Safe, Stay Connected',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Stay connected with Just Meet',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Image.asset(
            'assets/images/stay.jpg',
            height: 380,
          ),
        ],
      ),
    ),
  ];

  launchWebView(var URL, var TITLE) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AppWebView(
                  url: URL,
                  title: TITLE,
                )));
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'OpenSans',
      ),
      home: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          centerTitle: true,
          elevation: 5,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xFF242424)
              : Colors.blue,
          title: new Text(
            "Just Meet",
            style: TextStyle(
              color: Colors.white,
            ),
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
                      child: connected ? null : Text('You Are Offline!'),
                    ),
                  ),
                ),
              ],
            );
          },
          child: Builder(
            builder: (context) =>
                Stack(fit: StackFit.expand, children: <Widget>[
              Container(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(children: [
                        SizedBox(
                          height: 20,
                        ),
                        CarouselSlider(
                          carouselController: buttonCarouselController,
                          options: CarouselOptions(
                            height: 432,
                            aspectRatio: 2,
                            viewportFraction: 1,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            pageSnapping: true,
                            enlargeStrategy: CenterPageEnlargeStrategy.scale,
                            disableCenter: true,
                            onPageChanged: (int index,
                                CarouselPageChangedReason changeReason) {
                              setState(() {
                                currentPage = index.toDouble();
                              });
                            },
                            scrollDirection: Axis.horizontal,
                          ),
                          items: scrolls.toList(),
                        ),
                        DotsIndicator(
                          dotsCount: scrolls.length,
                          position: currentPage,
                          decorator: DotsDecorator(
                            size: const Size.square(9.0),
                            activeSize: const Size(18.0, 9.0),
                            activeShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                          ),
                        )
                      ]),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 45,
                        child: ArgonButton(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                          roundLoadingShape: true,
                          height: 50,
                          width: 250,
                          elevation: 10,
                          highlightElevation: 15,
                          highlightColor: Colors.grey,
                          borderRadius: 20.0,
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Image(
                                  image: AssetImage(
                                    'assets/images/search.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                height: 30,
                                width: 30,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Sign In With Google',
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          onTap: (startLoading, stopLoading, btnState) async {
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
                              _signIn(context);
                              if (btnState == ButtonState.Idle) {
                                startLoading();
                              } else {
                                stopLoading();
                              }
                            }
                          },
                          loader: Container(
                            padding: EdgeInsets.all(10),
                            child: SpinKitRotatingCircle(
                              color: Colors.blue,
                              // size: loaderWidth ,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        GestureDetector(
                          onTap: () => launchWebView(
                              'https://justmeetpolicies.blogspot.com/p/just-meet-privacy-policy.html',
                              'Privacy Policy'),
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        //SizedBox(width: 10,),
                        Text(
                          '‧',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.blue),
                        ),
                        //SizedBox(width: 10,),
                        GestureDetector(
                          onTap: () => launchWebView(
                              'https://justmeetpolicies.blogspot.com/p/just-meet-terms-conditions.html',
                              'Terms & Conditions'),
                          child: Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ]),
                    ],
                  )),
            ]),
          ),
        ),
      ),
      ),
    );
  }
}
