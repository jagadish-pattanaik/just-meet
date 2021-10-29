import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:jagu_meet/screens/meeting/schedule/NoteScreen.dart';
import 'package:jagu_meet/screens/meeting/schedule/viewScheduled.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/loading.dart';
import 'package:jagu_meet/widgets/quiet_box.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';

class WebUpcoming extends StatefulWidget {
  final email;
  final url;
  final uid;
  final name;
  const WebUpcoming({Key key,
    this.email,
    this.url,
    this.name,
    this.uid}) : super(key: key);

  @override
  _WebUpcomingState createState() => _WebUpcomingState();
}

class _WebUpcomingState extends State<WebUpcoming> {
  DatabaseService databaseService = new DatabaseService();

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
          bottom: PreferredSize(
              child: Divider(
                  height: 1,
                  color: themeNotifier.getTheme() == darkTheme
                      ?  Color(0xFF303030) : Colors.black12
              ),
              preferredSize: Size(double.infinity, 0.0)),
          title: Text(
            'Scheduled Meetings',
            style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white : Colors.black54,
            ),
          ),
        ),
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users')
            .doc(widget.uid)
            .collection('Scheduled').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Loading();
            }
            if (snapshot.hasError) {
              return Loading();
            }
            return snapshot.data.docs.length == 0
                ? Container(
                child: QuietBox(
                  heading: "Schedule",
                  subtitle:
                  "There are no upcoming meetings, schedule one for future now",
                  fun: _createNewNote,
                )
            )
                : ListView.separated(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (BuildContext context, int position) {
                  var dbDate = snapshot.data.docs[position]["date"];
                  var dateFormat = new DateFormat('dd, MMM yyyy');
                  final now = DateTime.now();
                  DateTime tomorrow = now.add(Duration(days: 1));
                  DateTime daytomorrow = now.add(Duration(days: 2));
                  DateTime yesterday = now.subtract(Duration(
                      days: 1));
                  String formattedDate = dateFormat
                      .format((DateTime.parse(dbDate)));
                  var finalDate;
                  if (DateTime
                      .parse(dbDate)
                      .day ==
                      now.day &&
                      DateTime
                          .parse(dbDate)
                          .month ==
                          now.month &&
                      DateTime
                          .parse(dbDate)
                          .year ==
                          now.year) {
                    finalDate = 'Today';
                  } else if ((DateTime
                      .parse(dbDate)
                      .day ==
                      tomorrow.day &&
                      DateTime
                          .parse(dbDate)
                          .month ==
                          tomorrow.month &&
                      DateTime
                          .parse(dbDate)
                          .year ==
                          tomorrow.year)) {
                    finalDate = 'Tomorrow';
                  } else if ((DateTime
                      .parse(dbDate)
                      .day ==
                      daytomorrow.day &&
                      DateTime
                          .parse(dbDate)
                          .month ==
                          daytomorrow.month &&
                      DateTime
                          .parse(dbDate)
                          .year ==
                          daytomorrow.year)) {
                    finalDate = 'Day After Tomorrow';
                  } else if ((DateTime
                      .parse(dbDate)
                      .day ==
                      yesterday.day &&
                      DateTime
                          .parse(dbDate)
                          .month ==
                          yesterday.month &&
                      DateTime
                          .parse(dbDate)
                          .year ==
                          yesterday.year)) {
                    finalDate = 'Yesterday';
                  } else {
                    finalDate = formattedDate;
                  }
                  var from = DateFormat.jm().format(DateFormat("hh:mm").parse(snapshot.data.docs[position]["from"])).toString();
                  for (var i = 0; i < snapshot.data.docs.length; i++) {
                    final date = DateTime.parse(dbDate);
                    if (snapshot.data.docs[position]["from"] == 'Never') {
                      if (date.isBefore(now)) {
                        databaseService.removeMyScheduled(snapshot.data.docs[position]["id"], widget.uid);
                        Fluttertoast.showToast(
                            msg: 'Scheduled meeting has expired',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.SNACKBAR,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      } else {}
                    } else {}
                  }
                  return ListTile(
                      onTap: () => _navigateToViewNote(snapshot.data.docs[position]["id"]),
                      contentPadding: EdgeInsets.all(0),
                      dense: true,
                      leading: Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Text(from,
                              style: TextStyle(
                                  color: Colors.blue, fontSize: 12),
                            )),
                      ),
                      trailing: Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Text(
                          finalDate,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      title: Text(snapshot.data.docs[position]["meetName"],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          //color: Colors.black,
                            fontSize: 16),
                      ),
                      subtitle: Text(snapshot.data.docs[position]["id"],
                        overflow: TextOverflow.ellipsis,
                      ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 1,
                    color: themeNotifier.getTheme() == darkTheme
                        ? Color(0xFF242424)
                        : Colors.black12,
                    indent: 15,
                    endIndent: 0,
                  );
                },
            );
          }),
    ),
    ),
    );
  }

  void _navigateToViewNote(String id) {
    Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => viewScheduled(
            id: id,
            name: widget.name,
            email: widget.email,
            PhotoUrl: widget.url,
            uid: widget.uid,
          )),
    );
  }

  void _createNewNote() {
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => NoteScreen(
            widget.uid,
            widget.email,
            randomNumeric(11),
            '',
            new DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
            '',
            '',
            'Never',
            true,
            false,
            false,
            true,
            true,
            false,
          ),
        ));
  }
}
