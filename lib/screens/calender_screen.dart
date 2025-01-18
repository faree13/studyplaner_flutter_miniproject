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
  Map<DateTime, List<Map<String, String>>> _tasks = {}; // Tasks with descriptions

  @override
  void initState() {
    super.initState();
    _fetchTasksFromFirebase();
  }

  void _fetchTasksFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance.collection('tasks').get();
    final tasks = snapshot.docs;

    setState(() {
      _tasks = {};
      for (var doc in tasks) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final task = data['task'] as String;
        final description = data['description'] as String;

        if (_tasks[normalizedDate] == null) {
          _tasks[normalizedDate] = [];
        }

        // Avoid duplicates
        if (!_tasks[normalizedDate]!.any((t) => t['task'] == task)) {
          _tasks[normalizedDate]!.add({'task': task, 'description': description});
        }
      }
    });
  }

  void _addTask(DateTime date, String task, String description) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    await FirebaseFirestore.instance.collection('tasks').add({
      'date': normalizedDate,
      'task': task,
      'description': description,
    });

    setState(() {
      if (_tasks[normalizedDate] == null) {
        _tasks[normalizedDate] = [];
      }
      _tasks[normalizedDate]!.add({'task': task, 'description': description});
    });
  }

  List<Map<String, String>> _getTasksForDay(DateTime day) {
    return _tasks[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Planner')),
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
            eventLoader: _getTasksForDay,
          ),
          const SizedBox(height: 8.0),
          if (_selectedDay != null)
            Expanded(
              child: ListView(
                children: _getTasksForDay(_selectedDay!).map((task) {
                  return Card(
                    child: ListTile(
                      title: Text(task['task'] ?? ''),
                      subtitle: Text(task['description'] ?? ''),
                    ),
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
                    String descriptionText = '';
                    return AlertDialog(
                      title: const Text('Add Task'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            onChanged: (value) {
                              taskText = value;
                            },
                            decoration: const InputDecoration(hintText: 'Enter Subject'),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            onChanged: (value) {
                              descriptionText = value;
                            },
                            decoration: const InputDecoration(hintText: 'Enter Description'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (taskText.isNotEmpty && descriptionText.isNotEmpty) {
                              _addTask(_selectedDay!, taskText, descriptionText);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }
}
