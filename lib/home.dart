import 'package:flutter/material.dart';
import 'tabPage.dart';
import 'ListRoot.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<File> _profileImage;
  File _storedImage;

  Future<File> _getStoredFile() async {
    final prefs = await SharedPreferences.getInstance();
    final imageFile = prefs.getString('imagePath');
    if (imageFile == null) {
      return null;
    } else {
      File f = File(imageFile);
      bool result = await f.exists();
      if (result) {
        return f;
      } else {
        return null;
      }
    }
  }

  Future<void> _loadImage() async {
    _storedImage = await _getStoredFile();
    setState(() {});
  }

  @override
  void initState() {
    _loadImage();
    super.initState();
  }

  void getImage(ImageSource source) {
    setState(() {
      showDialog(
          context: context,
          builder: (BuildContext contex) {
            return AlertDialog(
              title: Text("Replace Image"),
              content: Text("Are you sure you want to change the image?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Yes"),
                  onPressed: () {
                    setState(() {
                      _profileImage = ImagePicker.pickImage(source: source);
                    });
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }

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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                    onTap: () {
                      getImage(ImageSource.gallery);
                    },
                    child: showImage()),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget showImage() {
    return FutureBuilder(
      future: _profileImage,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          _storePreference(snapshot.data.path);
          return CircleAvatar(
            backgroundImage: FileImage(snapshot.data),
            backgroundColor: Colors.transparent,
            minRadius: 10,
            maxRadius: 70,
          );
        } else {
          return _checkImage();
        }
      },
    );
  }

  Widget _checkImage() {
    return _storedImage == null
        ? CircleAvatar(
            backgroundImage: ExactAssetImage('images/avatar.png'),
            backgroundColor: Colors.transparent,
            minRadius: 10,
            maxRadius: 70,
          )
        : CircleAvatar(
            backgroundImage: FileImage(_storedImage),
            backgroundColor: Colors.transparent,
            minRadius: 10,
            maxRadius: 70,
          );
  }

  Future<void> _storePreference(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("imagePath", value);
  }
}
