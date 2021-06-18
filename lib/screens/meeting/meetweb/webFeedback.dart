import 'package:flutter/material.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';

class WebFeedback extends StatefulWidget {

  WebFeedback({Key key,})
      : super(key: key);

  @override
  _WebFeedbackState createState() => _WebFeedbackState();
}

class _WebFeedbackState extends State<WebFeedback> {
  FocusNode myFocusNode = FocusNode();
  final reportText = TextEditingController();

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
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

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return MaterialApp(
      title: 'Just Meet',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.getTheme(),
      home: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: themeNotifier.getTheme() == darkTheme
              ? Colors.white : Colors.black54),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xff0d0d0d)
              : Color(0xffffffff),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        floatingActionButton: showFab
            ?  FloatingActionButton.extended(
          heroTag: "Contact Us",
          elevation: 5,
          onPressed: () => _launchURL(
              'jaguweb1234@gmail.com',
              'Feedback Just Meet',
              'Please Write your feedback here it will help us a lot in improving.'),
          label: Text('Contact Us',
              style: TextStyle(
                  color:  Colors.white,
                  fontWeight: FontWeight.bold)),
          icon: Icon(Icons.mail_outline,
              color: Colors.white),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xff0184dc)
              : Colors.blue,
        ) : Container(),
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
                children: <Widget>[
    Text('Feedback', style: TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    ),),
    SizedBox(
    height: 30.0,
    ),
                  TextField(
                    focusNode: myFocusNode,
                    autofocus: false,
                    controller: reportText,
                    onChanged: (val) {
                      isEmpty();
                    },
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        filled: true,
                        contentPadding: const EdgeInsets.only(
                            top: 12.0, bottom: 12, left: 10),
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
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF191919)
                            : Color(0xFFf9f9f9),
                        hintText: 'Please write your feedback here'),
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
                          ? () async {
                        // _submitFeedbackData(widget.email, widget.name, reportText.text);
                        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('Thank you for your feedback',)));
                        reportText.clear();
                      }
                          : null,
                      child: Text(
                        "Submit Feedback",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
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
      ),
    ),
      ),
    );
  }
}