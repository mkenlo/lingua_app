class Language {
  String _name;
  String _type;
  String _code;

  Language(this._name, this._type, this._code);

  String get code => _code;

  String get type => _type;

  String get name => _name;

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(json['name'], json['type'], json['code']);
  }
}
