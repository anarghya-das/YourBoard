import 'package:flutter/material.dart';
import 'dart:async';
import 'Task.dart';
import 'package:http/http.dart';
import 'dart:convert';

const String API_URL = "http://10.0.2.2:8000/api/list/";

class ListRoot extends StatefulWidget {
  @override
  _ListRootState createState() => _ListRootState();
}

class _ListRootState extends State<ListRoot> {
  TextEditingController _textEditingController;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              setState(() {});
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
                        child: Text(
                          "An error Occured!",
                          style: TextStyle(fontSize: 30),
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

  Future<List<Task>> getTaskList() async {
    final response = await get(API_URL);
    final jsonResponse = json.decode(response.body);
    List<Task> allTasks = List();
    for (var items in jsonResponse) {
      Task task = Task(items['title'], items['content'], items['isComplete']);
      allTasks.add(task);
    }
    return allTasks;
  }

  Widget createTaskList(BuildContext context, AsyncSnapshot snapshot) {
    List<Task> _items = snapshot.data;
    return ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (context, i) => Divider(
              height: 0,
              color: Colors.transparent,
            ),
        itemBuilder: (context, i) {
          return makeCurrentList(context, i, _items);
        });
  }

  Widget makeCurrentList(BuildContext context, int i, List<Task> _items) {
    if (_items[i].getStatus()) {
      return Text("NOt");
    } else {
      return Dismissible(
        background: Container(
          alignment: Alignment.centerLeft,
          color: Colors.redAccent,
          child: Icon(Icons.delete, color: Colors.white),
        ),
        key: Key(_items[i].title),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          setState(() {
            _items.removeAt(i);
          });
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Dismissed number:${i + 1}"),
            action: SnackBarAction(
              label: "UNDO",
              onPressed: () {
                setState(() {});
              },
            ),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onLongPress: () {
              debugPrint("long");
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _items[i].title,
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _items[i].content,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                  ],
                )),
          ),
        ),
      );
    }
  }

  Widget makeCompleteList() {
    return null;
  }
}
