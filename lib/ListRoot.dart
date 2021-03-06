import 'package:flutter/material.dart';
import 'dart:async';
import 'Task.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'CreateTask.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:random_string/random_string.dart';
import 'package:crypto/crypto.dart';

// const String API_URL = "http://10.0.2.2:8000/api/list/";
const String API_URL =
    "https://yb-server.appspot.com/api/list/"; // * API DATABASE URL from where the app fetches the task list

const String PREFERENCE_TITLE =
    "ListTitle"; // * Name of the SharedPreference which stores the application name

class ListRoot extends StatefulWidget {
  @override
  _ListRootState createState() => _ListRootState();
}

class _ListRootState extends State<ListRoot> {
  TextEditingController _textEditingController;
  String title = "Enter List Title";
  final _formKey = GlobalKey<FormState>();

  Future<String> _getListTitle() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(PREFERENCE_TITLE);
    if (name == null) {
      return "Enter List Title";
    } else {
      return name;
    }
  }

  Future<void> _loadTitle() async {
    title = await _getListTitle();
    setState(() {});
  }

  Future<void> _storeTitle(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PREFERENCE_TITLE, value);
  }

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _loadTitle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateTask("", "", 0)));
            }),
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          centerTitle: true,
          title: GestureDetector(
            child: Text(title),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext contex) {
                    return AlertDialog(
                      title: Text("Rename List"),
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please enter a title!";
                            }
                          },
                          controller: _textEditingController,
                          decoration:
                              InputDecoration(hintText: "Enter your title"),
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Confirm"),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _storeTitle(_textEditingController.text);
                              setState(() {
                                title = _textEditingController.text;
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
          ),
          elevation: 0,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.help),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext contex) {
                        return AlertDialog(
                            title: Text("Help"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Ok"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                            content: Text("To create a task, use the button at the bottom of the page.\n\n" +
                                "To edit/update the a task, tap on the task.\n\n"
                                    "To mark a task as complete, swipe towards the right." +
                                " The task will then be moved to the completed list below.\n\n" +
                                "To delete a task, long press a task in the completed section."));
                      });
                }),
          ],
        ),
        body: TaskList());
  }
}

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  String _secretUserId;
  String _encodedUserId;

// * Loads the userID from the preference, if no preference found then creates a user id as an alphaNumeric value
// * and stores it in the preference.
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _secretUserId = prefs.getString("userId");
    if (_secretUserId == null) {
      _secretUserId = randomAlphaNumeric(255);
      _storePreference(_secretUserId);
    }
    _createEncodedId(_secretUserId);
  }

  Future<void> _storePreference(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", value);
  }

  void _createEncodedId(String id) {
    var bytes = utf8.encode(id);
    _encodedUserId = sha1.convert(bytes).toString();
  }

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: FutureBuilder(
          future: getTaskList(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Loading..."),
                    )
                  ],
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "An error Occured!",
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  return createTaskList(context, snapshot);
                }
            }
          },
        ));
  }

// * GETs the list of tasks from the API and displays the UI using the Future Builder
  Future<List<List<Task>>> getTaskList() async {
    final response = await get(API_URL + '?user_id=' + _encodedUserId);
    final jsonResponse = json.decode(response.body);
    List<Task> allTasks = List();
    List<Task> completedTasks = List();
    List<List<Task>> both = List();
    for (var items in jsonResponse) {
      Task task = Task(items['title'], items['content'], items['isComplete'],
          items['id'], items['user_id']);
      if (task.isComplete) {
        completedTasks.add(task);
      } else {
        allTasks.add(task);
      }
    }
    both.add(allTasks);
    both.add(completedTasks);
    return both;
  }

// * Creates the seperated list view for each task form the API
  Widget createTaskList(BuildContext context, AsyncSnapshot snapshot) {
    List<List<Task>> _bothItems = snapshot.data;
    List<Task> _items = _bothItems[0];
    List<Task> _completedItems = _bothItems[1];

    return ListView.separated(
        itemCount: _items.length + 1,
        separatorBuilder: (context, i) => Divider(
              height: 1,
              color: Colors.black26,
            ),
        itemBuilder: (context, i) {
          return makeCurrentList(context, i, _items, _completedItems);
        });
  }

  Widget makeCurrentList(BuildContext context, int i, List<Task> _items,
      List<Task> _completedIitems) {
    if (i == _items.length) {
      if (_completedIitems.isEmpty) {
        return null;
      } else {
        return ExpansionTile(
          title: Text(
            "Completed",
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          children: _completedIitems
              .map((val) => ListTile(
                  onLongPress: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext contex) {
                          return AlertDialog(
                            title: Text("Confirm"),
                            content: Text("Are you sure you want to DELETE?"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("Yes"),
                                onPressed: () {
                                  delete(API_URL + "${val.getId()}/")
                                      .then((Response response) {
                                    final int statusCode = response.statusCode;
                                    if (statusCode < 200 || statusCode > 400) {
                                    } else {
                                      setState(() {});
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        content:
                                            Text("Task Sucessfully Deleted!"),
                                        duration: Duration(seconds: 1),
                                      ));
                                    }
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
                  },
                  onTap: () {
                    var msg = Map<String, String>();
                    msg['user_id'] = _encodedUserId;
                    msg['title'] = val.getTitle();
                    msg['id'] = "${val.getId()}";
                    msg['isComplete'] = "false";
                    put(API_URL + "${val.getId()}/", body: msg)
                      ..then((Response response) {
                        final int statusCode = response.statusCode;
                        if (statusCode < 200 || statusCode > 400) {
                        } else {
                          setState(() {});
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text("Task Marked Incomplete!"),
                            duration: Duration(seconds: 1),
                          ));
                        }
                      });
                  },
                  leading: Icon(
                    Icons.check_box,
                    color: Theme.of(context).accentColor,
                  ),
                  title: Text(val.getTitle()),
                  subtitle:
                      val.getContent().isEmpty ? null : Text(val.getContent())))
              .toList(),
        );
      }
    } else {
      return Dismissible(
          background: Container(
            alignment: Alignment.centerLeft,
            color: Theme.of(context).accentColor,
            child: Icon(Icons.check, color: Theme.of(context).primaryColor),
          ),
          key: Key(_items[i].title),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) {
            var msg = Map<String, String>();
            msg['user_id'] = _encodedUserId;
            msg['title'] = _items[i].getTitle();
            msg['id'] = "${_items[i].getId()}";
            msg['isComplete'] = "true";
            put(API_URL + "${_items[i].getId()}/", body: msg)
                .then((Response response) {
              final int statusCode = response.statusCode;
              if (statusCode < 200 || statusCode > 400) {
              } else {
                setState(() {});
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Task Marked Completed!"),
                  duration: Duration(seconds: 1),
                ));
              }
            });
          },
          child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateTask(
                            _items[i].title, _items[i].content, _items[i].id)));
              },
              leading: Icon(Icons.check_box_outline_blank,
                  color: Theme.of(context).accentColor),
              title: Text(_items[i].title,
                  style: TextStyle(color: Theme.of(context).accentColor)),
              subtitle: _items[i].content.isEmpty
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _items[i].content,
                      ),
                    )));
    }
  }
}
