import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/themeNotifier.dart';
import '../theme/theme.dart';

enum DialogAction {yes, no, abort}

class Dialogs{
  static Future<DialogAction> yesAbortDialog(
      BuildContext context,
      String Title,
      String Body,
      String Yes,
      String No,
      ) async {
    final action = await showDialog(
      context: context,
      barrierDismissible: true,
    builder: (BuildContext context) {
      var _darkTheme;
      final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
      _darkTheme = (themeNotifier.getTheme() == darkTheme);
        return Theme(
            data: themeNotifier.getTheme(),
      child:
          AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(Title,
            overflow: TextOverflow.ellipsis,),
          content: Text(Body,
            overflow: TextOverflow.ellipsis,),
          actions: <Widget>[
            FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.transparent,
              onPressed: () => Navigator.of(context).pop(DialogAction.yes),
              child: Text(Yes,
                overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: themeNotifier.getTheme() == darkTheme ? Colors.blueAccent : Colors.blue,
              ),),
            ),
            FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.transparent,
              onPressed: () => Navigator.of(context).pop(DialogAction.no),
              child: Text(No,
                overflow: TextOverflow.ellipsis,
      style: TextStyle(
      color: themeNotifier.getTheme() == darkTheme ? Colors.blueAccent : Colors.blue,
      ),),
            )
          ],
          ),
        );
      }
    );
    return (action != null) ? action: DialogAction.abort;
  }
}