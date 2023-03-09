import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom, //This line is used for showing the bottom bar
  ]);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _number = 0;
  Color _backgroundColor = Colors.black;
  bool _isMonochrome = false;
  bool _isSimple = true;
  int _changeFrequency = 3; // 3 seconds as default
  bool _isColorOnly = false;
  late Timer _timer;
  late List<Color> _selectedColors;

  @override
  void initState() {
    _selectedColors = List.from(_colors);
    _timer = Timer.periodic(Duration(seconds: _changeFrequency), (_) {
      _changeNumber();
    });
    super.initState();
    Wakelock.enable();
    _changeNumber();
  }

  @override
  void dispose() {
    _timer.cancel();
    Wakelock.disable();
    super.dispose();
  }

  final List<Color> _colors = [
    Colors.red.shade800,
    Colors.green,
    Colors.blue.shade800,
    Colors.amber,
  ];

  String _get_color_name(Color color) {
    if (color == Colors.red.shade800) {
      return "Red";
    } else if (color == Colors.green) {
      return "Green";
    } else if (color == Colors.blue.shade800) {
      return "Blue";
    } else if (color == Colors.amber) {
      return "Yellow";
    } else {
      return "Unknown";
    }
  }

  void _updateBackgroundColor() {
    if (_selectedColors.length > 0) {
      _backgroundColor =
          _selectedColors[Random().nextInt(_selectedColors.length)];
    }
  }

  void _changeNumber() {
    setState(() {
      _number = _isSimple ? Random().nextInt(10) : Random().nextInt(20);
      if (!_isMonochrome) {
        _updateBackgroundColor();
      }
    });
    _timer.cancel();
    _timer = Timer.periodic(Duration(seconds: _changeFrequency), (_) {
      _changeNumber();
    });
  }

  void _toggleMonochrome() {
    if (_isColorOnly) {
      return;
    }
    setState(() {
      _isMonochrome = !_isMonochrome;
      _isMonochrome
          ? _backgroundColor = Colors.black
          : _updateBackgroundColor();
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

  void _toggleColorOnly() {
    if (_isMonochrome) {
      return;
    }
    setState(() {
      _isColorOnly = !_isColorOnly;
    });

    _changeNumber();
  }

  void _openColorSelector() {
    showDialog(
      context: context,
      builder: (context) {
        // Store the state of the checkboxes in the State object of the AlertDialog
        return StatefulBuilder(
          builder: (context, setState) => Theme(
            data: ThemeData(
              brightness: Brightness.dark,
            ),
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(
                  color: Colors.grey.shade400,
                  width: 1,
                ),
              ),
              title: Text(
                'SELECT COLORS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontFamily: 'Roboto',
                  color: Colors.grey.shade800,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: _colors.map((color) {
                    return CheckboxListTile(
                      title: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: color,
                            radius: 10.0,
                          ),
                          const SizedBox(width: 20.0),
                          Text(
                            _get_color_name(color),
                            style: TextStyle(
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      checkColor: Colors.white,
                      activeColor: Colors.black54,
                      value: _selectedColors.contains(color),
                      onChanged: (selected) {
                        setState(() {
                          if (selected!) {
                            _selectedColors.add(color);
                          } else {
                            _selectedColors.remove(color);
                          }
                        });
                        _changeNumber();
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double iconSize;
    double insetSize;
    double textSize;
    double buttonBorder;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      textSize = screenSize.width * 0.75;
      iconSize = screenSize.width * 0.05;
      insetSize = iconSize * 3 / 4;
      buttonBorder = screenSize.width * 0.004;
    } else {
      textSize = screenSize.height * 0.9;
      iconSize = screenSize.height * 0.05;
      insetSize = iconSize * 3 / 4;
      buttonBorder = screenSize.height * 0.004;
    }

    insetSize = insetSize < 28 ? 28 : insetSize;

    return Stack(
      children: <Widget>[
        Container(
          color: _isColorOnly ? Colors.black : _backgroundColor,
          child: Center(
            child: _isColorOnly
                ? Container(
                    width: textSize,
                    height: textSize,
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      shape: BoxShape.circle,
                    ),
                  )
                : Text(
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
          top: insetSize,
          right: insetSize,
          child: GestureDetector(
            onTap: _toggleMonochrome,
            child: Icon(
              _isMonochrome ? Icons.wb_sunny : Icons.brightness_3,
              color: _isMonochrome ? Colors.white : Colors.black,
              size: iconSize,
            ),
          ),
        ),
        Positioned(
          top: insetSize,
          right: insetSize,
          child: GestureDetector(
            onTap: _isColorOnly ? _openColorSelector : _toggleMonochrome,
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isColorOnly ? Colors.white : Colors.transparent,
                  width: buttonBorder,
                ),
              ),
              child: Icon(
                Icons.color_lens,
                color: _isColorOnly ? Colors.white : Colors.transparent,
                size: iconSize * 3 / 4,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: insetSize,
          right: insetSize,
          child: GestureDetector(
            onTap: _toggleSimple,
            child: Icon(_isSimple ? Icons.filter_1 : Icons.filter_9_plus,
                color: _isMonochrome ? Colors.white : Colors.black,
                size: iconSize),
          ),
        ),
        Positioned(
          bottom: insetSize,
          left: insetSize,
          child: GestureDetector(
            onTap: () => _changeFrequencyCycle(_changeFrequency),
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isMonochrome || _isColorOnly
                      ? Colors.white
                      : Colors.black,
                  width: buttonBorder,
                ),
              ),
              child: Center(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final fontSize = constraints.maxHeight /
                        2; // adjust the font size as desired
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '$_changeFrequency',
                          style: TextStyle(
                              color: _isMonochrome || _isColorOnly
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: fontSize,
                              fontFamily: 'Arial',
                              inherit: false),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          's',
                          style: TextStyle(
                              color: _isMonochrome || _isColorOnly
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: fontSize,
                              fontFamily: 'Arial',
                              inherit: false),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: insetSize,
          left: insetSize,
          child: GestureDetector(
            onTap: _toggleColorOnly,
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isColorOnly ? Colors.white : Colors.black,
                  width: buttonBorder,
                ),
              ),
              child: Icon(
                _isColorOnly ? Icons.numbers : Icons.format_color_fill,
                color: _isColorOnly ? Colors.white : Colors.black,
                size: iconSize * 3 / 4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
