import 'package:device_info/device_info.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_offline/flutter_offline.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:jagu_meet/main.dart';
import 'package:jagu_meet/screens/others/webview.dart';
//import 'package:jagu_meet/sever_db/users%20db/users_db.dart';
//import 'package:jagu_meet/sever_db/users%20db/users_db_controller.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
//import 'package:mobile_number/mobile_number.dart';
//import 'package:mobile_number/sim_card.dart';
import 'package:permission_handler/permission_handler.dart';
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
    checkPermissions();
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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Start or join meeting on the go',
            overflow: TextOverflow.ellipsis,
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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Chat while on meeting and share your content',
            overflow: TextOverflow.ellipsis,
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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'No more restrictions on long and group talks',
            overflow: TextOverflow.ellipsis,
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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Low Internet speed? no problem, Just Meet',
            overflow: TextOverflow.ellipsis,
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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Your data is safe and encrypted',
            overflow: TextOverflow.ellipsis,
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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Participants can join only after approval',
            overflow: TextOverflow.ellipsis,
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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Share YouTube videos in meetings with ease',
            overflow: TextOverflow.ellipsis,
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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Protect your meetings with password',
            overflow: TextOverflow.ellipsis,
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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Available on Android, iOS and PC',
            overflow: TextOverflow.ellipsis,
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
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Stay connected with Just Meet',
            overflow: TextOverflow.ellipsis,
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
        CupertinoPageRoute(
            builder: (context) => AppWebView(
                  url: URL,
                  title: TITLE,
                )));
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

  bool permisions = false;

  checkPermissions() async {
    var status = await Permission.camera.status;
    var stat = await Permission.microphone.status;
    if (status.isGranted && stat.isGranted) {
      setState(() {
        permisions = true;
      });
    } else {
      setState(() {
        permisions = false;
      });
    }
  }

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
      Future.delayed(Duration(milliseconds: 1000), () {
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => MyApp(),
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
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    TextStyle linkStyle = TextStyle(color: Colors.blue);
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
                                enlargeStrategy:
                                    CenterPageEnlargeStrategy.scale,
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
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              onTap:
                                  (startLoading, stopLoading, btnState) async {
                                var connectivityResult =
                                    await (Connectivity().checkConnectivity());
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
                                text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    text:
                                        'By clicking Sign Up you accept all the',
                                    style: TextStyle(
                                      color:
                                          themeNotifier.getTheme() == darkTheme
                                              ? Colors.white
                                              : Colors.black,
                                    )),
                                TextSpan(
                                    text: ' Terms & Conditions ',
                                    style: linkStyle,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launchWebView(
                                            'https://justmeetpolicies.blogspot.com/p/just-meet-terms-conditions.html',
                                            'Terms & Conditions');
                                      }),
                                TextSpan(
                                    text: 'and that you have read our',
                                    style: TextStyle(
                                      color:
                                          themeNotifier.getTheme() == darkTheme
                                              ? Colors.white
                                              : Colors.black,
                                    )),
                                TextSpan(
                                    text: ' Privacy Policy.',
                                    style: linkStyle,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launchWebView(
                                            'https://justmeetpolicies.blogspot.com/p/just-meet-privacy-policy.html',
                                            'Privacy Policy');
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
