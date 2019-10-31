import "dart:async";
import "dart:convert" show json;
import 'dart:convert';
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

Future<String> saveUserProfile(User user) async {
  final response = await http.post(url, body: json.encode(
    {
      "username" : user.username,
      "fullname" : user.fullName(),
      "location": user.location,
      "avatar": user.avatar
    }
  ));
  final jsonResponse= json.decode(response.body);
  if (response.statusCode != 200) {
    throw Exception(jsonResponse["message"]);
  } else{
    return jsonResponse['result']['id'];
  }
}
