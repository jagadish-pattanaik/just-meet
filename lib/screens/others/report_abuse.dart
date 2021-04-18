import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
//import 'package:jagu_meet/sever_db/report_abuse/report_db.dart';
//import 'package:jagu_meet/sever_db/report_abuse/report_db_controller.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Report extends StatefulWidget {
  final userid;
  final email;

  Report({
    Key key,
    @required this.userid,
    this.email,
  }) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  var _darkTheme;
  FocusNode myFocusNode = FocusNode();
  final reportText = TextEditingController();

  var rType = "Others";

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
          msg: 'Failed...Please check your internet connection',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  bool isButtonEnabled = false;
  isEmpty() {
    if (reportText.text.length >= 5) {
      setState(() {
        isButtonEnabled = true;
      });
    } else {
      setState(() {
        isButtonEnabled = false;
      });
    }
  }

  //void _submitAbuseData(String email, String userid, String type, String reports,) {
  //ReportDb reportDb  = ReportDb(email, userid, type, reports);
//
  //ReportServerController reportServerController = ReportServerController(
  //(String response) {
  //print(response);
  //}
  //);
  //reportServerController.submitAbuseData(reportDb);
  //}

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return MaterialApp(
      title: 'Just Meet',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.getTheme(),
      home: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xFF242424)
              : Colors.blue,
          elevation: 5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Report Abuse',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButton: showFab
            ?  FloatingActionButton.extended(
          heroTag: "Contact Us",
          elevation: 5,
          onPressed: () => _launchURL(
              'jaguweb1234@gmail.com',
              'Report Abuse Just Meet',
              'Please write the date, time, meeting Id and username/s of the person here. If we find any suh act harming our community or you then we will take neccessary actions and report you about that.'
                  '\n'
                  'Name:'
                  '\n'
                  'meeting id:'
                  '\n'
                  'date:'
                  '\n'
                  'time:'
                  '\n'
                  'Any other data:'
                  '\n'
                  '\n'
                  'User Details:'
                  '\n'
                  'user id: ${widget.userid}'
                  '\n'
                  'email: ${widget.email}'),
          label: Text('Contact Us',
              style: TextStyle(
                  color: themeNotifier.getTheme() == darkTheme
                      ? Colors.blueAccent
                      : Colors.white,
                  fontWeight: FontWeight.bold)),
          icon: Icon(Icons.add,
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.blueAccent
                  : Colors.white),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xFF242424)
              : Colors.blue,
        ) :  Container(),
        body: SafeArea(
          child: Container(
            height: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  RadioButtonGroup(
                    labels: <String>[
                      "Inappropriate Language or Visuals",
                      "Bullying",
                      "Sexting",
                      "Nudity",
                      "Sexual Abuse",
                      "I just didn't like",
                      "Others",
                    ],
                    onSelected: (String selected) {
                      setState(() {
                        rType = selected;
                      });
                    },
                    picked: rType,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: TextField(
                      focusNode: myFocusNode,
                      keyboardType: TextInputType.multiline,
                      autofocus: false,
                      maxLength: 11,
                      controller: reportText,
                      onChanged: (val) {
                        isEmpty();
                      },
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.blue, width: 1.0),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          counterText: '',
                          isDense: true,
                          filled: true,
                          contentPadding: const EdgeInsets.only(
                              top: 12.0, bottom: 12, left: 10),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: "Tell us more",
                          labelStyle: TextStyle(
                            color: Colors.blue,
                          ),
                          fillColor: themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF191919)
                              : Color(0xFFf9f9f9),
                          hintText: 'More Information'),
                    ),
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  SizedBox(
                    height: 45.0,
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
                          ? () async {
                              //_submitAbuseData(widget.email, widget.userid, rType, reportText.text);
                              Fluttertoast.showToast(
                                  msg: 'Report Submitted!',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.SNACKBAR,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              reportText.clear();
                            }
                          : null,
                      child: Text(
                        "Report",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      color: themeNotifier.getTheme() == darkTheme
                          ? Colors.blueAccent
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
      ),
    );
  }
}
