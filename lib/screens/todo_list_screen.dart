import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/Helpers/database_helper.dart';
import 'package:notekeeper/Helpers/kTextHelpers.dart';
import 'package:notekeeper/models/task_model.dart';
import 'package:notekeeper/screens/add_task_screen.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Future<List<Task>> _taskList;

  final DateFormat _dateFormatter = DateFormat('MMM dd,yyyy', 'tr_TR');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddTaskScreen(
                      updateTaskList: _updateTaskList,
                    ))),
      ),
      body: buildFutureBuilder(),
    );
  }

  FutureBuilder<List<Task>> buildFutureBuilder() {
    return FutureBuilder(
      future: _taskList,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final int completedTaskCount = snapshot.data
            .where((Task task) => task.status == 1)
            .toList()
            .length;

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 80.0),
          itemCount: 1 + snapshot.data.length,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTextHelpers(text: "My Task", size: 40.0),
                    SizedBox(
                      height: 10.0,
                    ),
                    buildTextHelpers(
                        text: '$completedTaskCount of ${snapshot.data.length}',
                        size: 20.0,
                        color: Colors.grey,
                        fontW: FontWeight.w600),
                  ],
                ),
              );
            }
            return _buildTask(snapshot.data[index - 1]);
          },
        );
      },
    );
  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 18.0,
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text(
              '${_dateFormatter.format(task.date)} * ${task.priority}',
              style: TextStyle(
                fontSize: 18.0,
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            trailing: Checkbox(
              onChanged: (value) {
                print(value);
                task.status = value ? 1 : 0;
                DatabaseHelper.instance.updateTask(task);
                _updateTaskList();
              },
              activeColor: Theme.of(context).primaryColor,
              value: task.status == 1 ? true : false,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddTaskScreen(
                            updateTaskList: _updateTaskList,
                            task: task,
                          )));
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
