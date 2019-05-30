import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'tabPage.dart';

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

// * Wrap the class with AutomaticKeepAliveClientMixin to ensure it does not die when the user swipes away
// * and WidgetsBindingObserver to check when the application was paused or resumed to display notifications.
class _TimerPageState extends State<TimerPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  // * Displaying the time in hours, minutes and seconds. 0 represents the first digit on left for a porticular time
  // * and 1 represents the digit on the right.
  String _hour0 = "0",
      _hour1 = "0",
      _minute0 = "0",
      _minute1 = "0",
      _second0 = "0",
      _second1 = "0";
  bool _isSelectedH = false;
  bool _isSelectedM = false;
  bool _isSelectedS = false;
  bool _playVisibility = false;
  int _currentIndex = 0;
  int _hours = 0, _minutes = 0, _seconds = 0;
  Duration duration;
  Timer _watchHandler;
  static AudioCache player = new AudioCache();
  Future<AudioPlayer> audioPlayer;
  bool isAudioPlaying = false, isPaused = false;
  bool _timerPaused = false;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

// * Function styles hour, minute and second displays seperately
  TextStyle _check(String time) {
    if (time == "hour" && _isSelectedH) {
      return TextStyle(color: Colors.grey);
    } else if (time == "minute" && _isSelectedM) {
      return TextStyle(color: Colors.grey);
    } else if (time == "second" && _isSelectedS) {
      return TextStyle(color: Colors.grey);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _changeBool("second");
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    var initSettings = InitializationSettings(android, ios);
    _flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
  }

// * Function which displays the activity again when the notificaiton is pressed
  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.maybePop(
      context,
      MaterialPageRoute(builder: (context) => TabPage()),
    );
  }

  Future showNotification() async {
    var android = AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DISCRIPTION',
        importance: Importance.Max, priority: Priority.High, playSound: false);
    var ios = IOSNotificationDetails();
    var platform = NotificationDetails(android, ios);
    await _flutterLocalNotificationsPlugin.show(
        0, "Timer", "Time is up!", platform);
  }

  Future hideNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("State: ${state.toString()}");
    switch (state) {
      case AppLifecycleState.paused:
        if (isAudioPlaying) {
          showNotification();
        }
        isPaused = true;
        break;
      case AppLifecycleState.resumed:
        if (isAudioPlaying) {
          hideNotification();
        }
        isPaused = false;
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.suspending:
        break;
    }
  }

  void _timerHelper() {
    if (!_timerPaused) {
      _hours = int.parse(_hour0 + _hour1);
      _minutes = int.parse(_minute0 + _minute1);
      _seconds = int.parse(_second0 + _second1);
    }
    duration = Duration(hours: _hours, minutes: _minutes, seconds: _seconds);
    _watchHandler = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timer.tick == duration.inSeconds) {
        audioPlayer = player.loop("alarm.wav");
        timer.cancel();
        isAudioPlaying = true;
        if (isPaused) {
          showNotification();
        }
      }
      setState(() {
        if (_seconds == 0 && _minutes != 0) {
          _seconds = 60;
          _minutes--;
        }
        if (_seconds == 0 && _minutes == 0 && _hours != 0) {
          _seconds = 60;
          _minutes = 60;
          _minutes--;
          _hours--;
        }
        _seconds--;
      });
    });
  }

  // * Displays the timer view when the timer is running after the user hits play.
  Widget watchView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RichText(text: _renderTime()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: !isAudioPlaying,
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 40,
                  ),
                  onPressed: () {
                    _watchHandler.cancel();
                    _timerPaused = false;
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                ),
              ),
              Visibility(
                visible: !isAudioPlaying,
                child: IconButton(
                  icon: _timerPaused
                      ? Icon(
                          Icons.play_circle_filled,
                          size: 40,
                        )
                      : Icon(
                          Icons.pause_circle_filled,
                          size: 40,
                        ),
                  onPressed: _timerPaused
                      ? () {
                          _timerPaused = false;
                          _timerHelper();
                        }
                      : () {
                          _watchHandler.cancel();
                          setState(() {
                            _timerPaused = true;
                          });
                        },
                ),
              ),
              Visibility(
                visible: isAudioPlaying,
                child: IconButton(
                  icon: Icon(
                    Icons.stop,
                    size: 50,
                  ),
                  onPressed: () {
                    setState(() {
                      if (audioPlayer != null) {
                        audioPlayer.then((AudioPlayer val) => val.release());
                      }
                      isAudioPlaying = false;
                      _watchHandler.cancel();
                      _currentIndex = 0;
                    });
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }

// * Function which displays the running timer on the screen.
  TextSpan _renderTime() {
    if (_seconds >= 60) {
      _minutes += _seconds ~/ 60;
      _seconds = _seconds % 60;
    }
    if (_minutes >= 60) {
      _hours += _minutes ~/ 60;
      _minutes = _minutes % 60;
    }
    TextSpan _minuteText = _minutes < 10
        ? TextSpan(text: "0$_minutes")
        : TextSpan(text: "$_minutes");
    TextSpan _secondText = _seconds < 10
        ? TextSpan(text: "0$_seconds")
        : TextSpan(text: "$_seconds");
    TextSpan _hourText =
        _hours < 10 ? TextSpan(text: "0$_hours") : TextSpan(text: "$_hours");
    return TextSpan(
        style: TextStyle(
          fontSize: 60.0,
          color: Theme.of(context).accentColor,
        ),
        children: <TextSpan>[
          _hourText,
          TextSpan(text: ":"),
          _minuteText,
          TextSpan(text: ":"),
          _secondText,
        ]);
  }

  // * This function manages the selective functionality of the selected text of hours, minutes and seconds.
// * At a single time only one of those three can be selected and changed and this function manages that.
  void _changeBool(String time) {
    switch (time) {
      case "hour":
        _isSelectedH = true;
        _isSelectedM = false;
        _isSelectedS = false;
        break;
      case "minute":
        _isSelectedH = false;
        _isSelectedM = true;
        _isSelectedS = false;
        break;
      case "second":
        _isSelectedH = false;
        _isSelectedM = false;
        _isSelectedS = true;
        break;
    }
  }

// * Function which deals with updating the UI of time selection before starting the timer. Works together with _changeBool function.
  void _updateTime(String i) {
    if (i == "DEL") {
      if (_isSelectedH) {
        if (_hour0 != "0") {
          String _temp = _hour0;
          _hour0 = "0";
          _hour1 = _temp;
        } else {
          _hour1 = "0";
        }
      }
      if (_isSelectedM) {
        if (_minute0 != "0") {
          String _temp = _minute0;
          _minute0 = "0";
          _minute1 = _temp;
        } else {
          _minute1 = "0";
        }
      }
      if (_isSelectedS) {
        if (_second0 != "0") {
          String _temp = _second0;
          _second0 = "0";
          _second1 = _temp;
        } else {
          _second1 = "0";
        }
      }
      if (_hour0 == "0" &&
          _hour1 == "0" &&
          _minute0 == "0" &&
          _minute1 == "0" &&
          _second0 == "0" &&
          _second1 == "0") {
        _playVisibility = false;
      }
    } else {
      if (_isSelectedH) {
        if (_hour0 != "0" && _hour1 != "0") {
          return;
        } else if (_hour1 == "0") {
          _hour1 = i;
        } else {
          String _temp = _hour1;
          _hour0 = _temp;
          _hour1 = i;
        }
      }
      if (_isSelectedM) {
        if (_minute0 != "0" && _minute1 != "0") {
          return;
        } else if (_minute1 == "0") {
          _minute1 = i;
        } else {
          String _temp = _minute1;
          _minute0 = _temp;
          _minute1 = i;
        }
      }
      if (_isSelectedS) {
        if (_second0 != "0" && _second1 != "0") {
          return;
        } else if (_second1 == "0") {
          _second1 = i;
        } else {
          String _temp = _second1;
          _second0 = _temp;
          _second1 = i;
        }
      }
      if (_hour0 != "0" ||
          _hour1 != "0" ||
          _minute0 != "0" ||
          _minute1 != "0" ||
          _second0 != "0" ||
          _second1 != "0") {
        _playVisibility = true;
      }
    }
  }

// * Makes the number grid which helps the user to set the time for the timer.
  List<Widget> _fillGrid() {
    List<Widget> all = List();
    var c = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "DEL"];
    c.forEach((i) {
      all.add(FlatButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            setState(() {
              _updateTime(i);
            });
          },
          child: Text(
            "$i",
            style: TextStyle(fontSize: i == "DEL" ? 21 : 40),
          )));
    });
    return all;
  }

  @override
  bool get wantKeepAlive => true;

// * Used an indexed stack which displays only one view of the given index at any time. Opens with the time selection view for the timer.
// * After the time is selected and timer pressed, index is changed and the view is switched to the running timer and vice versa when the stop
// * button is pressed.
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return IndexedStack(
      index: _currentIndex,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 80.0,
                        color: Theme.of(context).accentColor,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: "$_hour0$_hour1",
                            style: _check("hour"),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  _changeBool("hour");
                                });
                              }),
                        TextSpan(
                          text: ":",
                        ),
                        TextSpan(
                            text: "$_minute0$_minute1",
                            style: _check("minute"),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  _changeBool("minute");
                                });
                              }),
                        TextSpan(
                          text: ":",
                        ),
                        TextSpan(
                            text: "$_second0$_second1",
                            style: _check("second"),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  _changeBool("second");
                                });
                              })
                      ]),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 100.0),
                      child: Text("H", style: TextStyle(fontSize: 20)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 100.0),
                      child: Text("M", style: TextStyle(fontSize: 20)),
                    ),
                    Text("S", style: TextStyle(fontSize: 20)),
                  ],
                ),
                GridView.count(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: 30, top: 30, right: 30),
                  crossAxisCount: 3,
                  crossAxisSpacing: 70.0,
                  mainAxisSpacing: 0.0,
                  children: _fillGrid(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, right: 27),
                  child: Visibility(
                    visible: _playVisibility,
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      icon: Icon(
                        Icons.play_circle_filled,
                        size: 60,
                      ),
                      onPressed: () {
                        _timerHelper();
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        watchView()
      ],
    );
  }
}
