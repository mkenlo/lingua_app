import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/fb_login.dart';
import '../l10n/strings.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'preferences_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String message = "";
  bool _isLanguageSaved;

  final FacebookLogin facebookSignIn = new FacebookLogin();

  void _doLogin() async {
    final FacebookLoginResult result =
        await facebookSignIn.logIn(['email', 'user_location']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        _saveProfilePreferences(result.accessToken.token);
        _navigateToNextPage();

        break;
      case FacebookLoginStatus.cancelledByUser:
        setState(() {
          message = loginCancelled;
        });
        break;
      case FacebookLoginStatus.error:
        setState(() {
          message = '$loginError ${result.errorMessage}';
        });

        break;
    }
  }

  void _saveProfilePreferences(String accessToken) async {
    User userProfile = await loadUserProfile(accessToken);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(!prefs.containsKey('username')){ // first install
      await prefs.setString('username', userProfile.username);
      await prefs.setString('firstName', userProfile.firstName);
      await prefs.setString('lastName', userProfile.lastName);
      await prefs.setString('location', userProfile.location);
      await prefs.setString('avatar', userProfile.avatar);

      String userId = await saveUserProfile(userProfile);
      await prefs.setString('userid', userId);
    }
  }

  Future<bool> _isPreferredLanguagesSet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getString("sourceLanguage") != null) ||
        (prefs.getString("targetLanguage") != null);
  }

  void _navigateToNextPage() async {
    _isLanguageSaved = await _isPreferredLanguagesSet();

    var nextPage;

    if (!_isLanguageSaved)
      nextPage = (BuildContext context) => PreferenceScreen();
    else
      nextPage = (BuildContext context) => HomeScreen();

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    Navigator.push(context, CupertinoPageRoute<void>(builder: nextPage));
  }

  Widget facebookLogInButton() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: GestureDetector(
            onTap: _doLogin,
            child: Row(children: [
              Image(
                  image: AssetImage("assets/images/f_logo_RGB-White_100.png"),
                  height: 24.0,
                  width: 24.0,
                  color: Theme.of(context).primaryColorDark),
              Padding(
                  padding: const EdgeInsets.only(left: 14.0, right: 10.0),
                  child: Text("Continue with Facebook",
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0))),
            ])));
  }

  @override
  void initState() {
    super.initState();
    _isLanguageSaved = false;
  }

  @override
  Widget build(BuildContext context) {
    final titleTile = Container(
        margin: EdgeInsets.fromLTRB(0.0, 200.0, 0.0, 32),
        child: Text(welcomeMessage,
            style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.w500,
                color: Colors.white)));

    final termsAndConditions =
        Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(termsAndConditionsPart1, style: TextStyle(color: Colors.white)),
      Text(termsAndConditionsPart2,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              decoration: TextDecoration.combine([TextDecoration.underline])))
    ]);

    return Scaffold(
        body: Container(
            padding: EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColorDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                titleTile,
                Expanded(
                    child:
                        Text(message, style: TextStyle(color: Colors.amber))),
                facebookLogInButton(),
                termsAndConditions
              ],
            )));
  }
}
