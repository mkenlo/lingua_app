import 'package:flutter/material.dart';

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

  void _startRecording() {

  }

  void _stopRecording() {

  }

  void _cancelRecording() {

  }

  void _navigateToListTranslation() {
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
              iconSize: _recorderIconSize/2,
              color: Theme.of(context).primaryColorDark,
              onPressed: () {
                _cancelRecording();
              }),
          _recorderWidget(),
          IconButton(
              icon: Icon(Icons.done_all),
              iconSize: _recorderIconSize/2,
              color: Theme.of(context).primaryColorDark,
              onPressed: () {
                _navigateToListTranslation();
              })
        ]));
  }

  Widget _voiceWaveWidget() {
    Widget wave = Text("wave voice here");

    return wave;
  }

  Widget _timerWidget() {
    return Text("$_recorderTimer", style: TextStyle(fontSize: 30.0));
  }

  @override
  void initState() {
    super.initState();
    _recorderTimer = "00:00:00";
    _isRecording = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
          _languageWidget(widget.phrase.language.name, widget.targetLang),
          Expanded(flex: 2, child: _sentenceWidget(widget.phrase.text)),
          Expanded(child: _voiceWaveWidget()),
          _timerWidget(),
          _controlsWidget()]));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
