import "package:flutter/material.dart";

import 'package:shared_preferences/shared_preferences.dart';
import "../services/sentence_service.dart";
import "../models/sentence_model.dart";
import "sentence_item.dart";
import 'error_screen.dart';

class SentenceListScreen extends StatefulWidget {
  @override
  _SentenceListScreenState createState() => _SentenceListScreenState();
}

class _SentenceListScreenState extends State<SentenceListScreen> {

  Future<List<Sentence>> sentences;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();

  Future<String> _getLanguagesFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("sourceLanguage");

  }

  Future<void> _refreshList() async {

    _getLanguagesFromPreferences().then((sourceLanguage){
      setState(() {
        sentences = fetchSentences("language=$sourceLanguage");
      });
    });

  }

  Widget _loadSentencesWidget() {
    return FutureBuilder(
        future: sentences,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.none) {
            if (!snapshot.hasData) return ErrorScreen(errorType.noData);
            return ErrorScreen(errorType.noConnection);
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return ErrorScreen(errorType.exception);
            }
            if (!snapshot.hasData) return ErrorScreen(errorType.noData);
            return _buildListWidget(snapshot.data);
          } else {
            return Center(
              child: CircularProgressIndicator()
            );
          }
        });
  }

  Widget _buildListWidget(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          Sentence item = data[index];
          return SentenceItem(phrase: item, index: index+1);
        });
  }

  @override
  void initState() {
    super.initState();

    _getLanguagesFromPreferences().then((sourceLanguage){
      sentences = fetchSentences("language=$sourceLanguage");
    });

  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: Text("Sentences"),
        );

    return Scaffold(
      appBar: appBar,
      body: RefreshIndicator(
          child: _loadSentencesWidget(),
          key: _refreshIndicatorKey,
          onRefresh: ()=>_refreshList()),
    );
  }
}
