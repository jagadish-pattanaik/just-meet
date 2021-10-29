import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/themeNotifier.dart';

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
      final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
        return Theme(
            data: themeNotifier.getTheme(),
      child:
          AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(Title),
          content: Text(Body,),
          actions: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Color(0xff0184dc),
              onPressed: () => Navigator.of(context).pop(DialogAction.yes),
              child: Text(Yes,
                overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
              ),),
            ),
            OutlineButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.transparent,
              borderSide: BorderSide(
                color: Color(0xff0184dc),
              ),
              onPressed: () => Navigator.of(context).pop(DialogAction.no),
              child: Text(No,
                overflow: TextOverflow.ellipsis,
      style: TextStyle(
      color: Color(0xff0184dc),
      ),),
            )
          ],
          ),
        );
      }
    );
    return (action != null) ? action: DialogAction.abort;
  }

  static Future<DialogAction> redAlertDialog(
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
          final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
          return Theme(
            data: themeNotifier.getTheme(),
            child:
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(Title,),
              content: Text(Body,),
              actions: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.red,
                  onPressed: () => Navigator.of(context).pop(DialogAction.yes),
                  child: Text(Yes,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                    ),),
                ),
                OutlineButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.transparent,
                  borderSide: BorderSide(
                    color: Color(0xff0184dc),
                  ),
                  onPressed: () => Navigator.of(context).pop(DialogAction.no),
                  child: Text(No,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xff0184dc),
                    ),),
                )
              ],
            ),
          );
        }
    );
    return (action != null) ? action: DialogAction.abort;
  }

  static Future<DialogAction> infoDialog(
      BuildContext context,
      String Title,
      String Body,
      String Yes,
      ) async {
    final action = await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
          return Theme(
            data: themeNotifier.getTheme(),
            child:
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(Title,),
              content: Text(Body),
              actions: <Widget>[
                OutlineButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  borderSide: BorderSide(
                    color: Color(0xff0184dc),
                  ),
                  color: Colors.transparent,
                  onPressed: () => Navigator.of(context).pop(DialogAction.abort),
                  child: Text(Yes,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xff0184dc),
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