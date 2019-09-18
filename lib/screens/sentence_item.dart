import "package:flutter/material.dart";

import "../models/sentence_model.dart";
import "recording_screen.dart";

class SentenceItem extends StatelessWidget {
  final Sentence phrase;
  final int index;

  SentenceItem({Key key, this.phrase, this.index});

  Color _tileBackgroundColor(BuildContext context) {
    if (index % 2 == 0) return Theme.of(context).primaryColorLight;
    return Color.fromRGBO(1, 1, 1, 0.0);
  }

  void _navigateToRecorder(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    Navigator.push(context,
        MaterialPageRoute<void>(builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                  elevation: 1.0,
                  title: Text("Recorder")),
              body: RecordingScreen(phrase:phrase),
              resizeToAvoidBottomPadding: false);
        }));

  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: _tileBackgroundColor(context),
        child: ListTile(
          title: Text(phrase.text),
          subtitle: Text(phrase.language.code),
          trailing: Icon(Icons.translate),
          onTap: () => _navigateToRecorder(context),
        ));
  }
}
