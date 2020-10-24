import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "fa_IR";

//  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  Future language() async {
    speech.listen(
      onResult: resultListener,
      localeId: ("fa"),
    );
  }

  @override
  void initState() {
    initSpeechState();
    super.initState();
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
//      _localeNames = await speech.locales();

//      var systemLocale = await speech.systemLocale();
      _currentLocaleId = "fa_IR";
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(children: [
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      FlatButton(
//                        child: Text('Initialize'),
//                        onPressed: _hasSpeech ? null : initSpeechState,
//                      ),
//                    ],
//                  ),

//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceAround,
//                    children: <Widget>[
//                      DropdownButton(
//                        onChanged: (selectedVal) => _switchLang(selectedVal),
//                        value: _currentLocaleId,
//                        items: _localeNames
//                            .map(
//                              (localeName) => DropdownMenuItem(
//                                value: localeName.localeId,
//                                child: Text(localeName.name),
//                              ),
//
//                            )
//                            .toList(),
//
//                      ),
//                    ],
//                  )
          SizedBox(height: 10.0,),
            Expanded(
              flex: 4,
              child: Column(
                children: <Widget>[
                  Center(
                    child: Text(
                      'Words',
                      style: TextStyle(fontSize: 22.0),
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          color: Theme.of(context).selectedRowColor,
                          child: Center(
                            child: Text(
                              lastWords,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                onTap: !_hasSpeech || speech.isListening
                                    ? null
                                    : startListening,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: .26,
                                          spreadRadius: level * 1.5,
                                          color:
                                              Colors.black.withOpacity(.05))
                                    ],
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  ),
                                  child: Icon(Icons.mic),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: .26,
                                        spreadRadius: level * 1.5,
                                        color: Colors.black.withOpacity(.05))
                                  ],
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.stop),
                                  onPressed:
                                      speech.isListening ? stopListening : null,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: .26,
                                        spreadRadius: level * 1.5,
                                        color: Colors.black.withOpacity(.05))
                                  ],
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.cancel),
                                  onPressed: speech.isListening
                                      ? cancelListening
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
//            Expanded(
//              flex: 1,
//              child: Column(
//                children: <Widget>[
//                  Center(
//                    child: Text(
//                      'Error Status',
//                      style: TextStyle(fontSize: 22.0),
//                    ),
//                  ),
//                  Center(
//                    child: Text(lastError),
//                  ),
//                ],
//              ),
//            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              color: Theme.of(context).backgroundColor,
              child: Center(
                child: speech.isListening
                    ? Text(
                        "I'm listening...",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    : Text(
                        'Not listening',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 10),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = "${result.recognizedWords} ";
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = "$status";
    });
  }

//  _switchLang(selectedVal) {
//    setState(() {
//      _currentLocaleId = selectedVal;
//    });
//    print(selectedVal);
//  }
}
