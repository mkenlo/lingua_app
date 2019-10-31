import "dart:async";
import "dart:convert";
import 'package:http/http.dart' as http;

import 'dart:io' show File;
import '../config.dart';
import '../models/translation_model.dart';

const url = '$apiAuthorityUrl/translations';

Future<dynamic> fetchTranslation(String userId) async {
  final response = await http.get('$apiAuthorityUrl/users/$userId/translations');

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return Translation.asListFromJson(jsonResponse["results"]);
  } else {
    throw Exception('Failed to load Data');
  }
}

Future<int> saveTranslation(Translation translation, String fileContent) async {
  final response = await http.post(url,
      body: json.encode({
        "author": translation.author,
        "sentence": translation.sentence,
        "target_lang": translation.targetLanguage,
        "audiofile": {"name": translation.audioFileName, "content": fileContent}
      }));

  if (response.statusCode != 200) {
    final error = json.decode(response.body);
    throw Exception(error["message"]);
  } else
    return response.statusCode;
}

Future readFileContentAndUploadTranslation(Translation translation) async {
  String fileContents = "";
  File file = File("$recordStorage/${translation.audioFileName}");

  if (await file.exists()) {
    var stream = file.openRead();

    return stream.transform(base64.encoder).listen((data) {
      if (data == null) {
        return;
      }
      fileContents = fileContents + data;
    }, onError: (e) {
      throw Exception(e);
    }, onDone: () {
      saveTranslation(translation, fileContents).catchError((err){
        // TODO : find a way to properly propagate error to the widget
        print(err); // Intentionally left
      });
    });
  }
}
