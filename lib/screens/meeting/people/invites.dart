import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jagu_meet/screens/meeting/people/inviteDetails.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Invites extends StatefulWidget {
  final name;
  final email;
  final uid;
  final url;
  const Invites({Key key,
    @required this.name,
    this.email,
    this.uid,
    this.url,})
      : super(key: key);

  @override
  _InvitesState createState() => _InvitesState();
}

class _InvitesState extends State<Invites> {
  RefreshController _refreshController =
  RefreshController(initialRefresh: true);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Theme(
      data: themeNotifier.getTheme(),
      child: DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
    bottom: TabBar(
    tabs: [
    Tab(text: 'Join',),
    Tab(text: 'Co-Host',),
    ],
    ),
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
          title: Text(
            'Invites',
            style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white : Colors.black54,
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
            child: TabBarView(
          children: [
            joinInvites(),
            coHostInvites()
    ],
    ),
    ),
    ),
    ),
      ),
    );
  }

  Widget joinInvites() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return SafeArea(
          child: Container(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Users')
                    .doc(widget.uid)
                    .collection('Invited').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Loading();
                  }
                  if (snapshot.hasError) {
                    return Loading();
                  }
                  return snapshot.data.docs.length == 0
                      ? Center(
                    child: Text(
                    'You have no invites to join meetings',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: themeNotifier.getTheme() == darkTheme
                          ? Colors.white
                          : Colors.black54,
                    ),
                  )
                  )
                      : Container(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    child:
                    SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: false,
                      header: ClassicHeader(),
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: snapshot.data.docs.length,
                        separatorBuilder:
                            (BuildContext context, int index) {
                          return Divider(
                            height: 1,
                            color: themeNotifier.getTheme() == darkTheme
                                ? Color(0xFF242424)
                                : Colors.black12,
                            indent: 15,
                            endIndent: 0,
                          );
                        },
                        itemBuilder:
                            (BuildContext context, int position) {
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          InviteDetails(type: 'invite',
                                            id: snapshot.data
                                                .docs[position]["id"],
                                            name: widget.name,
                                            email: widget.email,
                                            PhotoUrl: widget.url,
                                            uid: widget.uid,)));
                            },
                            visualDensity: VisualDensity(
                                horizontal: 0, vertical: -4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(0),
                                    left: Radius.circular(0))),
                            trailing: Icon(Icons.arrow_forward_ios),
                            title: Text(
                              snapshot.data.docs[position]["meetName"],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: themeNotifier.getTheme() ==
                                    darkTheme
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                            ),
                            subtitle: Text(
                              snapshot.data.docs[position]["name"],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: themeNotifier.getTheme() ==
                                    darkTheme
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
          ),
    );
  }

  Widget coHostInvites() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return SafeArea(
      child: Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Users')
                .doc(widget.uid)
                .collection('Cohost').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              }
              if (snapshot.hasError) {
                return Loading();
              }
              return snapshot.data.docs.length == 0
                  ? Center(
                child: Text(
                'You have no invites to be Co-Host in a meeting',
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: themeNotifier.getTheme() == darkTheme
                      ? Colors.white
                      : Colors.black54,
                ),
              )
              )
                  : Container(
                height: double.maxFinite,
                width: double.maxFinite,
                child:
                SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  header: ClassicHeader(),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    separatorBuilder:
                        (BuildContext context, int index) {
                      return Divider(
                        height: 1,
                        color: themeNotifier.getTheme() == darkTheme
                            ? Color(0xFF242424)
                            : Colors.black12,
                        indent: 15,
                        endIndent: 0,
                      );
                    },
                    itemBuilder:
                        (BuildContext context, int position) {
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      InviteDetails(type: 'cohost',
                                        id: snapshot.data
                                            .docs[position]["id"],
                                        name: widget.name,
                                        email: widget.email,
                                        PhotoUrl: widget.url,
                                        uid: widget.uid,)));
                        },
                        visualDensity: VisualDensity(
                            horizontal: 0, vertical: -4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(0),
                                left: Radius.circular(0))),
                        trailing: Icon(Icons.arrow_forward_ios),
                        title: Text(
                          snapshot.data.docs[position]["meetName"],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: themeNotifier.getTheme() ==
                                darkTheme
                                ? Colors.white
                                : Colors.black54,
                          ),
                        ),
                        subtitle: Text(
                          snapshot.data.docs[position]["name"],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: themeNotifier.getTheme() ==
                                darkTheme
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
      ),
    );
  }

  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    if(mounted)
      setState(() {

      });
    _refreshController.loadComplete();
  }
}
