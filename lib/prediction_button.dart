import 'package:flutter/material.dart';

class PredictionButton extends StatelessWidget {
  String char;

  PredictionButton(String char) {
    this.char = char;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: AspectRatio(
            aspectRatio: 1,
            child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(0),
                child: RaisedButton(
                    color: Colors.white.withAlpha(50),
                    padding: EdgeInsets.all(0),
                    onPressed: () {},
                    child: FittedBox(
                        child: Text(
                      this.char,
                      textAlign: TextAlign.center,
                      style: new TextStyle(fontSize: 1000.0),
                    ))))));
  }
}
