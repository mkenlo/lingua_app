import 'dart:io' show File, Directory;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flushbar/flushbar.dart';

import '../models/sentence_model.dart';
import '../models/translation_model.dart';
import '../l10n/strings.dart';
import '../config.dart';
import '../services/translation_service.dart';
import '../services/sentence_service.dart';
import 'error_screen.dart';
import '../services/permission_service.dart';

class TranslationScreen extends StatefulWidget {
  @override
  State createState() {
    return TranslationScreenState();
  }
}

class TranslationScreenState extends State<TranslationScreen> {
  List<Sentence> _sentences;

  String _recorderTimer;
  bool _isRecording;
  double _recorderIconSize = 60.0;
  FlutterSound _flutterSound;
  StreamSubscription _recorderSubscription;
  String _author = dummyUserName;
  String _targetLang;
  String _sourceLanguage;

  Sentence _currentSentence;
  int _progression = 0;
  PageController _pageController;

  final Map<String, Color> _isRecordingColor = {
    "accent": Colors.red[600],
    "primaryLight": Colors.red[100],
    "primaryDark": Colors.red[800]
  };

  final AsyncMemoizer _caching = AsyncMemoizer();

  PermissionService _permissionService;
  bool _hasPermissions = false;

  _fetchAndCacheData() {
    // TODO  Deal with the issue that it will make it impossible to load more data from the server if pagination
    return _caching.runOnce(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return fetchSentences("language=${prefs.getString("sourceLanguage")}");
    });
  }

  Future<List> _getUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return [
      prefs.getString("username"),
      prefs.getString("sourceLanguage"),
      prefs.getString("targetLanguage")
    ];
  }

  void _startRecording() {
    if (_currentSentence == null) {
      _currentSentence = _sentences.first;
    }
    String filePath = "$appDirectory/${_currentSentence.id}.$fileExtension";
    _flutterSound.startRecorder(filePath).then((path) {
      setState(() {
        this._isRecording = true;
      });
      print(path);
      _recorderSubscription = _flutterSound.onRecorderStateChanged.listen((e) {
        if (e == null) {
          return;
        }
        DateTime date =
            new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        String txt = DateFormat('mm:ss:SS', 'en_US').format(date);

        setState(() {
          this._recorderTimer = txt.substring(0, 8);
        });
      });
    }).catchError((error) {
      print(error);
    }); // startRecorder
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

    _askToSaveRecording();
  }

  void _doneRecording() {
    final recordedFile = "${_currentSentence.id}.$fileExtension";

    Translation translation = Translation(
        author: _author,
        targetLanguage: _targetLang,
        sentence: _currentSentence.id,
        audioFileName: recordedFile);

    readFileContentAndUploadTranslation(translation);

    _navigateToNextSentencePage();
  }

  void _cancelRecording({BuildContext context}) {
    String fileId = _currentSentence.id;
    final recordedFile = File("$recordStorage/$fileId.$fileExtension");

    recordedFile.delete().then((result) {
      setState(() {
        _recorderTimer = "";
        _isRecording = false;
      });

      _showMessage(deletionSuccess, context: context);
    }).catchError((err) {
      _showMessage(deletionError, context: context);
    });
  }

  void _showMessage(String msg, {BuildContext context}) {
    Flushbar(
        message: msg,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        flushbarStyle: FlushbarStyle.FLOATING,
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Theme.of(context).primaryColorDark,
        ),
        leftBarIndicatorColor: Theme.of(context).primaryColorDark)
      ..show(context);
  }

  void _askToSaveRecording() {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              titleTextStyle: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
              title: Text("Save Recording"),
              content: Text("Are you satisfied with your recording?"),
              actions: <Widget>[
                FlatButton(
                  color: _isRecordingColor["primaryDark"],
                  textColor: Colors.white,
                  child: Text('No'),
                  onPressed: () {
                    _cancelRecording(context: context);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  color: Theme.of(context).primaryColorDark,
                  textColor: Colors.white,
                  child: Text('Yes'),
                  onPressed: () {
                    _doneRecording();
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        });
  }

  void _navigateToNextSentencePage() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        _progression > 0 ? _progression : 1,
        duration: const Duration(milliseconds: 800),
        curve: Curves.bounceInOut,
      );
    }
  }

  Widget _recorderWidget() {
    Widget stopIcon = Icon(Icons.stop,
        size: _recorderIconSize, color: _isRecordingColor["accent"]);
    Widget micIcon = Icon(Icons.mic,
        size: _recorderIconSize, color: Theme.of(context).accentColor);

    Color darkColor = Theme.of(context).primaryColorDark;
    Color lightColor = Theme.of(context).primaryColorLight;
    if (_isRecording) {
      darkColor = _isRecordingColor["primaryDark"];
      lightColor = _isRecordingColor["primaryLight"];
    }

    _permissionService
        .hasPermission(PermissionGroup.microphone)
        .then((granted) {
      setState(() {
        this._hasPermissions = granted;
      });
    });

    Widget recorder = GestureDetector(
        onTap: () {
          if (!_hasPermissions) {
            _permissionService.requestAppPermission();
          } else {
            (_isRecording) ? _stopRecording() : _startRecording();
          }
        },
        child: Container(
            child: _isRecording ? stopIcon : micIcon,
            padding: new EdgeInsets.all(10.0),
            decoration: new BoxDecoration(
                border: new Border.all(color: darkColor, width: 1.0),
                borderRadius: new BorderRadius.circular(80.0),
                color: lightColor,
                boxShadow: [
                  new BoxShadow(color: darkColor, blurRadius: 20.0)
                ])));

    return recorder;
  }

  Widget _controlsWidget() {
    final textStyle = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
        color: Theme.of(context).primaryColorDark);

    final controls = Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding:
            EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_sourceLanguage ?? "", style: textStyle),
          _recorderWidget(),
          Text(_targetLang ?? "", style: textStyle),
        ]));
    return Padding(padding: EdgeInsets.all(padding), child: controls);
  }

  Widget _timerWidget() {
    return Text("$_recorderTimer", style: TextStyle(fontSize: 30.0));
  }

  Widget _buildSentencePageWidget(data) {
    final itemList = PageView.builder(
      controller: _pageController,
      itemCount: data.length,
      itemBuilder: (context, index) {
        Sentence item = data[index];
        return _buildSentenceCard(item);
      },
      onPageChanged: (index) {
        setState(() {
          _currentSentence = data[index];
          _recorderTimer = "";
          _progression = index + 1;
        });
      },
    );

    return Container(child: itemList, padding: EdgeInsets.all(16.0));
  }

  Widget _buildSentenceCard(Sentence phrase) {
    return Card(
        elevation: 2.0,
        child: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(padding),
            child: Center(
                child: Text(
              phrase.text,
              style: TextStyle(
                  color: Theme.of(context).accentColor,
                  letterSpacing: 0.75,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ))));
  }

  Widget _loadSentencesWidget() {
    return FutureBuilder(
        future: _fetchAndCacheData(),
        builder: (context, snapshot) {
          // TODO : Deal with every type of error. eg Connection Error
          if (!snapshot.hasError && snapshot.hasData) {
            _sentences = snapshot.data;
            return _buildSentencePageWidget(_sentences);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _progressionBar() {
    int size = (_sentences != null) ? _sentences.length : 1;
    return LinearProgressIndicator(value: _progression / size);
  }

  @override
  void initState() {
    super.initState();
    _recorderTimer = "";
    _isRecording = false;
    _flutterSound = new FlutterSound();
    _pageController = PageController();

    // Create App Recording Folder
    if (_hasPermissions) {
      new Directory(recordStorage).create();
    }

    _getUserPreferences().then((prefs) {
      setState(() {
        this._author = prefs[0];
        this._sourceLanguage = prefs[1];
        this._targetLang = prefs[2];
      });
    });

    _permissionService = new PermissionService();


  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
        color: Color(0xFFF3F8F7),
        child: Column(children: [
          _progressionBar(),
          Expanded(child: _loadSentencesWidget()),
          _timerWidget(),
          _controlsWidget()
        ]));

    return content;
  }
}
