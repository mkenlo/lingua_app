class Translation {
  String author;

  String sentence;

  String targetLanguage;

  String audioFileName;

  String date;

  Translation(
      {this.author, this.sentence, this.targetLanguage, this.audioFileName, this.date});

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
        author: json['author'],
        targetLanguage: json['language']['to'],
        sentence: json['sentence'],
        audioFileName: json['audiofile']);
  }

  static List<Translation> asListFromJson(List<dynamic> json) {
    return json.map((i) => Translation.fromJson(i)).toList();
  }
}
