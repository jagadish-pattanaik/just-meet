class SearchMeet {
  String id, name, type, time;
  SearchMeet({this.id, this.name, this.type, this.time});

  SearchMeet.fromMap(Map<String, dynamic> mapData) {
    this.id = mapData['id'];
    this.name = mapData['meetName'];
    this.type = mapData['type'];
    this.time = mapData['time'];
  }
}
