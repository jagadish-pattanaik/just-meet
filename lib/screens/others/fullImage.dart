import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class fullImage extends StatefulWidget {
  final url;

  fullImage(
      {Key key,
        @required this.url,})
      : super(key: key);

  @override
  _fullImageState createState() => _fullImageState();
}

class _fullImageState extends State<fullImage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile Photo"),
          centerTitle: true,
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.white),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      backgroundColor: Colors.black,
      body: Center(
          child: Hero(
            tag: 'imageHero',
            child:  CachedNetworkImage(
              height: double.maxFinite,
              width: double.maxFinite,
              imageUrl:  widget.url,
              placeholder: (context, url) => CupertinoActivityIndicator(animating: true, ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
      ),
        onTap: () {
      Navigator.pop(context);
    },
    );
  }
}
