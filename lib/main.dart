import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lingua',
      theme: ThemeData(
        fontFamily: "Raleway",
        primarySwatch: Colors.teal
      ),
      home: Router(),
    );
  }

}

class Router extends StatefulWidget{

  @override
  State createState() => _RouterState();
}

class _RouterState extends State<Router>{

  FacebookLogin facebookSignIn;
  bool isFBTokenValid;
  bool isPrefSaved;

  @override
  void initState() {
    super.initState();
    facebookSignIn = new FacebookLogin();

    facebookSignIn.isLoggedIn.then((res){
      setState(() {
        isFBTokenValid = res;
      });
    });

    SharedPreferences.getInstance().then((prefInstance){
      if(prefInstance.containsKey("sourceLanguage") || prefInstance.containsKey("targetLanguage")){
        setState(() {
          isPrefSaved = true;
        });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    if(isFBTokenValid == null || isPrefSaved==null){
      return LoginScreen();
    }
    return HomeScreen();
  }
}