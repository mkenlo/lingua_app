import "dart:async";
import "dart:convert";
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/language_model.dart';

const url = '$apiAuthorityUrl/languages';

Future<List<Language>> fetchLanguages(String filter) async {

  final response = await http.get('$url?$filter');

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return Language.asListFromJson(jsonResponse["results"]);
  } else {
    throw Exception('Failed to load Data');
  }
}