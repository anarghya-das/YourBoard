import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class StopWatchPage extends StatefulWidget {
  @override
  _StopWatchPageState createState() => _StopWatchPageState();
}

class _StopWatchPageState extends State<StopWatchPage> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  Color _hourColor = Colors.black;
  Color _minuteColor = Colors.black;
  Color _secondColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  _hours < 10
                      ? TextSpan(
                          text: "0$_hours",
                          style: TextStyle(color: _hourColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                _hourColor = Colors.blue;
                                _minuteColor = Colors.black;
                                _secondColor = Colors.black;
                              });
                            })
                      : TextSpan(
                          text: "$_hours",
                          style: TextStyle(color: _hourColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                _hourColor = Colors.blue;
                                _minuteColor = Colors.black;
                                _secondColor = Colors.black;
                              });
                            }),
                  TextSpan(
                    text: ":",
                  ),
                  _minutes < 10
                      ? TextSpan(
                          text: "0$_minutes",
                          style: TextStyle(color: _minuteColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                _minuteColor = Colors.blue;
                                _hourColor = Colors.black;
                                _secondColor = Colors.black;
                              });
                            })
                      : TextSpan(text: "$_minutes"),
                  TextSpan(
                    text: ":",
                  ),
                  _seconds < 10
                      ? TextSpan(
                          text: "0$_seconds",
                          style: TextStyle(color: _secondColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                _secondColor = Colors.blue;
                                _minuteColor = Colors.black;
                                _hourColor = Colors.black;
                              });
                            })
                      : TextSpan(
                          text: "$_seconds",
                          style: TextStyle(color: _secondColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                _secondColor = Colors.blue;
                              });
                            }),
                ]),
          ),
          GridView.count(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 30, top: 30, right: 30),
            crossAxisCount: 3,
            crossAxisSpacing: 50.0,
            mainAxisSpacing: 0.0,
            children: _fillGrid(),
          )
        ],
      ),
    );
  }

  List<Widget> _fillGrid() {
    List<Widget> all = List();
    var c = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "DEL"];
    c.forEach((i) {
      all.add(FlatButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          color: Colors.white,
          onPressed: () {},
          child: Text(
            "$i",
            style: TextStyle(fontSize: i == "DEL" ? 28 : 40),
          )));
    });
    return all;
  }
}
