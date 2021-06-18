import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'meet.dart';

class WebJoin extends StatefulWidget {
  final name;
  final email;
  final url;
  const WebJoin({Key key,
    this.name,
    this.email,
    this.url,}) : super(key: key);

  @override
  _WebJoinState createState() => _WebJoinState(name, email, url);
}

class _WebJoinState extends State<WebJoin> {
  final name;
  final email;
  final url;

  _WebJoinState(this.name, this.email, this.url);

  String _userName;
  String _userEmail;
  var _userPhotoUrl;

  final roomText = TextEditingController();
  bool isTyping = false;
  bool isButtonEnabled;

  getInfo() {
    setState(() {
      _userName = name;
      _userEmail = email;
      _userPhotoUrl = url;
    });
  }

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

  checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
    } else {
    }
  }

  @override
  void initState() {
    getInfo();
    isEmpty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return MaterialApp(
      title: 'Just Meet | Join',
      theme: themeNotifier.getTheme(),
      home: Scaffold(
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
        ),
        body: SafeArea(
          child: ResponsiveBuilder(
            builder: (context, sizingInformation) => Container(
            height: double.maxFinite,
              child: Center(
                child:
                    Container(
                      height: double.maxFinite,
                      width: sizingInformation.deviceScreenType == DeviceScreenType.mobile || sizingInformation.deviceScreenType == DeviceScreenType.tablet
                          ? MediaQuery.of(context).size.width * 0.60 : MediaQuery.of(context).size.width * 0.30,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Join a Meeting', style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),),
                          SizedBox(
                            height: 30.0,
                          ),
                          TextField(
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
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(10.0),
                                  ),
                                  borderSide: BorderSide(
                                      color: themeNotifier.getTheme() == darkTheme
                                          ? Color(0xFF303030)
                                          : Colors.black12,
                                      width: 1.0),
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
                              onPressed:
                                   isButtonEnabled
                                  ? ()  {
                                     Navigator.push(
                                         context,
                                         CupertinoPageRoute(
                                             settings: RouteSettings(name: '/meeting'),
                                             builder: (context) =>
                                                 Meet(id: roomText.text, topic: 'Just Meet', name: _userName, email: _userEmail, url: _userPhotoUrl,)));
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
                    )
    ),
    ),
    ),
    ),
      ),
    );
  }
}
