class Note {
  int _id;
  String _title;
  String _description;
  var _chatEnabled;
  var _liveEnabled;
  var _recordEnabled;
  var _raiseEnabled;
  var _shareYtEnabled;
  var _kickOutEnabled;
  String _time;
  String _host;

  Note(this._title, this._description, this._time, this._chatEnabled, this._liveEnabled, this._recordEnabled, this._raiseEnabled, this._shareYtEnabled, this._kickOutEnabled, this._host);

  Note.map(dynamic obj) {
    this._id = obj['id'];
    this._title = obj['title'];
    this._description = obj['description'];
    this._time = obj['time'];
    this._chatEnabled = obj['chatEnabled'];
    this._liveEnabled = obj['liveEnabled'];
    this._recordEnabled = obj['recordEnabled'];
    this._raiseEnabled = obj['raiseEnabled'];
    this._shareYtEnabled = obj['shareYtEnabled'];
    this._kickOutEnabled = obj['kickOutEnabled'];
    this._host = obj['host'];
  }

  int get id => _id;
  String get title => _title;
  String get description => _description;
  String get time => _time;
  int get chatEnabled => _chatEnabled;
  int get liveEnabled => _liveEnabled;
  int get recordEnabled => _recordEnabled;
  int get raiseEnabled => _raiseEnabled;
  int get shareYtEnabled => _shareYtEnabled;
  int get kickOutEnabled => _kickOutEnabled;
  String get host => _host;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['time'] = _time;
    map['chatEnabled'] = _chatEnabled;
    map['liveEnabled'] = _liveEnabled;
    map['recordEnabled'] = _recordEnabled;
    map['raiseEnabled'] = _raiseEnabled;
    map['shareYtEnabled'] = _shareYtEnabled;
    map['kickOutEnabled'] = _kickOutEnabled;
    map['host'] = _host;

    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._time = map['time'];
    this._chatEnabled = map['chatEnabled'];
    this._liveEnabled = map['liveEnabled'];
    this._recordEnabled = map['recordEnabled'];
    this._raiseEnabled = map['raiseEnabled'];
    this._shareYtEnabled = map['shareYtEnabled'];
    this._kickOutEnabled = map['kickOutEnabled'];
    this._host = map['host'];
  }
}

class Note1 {
  int _id1;
  String _title1;
  String _description1;

  Note1(this._title1, this._description1);

  Note1.map(dynamic obj) {
    this._id1 = obj['id1'];
    this._title1 = obj['title1'];
    this._description1 = obj['description1'];
  }

  int get id1 => _id1;

  String get title1 => _title1;

  String get description1 => _description1;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id1 != null) {
      map['id1'] = _id1;
    }
    map['title1'] = _title1;
    map['description1'] = _description1;

    return map;
  }

  Note1.fromMap(Map<String, dynamic> map) {
    this._id1 = map['id1'];
    this._title1 = map['title1'];
    this._description1 = map['description1'];
  }
}

class Note2 {
  int _id2;
  String _title2;
  String _description2;
  String _date2;
  String _from2;
  String _to2;
  String _repeat;
  var _chatEnabled2;
  var _liveEnabled2;
  var _recordEnabled2;
  var _raiseEnabled2;
  var _shareYtEnabled2;
  var _kickOutEnabled2;


  Note2(this._title2, this._description2, this._date2, this._from2, this._to2, this._repeat, this._chatEnabled2, this._liveEnabled2, this._recordEnabled2, this._raiseEnabled2, this._shareYtEnabled2, this._kickOutEnabled2);

  Note2.map(dynamic obj) {
    this._id2 = obj['id2'];
    this._title2 = obj['title2'];
    this._description2 = obj['description2'];
    this._date2 = obj['date2'];
    this._from2 = obj['from2'];
    this._to2 = obj['to2'];
    this._repeat = obj['repeat'];
    this._chatEnabled2 = obj['chatEnabled2'];
    this._liveEnabled2 = obj['liveEnabled2'];
    this._recordEnabled2 = obj['recordEnabled2'];
    this._raiseEnabled2 = obj['raiseEnabled2'];
    this._shareYtEnabled2 = obj['shareYtEnabled2'];
    this._kickOutEnabled2 = obj['kickOutEnabled2'];
  }

  int get id2 => _id2;
  String get title2 => _title2;
  String get description2 => _description2;
  String get date2 => _date2;
  String get from2 => _from2;
  String get to2 => _to2;
  String get repeat => _repeat;
  int get chatEnabled2 => _chatEnabled2;
  int get liveEnabled2 => _liveEnabled2;
  int get recordEnabled2 => _recordEnabled2;
  int get raiseEnabled2 => _raiseEnabled2;
  int get shareYtEnabled2 => _shareYtEnabled2;
  int get kickOutEnabled2 => _kickOutEnabled2;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id2 != null) {
      map['id2'] = _id2;
    }
    map['title2'] = _title2;
    map['description2'] = _description2;
    map['date2'] = _date2;
    map['from2'] = _from2;
    map['to2'] = _to2;
    map['repeat'] = _repeat;
    map['chatEnabled2'] = _chatEnabled2;
    map['liveEnabled2'] = _liveEnabled2;
    map['recordEnabled2'] = _recordEnabled2;
    map['raiseEnabled2'] = _raiseEnabled2;
    map['shareYtEnabled2'] = _shareYtEnabled2;
    map['kickOutEnabled2'] = _kickOutEnabled2;
    return map;
  }

  Note2.fromMap(Map<String, dynamic> map) {
    this._id2 = map['id2'];
    this._title2 = map['title2'];
    this._description2 = map['description2'];
    this._date2 = map['date2'];
    this._from2 = map['from2'];
    this._to2 = map['to2'];
    this._repeat = map['repeat'];
    this._chatEnabled2 = map['chatEnabled2'];
    this._liveEnabled2 = map['liveEnabled2'];
    this._recordEnabled2 = map['recordEnabled2'];
    this._raiseEnabled2 = map['raiseEnabled2'];
    this._shareYtEnabled2 = map['shareYtEnabled2'];
    this._kickOutEnabled2 = map['kickOutEnabled2'];
  }
}