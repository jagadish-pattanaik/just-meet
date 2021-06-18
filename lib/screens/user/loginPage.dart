import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jagu_meet/main.dart';
import 'package:jagu_meet/screens/meeting/meetweb/meetWeb.dart';
import 'package:jagu_meet/screens/others/webview.dart';
//import 'package:jagu_meet/sever_db/users%20db/users_db.dart';
//import 'package:jagu_meet/sever_db/users%20db/users_db_controller.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/slider.dart';
//import 'package:mobile_number/mobile_number.dart';
//import 'package:mobile_number/sim_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:connectivity/connectivity.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  var connectivityResult;

  checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(content: Text('No internet connection!',)));
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
      ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(content: Text('No internet connection!',)));
    }
  }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var PhotoUrl;
    var Name;
    var Email;
    var Uid;
    final User user = FirebaseAuth.instance.currentUser;
    final FirebaseAuth auth = FirebaseAuth.instance;

    //_getUserAuth() async {
    // final User user = auth.currentUser;
    // setState(() {
    //   PhotoUrl = user.photoURL;
    //   Name = user.displayName;
    //  Email = user.email;
    //   Uid = user.uid;
    // });
    //}

    //final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    //Position _currentPosition;
    // String _currentAddress;

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
//
    //String _mobileNumber = '';
    //SimCard sim;
//
    //Future<void> initMobileNumberState() async {
    //if (!await MobileNumber.hasPhonePermission) {
    //await MobileNumber.requestPhonePermission;
    //return;
    //}
    //String mobileNumber = '';
    //// Platform messages may fail, so we use a try/catch PlatformException.
    //try {
    //mobileNumber = (await MobileNumber.mobileNumber);
    //} on PlatformException catch (e) {
    //debugPrint("Failed to get mobile number because of '${e.message}'");
    //}
//
    //// If the widget was removed from the tree while the asynchronous platform
    //// message was in flight, we want to discard the reply rather than calling
    //// setState to update our non-existent appearance.
    //if (!mounted) return;
//
    //setState(() {
    //_mobileNumber = mobileNumber;
    //});
    //}

    // bool permisions = false;

    //checkPermissions() async {
    //  var status = await Permission.camera.status;
    //  var stat = await Permission.microphone.status;
    //  if (status.isGranted && stat.isGranted) {
    //   setState(() {
    //     permisions = true;
    //    });
    //  } else {
    //    setState(() {
    //     permisions = false;
    //     });
    //  }
//  }

    //void _submitUserData() async {
    //String external = await FlutterIp.externalIP;
    //String internal = await FlutterIp.internalIP;
    //_getUserAuth();
    //_getCurrentLocation();
    //initMobileNumberState();
    //AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    //UsersDb usersDb = UsersDb(
    //Uid,
    //Email,
    //Name,
    //_currentAddress,
    //_mobileNumber,
    //sim.number,
    //sim.carrierName,
    //sim.countryIso,
    //sim.countryPhonePrefix,
    //androidInfo.version.securityPatch,
    //androidInfo.version.sdkInt.toString(),
    //androidInfo.version.release.toString(),
    //androidInfo.version.previewSdkInt.toString(),
    //androidInfo.version.incremental.toString(),
    //androidInfo.version.codename,
    //androidInfo.version.baseOS,
    //androidInfo.board,
    //androidInfo.bootloader,
    //androidInfo.brand,
    //androidInfo.device,
    //androidInfo.display,
    //androidInfo.fingerprint,
    //androidInfo.hardware,
    //androidInfo.host,
    //androidInfo.id,
    //androidInfo.manufacturer,
    //androidInfo.model,
    //androidInfo.product,
    //androidInfo.type,
    //androidInfo.isPhysicalDevice.toString(),
    //androidInfo.androidId,
    //external,
    //internal);
//
    //ServerController1 serverController1 = ServerController1((String response) {
    //print(response);
    //});
    //serverController1.submitData1(usersDb);
    //}

    Future<User> _signIn(BuildContext context) async {
      var connectivityResult = await (Connectivity().checkConnectivity());
      // if (!await MobileNumber.hasPhonePermission) {
      // await MobileNumber.requestPhonePermission;
      //} else {
      // if (permisions = false) {
      //    Map<Permission, PermissionStatus> statuses = await [
      //     Permission.phone,
      //     Permission.location,
      // ].request();
      // } else {
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

        GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
        GoogleSignInAuthentication gsa = await googleSignInAccount
            .authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
            idToken: gsa.idToken, accessToken: gsa.accessToken);

        User user = (await _auth.signInWithCredential(credential)).user;
        Future.delayed(Duration(milliseconds: 1000), () {
          !kIsWeb ?
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) => MyApp(),
              )) : Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) => MyWeb(),
              ));
          onSignIn();
        });
      }
    }
    // }
    // return userDetails;
    // }

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
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
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
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    onTap:
                                        (startLoading, stopLoading,
                                        btnState) async {
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
