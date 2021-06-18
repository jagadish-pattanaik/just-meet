import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:provider/provider.dart';

class AppWebView extends StatefulWidget {
  var url;
  var title;
  AppWebView({Key key, @required this.url, this.title}) : super(key: key);

  @override
  WebViewState createState() => WebViewState(url, title);
}

class WebViewState extends State<AppWebView> {
  var url;
  var title;
  WebViewState(this.url, this.title);

  bool isLoading = true;
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    setState(() {
      isLoading = true;
    });
  }

  checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.getTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: TextStyle(color: themeNotifier.getTheme() == darkTheme
                ? Colors.white : Colors.black54,),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.clear,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
              ),
              onPressed: () => showActionSheet(),
            ),
          ],
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
        ),
        body: SafeArea(
          child: OfflineBuilder(
            connectivityBuilder: (
              BuildContext context,
              ConnectivityResult connectivity,
              Widget child,
            ) {
              final bool connected = connectivity != ConnectivityResult.none;
              return new Stack(
                fit: StackFit.expand,
                children: [
                  child,
                  Positioned(
                    height: 24.0,
                    left: 0.0,
                    right: 0.0,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      color: connected ? null : Color(0xFFEE4400),
                      child: Center(
                        child: connected ? null : Text('You Are Offline!',
                            style: TextStyle(color: Colors.white,)),
                      ),
                    ),
                  ),
                ],
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                new WebView(
                  initialUrl: url,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (webViewCreate) {
                    _controller.complete(webViewCreate);
                  },
                  onPageFinished: (_) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                isLoading
                    ? Center(
                        child: Center(
                            child: CupertinoActivityIndicator(animating: true),))
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showActionSheet() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
          actions: <Widget>[
      Container(
      color:themeNotifier.getTheme() == darkTheme
          ? Color(0xFF242424)
          : Colors.white,
        child: CupertinoActionSheetAction(
              child: Text('Open in browser',
                style: TextStyle(color: themeNotifier.getTheme() == darkTheme
                  ? Colors.white
                  : Colors.blue,),),
              isDefaultAction: true,
              onPressed: () async {
                var url = widget.url;
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text('No internet connection!',)));
                }
                Navigator.pop(context,);
              },
            ),
      ),
    Container(
    color:themeNotifier.getTheme() == darkTheme
    ? Color(0xFF242424)
        : Colors.white,
    child: CupertinoActionSheetAction(
              child: Text('Share',
                style: TextStyle(color: themeNotifier.getTheme() == darkTheme
                    ? Colors.white
                    : Colors.blue,),),
              isDefaultAction: true,
              onPressed: () {
                _share(widget.url);
                Navigator.pop(context);
              },
            ),
    ),
          ],
          cancelButton: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              color:themeNotifier.getTheme() == darkTheme
                  ? Color(0xFF242424)
                  : Colors.white,
            ),
              child: CupertinoActionSheetAction(
            child: Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold),),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      ),
    );
  }

  _share(String text) {
    final textshare = text;
    final RenderBox box = context.findRenderObject();
    Share.share(textshare,
        subject: text,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}
