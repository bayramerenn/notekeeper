import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/Helpers/database_helper.dart';
import 'package:notekeeper/Helpers/kTextHelpers.dart';
import 'package:notekeeper/models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final Task task;
  final Function updateTaskList;
  AddTaskScreen({this.task, this.updateTaskList});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _priority = "Öncelik Durumu";
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat('MMM dd,yyyy', 'tr_TR');
  final List<String> _priorities = ['Öncelik Durumu', 'Low', 'Medium', 'High'];

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale("tr", "TR"),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });

      _dateController.text = _dateFormatter.format(date);
    }
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      Task task = Task(title: _title, date: _date, priority: _priority);
      if (widget.task == null) {
        task.status = 0;
        print(
            '${task.status} ${task.title} ${task.priority} ${task.date} ${task.id}');
        DatabaseHelper.instance.insertTask(task);
      } else {
        task.id = widget.task.id;
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }
      widget.updateTaskList();
      Navigator.pop(context);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTask(widget.task.id);
    widget.updateTaskList();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  // ignore: must_call_super
  void initState() {
    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
    }

    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 25),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                buildTextHelpers(
                    text: widget.task == null ? "Add Task" : 'Update Task',
                    size: 40.0),
                SizedBox(
                  height: 10,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildTextTitle(),
                      buildDate(),
                      buildDropDown(context),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: FlatButton(
                          child: buildTextHelpers(
                            text: widget.task == null ? "Add" : 'Update',
                            color: Colors.white,
                            size: 20.0,
                          ),
                          onPressed: _submit,
                        ),
                      ),
                      widget.task != null
                          ? Container(
                              margin: EdgeInsets.symmetric(vertical: 20.0),
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: FlatButton(
                                child: buildTextHelpers(
                                  text: "Delete",
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                                onPressed: _delete,
                              ),
                            )
                          : SizedBox.shrink()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding buildDropDown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: DropdownButtonFormField(
        isDense: true,
        icon: Icon(Icons.arrow_drop_down_circle),
        iconSize: 22.0,
        iconEnabledColor: Theme.of(context).primaryColor,
        items: _priorities.map((String priority) {
          return DropdownMenuItem(
            value: priority,
            child: Text(
              priority,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
            ),
          );
        }).toList(),
        style: TextStyle(fontSize: 18.0),
        decoration: InputDecoration(
          labelText: 'Prority',
          labelStyle: TextStyle(fontSize: 18.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: (input) {
          return _priority == null || _priority == 'Öncelik Durumu'
              ? 'please enter a task title'
              : null;
        },
        onSaved: (input) => _priority = input,
        onChanged: (value) {
          setState(() {
            _priority = value;
          });
        },
        value: _priority,
      ),
    );
  }

  Padding buildDate() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: TextFormField(
        readOnly: true,
        controller: _dateController,
        onTap: _handleDatePicker,
        style: TextStyle(fontSize: 18.0),
        decoration: InputDecoration(
          labelText: 'Date',
          labelStyle: TextStyle(fontSize: 18.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Padding buildTextTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: TextFormField(
        style: TextStyle(fontSize: 18.0),
        decoration: InputDecoration(
          labelText: 'title',
          labelStyle: TextStyle(fontSize: 18.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        validator: (input) =>
            input.trim().isEmpty ? 'please enter a task title' : null,
        onSaved: (input) => _title = input,
        initialValue: _title,
      ),
    );
  }
}
