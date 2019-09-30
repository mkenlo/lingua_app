import "dart:async";
import "dart:convert" show json;
import 'package:http/http.dart' as http;



Future loadUserProfile(dynamic accessToken) async {
  String queryFields = "name,first_name,last_name,email,location,profile_pic";

  final graphResponse = await http.get(
      "https://graph.facebook.com/v4.0/me?fields=$queryFields&access_token=$accessToken");
  return json.decode(graphResponse.body);
}
