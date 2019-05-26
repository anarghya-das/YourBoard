import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class StopWatchPage extends StatefulWidget {
  @override
  _StopWatchPageState createState() => _StopWatchPageState();
}

class _StopWatchPageState extends State<StopWatchPage>
    with AutomaticKeepAliveClientMixin {
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

  TextStyle _check(String time) {
    if (time == "hour" && _isSelectedH) {
      return TextStyle(color: Colors.blueAccent);
    } else if (time == "minute" && _isSelectedM) {
      return TextStyle(color: Colors.blueAccent);
    } else if (time == "second" && _isSelectedS) {
      return TextStyle(color: Colors.blueAccent);
    }
    return null;
  }

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 80.0,
                    color: Colors.black,
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
              crossAxisSpacing: 50.0,
              mainAxisSpacing: 0.0,
              children: _fillGrid(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, right: 27),
              child: Visibility(
                visible: _playVisibility,
                child: IconButton(
                  icon: Icon(
                    Icons.play_circle_filled,
                    size: 60,
                  ),
                  onPressed: () {
                    //TODO: Start the Countdown
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _updateTime(String i) {
    if (i == "DEL") {
      if (_isSelectedH) {
        if (_hour0 != "0") {
          _hour0 = "0";
        } else {
          _hour1 = "0";
        }
      }
      if (_isSelectedM) {
        if (_minute0 != "0") {
          _minute0 = "0";
        } else {
          _minute1 = "0";
        }
      }
      if (_isSelectedS) {
        if (_second0 != "0") {
          _second0 = "0";
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
      _playVisibility = true;
    }
  }

  List<Widget> _fillGrid() {
    List<Widget> all = List();
    var c = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "DEL"];
    c.forEach((i) {
      all.add(FlatButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          color: Colors.white,
          onPressed: () {
            setState(() {
              _updateTime(i);
            });
          },
          child: Text(
            "$i",
            style: TextStyle(fontSize: i == "DEL" ? 28 : 40),
          )));
    });
    return all;
  }

  @override
  bool get wantKeepAlive => true;
}
