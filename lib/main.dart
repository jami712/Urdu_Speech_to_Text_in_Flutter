// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'اردو تقریر سے متن',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const SpeechToTextScreen(),
    );
  }
}

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _transcription = 'بولنے کے لیے مائیک پر ٹیپ کریں...';


  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('Status: $val');
          if (val == "done" || val == "notListening") {
            // Seamlessly restart listening if user hasn't pressed stop
            if (_isListening) {
              print("Restarting listening...");
              _speech.listen(
                onResult: (val) {
                  setState(() {
                    _transcription = val.recognizedWords;
                  });
                },
                localeId: 'ur-PK',
                listenMode: stt.ListenMode.dictation,
                partialResults: true,
                cancelOnError: false,
                listenFor: const Duration(minutes: 5), // 5 min max per session
                pauseFor: const Duration(seconds: 30),
              );
            }
          }
        },
        onError: (val) {
          print('Error: $val');
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _transcription = val.recognizedWords;
            });
          },
          localeId: 'ur-PK',
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
          listenFor: const Duration(minutes: 1), // Restart every 1 min
          pauseFor: const Duration(seconds: 30),
        );
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text('اردو تقریر سے متن'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                height: 300, // Fixed height for transcript box
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // shadow position
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _transcription,
                    style: const TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 24,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.right, // Urdu aligns right
                  ),
                ),
              )

            ),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _transcription));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Transcript copied!")),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text("Copy Transcript"),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: _listen,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.redAccent : Colors.teal,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isListening ? Colors.red.shade200 : Colors.teal.shade200,
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedOpacity(
              opacity: _isListening ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: const Text(
                'سن رہا ہے...',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
            const SizedBox(height: 10),

                const Row(

                  children: [
                    Padding(padding: EdgeInsets.symmetric(vertical: 60, horizontal: 0)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Developed by Mudassir Jamal',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

      ),
    );
  }
}
