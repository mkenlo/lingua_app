import 'language_model.dart';

class Sentence {
  String _id;
  String _text;
  Language _language;

  Sentence(this._id, this._text, this._language);

  String get id => _id;

  String get text => _text;

  Language get language => _language;

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
        json['id'], json['text'], Language.fromJson(json['language']));
  }

  static List<Sentence> asListFromJson(List<dynamic> json) {
    return json.map((i) => Sentence.fromJson(i)).toList();
  }
}
