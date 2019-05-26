import 'package:flutter/material.dart';
import 'timerView.dart';
import 'stopWatchView.dart';

class TabPage extends StatefulWidget {
  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<TabPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  var _tabPages = <Widget>[TimerPage(), StopWatchPage()];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabPages.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
        ),
        body: TabBarView(
          children: _tabPages,
          controller: _tabController,
        ),
        bottomNavigationBar: Material(
          color: Colors.white,
          child: TabBar(
            indicatorColor: Colors.black,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.timer), text: "Timer"),
              Tab(icon: Icon(Icons.timer), text: "StopWatch"),
            ],
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.blueAccent,
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ));
  }
}
