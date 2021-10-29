import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jagu_meet/main.dart';
import 'package:jagu_meet/screens/meetweb/meetWeb.dart';
import 'package:jagu_meet/screens/others/webview.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/slider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:sign_button/sign_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  bool loading = false;

  var connectivityResult;

  DatabaseService databaseService = new DatabaseService();

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
    } else {}
  }

  @override
  void initState() {
    super.initState();
    //checkPermissions();
    checkConnection();
    getBg();
  }

  getBg() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        darkModeOn = prefs.getBool('darkMode');
      });
    });
    if (darkModeOn == false) {
      setState(() {
        bgColor = Colors.white;
        textColor = Colors.black;
      });
    } else {
      setState(() {
        bgColor = Color(0xff0d0d0d);
        textColor = Colors.white;
      });
    }
  }

  onSignIn() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('signStatus', true);
    });
  }

  Color bgColor;
  Color textColor;
  var darkModeOn;

  launchWebView(var URL, var TITLE) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                AppWebView(
                  url: URL,
                  title: TITLE,
                )));
  }

  _launchUrl(url) async {
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

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var PhotoUrl;
    var Name;
    var Email;
    var Uid;
    final User user = FirebaseAuth.instance.currentUser;
    final FirebaseAuth auth = FirebaseAuth.instance;
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
        ScaffoldMessenger.of(context).showSnackBar(
            new SnackBar(content: Text('Signing in...',)));

        try {
          GoogleSignInAccount googleSignInAccount = await _googleSignIn
              .signIn();
          GoogleSignInAuthentication gsa = await googleSignInAccount
              .authentication;

          final AuthCredential credential = GoogleAuthProvider.credential(
              idToken: gsa.idToken, accessToken: gsa.accessToken);

          User user = (await _auth.signInWithCredential(credential)).user;

          assert(user.email != null);
          assert(user.displayName != null);
          assert(!user.isAnonymous);
          assert(await user.getIdToken() != null);

          databaseService.addUser(user.uid, user.displayName, user.email, user.phoneNumber, user.photoURL);

          onSignIn();
          Future.delayed(Duration(milliseconds: 500), () {
            !kIsWeb ?
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (BuildContext context) => MyApp(),
                )) : Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  settings: RouteSettings(name: '/home'),
                  builder: (BuildContext context) => MyWeb(),
                ));
          });

          return user;
        } catch (e) {
          setState(() {
            loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                  content: Text("Couldn't sign in, please try again",)));
          return null;
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
      TextStyle linkStyle = TextStyle(color: Colors.blue);
      return MaterialApp(
        title: 'Just Meet',
        home: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            centerTitle: true,
            iconTheme: IconThemeData(
                color: themeNotifier.getTheme() == darkTheme
                    ? Colors.white : Colors.black54),
            backgroundColor: themeNotifier.getTheme() == darkTheme
                ? Color(0xff0d0d0d)
                : Color(0xffffffff),
            elevation: 0,
            bottom: PreferredSize(
                child: Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF303030) : Colors.black12
                ),
                preferredSize: Size(double.infinity, 0.0)),
            title: new Text(
              "Sign In",
              style: TextStyle(
                color: themeNotifier.getTheme() == darkTheme
                    ? Colors.white : Colors.black54,
              ),
            ),
          ),
          body: SafeArea(
            child: OfflineBuilder(
              connectivityBuilder: (BuildContext context,
                  ConnectivityResult connectivity,
                  Widget child,) {
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
              child: Builder(
                builder: (context) =>
                    Stack(fit: StackFit.expand, children: <Widget>[
                      Container(
                        height: double.maxFinite,
                        width: double.maxFinite,
                        child: SingleChildScrollView(
                          child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CustomSlider(isWeb: false,),
                                SizedBox(
                                  height: 15,
                                ),
                            loading ? SizedBox(width: 25, height: 25, child:CircularProgressIndicator()) :
                            SignInButton(
                              buttonType: ButtonType.google,
                              btnText: "Sign in with Google",
                              onPressed: () async {
                                      var connectivityResult =
                                      await (Connectivity()
                                          .checkConnectivity());
                                      if (connectivityResult ==
                                          ConnectivityResult.none) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(new SnackBar(
                                            content: Text(
                                              'No internet connection!',)));
                                      } else {
                                        setState(() {
                                          loading = true;
                                        });
                                        _signIn(context);
                                      }
                                    },
                                  ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                              text:
                                              'By clicking Sign in you accept all the',
                                              style: TextStyle(
                                                color:
                                                themeNotifier.getTheme() ==
                                                    darkTheme
                                                    ? Colors.white
                                                    : Colors.black,
                                              )),
                                          TextSpan(
                                              text: ' Terms & Conditions ',
                                              style: linkStyle,
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
      if (!kIsWeb) {
        launchWebView(
            'https://justmeetpolicies.blogspot.com/p/just-meet-terms-conditions.html',
            'Terms & Conditions');
      } else {
        _launchUrl('https://justmeetpolicies.blogspot.com/p/just-meet-terms-conditions.html');
      }
                                                }),
                                          TextSpan(
                                              text: 'and that you have read our',
                                              style: TextStyle(
                                                color:
                                                themeNotifier.getTheme() ==
                                                    darkTheme
                                                    ? Colors.white
                                                    : Colors.black,
                                              )),
                                          TextSpan(
                                              text: ' Privacy Policy.',
                                              style: linkStyle,
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  if (!kIsWeb) {
                                                    launchWebView(
                                                        'https://justmeetpolicies.blogspot.com/p/just-meet-privacy-policy.html',
                                                        'Privacy Policy');
                                                  } else {
                                                    _launchUrl('https://justmeetpolicies.blogspot.com/p/just-meet-privacy-policy.html');
                                                  }
                                                }),
                                        ],
                                      )),
                                ),
                              ]),
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      );
    }
  }
