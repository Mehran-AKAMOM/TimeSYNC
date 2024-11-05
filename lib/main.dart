import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeSync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Time Sync Home Page'),
    );
  }
}

final platform = MethodChannel('com.example.timesync/timezones');

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentTime = 'Loading...';
  late Timer _timer;
  final GameState gameState = GameState(); // Add GameState instance

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      await Permission.camera.request();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _updateTime() async {
    try {
      final String time = await getCurrentTime('Africa/Nairobi');
      setState(() {
        _currentTime = time;
      });
    } catch (e) {
      setState(() {
        _currentTime = 'Error: ${e.toString()}';
      });
    }
  }

  Future<String> getCurrentTime(String timezone) async {
    final response = await http.get(Uri.parse(
        'https://timeapi.io/api/Time/current/zone?timeZone=$timezone'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return '${data['hour']}:${data['minute']}:${data['seconds']}';
    } else {
      throw Exception('Failed to load time');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Welcome To Time Sync',
            ),
            Text(
              'Current time in Nairobi: $_currentTime',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineMedium,
            ),
            // Unscramble Game UI
            Text('Unscramble the word:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              gameState.shuffledWord,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (text) {
                setState(() {
                  gameState.userInput = text;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (gameState.checkAnswer()) {
                  // Correct answer
                  showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          title: Text('Correct!'),
                          content: Text('You unscrambled the word!'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  gameState.resetGame();
                                });
                              },
                              child: Text('Next Word'),
                            ),
                          ],
                        ),
                  );
                } else {
                  // Incorrect answer
                  // ... (same as before)
                }
              },
              child: Text('Check Answer'),
            ),
          ],
        ),
      ),
    );
  }
}

// GameState class (same as before)
class GameState {
  // ... (same as before)
}

// shuffleWord function (same as before)
String shuffleWord(String word) {
  // ... (same as before)
}

// Word list (same as before)
final List<String> words = [
  // ... (same as before)
];