import 'package:flutter/material.dart';
import 'api.dart';
import '../welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model class for notification items.
class NotificationItem {
  final String title;
  final String message;
  final DateTime dateTime;
  final IconData icon;
  final Color iconColor;

  NotificationItem({
    required this.title,
    required this.message,
    required this.dateTime,
    required this.icon,
    required this.iconColor,
  });
}

class HeaderChild extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const HeaderChild({
    Key? key,
    required this.title,
    this.onBack,
    this.actions,
  }) : super(key: key);

  Future<bool> _checkNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      throw Exception("Phiên đăng nhập hết hạn");
    }
    return Api.hasNotification(accessToken: token);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2F3D85),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer()
        ],
      ),
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<NotificationItem>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  Future<List<NotificationItem>> _fetchNotifications() async {
    // Retrieve the access token from local storage.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) throw Exception("Phiên đăng nhập hết hạn");
    final data = await Api.getNotifications(accessToken: token);
    return data.map<NotificationItem>((map) {
      // Map API string to IconData.
      IconData iconData;
      switch (map["icon"]) {
        case "star":
          iconData = Icons.star;
          break;
        case "school":
          iconData = Icons.school;
          break;
        case "payment":
          iconData = Icons.payment;
          break;
        case "alarm":
          iconData = Icons.alarm;
          break;
        case "event":
          iconData = Icons.event;
          break;
        case "build":
          iconData = Icons.build;
          break;
        case "question_answer":
          iconData = Icons.question_answer;
          break;
        default:
          iconData = Icons.notifications;
      }
      return NotificationItem(
        title: map["title"],
        message: map["message"],
        dateTime: DateTime.parse(map["dateTime"]),
        icon: iconData,
        iconColor: Color(map["iconColor"]),
      );
    }).toList();
  }

  String _formatTime(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} mins ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours ago';
    } else {
      return '${duration.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove standard AppBar in favor of our custom header.
      body: SafeArea(
        child: Column(
          children: [
            const HeaderChild(title: "Thông báo"),
            Expanded(
              child: FutureBuilder<List<NotificationItem>>(
                future: _notificationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    final notifications = snapshot.data!;
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: item.iconColor.withOpacity(0.2),
                              child: Icon(
                                item.icon,
                                color: item.iconColor,
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.message),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(item.dateTime),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              // Handle notification tap if needed.
                            },
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
