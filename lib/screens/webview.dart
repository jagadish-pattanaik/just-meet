import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  var _darkTheme;
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
      Fluttertoast.showToast(
          msg: 'No Internet Connection!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.getTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: themeNotifier.getTheme() == darkTheme
              ? Color(0xFF242424)
              : Colors.blue,
          elevation: 5,
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
                        child: connected ? null : Text('You Are Offline!'),
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
                            child: CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.blue),
                      )))
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
