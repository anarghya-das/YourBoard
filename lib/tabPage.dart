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
    _tabController.addListener(_handleSelected);
  }

  void _handleSelected() {
    setState(() {});
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
          title: _tabController.index == 0
              ? Text("Stopwatch")
              : Text("Countdown Timer"),
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
              Tab(icon: Icon(Icons.timer), text: "Stopwatch"),
              Tab(icon: Icon(Icons.timer), text: "Countdown Timer"),
            ],
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ));
  }
}
