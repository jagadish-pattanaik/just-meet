import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jagu_meet/firebase/databases/appCloudDb.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginPage.dart';
import '../others/fullImage.dart';
import '../others/infoPage.dart';

class profilePage extends StatefulWidget {
  final name;
  final email;
  final photoURL;
  profilePage(
      {Key key,
      @required this.name,
      this.email,
      this.photoURL})
      : super(key: key);

  @override
  _profilePageState createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  String _userName;
  String _userEmail;
  var _userPhotoUrl;

  AppCloudService appService  = new AppCloudService();

  onSignOut() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('signStatus', false);
    });
  }

  setValue() {
    setState(() {
      _userName = widget.name;
      _userEmail = widget.email;
      _userPhotoUrl = widget.photoURL;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    setState(() {
      _userName = widget.name;
      _userEmail = widget.email;
      _userPhotoUrl = widget.photoURL;
    });
    return Theme(
      data: themeNotifier.getTheme(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
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
            'Profile',
            style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white : Colors.black54,
            ),
          ),
        ),
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
                    onTap: () async {
                      final plan = await appService.getPlan();
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => Information(
                                text: plan,
                                title: 'Plan',
                              )));
                      },
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
                      ? Color
                    (0xFF191919)
                        : Color(0xFFf9f9f9),
                    title: Text('License'),
                    subtitle: Text('Unlimited Time and Participants'),
                    onTap: () async {
    final license = await appService.getLicense();
    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => Information(
                              text: license,
                              title: 'License',
                            )));
                    },
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
                      final action = await Dialogs.redAlertDialog(
                          context,
                          'Sign Out ?',
                          'Do you want to Sign Out from this account?',
                          'Sign Out',
                          'No');
                      if (action == DialogAction.yes) {
                        _gSignIn.signOut();
                        auth.signOut();
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
      ),
    );
  }
}
