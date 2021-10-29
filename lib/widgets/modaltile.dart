import 'package:flutter/material.dart';
import 'customtile.dart';

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function onTap;

  const ModalTile({
    @required this.title,
    @required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Color(0xff8f8f8f),
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}