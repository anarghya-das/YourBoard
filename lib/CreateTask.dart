import 'package:flutter/material.dart';
import 'package:http/http.dart';

const String API_URL = "http://10.0.2.2:8000/api/list/";

class CreateTask extends StatefulWidget {
  final String heading, body;
  final int id;

  CreateTask(this.heading, this.body, this.id);

  @override
  _CreateTaskState createState() => _CreateTaskState(heading, body, id);
}

class _CreateTaskState extends State<CreateTask> {
  final String heading, body;
  final int id;

  _CreateTaskState(this.heading, this.body, this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: heading.isEmpty ? Text("Create Task") : Text("Update Task"),
        ),
        body: Form(heading, body, id));
  }
}

class Form extends StatefulWidget {
  final String heading, body;
  final int id;

  Form(this.heading, this.body, this.id);

  @override
  _FormState createState() => _FormState(heading, body, id);
}

class _FormState extends State<Form> {
  String heading, body;
  int id;
  TextEditingController _headingController;
  TextEditingController _bodyController;

  _FormState(this.heading, this.body, this.id);

  @override
  void initState() {
    super.initState();
    _headingController = TextEditingController(text: heading);
    _bodyController = TextEditingController(text: body);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _headingController,
              style: TextStyle(fontSize: 25),
              decoration: InputDecoration.collapsed(
                  border: InputBorder.none,
                  hintText: "Title",
                  hintStyle: TextStyle(fontSize: 25)),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _bodyController,
              decoration: InputDecoration.collapsed(
                  border: InputBorder.none, hintText: "Body"),
              maxLines: null,
            ),
          ),
        ),
        RaisedButton(
          onPressed: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            var msg = Map<String, String>();
            String _title = _headingController.text;
            String _content = _bodyController.text;
            if (_title.isEmpty && _content.isEmpty) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Both Fields cannot be empty"),
              ));
            } else {
              msg['title'] = _title;
              msg['content'] = _content;
              if (heading.isEmpty) {
                post(
                  API_URL,
                  body: msg,
                ).then((Response response) {
                  final int statusCode = response.statusCode;
                  if (statusCode < 200 || statusCode > 400) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Server Error! :("),
                    ));
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Created!"),
                    ));
                    Navigator.pop(context);
                  }
                });
              } else {
                msg['id'] = "$id";
                put(API_URL + "$id/", body: msg);
                Navigator.pop(context);
              }
            }
          },
          child: heading.isEmpty
              ? Text("Create", style: TextStyle(color: Colors.white))
              : Text("Update", style: TextStyle(color: Colors.white)),
          color: Colors.black,
        )
      ],
    );
  }
}
