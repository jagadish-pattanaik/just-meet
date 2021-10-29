import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jagu_meet/screens/meeting/host.dart';
import 'package:jagu_meet/screens/meeting/join.dart';
import 'package:jagu_meet/screens/meeting/schedule/NoteScreen.dart';
import 'package:jagu_meet/screens/meeting/schedule/viewScheduled.dart';
import 'package:jagu_meet/screens/meeting/startLive.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class LocalNotificationServices {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize(BuildContext context, _userName, _userEmail, _userUid, _userUrl) async {
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: AndroidInitializationSettings("@drawable/ic_stat_notification"));

    tz.initializeTimeZones();
    final locationName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(locationName));

    scheduleDaily(0001, 'Scheduled meetings?', 'Scheduled all meetings for today? Schedule now!', 'schedule', 7, 0);
    scheduleDaily(0002, 'Express your thoughts!', 'Start a live stage and let the world join you, share your ideas, thoughts, emotions!', 'live', 16, 0);
    scheduleDaily(0003, 'Share  your ideas and emotions!', 'Start a live stage and let the world join you, share your ideas, thoughts, emotions!', 'live', 12, 0);
    scheduleDaily(0004, 'Show your talent on stage!', 'Start a live stage and show your talent to the whole world!', 'live', 20, 0);
    scheduleWeekly(0005, 'All ready for next week?', 'Schedule your meetings for the next week!', 'schedule', 9);
    scheduleDaily(0006, 'Scheduled meetings?', "Haven't scheduled meetings for tomorrow yet? Schedule now!", 'schedule', 22, 0);

    _notificationsPlugin.initialize(
        initializationSettings,onSelectNotification: (String route) async{
      if(route != null){
        if (route == 'schedule') {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => NoteScreen(
                  _userUid,
                  _userEmail,
                  randomNumeric(11),
                  '',
                  new DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
                  '',
                  '',
                  'Never',
                  true,
                  false,
                  false,
                  true,
                  true,
                  false,
                ),
              ));
        } else if (route == 'host') {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                      HostPage(
                        name: _userName,
                        email: _userEmail,
                        uid: _userUid,
                        url: _userUrl,
                      )));
        }  else if (route == 'join') {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => Join(
                    name: _userName,
                    email: _userEmail,
                    uid: _userUid,
                    url: _userUrl,
                  )));
        }  else if (route == 'live') {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => StartLive(
                    email: _userEmail,
                    name: _userName,
                    url: _userUrl,)));
        } else if (route == 'live') {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => StartLive(
                    email: _userEmail,
                    name: _userName,
                    url: _userUrl,)));
        } else if (route.contains('reminder')) {
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => viewScheduled(
                  id: route.split('reminder_'),
                  name: _userName,
                  email: _userEmail,
                  PhotoUrl: _userUrl,
                  uid: _userUid,
                )),
          );
        } else {

        }
      }
    });
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/1000;

      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            "justmeet",
            "Cloud Notifications",
            channelDescription: "Cloud updates notifications",
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          )
      );


      await _notificationsPlugin.show(
        id,
        message.notification.title,
        message.notification.body,
        notificationDetails,
        payload: message.data["route"],
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  scheduleDaily(int id, String title, body, payload, int hour, int min) async {
    await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _scheduleDailyTime(Time(hour, min)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
              'justmeet',
              "Routine Notifications",
              channelDescription: 'Routine notification',
              playSound: true,)),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time);
  }

  scheduleWeekly(int id, String title, body, payload, int time) async {
    await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _scheduleWeeklyTime(Time(time), days: [DateTime.sunday, DateTime.monday]),
        const NotificationDetails(
            android: AndroidNotificationDetails(
              'justmeet',
              "Routine Notifications",
              channelDescription: 'Routine notification',
              playSound: true,)),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  scheduleDailyReminder(int id, String title, body, payload, int hour, int min) async {
    await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _scheduleDailyTime(Time(hour, min)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
              'justmeet',
              "Upcoming Meetings Notifications",
              channelDescription: 'Reminder for scheduled meetings',
              playSound: true,)),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  scheduleWeeklyReminder(int id, String title, body, payload, int hour, int min, day) async {
    await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _scheduleWeeklyTime(Time(hour, min), days: [day]),
        const NotificationDetails(
            android: AndroidNotificationDetails(
              'justmeet',
              "Upcoming Meetings Notifications",
              channelDescription: 'Reminder for scheduled meetings',
              playSound: true,)),
        payload: payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
  }

  static tz.TZDateTime _scheduleDailyTime(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute, time.second);

    return scheduledDate.isBefore(now)
    ? scheduledDate.add(Duration(days: 1))
        : scheduledDate;
  }

  static tz.TZDateTime _scheduleWeeklyTime(Time time, {@required List days}) {
    tz.TZDateTime scheduledDate = _scheduleDailyTime(time);
    
    while (!days.contains(scheduledDate.weekday)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }
}