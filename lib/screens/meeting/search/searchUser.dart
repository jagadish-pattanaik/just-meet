import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:jagu_meet/model/searchUser.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/utils/universal_variables.dart';
import 'package:provider/provider.dart';

class SearchUsersScreen extends StatefulWidget {
  final name;
  final email;
  final PhotoUrl;
  final uid;
  final type;
  final meetId;
  final meetName;
  SearchUsersScreen(
      {Key key,
        @required
        this.name,
        this.email,
        this.PhotoUrl,
        this.uid,
      this.type,
      this.meetId,
      this.meetName})
      : super(key: key);

  @override
  _SearchUsersScreenState createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  List<SearchUser> usersList;
  String query = "";
  DatabaseService databaseService = new DatabaseService();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    databaseService.fetchAllUsers().then((List<SearchUser> list) {
      setState(() {
        usersList = list;
      });
    });
  }

  searchAppBar(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return AppBar(
      backgroundColor: themeNotifier.getTheme() == darkTheme
          ? Color(0xff0d0d0d)
          : Color(0xffffffff),
      bottom: PreferredSize(
          child: Divider(
              height: 1,
              color: themeNotifier.getTheme() == darkTheme
                  ?  Color(0xFF303030) : Colors.black12
          ),
          preferredSize: Size(double.infinity, 0.0)),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_sharp, color: themeNotifier.getTheme() == darkTheme
            ? Colors.white
            : Colors.black54,),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      title: TextField(
        controller: searchController,
        onChanged: (val) {
          setState(() {
            query = val;
          });
        },
        cursorColor: themeNotifier.getTheme() == darkTheme
            ? Colors.white
            : Colors.black54,
        autofocus: true,
        style: TextStyle(
          color: themeNotifier.getTheme() == darkTheme
              ? Colors.white
              : Colors.black54,
          fontSize: 20,
        ),
        decoration: InputDecoration(
          suffixIcon: Visibility(
            visible: searchController.text.isEmpty ? false : true,
            child:  IconButton(
              icon: Icon(Icons.close, color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white
                  : Colors.black54,),
              onPressed: () {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => searchController.clear());
              },
            ),
          ),
          border: InputBorder.none,
          hintText: "Search people",
          hintStyle: TextStyle(
            fontSize: 20,
            color: Color(0x88ffffff),
          ),
        ),
      ),
    );
  }

  buildSuggestions(String query) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final List<SearchUser> suggestionList = query.isEmpty
    ? []
    : usersList != null
    ? usersList.where((SearchUser user) {
    String _getUsername = user.name.toLowerCase();
    String _query = query.toLowerCase();
    String _getEmail = user.email.toLowerCase();
    bool matchesUsername = _getUsername.contains(_query);
    bool matchesEmail = _getEmail.contains(_query);

    return (matchesUsername || matchesEmail);
    }).toList()
        : [];
    return ListView.builder(
    itemCount: suggestionList.length,
    itemBuilder: ((context, index) {
    String invUid = suggestionList[index].uid;
    SearchUser searchedUser = SearchUser(
    uid: suggestionList[index].uid,
    name: suggestionList[index].name,
    email: suggestionList[index].email,
    avatar: suggestionList[index].avatar);
    return searchedUser.name != 'notupdated' ? ListTile(
    trailing: button(invUid),
    leading: Padding(
    padding: EdgeInsets.only(left: 5),
    child: CircleAvatar(
    backgroundColor: Colors.transparent,
    child: CachedNetworkImage(
    imageUrl: searchedUser.avatar,
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
    ),),
    ),
    title: Text(
    searchedUser.name,
    style: TextStyle(
    fontWeight: FontWeight.bold,
    color: themeNotifier.getTheme() == darkTheme
    ? Colors.white
        : Colors.black
    ),
    ),
    subtitle: Text(
    searchedUser.email,
    style: TextStyle(color: UniversalVariables.greyColor),
    ),
    ) : null;
    }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Theme(
      data: themeNotifier.getTheme(),
      child: Scaffold(
        backgroundColor: themeNotifier.getTheme() == darkTheme
            ? Color(0xff0d0d0d)
            : Color(0xffffffff),
        appBar: searchAppBar(context),
        body: Container(
          child: buildSuggestions(query),
        ),
      ),
    );
  }

  button(invUid) {
    if (widget.type == 'invite') {
      if (isInvited(widget.meetId, invUid) == false) {
        return RaisedButton(
              color: Color(0xff0184dc),
              elevation: 5,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onPressed: () {
                databaseService.inviteUser(widget.uid, invUid, widget.name, widget.email, widget.PhotoUrl, widget.meetId, widget.meetName);
                Fluttertoast.showToast(
                    msg: 'Invitation sent',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                },
              child: Text('Invite',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              )
        );
      } else if (isInvited(widget.meetId, invUid) == true) {
        return OutlineButton(
            color: Colors.transparent,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Color(0xff0184dc),
            ),
            onPressed: () {
              databaseService.deleteInvitedUser(widget.uid, invUid, widget.meetId);
              Fluttertoast.showToast(
                  msg: 'Deleted invitation',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.SNACKBAR,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            child: Text(
              'Invited',
              style: TextStyle(
                  fontSize: 17,
                  color: Color(0xff0184dc),
                  fontWeight: FontWeight.bold),
            ));
      }
    } else if (widget.type == 'cohost') {
      if (isCoHost(widget.meetId, invUid) == false) {
        return RaisedButton(
            color: Color(0xff0184dc),
            elevation: 5,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: () {
              databaseService.inviteCoHost(widget.uid, invUid, widget.name, widget.email, widget.PhotoUrl, widget.meetId, widget.meetName);
              Fluttertoast.showToast(
                  msg: 'Invitation sent',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.SNACKBAR,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
              },
            child: Text('Make Co-Host',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
            )
        );
      } else {
        return OutlineButton(
            color: Colors.transparent,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Color(0xff0184dc),
            ),
            onPressed: () {
              databaseService.deleteInvitedCoHost(widget.uid, invUid, widget.meetId);
              Fluttertoast.showToast(
                  msg: 'Deleted Invitation',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.SNACKBAR,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            child: Text(
              'Co-Host',
              style: TextStyle(
                  fontSize: 17,
                  color: Color(0xff0184dc),
                  fontWeight: FontWeight.bold),
            ));
      }
    } else {
      if (isBlocked(widget.meetId, invUid) == false) {
        return RaisedButton(
            color: Colors.red,
            elevation: 5,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: () {
              databaseService.blockUser(invUid, widget.meetId, widget.meetName);
              Fluttertoast.showToast(
                  msg: 'Blocked',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.SNACKBAR,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            child: Text('Block',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
            )
        );
      } else {
        return OutlineButton(
            color: Colors.transparent,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.red,
            ),
            onPressed: () {
              databaseService.deleteBlockedUser(invUid, widget.meetId);
              Fluttertoast.showToast(
                  msg: 'Unblocked',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.SNACKBAR,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            child: Text(
              'Blocked',
              style: TextStyle(
                  fontSize: 17,
                  color: Color(0xff0184dc),
                  fontWeight: FontWeight.bold),
            ));
      }
    }
  }

  isBlocked(meetId, uid) {
    bool isBlocked;
    try {
      FirebaseFirestore.instance.doc(
          "Invcoblocked/$meetId/Blocked/$uid")
          .get()
          .then((doc)  {
        if (doc.exists) {
          setState(() {
            isBlocked = true;
          });
        } else {
          setState(() {
            isBlocked = false;
          });
        }
      });
    } catch (e) {
      print(e);
    }
    return isBlocked;
  }

  isInvited(meetId, uid) async {
    bool isInvited;
    try {
       await FirebaseFirestore.instance.doc(
          "Invcoblocked/$meetId/Invited/$uid")
          .get()
          .then((doc)  {
        if (doc.exists) {
          setState(() {
            isInvited = true;
          });
        } else {
          setState(() {
            isInvited = false;
          });
        }
      });
    } catch (e) {
      print(e);
    }
    return isInvited;
  }

  isCoHost(meetId, uid) {
    bool isCoHost;
    try {
       FirebaseFirestore.instance.doc(
          "Invcoblocked/$meetId/Cohost/$uid")
          .get()
          .then((doc)  {
        if (doc.exists) {
          setState(() {
            isCoHost = true;
          });
        } else {
          setState(() {
            isCoHost = false;
          });
        }
      });
    } catch (e) {
      print(e);
    }
    return isCoHost;
  }
}