import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _tasks = {}; // To store tasks locally

  @override
  void initState() {
    super.initState();
    _fetchTasksFromFirebase(); // Fetch tasks on initialization
  }

  void _fetchTasksFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance.collection('tasks').get();
    final tasks = snapshot.docs;

    setState(() {
      _tasks = {};
      for (var doc in tasks) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final task = data['task'] as String;

        if (_tasks[date] == null) {
          _tasks[date] = [];
        }
        _tasks[date]!.add(task);
      }
    });
  }

  List<String> _getTasksForDay(DateTime day) {
    return _tasks[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _addTask(DateTime date, String task) async {
    final formattedDate = DateTime(date.year, date.month, date.day);

    await FirebaseFirestore.instance.collection('tasks').add({
      'date': formattedDate,
      'task': task,
    });

    setState(() {
      if (_tasks[formattedDate] == null) {
        _tasks[formattedDate] = [];
      }
      _tasks[formattedDate]!.add(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Study Planner')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) => _getTasksForDay(day),
          ),
          const SizedBox(height: 8.0),
          if (_selectedDay != null)
            Expanded(
              child: ListView(
                children: _getTasksForDay(_selectedDay!).map((task) {
                  return ListTile(
                    title: Text(task),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () {
              if (_selectedDay != null) {
                showDialog(
                  context: context,
                  builder: (context) {
                    String taskText = '';
                    return AlertDialog(
                      title: Text('Add Task'),
                      content: TextField(
                        onChanged: (value) {
                          taskText = value;
                        },
                        decoration: InputDecoration(hintText: 'Enter task'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (taskText.isNotEmpty) {
                              _addTask(_selectedDay!, taskText);
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Text('Add Task'),
          ),
        ],
      ),
    );
  }
}
