import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  static const platform=MethodChannel("samples.flutter.dev/battery");
   static const EventChannel eventChannel =
      EventChannel('samples.flutter.dev/charging');
  Timer? timer;
  String _batteryLevel = 'Unknown battery Level';
    String _chargingStatus = 'Battery status: unknown.';
    
  Future<void> _getBatteryLevel() async {
    String batteryLevel = "";
    try{
      final int result = await platform.invokeMethod("getBatteryLevel");
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch(e){
      if (e.code == 'NO_BATTERY') {
        batteryLevel = 'No battery.';
      } else {
        batteryLevel = "Failed to get battery Level: '${e.message}' ";
      }
     
    }
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }
  @override
void initState() {
  super.initState();
  eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  // timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getBatteryLevel());
}
void _onEvent(Object? event) {
    setState(() {
      _chargingStatus =
          "Battery status: ${event == 'charging' ? '' : 'dis'}charging.";
    });
  }

  void _onError(Object error) {
    setState(() {
      _chargingStatus = 'Battery status: unknown.';
    });
  }
@override
void dispose() {
  timer?.cancel();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_batteryLevel, key: const Key('Battery level label')),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _getBatteryLevel,
                  child: const Text('Refresh'),
                ),
              ),
            ],
          ),
          Text(_chargingStatus),
        ],
      ),
      ),
     
    );
  }
}
