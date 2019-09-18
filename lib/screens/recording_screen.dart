import 'dart:math' show pi;
import 'dart:io' show File, Directory;
import 'dart:async' show StreamSubscription;

import 'package:flutter/material.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_sound/flutter_sound.dart';

import '../models/sentence_model.dart';

class RecordingScreen extends StatefulWidget {
  final Sentence phrase;
  final String targetLang = "Yemba";

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
  String _recordStorage = "/sdcard/Lingua";
  StreamSubscription _recorderSubscription;

  void _startRecording() {
    String fileId = widget.phrase.id;
    new File("$_recordStorage/$fileId.m4a").create().then((filePath) {

      _flutterSound.startRecorder(filePath.path).then((path) {

        setState(() {
          this._isRecording = true;
        });

        print('startRecorder, file is: $path');

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

  void _stopRecording() {
    _flutterSound.stopRecorder().then((value) {
      print('stopRecorder: $value');
      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }

      setState(() {
        this._isRecording = false;
      });
    }).catchError((error) {
      print("Was not able to stop recorder: $error");
    });

    // TODO: Upload the audioFile to server
  }

  void _cancelRecording() {
    // TODO : add a Confirmation Dialog Box before deletion
    String fileId = widget.phrase.id;
    final recordedFile = File("$_recordStorage/$fileId.m4a");
    //recordedFile.deleteSync();
  }

  void _navigateToListTranslation() {
    // TODO : implement Navigation Route to Translation Screen
    print("Recording is Done, Navigating to next page");
  }

  Widget _languageWidget(String source, String target) {
    return Container(
        padding: EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1.0, color: Color(0xFFB2B7B6)),
          ),
        ),
        child: Row(children: [
          Text(
            source,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Icon(Icons.compare_arrows)),
          Text(target, style: TextStyle(fontWeight: FontWeight.bold))
        ]));
  }

  Widget _sentenceWidget(String text) {
    return Padding(
        padding: EdgeInsets.all(16.0),
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
        padding: EdgeInsets.all(16.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
              icon: Icon(Icons.cancel),
              iconSize: _recorderIconSize / 2,
              color: Theme.of(context).primaryColorDark,
              onPressed: () {
                _cancelRecording();
              }),
          _recorderWidget(),
          IconButton(
              icon: Icon(Icons.done_all),
              iconSize: _recorderIconSize / 2,
              color: Theme.of(context).primaryColorDark,
              onPressed: () {
                _navigateToListTranslation();
              })
        ]));
  }

  Widget _voiceWaveWidget() {
    Widget wave = WaveWidget(
      config: CustomConfig(
        colors: [
          Colors.teal[400],
          Colors.teal[300],
          Colors.teal[200],
          Colors.teal[100],
        ],
        durations: [35000, 19440, 10800, 6000],
        heightPercentages: [0.20, 0.23, 0.25, 0.30],
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
    new Directory(_recordStorage).create().then((Directory directory) {
      print(directory.path);
    }).catchError((err) {
      print(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      _languageWidget(widget.phrase.language.name, widget.targetLang),
      Expanded(flex: 2, child: _sentenceWidget(widget.phrase.text)),
      Expanded(child: _voiceWaveWidget()),
      _timerWidget(),
      _controlsWidget()
    ]));
  }


}
