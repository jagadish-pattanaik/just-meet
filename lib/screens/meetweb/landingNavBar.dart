import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jagu_meet/screens/user/loginPage.dart';
import 'package:jagu_meet/utils/responsiveLayout.dart';
import 'package:universal_platform/universal_platform.dart';

class NavBar extends StatelessWidget {
  final navLinks = ["Home", "Products", "Features", "Contact"];

  List<Widget> navItem() {
    return navLinks.map((text) {
      return Padding(
        padding: EdgeInsets.only(left: 18),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold),),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 45, vertical: 38),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(
                "assets/images/logo.png",
                height: 50,
                alignment: Alignment.topCenter,
              ),
              SizedBox(
                width: 16,
              ),
              Text("Just Meet", style: TextStyle(fontSize: 26))
            ],
          ),
          if (!ResponsiveLayout.isSmallScreen(context))
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[...navItem()]..add(
                  InkWell(
                    radius: 20,
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          settings: RouteSettings(name: '/signin'),
                          builder: (context) =>
                              LoginScreen()));
                },
                  child: Container(
                    margin: EdgeInsets.only(left: 20),
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xff00b6f3), Color(0xff0184dc)],
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Color(0xFF6078ea).withOpacity(.3),
                              offset: Offset(0, 8),
                              blurRadius: 8)
                        ]),
                    child: Material(
                      color: Colors.transparent,
                      child: Center(
                        child: Text(UniversalPlatform.isAndroid ? "Download" : "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1,)),
                      ),
                    ),
                  ))),
            )
          else
            Image.network("assets/menu.png", width: 26, height: 26)
        ],
      ),
    );
  }
}