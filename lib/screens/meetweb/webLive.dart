import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'meet.dart';

class WebLive extends StatefulWidget {
  final name;
  final email;
  final url;
  final uid;
  const WebLive({Key key,
    this.name,
    this.email,
    this.url,
    this.uid}) : super(key: key);

  @override
  _WebLiveState createState() => _WebLiveState();
}

class _WebLiveState extends State<WebLive> {
  final roomText = TextEditingController();
  bool isTyping = false;
  bool isButtonEnabled;

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
    if (roomText.text.length >= 3) {
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

  @override
  void initState() {
    isEmpty();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
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
        ),
        body: SafeArea(
          child: Container(
            height: double.maxFinite,
            child: Center(
              child:
              ResponsiveBuilder(
                  builder: (context, sizingInformation) => Container(
                    height: double.maxFinite,
                    width: sizingInformation.deviceScreenType == DeviceScreenType.mobile || sizingInformation.deviceScreenType == DeviceScreenType.tablet
                        ? MediaQuery.of(context).size.width * 0.60 : MediaQuery.of(context).size.width * 0.30,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Start a Stage', style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),),
                        SizedBox(
                          height: 30.0,
                        ),
                        TextField(
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          onChanged: (val) {
                            isEmpty();
                            istyping(roomText);
                          },

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
                              hintText: 'Meeting Topic'),
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
                              String randomId = randomNumeric(11);
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      settings: RouteSettings(name: '/meeting'),
                                      builder: (context) =>
                                          Meet(id: randomId, topic: roomText.text, name: widget.name, email: widget.email, url: widget.url, uid: widget.uid, type: 'live',)));
                            }
                                : null,
                            child: Text(
                              "Start Meeting",
                              style:
                              TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            color: Color(0xff0184dc),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('Once you start the meeting, Just Meet users from all over'
                              '\n'
                              ' the world will be able to see and join your meeting',
                              maxLines: 3,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: themeNotifier.getTheme() == darkTheme
                                    ? Colors.white
                                    : Colors.grey,
                              )),
                        ]),
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
