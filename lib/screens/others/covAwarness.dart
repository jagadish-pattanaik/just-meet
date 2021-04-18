import 'package:flutter/cupertino.dart';
import 'package:jagu_meet/screens/others/webview.dart';
import 'package:jagu_meet/theme/theme.dart';
import 'package:jagu_meet/theme/themeNotifier.dart';
import 'package:jagu_meet/widgets/constant.dart';
import 'package:jagu_meet/widgets/my_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoScreen extends StatefulWidget {
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final controller = ScrollController();
  double offset = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.addListener(onScroll);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }
  
  var _darkTheme;

  launchWebView(var URL, var TITLE) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => AppWebView(
              url: URL,
              title: TITLE,
            )));
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return MaterialApp(
        title: 'Just Meet',
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.getTheme(),
    home: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        controller: controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MyHeader(
              image: "assets/icons/coronadr.svg",
              textTop: "Get to know",
              textBottom: "About COVID-19.",
              offset: offset,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Symptoms",
                    style: kTitleTextstyle.copyWith(
                      color: themeNotifier.getTheme() == darkTheme
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SymptomCard(
                          image: "assets/images/headache.png",
                          title: "Headache",
                          isActive: true,
                            mode: themeNotifier.getTheme() == darkTheme
                                ? 'd'
                                : 'l'
                        ),
                        SymptomCard(
                          image: "assets/images/caugh.png",
                          title: "Cough",
                            mode: themeNotifier.getTheme() == darkTheme
                                ? 'd'
                                : 'l'
                        ),
                        SymptomCard(
                          image: "assets/images/caugh.png",
                          title: "Difficulty in breathing",
                            mode: themeNotifier.getTheme() == darkTheme
                                ? 'd'
                                : 'l'
                        ),
                        SymptomCard(
                          image: "assets/images/fever.png",
                          title: "Fever",
                            mode: themeNotifier.getTheme() == darkTheme
                                ? 'd'
                                : 'l'
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Prevention", style: kTitleTextstyle.copyWith(
                    color: themeNotifier.getTheme() == darkTheme
                        ? Colors.white
                        : Colors.black,
                  ),),
                  SizedBox(height: 20),
                  PreventCard(
                    text:
                    "Wear face masks to prevent virus and infected droplets from getting in and frequent hand touches.",
                    image: "assets/images/wear_mask.png",
                    title: "Wear face mask",
                      mode: themeNotifier.getTheme() == darkTheme
                          ? 'd'
                          : 'l'
                  ),
                  PreventCard(
                    text:
                    "Wash your hands properly for at least 20 minutes with good hand wash as physical touch is done mainly with hands.",
                    image: "assets/images/wash_hands.png",
                    title: "Wash your hands",
                      mode: themeNotifier.getTheme() == darkTheme
                          ? 'd'
                          : 'l'
                  ),
                  PreventCard(
                    text:
                    "Sanitize your hands with an alcohol sanitizer frequently time to time after touching different objects or a person.",
                    image: "assets/images/wash_hands.png",
                    title: "Sanitize your hands",
                    mode: themeNotifier.getTheme() == darkTheme
                        ? 'd'
                        : 'l'
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child:
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
                      onPressed: () => launchWebView('https://www.mohfw.gov.in/', 'Information Regarding'),
                      child: Text(
                        "Go To Website",
                        style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      color: themeNotifier.getTheme() == darkTheme
                          ? Colors.blueAccent
                          : Colors.blue,
                    ),
                  ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('*Only for India',
                      style: TextStyle(
                      color: themeNotifier.getTheme() == darkTheme
                      ? Colors.white
                      : Colors.black,)),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Facts About COVID-19",
                    style: kTitleTextstyle.copyWith(
                      color: themeNotifier.getTheme() == darkTheme
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  factCard(text:'COVID-19 vaccine development was accelerated without impacting safety',  mode: themeNotifier.getTheme() == darkTheme
                      ? 'd'
                      : 'l'),
                  factCard(text: 'Vaccines are thoroughly tested for the safety before they are approved',  mode: themeNotifier.getTheme() == darkTheme
                      ? 'd'
                      : 'l'),
                  factCard(text: 'Vaccine side effects are usually mild',  mode: themeNotifier.getTheme() == darkTheme
                      ? 'd'
                      : 'l'),
                  factCard(text: "Pneumonia vaccines don't prevent COVID-19",  mode: themeNotifier.getTheme() == darkTheme
                      ? 'd'
                      : 'l'),
                  SizedBox(height: 20),
                ],
              ),
            )
          ],
        ),
      ),
    ),
    );
  }
}

class factCard extends StatelessWidget {
  final String text;
  final String mode;
  const factCard({
  Key key,
  this.text,
  this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
        child: Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      color: mode == 'd' ? Color(0xFF242424) :  Colors.white,
        ),
        child: ListTile(
          onTap: () => null,
          title: Text(text, style: TextStyle(fontSize: 16, color: mode == 'd' ? Colors.white :  Colors.black, fontWeight: FontWeight.bold),),
          dense: true,
          isThreeLine: false,
        ),
        ),
    );

  }

}

class PreventCard extends StatelessWidget {
  final String image;
  final String title;
  final String text;
  final String mode;
  const PreventCard({
    Key key,
    this.image,
    this.title,
    this.text,
    this.mode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 156,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Container(
              height: 136,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: mode == 'd' ? Color(0xFF242424)
                    : Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 8),
                    blurRadius: 24,
                    color: kShadowColor,
                  ),
                ],
              ),
            ),
            Image.asset(image),
            Positioned(
              left: 130,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                height: 136,
                width: MediaQuery.of(context).size.width - 170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      title,
                      style: kTitleTextstyle.copyWith(
                        fontSize: 16,
                        color: mode == 'd' ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SymptomCard extends StatelessWidget {
  final String image;
  final String title;
  final bool isActive;
  final String mode;
  const SymptomCard({
    Key key,
    this.image,
    this.title,
    this.isActive = false,
    this.mode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: EdgeInsets.only(right: 10),
        child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: mode == 'd' ? Color(0xFF242424)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          isActive
              ? BoxShadow(
            offset: Offset(0, 10),
            blurRadius: 20,
            color: kActiveShadowColor,
          )
              : BoxShadow(
            offset: Offset(0, 3),
            blurRadius: 6,
            color: kShadowColor,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Image.asset(image, height: 90),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: mode == 'd' ? Colors.white
                : Colors.black,),
          ),
        ],
      ),
        ),
    );
  }
}