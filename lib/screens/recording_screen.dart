import 'dart:math' show pi;
import 'dart:io' show File, Directory;
import 'dart:async' show StreamSubscription;

import 'package:flutter/material.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sentence_model.dart';
import '../models/translation_model.dart';
import '../l10n/strings.dart';
import '../config.dart';
import '../services/translation_service.dart';
import '../services/language_service.dart';

class RecordingScreen extends StatefulWidget {
  final Sentence phrase;

  RecordingScreen({Key key, @required this.phrase})
      : assert(phrase != null),
        super(key: key);

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  String _recorderTimer;
  bool _isRecording;
  double _recorderIconSize = 60.0;
  FlutterSound _flutterSound;
  StreamSubscription _recorderSubscription;
  String _author = dummyUserName;
  String _selectedTargetLang;
  String _sourceLanguage;


  Future<List<String>> _getLanguagesFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return [
      prefs.getString("sourceLanguage"),
      prefs.getString("targetLanguage")
    ];
  }

  Future<String> _getUserNameFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("username");
    return username;
  }

  void _startRecording() {
    if (_selectedTargetLang == null) {
      _askForTargetLanguage();
    } else {
      String fileId = widget.phrase.id;
      new File("$recordStorage/$fileId.$fileExtension")
          .create()
          .then((filePath) {
        _flutterSound.startRecorder(filePath.path).then((path) {
          setState(() {
            this._isRecording = true;
          });

          _recorderSubscription =
              _flutterSound.onRecorderStateChanged.listen((e) {
            if (e == null) {
              return;
            }
            DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                e.currentPosition.toInt());
            String txt = DateFormat('mm:ss:SS', 'en_US').format(date);

            setState(() {
              this._recorderTimer = txt.substring(0, 8);
            });
          });
        }).catchError((error) {
          print(error);
        });
      }); //File
    }
  }

  void _stopRecording() {
    _flutterSound.stopRecorder().then((value) {
      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }

      setState(() {
        this._isRecording = false;
      });
    }).catchError((error) {
      _showMessage(recorderCantStop);
    });
  }

  void _doneRecording() {
    final recordedFile = "${widget.phrase.id}.$fileExtension";

    Translation translation = Translation(
        // TODO Change Dummy values with values picked from settings
        // TODO Implement Settings / Preferences Screen
        author: _author,
        targetLanguage: _selectedTargetLang,
        sentenceId: widget.phrase.id,
        audioFileName: recordedFile);

    readFileContentAndUploadTranslation(translation);

    _navigateToListTranslation();
  }

  void _cancelRecording() {
    String fileId = widget.phrase.id;
    final recordedFile = File("$recordStorage/$fileId.$fileExtension");

    recordedFile.delete().then((result) {
      setState(() {
        _recorderTimer = "00:00:00";
        _isRecording = false;
      });

      _showMessage(deletionSuccess);
    }).catchError((err) {
      _showMessage(deletionError);
    });
  }

  void _showMessage(String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future<void> _requestDeletionConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(deletionAlert),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(deletionConfirmation)],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(cancelBtn),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(deleteBtn),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelRecording();
              },
            ),
          ],
        );
      },
    );
  }

  void _askForTargetLanguage() {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              titleTextStyle: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
              title: Text(askLanguageAlert),
              content: Text(askLanguageAlertContent),
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

  void _navigateToListTranslation() {
    // TODO : implement Navigation Route to Translation Screen
  }

  Widget _languageWidget(String source) {
    return Container(
        padding: EdgeInsets.all(padding),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1.0, color: Color(0xFFB2B7B6)),
          ),
        ),
        child: Row(children: [
          Text(
            _sourceLanguage,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
          Expanded(child: Icon(Icons.compare_arrows)),
          DropdownButtonHideUnderline(child: _dropDownButton())
        ]));
  }

  Widget _dropDownButton() {
    return FutureBuilder(
        future: fetchLanguages("type=local"),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData)
            return Text(defaultTargetLang);
          else {
            List<DropdownMenuItem> languageItems = new List();
            snapshot.data.forEach((lang) {
              languageItems.add(DropdownMenuItem<String>(
                value: lang.name,
                child: Text(lang.name),
              ));
            });
            return DropdownButton(
              items: languageItems,
              value: _selectedTargetLang,
              hint: Text("Translate to",
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onChanged: (value) {
                setState(() {
                  _selectedTargetLang = value;
                });
              },
            );
          }
        });
  }

  Widget _sentenceWidget(String text) {
    return Padding(
        padding: EdgeInsets.all(padding),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 20.0,
              color: Theme.of(context).accentColor,
              letterSpacing: 0.75,
              fontWeight: FontWeight.bold),
        ));
  }

  Widget _recorderWidget() {
    Widget stopIcon = Icon(Icons.stop,
        size: _recorderIconSize, color: Theme.of(context).accentColor);
    Widget micIcon = Icon(Icons.mic,
        size: _recorderIconSize, color: Theme.of(context).accentColor);

    Widget recorder = GestureDetector(
        onTap: () {
          (_isRecording) ? _stopRecording() : _startRecording();
        },
        child: Container(
            child: _isRecording ? stopIcon : micIcon,
            padding: new EdgeInsets.all(10.0),
            decoration: new BoxDecoration(
                border: new Border.all(
                    color: Theme.of(context).primaryColorDark, width: 1.0),
                borderRadius: new BorderRadius.circular(80.0),
                color: Theme.of(context).primaryColorLight,
                boxShadow: [
                  new BoxShadow(
                      color: Theme.of(context).primaryColorDark,
                      blurRadius: 8.0)
                ])));

    return recorder;
  }

  Widget _controlsWidget() {
    return Container(
        padding: EdgeInsets.all(padding),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
              icon: Icon(Icons.delete),
              iconSize: _recorderIconSize / 2,
              color: Theme.of(context).primaryColorDark,
              onPressed: () {
                _requestDeletionConfirmation();
              }),
          _recorderWidget(),
          IconButton(
              icon: Icon(Icons.done_all),
              iconSize: _recorderIconSize / 2,
              color: Theme.of(context).primaryColorDark,
              onPressed: () {
                _doneRecording();
              })
        ]));
  }

  Widget _voiceWaveWidget() {
    final List<Color> waveColors = [
      Colors.teal[400],
      Colors.teal[300],
      Colors.teal[200],
      Colors.teal[100],
    ];
    final List<int> durations = [35000, 19440, 10800, 6000];
    final List<double> waveHeight = [0.20, 0.23, 0.25, 0.30];
    Widget wave = WaveWidget(
      config: CustomConfig(
        colors: waveColors,
        durations: durations,
        heightPercentages: waveHeight,
        blur: MaskFilter.blur(BlurStyle.inner, 10.0),
      ),
      waveAmplitude: 0,
      backgroundColor: Colors.transparent,
      size: Size(double.infinity, 30.0),
    );

    return Column(children: [wave, Transform.rotate(angle: pi, child: wave)]);
  }

  Widget _timerWidget() {
    return Text("$_recorderTimer", style: TextStyle(fontSize: 30.0));
  }

  @override
  void initState() {
    super.initState();
    _recorderTimer = "00:00:00";
    _isRecording = false;
    _flutterSound = new FlutterSound();

    // Create App Recording Folder
    new Directory(recordStorage).create();

    _getUserNameFromPreferences().then((name) {
      setState(() {
        this._author = name;
      });
    });

    _getLanguagesFromPreferences().then((languages){

      setState(() {
        this._sourceLanguage = languages[0];
        this._selectedTargetLang = languages[1]; //set as default target language
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      _languageWidget(widget.phrase.language.name),
      Expanded(flex: 2, child: _sentenceWidget(widget.phrase.text)),
      Expanded(child: _voiceWaveWidget()),
      _timerWidget(),
      _controlsWidget()
    ]));
  }
}
