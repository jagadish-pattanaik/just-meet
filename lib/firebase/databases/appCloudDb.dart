import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _analytics = _firestore.collection('Analytics');
final CollectionReference _appData = _firestore.collection('AppData');
final CollectionReference _reportData = _firestore.collection('Reports');

class AppCloudService {
  Future<void> addFeedback(uid, email, feedback) async {
    Map<String, dynamic> data = <String, dynamic>{
      "feedback": feedback,
      "email": email,
    };

    await _reportData
        .doc('Feedbacks')
        .collection('Feedbacks')
    .add(data)
        .whenComplete(() => print("feedback done"))
        .catchError((e) => print(e));
  }

  Future<void> addAbuseReport(uid, email, report) async {
    Map<String, dynamic> data = <String, dynamic>{
      "report": report,
      "email": email,
    };

    await _reportData
        .doc('Report Abuses')
        .collection('Reports')
        .add(data)
        .whenComplete(() => print("reported"))
        .catchError((e) => print(e));
  }

  Future<void> hostAbuseReport(uid, partUid, email, partemail, meetId) async {
    Map<String, dynamic> data = <String, dynamic>{
      "myemail": email,
      "against": partUid,
      "againstemail": partemail,
      "meetId": meetId,
    };

    await _reportData
        .doc('Report Abuses')
        .collection('Reports By Hosts')
    .doc(partUid)
        .set(data)
        .whenComplete(() => print("reported"))
        .catchError((e) => print(e));
  }

  Future<void> participantAbuseReport(uid, email, hostEmail, meetId) async {
    Map<String, dynamic> data = <String, dynamic>{
      "meetId": meetId,
      "myemail": email,
      "against": hostEmail,
    };

    await _reportData
        .doc('Report Abuses')
        .collection('Reports By Part')
        .add(data)
        .whenComplete(() => print("reported"))
        .catchError((e) => print(e));
  }

  Future<void> totalHosted() async {
    Map<String, dynamic> data = <String, dynamic>{
      "Total Hosted": FieldValue.increment(1)
    };

          await _analytics
              .doc('Total Meetings')
              .set(data)
              .whenComplete(() => print(""))
              .catchError((e) => print(e));

  }

  Future<String> getPlan() async {
    String plan;
    await  FirebaseFirestore.instance.collection('AppData').doc('planDetails').get().then((snapshot) {
      plan = snapshot.data()['basicPlan'].toString();
    });
    return plan;
  }

  Future<String> getLicense() async {
    String license;
    await  FirebaseFirestore.instance.collection('AppData').doc('planDetails').get().then((snapshot) {
      license = snapshot.data()['basicLicense'].toString();
    });
    return license;
  }

}