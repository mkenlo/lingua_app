import "dart:async";
import "dart:convert" show json;
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../config.dart';

const url = '$apiAuthorityUrl/users';

Future<User> loadUserProfile(dynamic accessToken) async {
  String queryFields = "name,first_name,last_name,email,location,picture";

  final graphResponse = await http.get(
      "https://graph.facebook.com/v4.0/me?fields=$queryFields&access_token=$accessToken");
  final jsonProfile = json.decode(graphResponse.body);
  return User.fromJson(jsonProfile);
}

Future<int> saveUserProfile(User user) async {
  final response = await http.post(url, body: json.encode(user));

  if (response.statusCode != 200) {
    final error = json.decode(response.body);
    throw Exception(error["message"]);
  } else
    return response.statusCode;
}
