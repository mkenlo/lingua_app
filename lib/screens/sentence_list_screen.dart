import "package:flutter/material.dart";
import "../services/sentence_service.dart";
import "../models/sentence_model.dart";
import "package:lingua_app/screens/sentence_item.dart";

class SentenceListScreen extends StatefulWidget {
  @override
  _SentenceListScreenState createState() => _SentenceListScreenState();
}

class _SentenceListScreenState extends State<SentenceListScreen> {

  Future<List<Sentence>> sentences;

  Widget _errorWidget(String message){
    return Center(
      child: Column(
        children: <Widget>[
          Icon(Icons.block, size: 64.0),
          Text("$message", style: TextStyle(color: Colors.red[400]))
        ],
      )
    );
  }

  Widget _loadSentencesWidget() {
    return FutureBuilder(
        future: fetchSentences(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none) {
            return _errorWidget("No connection to API");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return _errorWidget(snapshot.error.toString());
            }
            if (!snapshot.hasData) return Text("The API returned no DATA");
            return _buildListWidget(snapshot.data);
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Widget _buildListWidget(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          Sentence item = data[index];
          return SentenceItem(item, index+1);
        });
  }

  @override
  void initState() {
    super.initState();
    sentences = fetchSentences();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          "Sentences",
          style: TextStyle(fontSize: 30.0, color: Colors.black),
        ));

    return Scaffold(
      appBar: appBar,
      body: _loadSentencesWidget(),
    );
  }
}
