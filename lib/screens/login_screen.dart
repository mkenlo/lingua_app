import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'sentence_list_screen.dart';
import '../services/fb_login.dart';
import '../l10n/strings.dart';


class LoginScreen extends StatefulWidget {
  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String message = "";
  final FacebookLogin facebookSignIn = new FacebookLogin();

  void _doLogin() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        _setUserPreferences(result.accessToken.token);
        _navigateToHomePage();
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


  void _setUserPreferences(String accessToken) async{
    //TODO : load and set user Profile
    dynamic userProfile = await loadUserProfile(accessToken);
  }

  void _navigateToHomePage(){
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    Navigator.push(context,
        CupertinoPageRoute<void>(builder: (BuildContext context) => SentenceListScreen()));
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
      Text(termsAndConditionsPart1,
          style: TextStyle(color: Colors.white)),
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
                Expanded(child: Text(message, style: TextStyle(color: Colors.amber))),
                facebookLogInButton(),
                termsAndConditions
              ],
            )));
  }
}
