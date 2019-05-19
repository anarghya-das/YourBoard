import 'dart:async';
import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage>
    with AutomaticKeepAliveClientMixin {
  static const duration = const Duration(milliseconds: 1);
  int _seconds = 0;
  int _milliseconds = 0;
  int _minutes = 0;
  bool _notStarted = true;
  bool _restart = false;
  Stopwatch _stopwatch = new Stopwatch();
  Timer _timer;
  IconData _defIcon = Icons.play_circle_outline;

  void _update() {
    setState(() {
      int _ms = _stopwatch.elapsedMilliseconds;
      _milliseconds = _ms % 1000;
      _seconds = (_ms ~/ 1000) % 60;
      _minutes = _ms ~/ 60000;
    });
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RichText(
          text: TextSpan(
              style: TextStyle(
                fontSize: 60.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                _minutes < 10
                    ? TextSpan(text: "0$_minutes:")
                    : TextSpan(text: "$_minutes:"),
                _seconds < 10
                    ? TextSpan(text: "0$_seconds.")
                    : TextSpan(text: "$_seconds."),
                TextSpan(text: "$_milliseconds", style: TextStyle(fontSize: 30))
              ]),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onPressed: () {
                  if (_defIcon == Icons.pause_circle_outline) {
                    _stopwatch.stop();
                    setState(() {
                      _defIcon = Icons.play_circle_outline;
                      _restart = true;
                    });
                  } else {
                    if (_notStarted) {
                      _timer = Timer.periodic(duration, (Timer t) => _update());
                      _notStarted = false;
                    }
                    _stopwatch.start();
                    setState(() {
                      _defIcon = Icons.pause_circle_outline;
                      _restart = false;
                    });
                  }
                },
                icon: Icon(
                  _defIcon,
                  size: 50,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: IconButton(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onPressed: _restart
                    ? () {
                        _stopwatch.stop();
                        _stopwatch.reset();
                        setState(() {
                          _seconds = 0;
                          _milliseconds = 0;
                          _minutes = 0;
                        });
                        _timer.cancel();
                        _notStarted = true;
                        _restart = false;
                        _defIcon = Icons.play_circle_outline;
                      }
                    : null,
                icon: Visibility(
                  visible: _restart,
                  child: Icon(
                    Icons.refresh,
                    size: 50,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    ));
  }
}
