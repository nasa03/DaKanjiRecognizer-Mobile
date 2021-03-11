import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent/android_intent.dart';

import 'package:da_kanji_recognizer_mobile/globals.dart';

class PredictionButton extends StatelessWidget {
  String char;

  PredictionButton(String char) {
    this.char = char;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: MaterialButton(
        color: Colors.white.withAlpha(50),
        padding: EdgeInsets.all(0),
        // copy the character to clipboard on single press
        onPressed: () {
          if (this.char != " ")
            Clipboard.setData(new ClipboardData(text: this.char));
        },
        // open prediction in the dictionary set in setting on long press
        onLongPress: () async {
          // only open a page when there is a prediction
          if (this.char != " ") {
            // the prediction should be translated with system dialogue
            if(SETTINGS.openWithDefaultTranslator){ 
              if(Platform.isAndroid){
                AndroidIntent intent = AndroidIntent(
                  action: 'android.intent.action.TRANSLATE',
                  arguments: <String, dynamic>{
                    "android.intent.extra.TEXT" : this.char
                  }
                );
                if(await intent.canResolveActivity())
                  await intent.launch();
                else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context){ 
                      return SimpleDialog(
                        title: Center(child: Text("No translator installed")),
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                MaterialButton(
                                  color: Colors.white.withAlpha(50),
                                  onPressed: () async {
                                    // try to open google translate in the playstore
                                    if (await canLaunch(PLAYSTORE_BASE_INTENT + GOOGLE_TRANSLATE_ID)){
                                      await launch(PLAYSTORE_BASE_INTENT + GOOGLE_TRANSLATE_ID);
                                    }
                                    else{
                                      await launch(PLAYSTORE_BASE_URL + GOOGLE_TRANSLATE_ID,
                                        forceWebView: true,
                                        enableJavaScript: true);
                                    }
                                  },
                                  child: Text("Download Google Translate")
                                ) 
                              ]
                            )
                          )
                        ],
                      );
                    }
                  );
                }
              }
              else if(Platform.isIOS && false){
                print("iOS is not implemented for choosing translator");
              }
            }
            else{
              launch(SETTINGS.openWithSelectedDictionary(this.char));
            }
          }
        },
        child: FittedBox(
          child: Text(
            this.char,
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 1000.0),
          )
        )
      )
    );
  }
}
