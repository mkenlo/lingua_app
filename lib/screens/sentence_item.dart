import "package:flutter/material.dart";

import "../models/sentence_model.dart";

class SentenceItem extends StatelessWidget {
  final Sentence _phrase;
  final int _index;

  SentenceItem(this._phrase, this._index);

  Color _tileBackgroundColor(BuildContext context) {
    if (_index % 2 == 0) return Theme.of(context).primaryColorLight;
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
              title: Text("Recording")),
          body: Text("...loading Recording page..."),
          resizeToAvoidBottomPadding: false);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: _tileBackgroundColor(context),
        child: ListTile(
          title: Text(_phrase.text),
          subtitle: Text(_phrase.language.code),
          trailing: Icon(Icons.translate),
          onTap: () => _navigateToRecorder(context),
        ));
  }
}
