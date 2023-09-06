class User {
  String? _username;
  String? _tokenType;
  String? _accessToken;
  String? _baseUrl;
  String? _password;
  User(this._username, this._tokenType, this._accessToken, this._baseUrl,
      this._password);

  User.map(dynamic obj) {
    _username = obj["username"];
    _tokenType = obj["token_type"];
    _accessToken = obj["access_token"];
    _baseUrl = obj["baseUrl"];
    _password = obj["password"];
  }

  set username(String username) {
    _username = username;
  }

  set password(String password) {
    _password = password;
  }

  set url(String url) {
    _baseUrl = url;
  }

  String get username => _username ?? '';
  String get tokenType => _tokenType ?? '';
  String get accessToken => _accessToken ?? '';
  String get baseUrl => _baseUrl ?? '';
  String get password => _password ?? '';

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["username"] = _username;
    map["tokenType"] = _tokenType;
    map["accessToken"] = _accessToken;
    map["baseUrl"] = _baseUrl;
    map["password"] = _password;
    return map;
  }
}
