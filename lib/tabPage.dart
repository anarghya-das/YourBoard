import 'package:flutter/material.dart';
import 'TimerPage.dart';
import 'StopwatchPage.dart';

// * Tab page to display both countdown Timer and Stopwatch. Used a tab so that the user could easily swipe between the two views.
class TabPage extends StatefulWidget {
  @override
  _TimerState createState() => _TimerState();
}

// * Wrap the class with SingleTickerProviderStateMixin to use the Tab View
class _TimerState extends State<TabPage> with SingleTickerProviderStateMixin {
  TabController
      _tabController; // *Tab controller helps to swtich tabs, get tab title, etc.
  var _tabPages = <Widget>[
    StopwatchPage(),
    TimerPage()
  ]; // * Pages displayed on this Tab View

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabPages.length, vsync: this);
    _tabController.addListener(_handleSelected);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleSelected() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: _tabController.index == 0 // * Dynamically switches the title based on the tab
              ? Text("Stopwatch")
              : Text("Countdown Timer"),
        ),
        body: TabBarView(
          children: _tabPages,
          controller: _tabController,
        ),
        bottomNavigationBar: Material(
          color: Theme.of(context).primaryColor,
          child: TabBar(
            indicatorColor: Theme.of(context).accentColor,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.timer), text: "Stopwatch"),
              Tab(icon: Icon(Icons.timer), text: "Countdown Timer"),
            ],
            controller: _tabController,
            labelColor: Theme.of(context).accentColor,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ));
  }
}
