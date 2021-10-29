import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jagu_meet/firebase/databases/usersCloudDb.dart';
import 'package:jagu_meet/model/searchMeet.dart';
import 'package:jagu_meet/screens/meeting/details/meetDetails.dart';
import 'package:jagu_meet/screens/meeting/schedule/viewScheduled.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/utils/universal_variables.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  final name;
  final email;
  final PhotoUrl;
  final uid;
  SearchScreen(
      {Key key,
        @required
        this.name,
        this.email,
        this.PhotoUrl,
        this.uid,})
      : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<SearchMeet> meetList;
  String query = "";
  DatabaseService databaseService = new DatabaseService();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
      databaseService.fetchAllMeets(widget.uid).then((List<SearchMeet> list) {
        setState(() {
          meetList = list;
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
            hintText: "Search in meetings",
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
    final List<SearchMeet> suggestionList = query.isEmpty
    ? []
    : meetList != null
    ? meetList.where((SearchMeet meet) {
    String _getMeetname = meet.name.toLowerCase();
    String _query = query.toLowerCase();
    String _getId = meet.id.toLowerCase();
    bool matchesMeetname = _getMeetname.contains(_query);
    bool matchesId = _getId.contains(_query);

    return (matchesMeetname || matchesId);
    }).toList()
        : [];
    return ListView.builder(
    itemCount: suggestionList.length,
    itemBuilder: ((context, index) {
    String dbTime = suggestionList[index].time.toString();
    SearchMeet searchedMeet = SearchMeet(
    id: suggestionList[index].id,
    name: suggestionList[index].name,
    type: suggestionList[index].type,
    time: dbTime);

    return ListTile(
    onTap: () {
      if (searchedMeet.type == 'host') {
    Navigator.push(
    context,
    CupertinoPageRoute(
    builder: (context) => meetDetails(db: 'host', id: searchedMeet.id, name: widget.name, email: widget.email, uid: widget.uid, PhotoUrl: widget.PhotoUrl, time: searchedMeet.time,)));
    } else if (searchedMeet.type == 'join') {
    Navigator.push(
    context,
    CupertinoPageRoute(
    builder: (context) => meetDetails(db: 'join', id: searchedMeet.id, name: widget.name, email: widget.email, uid: widget.uid, PhotoUrl: widget.PhotoUrl, time: searchedMeet.time,)));
    } else {
    Navigator.push(
    context,
    CupertinoPageRoute(
    builder: (context) => viewScheduled(id: searchedMeet.id, name: widget.name, email: widget.email, uid: widget.uid, PhotoUrl: widget.PhotoUrl,)));
    }
    },
    leading: CircleAvatar(
    backgroundColor: Colors.transparent,
    child: Text(searchedMeet.name.substring(0, 2).toUpperCase(),
    style: TextStyle(
    color: Colors.blue,),
    )
    ),
    title: Text(
    searchedMeet.name,
    style: TextStyle(
    fontWeight: FontWeight.bold,
    color: themeNotifier.getTheme() == darkTheme
    ? Colors.white
        : Colors.black
    ),
    ),
    subtitle: Text(
    searchedMeet.id,
    style: TextStyle(color: UniversalVariables.greyColor),
    ),
    );
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
}