import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/language_service.dart';
import '../models/language_model.dart';
import 'error_screen.dart';
import 'sentence_list_screen.dart';

class PreferenceScreen extends StatefulWidget {
  @override
  State createState() => PreferenceScreenState();
}

class PreferenceScreenState extends State<PreferenceScreen> {
  String _preferredSourceLang;
  String _preferredTargetLang;

  @override
  void initState() {
    super.initState();
  }

  Widget _loadDropDownItems(List<Language> data, String languageType) {
    String hint =
        (languageType == "source") ? "Source Language" : "Target Language";

    return DropdownButtonFormField(
      decoration: InputDecoration(
        focusColor: Colors.amber,
        labelText: hint,
        border: OutlineInputBorder(
            borderSide:
                BorderSide(style: BorderStyle.solid, color: Colors.white)),
      ),
      value: (languageType == "source")
          ? _preferredSourceLang
          : _preferredTargetLang,
      onChanged: (selected) {
        setState(() {
          if (languageType == "target") {
            _preferredTargetLang = selected;
          } else if (languageType == "source") {
            _preferredSourceLang = selected;
          }
        });
      },
      items: data.map<DropdownMenuItem>((lang) {
        return DropdownMenuItem<String>(
          value: lang.name,
          child: Text(lang.name),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageDropDown(String languageType) {
    String queryFilter =
        (languageType == "source") ? "type=foreign" : "type=local";

    return FutureBuilder(
        future: fetchLanguages(queryFilter),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return ErrorScreen(errorType.noConnection);
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) return ErrorScreen(errorType.exception);

              return _loadDropDownItems(snapshot.data, languageType);
          }
          return null;
        });
  }

  void _navigateToRecordingPage() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    Navigator.push(
        context,
        CupertinoPageRoute<void>(
            builder: (BuildContext context) => SentenceListScreen()));
  }

  Future<bool> _setLanguagesPreferences() async {
    if (_preferredTargetLang == null || _preferredSourceLang == null) {
      _askForPreferences();
      return false;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('sourceLanguage', _preferredSourceLang);
      await prefs.setString('targetLanguage', _preferredTargetLang);
      return true;
    }
  }

  void _askForPreferences() {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              titleTextStyle: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
              title: Text("Preferences"),
              content: Text("Please select your languages"),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    final doneButton = Container(
        margin: EdgeInsets.fromLTRB(0.0, 32.0, 0.0, 0.0),
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: FlatButton(
            onPressed: () {
              _setLanguagesPreferences().then((isLanguageSaved){
                if(isLanguageSaved) _navigateToRecordingPage();
              });
            },
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.done_all, color: Theme.of(context).primaryColorDark),
              Padding(
                  padding: const EdgeInsets.only(left: 14.0, right: 10.0),
                  child: Text("You're all set",
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0))),
            ])));

    return Scaffold(
        body: Container(
            constraints: BoxConstraints.expand(),
            padding: EdgeInsets.fromLTRB(16.0, 150.0, 16.0, 32),
            color: Theme.of(context).primaryColorDark,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text("One last thing,",
                      style: TextStyle(color: Colors.white)),
                  Padding(
                      child: Text("Set your preferences",
                          style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                      padding: EdgeInsets.symmetric(vertical: 48.0)),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: _buildLanguageDropDown("source"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: _buildLanguageDropDown("target"),
                  ),
                  doneButton
                ])));
  }
}
