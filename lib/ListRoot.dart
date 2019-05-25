import 'package:flutter/material.dart';
import 'dart:async';
import 'Task.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'CreateTask.dart';

const String API_URL = "http://10.0.2.2:8000/api/list/";

class ListRoot extends StatefulWidget {
  @override
  _ListRootState createState() => _ListRootState();
}

class _ListRootState extends State<ListRoot> {
  @override
  void initState() {
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Title"),
          elevation: 0,
        ),
        body: TaskList());
  }
}

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
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
                          backgroundColor: Colors.black,
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

  Future<List<List<Task>>> getTaskList() async {
    final response = await get(API_URL);
    final jsonResponse = json.decode(response.body);
    List<Task> allTasks = List();
    List<Task> completedTasks = List();
    List<List<Task>> both = List();
    for (var items in jsonResponse) {
      Task task = Task(
          items['title'], items['content'], items['isComplete'], items['id']);
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
            style: TextStyle(color: Colors.black),
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
                                  setState(() {
                                    delete(API_URL + "${val.getId()}/");
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
                    msg['title'] = val.getTitle();
                    msg['id'] = "${val.getId()}";
                    msg['isComplete'] = "false";
                    setState(() {
                      put(API_URL + "${val.getId()}/", body: msg);
                    });
                  },
                  leading: Icon(
                    Icons.check_box,
                    color: Colors.black,
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
            color: Colors.blueAccent,
            child: Icon(Icons.check, color: Colors.white),
          ),
          key: Key(_items[i].title),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) {
            var msg = Map<String, String>();
            msg['title'] = _items[i].getTitle();
            msg['id'] = "${_items[i].getId()}";
            msg['isComplete'] = "true";
            setState(() {
              put(API_URL + "${_items[i].getId()}/", body: msg);
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
              leading: Icon(
                Icons.check_box_outline_blank,
                color: Colors.black,
              ),
              title:
                  Text(_items[i].title, style: TextStyle(color: Colors.black)),
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

  Widget makeCompleteList() {
    return null;
  }
}
