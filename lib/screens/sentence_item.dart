import "package:flutter/material.dart";

import "../models/sentence_model.dart";

class SentenceItem extends StatelessWidget {
  final Sentence _phrase;
  final int _index;

  SentenceItem(this._phrase, this._index);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Padding(
            child: Text("$_index",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor)),
            padding: EdgeInsets.symmetric(horizontal: 8.0)),
        Expanded(child: Text(_phrase.text)),
        Text(_phrase.language.code)
      ]),
    );
  }
}
