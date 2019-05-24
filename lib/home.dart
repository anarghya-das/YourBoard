import 'package:flutter/material.dart';
import 'tabPage.dart';
import 'ListRoot.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          centerTitle: true,
          title: Text(
            "YB",
            style: TextStyle(fontSize: 40),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.settings,
              ),
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text(
                  'Your Board',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TabPage()));
                },
                leading: Icon(
                  Icons.timer,
                  color: Colors.black,
                  size: 40,
                ),
                title: Text(
                  "Timer/Stopwatch",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              ListTile(
                onTap: () {},
                leading: Icon(
                  Icons.calendar_today,
                  color: Colors.black,
                  size: 40,
                ),
                title: Text(
                  "Calendar",
                  style: TextStyle(fontSize: 25),
                ),
              )
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: Board());
  }
}

class Board extends StatefulWidget {
  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Card(
                margin: EdgeInsets.only(top: 100),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: GridView.count(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  crossAxisSpacing: 10.0,
                  crossAxisCount: 2,
                  children: <Widget>[
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TabPage()));
                        },
                        icon: Icon(Icons.timer, size: 90)),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListRoot()));
                        },
                        icon: Icon(Icons.list, size: 90)),
                    IconButton(
                        onPressed: () {}, icon: Icon(Icons.cloud, size: 90)),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.calendar_today, size: 90))
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 10),
                  width: 130.0,
                  height: 130.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(
                              "https://i.imgur.com/BoN9kdC.png")))),
            ],
          ),
        ],
      ),
    );
  }
}
