import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:ibm_watson_assistant/ibm_watson_assistant.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(MyApp());
}

final auth = IbmWatsonAssistantAuth(
  assistantId: '201d7dac-f645-4d42-97cc-a6b7e08c356c',
  url:
      'https://api.au-syd.assistant.watson.cloud.ibm.com/instances/e14303bf-f491-4348-9611-befd8647f383',
  apikey: 'kD2OJWHJyhPnMR_PPjzf4A45uFooQkh7o6hr8udMu0Nq',
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';

  // text to speech parameters
  late FlutterTts flutterTts;
  String language = 'en-US';
  String engine = '';
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    flutterTts = FlutterTts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("ChatBot"),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          animate: _isListening,
          glowColor: Theme.of(context).primaryColor,
          endRadius: 75.0,
          duration: const Duration(milliseconds: 2000),
          repeatPauseDuration: const Duration(milliseconds: 100),
          repeat: true,
          child: FloatingActionButton(
            onPressed: _listen,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
        ),
        body: Column(
          children: [
            SingleChildScrollView(
              reverse: true,
              child: Container(
                padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 75.0),
                child: Text(
                  _text,
                  style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[400]),
                ),
              ),
            ),
            Container(
              child: Image(image: AssetImage('images/robot.png'),),
            ),
          ],
        ));
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            print(val.recognizedWords);
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      ibm(_text);
    }
  }

  Future ibm(String s) async {
    final bot = IbmWatsonAssistant(auth);
    final sessionId = await bot.createSession();
    print(sessionId);

    final botRes = await bot.sendInput(s, sessionId: sessionId);
    print(botRes.responseText);
    tts(botRes.responseText.toString());
  }

  void tts(String s) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    await flutterTts.setLanguage(language);
    await flutterTts.speak(s);
  }
}
