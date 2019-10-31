import 'dart:async';
import "package:flutter/material.dart";

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import '../models/user_model.dart';
import '../services/language_service.dart';
import '../config.dart';
import 'error_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  String preferredSourceLanguage = "";
  String preferredTargetLanguage = "";

  @override
  void initState() {
    _getPreferredLanguage().then((values) {
      setState(() {
        preferredSourceLanguage = values[0] ?? defaultSourceLang;
        preferredTargetLanguage = values[1] ?? "";
      });
    });
    super.initState();
  }

  Future<User> _getProfileInfoFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return User(
        username: prefs.getString("username"),
        firstName: prefs.getString("firstName"),
        lastName: prefs.getString("lastName"),
        location: prefs.getString("location"),
        avatar: prefs.getString("avatar"));
  }

  Future<List> _getPreferredLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return [
      prefs.getString("sourceLanguage"),
      prefs.getString("targetLanguage")
    ];
  }

  void _setPreferredSourceLang(String preferredLang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("sourceLanguage", preferredLang);

    setState(() {
      preferredSourceLanguage = preferredLang;
    });
  }

  void _setPreferredTargetLang(String preferredLang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("targetLanguage", preferredLang);

    setState(() {
      preferredTargetLanguage = preferredLang;
    });
  }

  void _doLogout() async {
    final FacebookLogin facebookSignIn = new FacebookLogin();
    if (await facebookSignIn.isLoggedIn) {
      await facebookSignIn.logOut();

      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _changeSourceLanguage() {
    Widget languages = FutureBuilder(
      future: fetchLanguages("type=foreign"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          return ErrorScreen(errorType.noConnection);
        }
        if (snapshot.hasError) {
          return ErrorScreen(errorType.exception);
        }
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () {
                      _setPreferredSourceLang(snapshot.data[index].name);
                      Navigator.pop(context);
                    },
                    highlightColor: Theme.of(context).primaryColorLight,
                    child: ListTile(
                      title: Text(snapshot.data[index].name),
                      subtitle: Text(snapshot.data[index].code),
                    ));
              });
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );

    showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Change Language"), content: languages);
        });
  }

  void _changeTargetLanguage() {
    Widget languages = FutureBuilder(
      future: fetchLanguages("type=local"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          return ErrorScreen(errorType.noConnection);
        }
        if (snapshot.hasError) {
          return ErrorScreen(errorType.exception);
        }
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () {
                      _setPreferredTargetLang(snapshot.data[index].name);
                      Navigator.pop(context);
                    },
                    highlightColor: Theme.of(context).primaryColorLight,
                    child: ListTile(
                      title: Text(snapshot.data[index].name),
                      subtitle: Text(snapshot.data[index].code),
                    ));
              });
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );

    showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Change Language"), content: languages);
        });
  }

  _buildPreferencesContent(User profile) {
    final Widget profilePic = ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: Image.network(
          profile.avatar,
          width: 100.0,
          height: 100.0,
        ));

    final Widget name = ListTile(
        title: Text("${profile.fullName()}",
            style: Theme.of(context).textTheme.headline),
        subtitle: Text(profile.username));

    final Widget location = ListTile(
        leading:
            Icon(Icons.location_on, color: Theme.of(context).primaryColorDark),
        title: Text("${profile.location}" ?? "Unknown"));

    final sourceLang = ListTile(
      leading: Icon(Icons.language, color: Theme.of(context).primaryColorDark),
      title: Text("Source Language"),
      subtitle: Text(preferredSourceLanguage),
      onTap: () {
        _changeSourceLanguage();
      },
    );

    final targetLang = ListTile(
      leading: Icon(Icons.translate, color: Theme.of(context).primaryColorDark),
      title: Text("Target Language"),
      subtitle: Text(preferredTargetLanguage),
      onTap: () {
        _changeTargetLanguage();
      },
    );

    final loginStatus = ListTile(
      leading:
          Icon(Icons.exit_to_app, color: Theme.of(context).primaryColorDark),
      title: Text("Logout",
          style: TextStyle(color: Theme.of(context).primaryColorDark)),
      onTap: () {
        _doLogout();
      },
    );

    return Container(
        child: ListView(children: [
      profilePic,
      name,
      location,
      sourceLang,
      targetLang,
      loginStatus
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder<User>(
      future: _getProfileInfoFromPreferences(),
      builder: (BuildContext context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return ErrorScreen(errorType.noConnection);
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            return _buildPreferencesContent(snapshot.data);
        }
        return null; // unreachable
      },
    );

    return content;
  }
}
