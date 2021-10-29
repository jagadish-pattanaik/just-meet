import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jagu_meet/screens/meeting/people/participantDetails.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/loading.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';

class Participants extends StatefulWidget {
  final uid;
  final name;
  final email;
  final id;
  final topic;
  const Participants({
    this.uid,
    this.name,
    this.email,
    this.id,
    this.topic,
    Key key}) : super(key: key);

  @override
  _ParticipantsState createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {
  RefreshController _refreshController =
  RefreshController(initialRefresh: true);

  var linkImageUrl = Uri.parse(
      'https://play-lh.googleusercontent.com/7ZrxSsCqSNb86h57pPlJ3budCKTTZrCDSB3aq1F-srZnhO4M1iNtCXaM7fvxuJU3Yg=s180-rw');
  var urlLinkTitle = 'Join Just Meet Video Conference';
  var urlLinkDescription =
      'Just Meet is the leader in video conferences, with easy, secured, encrypted and reliable video and audio conferencing, chat, screen sharing and webinar across mobile and desktop. Unlimited participants and time with low bandwidth mode. Join Just Meet Video Conference now and enjoy high quality video conferences with security like no other. Stay Safe and Stay Connected with Just Meet. Developed in India with love.';

  Future<Uri> createDynamicLink(
      {@required String meet}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://jagumeet.page.link',
      link: Uri.parse(
          'https://www.jaguweb.jmeet.com/meet?id=$meet'),
      androidParameters: AndroidParameters(
        packageName: 'com.jaguweb.jagu_meet',
        minimumVersion: int.parse(packageInfo.buildNumber),
      ),
      iosParameters: IosParameters(
          fallbackUrl: Uri.parse('https://jmeet-8e163.web.app/'),
          ipadFallbackUrl: Uri.parse('https://jmeet-8e163.web.app/'),
          bundleId: ''),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'Video Conference',
        medium: 'Social',
        source: 'Just Meet',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        imageUrl: linkImageUrl,
        title: urlLinkTitle,
        description: urlLinkDescription,
      ),
    );
    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri dynamicUrl = shortDynamicLink.shortUrl;
    return dynamicUrl;
  }

  _shareMeeting(
      String roomids, String topics, String androidUrl, String url) async {
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
      final textshare =
          "${widget.name} is inviting you to join a Just Meet meeting.  "
          "\n"
          "\n"
          "Meeting Id - $roomids.  "
          "\n"
          "Meeting Topic - $topics.  "
          "\n"
          "\n"
          "Meeting URL - $androidUrl  ";
      final RenderBox box = context.findRenderObject();
      Share.share(textshare,
          subject:
          "${widget.name} is inviting you to join a Just Meet meeting.  ",
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
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
              Icons.arrow_back_ios,
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
            'Participants',
            style: TextStyle(
              color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white : Colors.black54,
            ),
          ),
        ),
        body: SafeArea(
          child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('Users').doc(widget.uid)
                      .collection('Hosted')
                      .doc(widget.id)
                      .collection('Participants').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Loading();
                    }
                    if (snapshot.hasError) {
                      return Loading();
                    }
                    return snapshot.data.docs.length == 0
                        ?
                    Container(
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('No Participants', style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold), ),
                            SizedBox(height: 20,),
                      SizedBox(
                      height: 50.0,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.50,
                      child: RaisedButton(
                          color: Color(0xff0184dc),
                          elevation: 5,
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          onPressed: () async {
                            var connectivityResult =
                            await (Connectivity().checkConnectivity());
                            if (connectivityResult ==
                                ConnectivityResult.none) {
                              Fluttertoast.showToast(
                                  msg: 'No Internet Connection!',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.SNACKBAR,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else {
                              var dynamicLink = await createDynamicLink(
                                meet: widget.id.replaceAll(
                                    RegExp(
                                        r'[-_!@#$%^&*(),.?":{}|<>+=|\/~` ]'),
                                    ""),
                              );
                              var dynamicWeb = 'https://jmeet-8e163.web.app/';
                              _shareMeeting(
                                  widget.id,
                                  widget.topic,
                                  dynamicLink.toString(),
                                  dynamicWeb);
                            }
                          },
                          child: Text(
                            'Invite Others',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          )),
                      ),
                          ],
                        )
                        ),
                    )
                        : SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: false,
                        header: ClassicHeader(),
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        child: ListView.separated(
                            itemCount: snapshot.data.docs.length,
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
                            itemBuilder: (context, position) {
                              return
                                    ListTile(
                                        title: Text(snapshot.data.docs[position]["name"],  overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),),
                                        subtitle: Text(snapshot.data.docs[position]["email"]),
                                        leading: Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: CircleAvatar(
                                              backgroundColor: Colors.transparent,
                                              child: CachedNetworkImage(
                                                imageUrl: snapshot.data.docs[position]["avatar"],
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
                                        contentPadding: EdgeInsets.only(
                                            top: 0, bottom: 0, left: 10),
                                        onTap: () {Navigator.push(context,
                                              CupertinoPageRoute(builder: (context) => ParticipantDetails(name: snapshot.data.docs[position]["name"], email: snapshot.data.docs[position]["email"], joined: snapshot.data.docs[position]["joined"], left: snapshot.data.docs[position]["left"],)));
                                        }
                                );
                            })
                    );
                  }),
    ),
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
