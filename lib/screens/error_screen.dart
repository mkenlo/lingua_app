import "package:flutter/material.dart";


enum errorType { noConnection, exception, noData}

String errorTypeToMessage(errorType err){
  switch (err) {
    case errorType.noConnection:
      return "Please check your internet connection and try again";
      break;
    case errorType.noData:
      return "No data available";
      break;
    default: // Without this, you see a WARNING.
      return "Application Internal Error"; //
  }
}


class ErrorScreen extends StatelessWidget {
  final errorType _message;



  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        padding: EdgeInsets.all(16.0),
        child:
            Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Expanded(
                        child: Icon(Icons.cloud_off,
                            size: 128.0, color: Theme.of(context).accentColor)),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                        child:Text("Whoops",
                            style: Theme.of(context).textTheme.display1,
                            textAlign: TextAlign.center)),
                    Expanded(
                        child: Column(
                          children: <Widget>[
                            Text(
                              errorTypeToMessage(_message),
                              style: TextStyle(color: Theme
                                  .of(context)
                                  .hintColor),
                              textAlign: TextAlign.center,
                            ),
                            FlatButton(
                                child: Text("Retry"),
                              onPressed: (){print("retrying...");},
                            )
                          ],
                        ))
        ]));
  }

  ErrorScreen(this._message);
}
