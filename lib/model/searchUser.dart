class SearchUser {
  String uid, name, email, avatar;
  SearchUser({this.uid, this.name, this.email, this.avatar});

  SearchUser.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'] ?? 'notupdated';
    this.name = mapData['name'] ?? 'notupdated';
    this.email = mapData['email'] ?? 'notupdated';
    this.avatar = mapData['avatar'] ?? 'notupdated';
  }
}
