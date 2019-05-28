import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'tabPage.dart';

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  static const duration = const Duration(milliseconds: 1);
  int _seconds = 0;
  int _milliseconds = 0;
  int _minutes = 0;
  bool _notStarted = true;
  bool _restart = false;
  Stopwatch _stopwatch = new Stopwatch();
  Timer _timer;
  IconData _defIcon = Icons.play_circle_outline;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, ios);
    _flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.maybePop(
      context,
      MaterialPageRoute(builder: (context) => TabPage()),
    );
  }

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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("State: ${state.toString()}");
    switch (state) {
      case AppLifecycleState.paused:
        if (!_notStarted) {
          showNotification();
        }
        break;
      case AppLifecycleState.resumed:
        if (!_notStarted) {
          hideNotification();
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.suspending:
        break;
    }
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
                color: Theme.of(context).accentColor,
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

  Future showNotification() async {
    var android = AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DISCRIPTION',
        importance: Importance.Max, priority: Priority.High, playSound: false);
    var ios = IOSNotificationDetails();
    var platform = NotificationDetails(android, ios);
    await _flutterLocalNotificationsPlugin.show(
        0, "Stopwatch Running", null, platform);
  }

  Future hideNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(0);
  }
}
