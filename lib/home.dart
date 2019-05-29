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
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          elevation: 1,
          centerTitle: true,
          title: Text(
            "YourBoard",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
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
  String _userName = "Enter your name!";
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textEditingController;

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

  Future<String> _getName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString("userName");
    if (name == null) {
      return "Enter your name!";
    } else {
      return name;
    }
  }

  Future<void> _loadName() async {
    _userName = await _getName();
    setState(() {});
  }

  Future<void> _storeName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userName", value);
  }

  @override
  void initState() {
    _loadImage();
    _loadName();
    _textEditingController = TextEditingController();
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
    return Align(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: GridView.count(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              crossAxisSpacing: 0.0,
              crossAxisCount: 2,
              children: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => TabPage()));
                    },
                    icon: Icon(Icons.timer, size: 90)),
                IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ListRoot()));
                    },
                    icon: Icon(Icons.list, size: 90)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 300.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      getImage(ImageSource.gallery);
                    },
                    child: showImage()),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext contex) {
                            return AlertDialog(
                              title: Text("Name"),
                              content: Form(
                                key: _formKey,
                                child: TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "Please enter your name!";
                                    }
                                  },
                                  controller: _textEditingController,
                                  decoration: InputDecoration(
                                      hintText: "Enter your name"),
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Confirm"),
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      _storeName(_textEditingController.text);
                                      setState(() {
                                        _userName = _textEditingController.text;
                                      });
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                                FlatButton(
                                  child: Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    },
                    child: Text(
                      "Hi, $_userName",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                )
              ],
            ),
          )
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
          _storedImage = File(snapshot.data.path);
          _storePreference(snapshot.data.path);
          return CircleAvatar(
            backgroundImage: FileImage(snapshot.data),
            backgroundColor: Colors.transparent,
            minRadius: 10,
            maxRadius: 70,
          );
        } else {
          return _checkImage(_storedImage);
        }
      },
    );
  }

  Widget _checkImage(File imgFile) {
    return imgFile == null
        ? CircleAvatar(
            backgroundImage: ExactAssetImage('images/avatar.png'),
            backgroundColor: Colors.transparent,
            minRadius: 10,
            maxRadius: 70,
          )
        : CircleAvatar(
            backgroundImage: FileImage(imgFile),
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
