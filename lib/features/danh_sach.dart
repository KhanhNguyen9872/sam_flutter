import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../headers/header_child.dart';

// Initialize the notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Define the TodoItem class
class TodoItem {
  final String title;
  final bool completed;
  final DateTime? dueDate;

  TodoItem(this.title, this.completed, {this.dueDate});

  Map<String, dynamic> toJson() => {
        'title': title,
        'completed': completed,
        'dueDate': dueDate?.toIso8601String(),
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        json['title'] as String,
        json['completed'] as bool,
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      );
}

class DanhSach extends StatefulWidget {
  const DanhSach({Key? key}) : super(key: key);

  @override
  _DanhSachState createState() => _DanhSachState();
}

class _DanhSachState extends State<DanhSach> {
  List<TodoItem> todoList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadTodoList();
  }

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Load tasks from shared preferences
  Future<void> _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('todo_list');
    if (jsonString != null) {
      List<Map<String, dynamic>> jsonList =
          List<Map<String, dynamic>>.from(jsonDecode(jsonString));
      todoList = jsonList.map((item) => TodoItem.fromJson(item)).toList();
    }
    setState(() {
      isLoading = false;
    });
  }

  // Save tasks to shared preferences
  Future<void> _saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString =
        jsonEncode(todoList.map((item) => item.toJson()).toList());
    await prefs.setString('todo_list', jsonString);
  }

  // Add a new task
  void _addTodoItem(String title, {DateTime? dueDate}) {
    setState(() {
      todoList.add(TodoItem(title, false, dueDate: dueDate));
    });
    _saveTodoList();
    if (dueDate != null) {
      scheduleNotification(title, dueDate);
    }
  }

  // Toggle task completion
  void _toggleTodoItem(int index, bool value) {
    setState(() {
      todoList[index] = TodoItem(todoList[index].title, value,
          dueDate: todoList[index].dueDate);
    });
    _saveTodoList();
    if (value && todoList[index].dueDate != null) {
      _cancelNotification(index);
    }
  }

  // Delete a task
  void _deleteTodoItem(int index) {
    if (todoList[index].dueDate != null) {
      _cancelNotification(index);
    }
    setState(() {
      todoList.removeAt(index);
    });
    _saveTodoList();
  }

  Future<void> scheduleNotification(
      String title, DateTime scheduledTime) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id', // Unique channel ID
      'Channel Name', // Channel name
      channelDescription: 'Channel for scheduled notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      title.hashCode, // Unique ID for the notification
      'Task: $title', // Notification title
      'This task is due now!', // Notification body
      tz.TZDateTime.from(scheduledTime, tz.local), // Scheduled time
      notificationDetails,
      androidAllowWhileIdle:
          true, // Allow notification even when device is idle
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel a notification
  Future<void> _cancelNotification(int index) async {
    await flutterLocalNotificationsPlugin
        .cancel(todoList[index].title.hashCode);
  }

  // Show dialog to add a new task
  void _showAddTaskDialog() {
    String newTitle = '';
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => newTitle = value,
                decoration: const InputDecoration(
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    }
                  }
                  setState(() {});
                },
                child: const Text('Set Due Date & Time'),
              ),
              if (selectedDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Due: ${selectedDate!.toLocal().toString().split('.')[0]}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newTitle.isNotEmpty) {
                  _addTodoItem(newTitle, dueDate: selectedDate);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderChild(
            title: 'To-Do List',
            onBack: () => Navigator.pop(context), // Navigate back
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : todoList.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks yet!\nAdd some tasks to get started.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: todoList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                todoList[index].title,
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.045,
                                  decoration: todoList[index].completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: todoList[index].completed
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              subtitle: todoList[index].dueDate != null
                                  ? Text(
                                      'Due: ${todoList[index].dueDate!.toLocal().toString().split('.')[0]}',
                                      style: const TextStyle(fontSize: 14),
                                    )
                                  : null,
                              leading: Checkbox(
                                value: todoList[index].completed,
                                onChanged: (value) =>
                                    _toggleTodoItem(index, value!),
                                activeColor: Colors.teal,
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTodoItem(index),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  runApp(
    MaterialApp(
      home: const DanhSach(),
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    ),
  );
}
