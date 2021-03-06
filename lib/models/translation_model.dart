class Translation {
  String author;

  String sentence;

  String targetLanguage;

  String audioFileName;

  String recordedOn;

  Translation(
      {this.author,
      this.sentence,
      this.targetLanguage,
      this.audioFileName,
      this.recordedOn});

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
        author: json['author'],
        targetLanguage: json['language']['to'],
        sentence: json['sentence'],
        audioFileName: json['audiofile'],
        recordedOn: json['recordeddate']);
  }

  static List<Translation> asListFromJson(List<dynamic> json) {
    return json.map((i) => Translation.fromJson(i)).toList();
  }
}
