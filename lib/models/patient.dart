class Patient {
  String? _accessToken;
  String? _tokenType;
  String? _userId;
  String? _username;
  String? _city;
  String? _countryCode;
  String? _dob;
  String? _ethnicity;
  String? _fname;
  int? _id;
  String? _lname;
  String? _mname;
  String? _phoneContact;
  int? _pid;
  String? _postalCode;
  String? _pubpid;
  String? _race;
  String? _sex;
  String? _state;
  String? _street;
  String? _title;

  int get pid => _pid ?? 0;
  String get title => _title ?? '';
  String get fname => _fname ?? '';
  String get mname => _mname ?? '';
  String get lname => _lname ?? '';
  String get sex => _sex ?? '';

  Patient(
      this._accessToken,
      this._tokenType,
      this._userId,
      this._username,
      this._city,
      this._countryCode,
      this._dob,
      this._ethnicity,
      this._fname,
      this._id,
      this._lname,
      this._mname,
      this._phoneContact,
      this._pid,
      this._postalCode,
      this._pubpid,
      this._race,
      this._sex,
      this._state,
      this._street,
      this._title);

  Patient.map(dynamic obj) {
    _accessToken = obj["access_token"];
    _tokenType = obj["token_type"];
    _userId = obj["user_id"];
    _username = obj["username"];
    _city = obj["city"];
    _countryCode = obj["country_code"];
    _dob = obj["DOB"];
    _ethnicity = obj["ethnicity"];
    _fname = obj["fname"];
    _id = obj["id"];
    _lname = obj["lname"];
    _mname = obj["mname"];
    _phoneContact = obj["phone_contact"];
    _pid = obj["pid"];
    _postalCode = obj["postal_code"];
    _pubpid = obj["pubpid"];
    _race = obj["race"];
    _sex = obj["sex"];
    _state = obj["state"];
    _street = obj["street"];
    _title = obj["title"];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["access_token"] = _accessToken;
    map["token_type"] = _tokenType;
    map["user_id"] = _userId;
    map["username"] = _username;
    map["city"] = _city;
    map["country_code"] = _countryCode;
    map["DOB"] = _dob;
    map["ethnicity"] = _ethnicity;
    map["fname"] = _fname;
    map["id"] = _id;
    map["lname"] = _lname;
    map["mname"] = _mname;
    map["phone_contact"] = _phoneContact;
    map["pid"] = _pid;
    map["postal_code"] = _postalCode;
    map["pubpid"] = _pubpid;
    map["race"] = _race;
    map["sex"] = _sex;
    map["state"] = _state;
    map["street"] = _street;
    map["title"] = _title;
    return map;
  }
}
