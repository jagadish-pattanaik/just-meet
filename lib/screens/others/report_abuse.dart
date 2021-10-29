import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/firebase/databases/appCloudDb.dart';
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
  FocusNode myFocusNode = FocusNode();
  final reportText = TextEditingController();

  AppCloudService appService  = new AppCloudService();

  var rType = "Others";

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
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Theme(
      data: themeNotifier.getTheme(),
      child: Scaffold(
        appBar: AppBar(
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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Report Abuse',
            style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white : Colors.black54,
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
                  'Any other data:'),
          label: Text('Contact Us',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          icon: Icon(Icons.mail_outline,
              color: Colors.white),
          backgroundColor: Color(0xff0184dc)
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
              Divider(
                height: 1,
                color: themeNotifier.getTheme() == darkTheme
                    ? Color(0xFF303030)
                    : Colors.black12,
              ),
              TextField(
                      focusNode: myFocusNode,
                      keyboardType: TextInputType.multiline,
                      autofocus: false,
                      maxLength: 11,
                      controller: reportText,
                      onChanged: (val) {
                        isEmpty();
                      },
                      decoration: InputDecoration(
                          counterText: '',
                          isDense: true,
                          filled: true,
                          contentPadding: const EdgeInsets.only(
                              top: 12.0, bottom: 12, left: 10),
                          border: InputBorder.none,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          fillColor: themeNotifier.getTheme() == darkTheme
                              ? Color(0xFF191919)
                              : Color(0xFFf9f9f9),
                          hintText: 'More Information'),
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
                              appService.addAbuseReport(widget.userid, widget.email, reportText.text);
                        Fluttertoast.showToast(
                            msg: 'Reported',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.SNACKBAR,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0);
                              reportText.clear();
                              isEmpty();
                            }
                          : null,
                      child: Text(
                        "Report",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      color: Color(0xff0184dc)
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
