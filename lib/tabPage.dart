import 'package:flutter/material.dart';
import 'timerView.dart';
import 'stopWatchView.dart';

class TabPage extends StatefulWidget {
  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<TabPage> {
  int _bottomIdx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _bottomIdx,
        children: <Widget>[TimerPage(), StopWatchPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        currentIndex: _bottomIdx,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.timer), title: Text("Timer")),
          BottomNavigationBarItem(
              icon: Icon(Icons.timer), title: Text("StopWatch")),
        ],
        onTap: (idx) {
          setState(() {
            _bottomIdx = idx;
          });
        },
      ),
    );
  }
}
