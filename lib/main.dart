import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _number = 0;
  Color _backgroundColor = Colors.blue;
  bool _isMonochrome = false;
  bool _isSimple = true;
  int _changeFrequency = 3; // 3 seconds as default
  late Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(seconds: _changeFrequency), (_) {
      _changeNumber();
    });
    super.initState();
    _changeNumber();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  void _changeNumber() {
    setState(() {
      _number = _isSimple ? Random().nextInt(10) : Random().nextInt(100);
      if (!_isMonochrome) {
        _backgroundColor = _colors[Random().nextInt(_colors.length)];
      }
    });
    _timer.cancel();
    _timer = Timer.periodic(Duration(seconds: _changeFrequency), (_) {
      _changeNumber();
    });
  }

  void _toggleMonochrome() {
    setState(() {
      _isMonochrome = !_isMonochrome;
      _backgroundColor = _isMonochrome
          ? Colors.black
          : _colors[Random().nextInt(_colors.length)];
    });
  }

  void _changeFrequencyCycle(int currentFrequency) {
    setState(() {
      if (currentFrequency == 1) {
        _changeFrequency = 3;
      } else if (currentFrequency == 3) {
        _changeFrequency = 5;
      } else {
        _changeFrequency = 1;
      }
    });
    _changeNumber();
  }

  void _toggleSimple() {
    setState(() {
      _isSimple = !_isSimple;
    });
    _changeNumber(); // call _changeNumber method after toggling the mode
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double textSize;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      textSize = screenSize.width * 0.75;
    } else {
      textSize = screenSize.height * 0.9;
    }
    return Stack(
      children: <Widget>[
        Container(
          color: _backgroundColor,
          child: Center(
            child: Text(
              '$_number',
              style: TextStyle(
                fontSize: textSize,
                color: _isMonochrome ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
                inherit: false,
              ),
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: GestureDetector(
            onTap: _toggleMonochrome,
            child: Icon(
              _isMonochrome ? Icons.wb_sunny : Icons.brightness_3,
              color: _isMonochrome ? Colors.white : Colors.black,
              size: 40.0,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: GestureDetector(
            onTap: _toggleSimple,
            child: Icon(_isSimple ? Icons.filter_1 : Icons.filter_9_plus,
                color: _isMonochrome ? Colors.white : Colors.black, size: 40.0),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: GestureDetector(
            onTap: () => _changeFrequencyCycle(_changeFrequency),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isMonochrome ? Colors.white : Colors.black,
                  width: 3,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$_changeFrequency',
                      style: TextStyle(
                          color: _isMonochrome ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          fontFamily: 'Arial',
                          inherit: false),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      's',
                      style: TextStyle(
                          color: _isMonochrome ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          fontFamily: 'Arial',
                          inherit: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
