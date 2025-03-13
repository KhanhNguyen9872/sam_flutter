import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../footer_menu.dart';
import '../api.dart';
import '../welcome.dart';

class ThoiKhoaBieuScreen extends StatefulWidget {
  const ThoiKhoaBieuScreen({Key? key}) : super(key: key);

  @override
  State<ThoiKhoaBieuScreen> createState() => _ThoiKhoaBieuScreenState();
}

class _ThoiKhoaBieuScreenState extends State<ThoiKhoaBieuScreen> {
  // Toggle between week view and month view.
  bool _isWeekView = true;

  // Selected day in week view (default: today's date)
  DateTime _selectedDay = DateTime.now();

  // Selected month in month view (1 to 12), null means none selected.
  int? _selectedMonth;

  // Future for schedule classes.
  late Future<List<Map<String, String>>> _scheduleFuture;

  // Access token from SharedPreferences.
  String? _accessToken;
  bool _isLoadingToken = true;

  @override
  void initState() {
    super.initState();
    _loadTokenAndSchedule();
  }

  /// Check for accessToken; if found, load schedule classes.
  /// Otherwise, show error and navigate to Welcome.
  Future<void> _loadTokenAndSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      _showTokenExpiredAndNavigate();
      return;
    } else {
      setState(() {
        _accessToken = token;
        _scheduleFuture = Api.getScheduleClasses(accessToken: token);
        _isLoadingToken = false;
      });
    }
  }

  /// Handle token expiration: show message, remove token, and navigate to Welcome.
  Future<void> _showTokenExpiredAndNavigate() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại!"),
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Welcome()),
        (route) => false,
      );
    }
  }

  /// Filter the schedule classes based on the selected view.
  List<Map<String, String>> _filterClasses(List<Map<String, String>> classes) {
    if (_isWeekView) {
      return classes.where((cls) {
        try {
          final classDate = DateFormat('yyyy-MM-dd').parse(cls["date"]!);
          return classDate.year == _selectedDay.year &&
              classDate.month == _selectedDay.month &&
              classDate.day == _selectedDay.day;
        } catch (e) {
          return false;
        }
      }).toList();
    } else {
      if (_selectedMonth != null) {
        return classes.where((cls) {
          try {
            final classDate = DateFormat('yyyy-MM-dd').parse(cls["date"]!);
            return classDate.month == _selectedMonth;
          } catch (e) {
            return false;
          }
        }).toList();
      }
      return classes;
    }
  }

  /// Helper: Map weekday number to Vietnamese label.
  String _getWeekdayLabel(DateTime day) {
    switch (day.weekday) {
      case 1:
        return "Th 2";
      case 2:
        return "Th 3";
      case 3:
        return "Th 4";
      case 4:
        return "Th 5";
      case 5:
        return "Th 6";
      case 6:
        return "Th 7";
      case 7:
        return "CN";
      default:
        return "";
    }
  }

  /// Build a widget for each class item.
  Widget _buildClassItem(Map<String, String> item) {
    final start = item["startTime"] ?? "";
    final end = item["endTime"] ?? "";
    final title = item["title"] ?? "";
    final topic = item["topic"] ?? "";
    final teacher = item["teacher"] ?? "";
    final room = item["room"] ?? "";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time block with full height.
            Container(
              width: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5722),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    start,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "-",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    end,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Class details.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF2F3D85),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic,
                    style: const TextStyle(
                      color: Color(0xFFFF5722),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.black, size: 18),
                      const SizedBox(width: 4),
                      const Text(
                        "Giáo viên: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        teacher,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.meeting_room,
                          color: Colors.black, size: 18),
                      const SizedBox(width: 4),
                      const Text(
                        "Phòng: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        room,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the week view header with days of the current week.
  Widget _buildWeekDaysRow() {
    DateTime today = _selectedDay;
    int weekday = today.weekday;
    DateTime monday = today.subtract(Duration(days: weekday - 1));
    List<DateTime> weekDays =
        List.generate(7, (index) => monday.add(Duration(days: index)));

    return Row(
      children: weekDays.map((day) {
        bool isSelected = day.year == _selectedDay.year &&
            day.month == _selectedDay.month &&
            day.day == _selectedDay.day;
        String label = _getWeekdayLabel(day);
        String dayNum = day.day.toString();
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = day;
              });
            },
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dayNum,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build the month grid view.
  Widget _buildMonthGrid() {
    List<int> months = List.generate(12, (index) => index + 1);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: months.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2,
      ),
      itemBuilder: (context, index) {
        int month = months[index];
        bool isSelected = _selectedMonth == month;
        // Display month name in Vietnamese using locale "vi"
        String monthName = DateFormat.MMMM('vi').format(DateTime(0, month));
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMonth = month;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            child: Text(
              monthName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build the sub-header that toggles week/month view.
  Widget _buildSubHeader() {
    return Container(
      color: const Color(0xFF2F3D85),
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display current month-year in week view or "Chọn tháng" in month view.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isWeekView
                    ? DateFormat('MMMM, yyyy', 'vi').format(_selectedDay)
                    : "Chọn tháng",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              // Toggle for week / month view.
              Container(
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isWeekView = true;
                          _selectedMonth = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              _isWeekView ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Tuần",
                          style: TextStyle(
                            color: _isWeekView ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isWeekView = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              !_isWeekView ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Tháng",
                          style: TextStyle(
                            color: !_isWeekView ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isWeekView ? _buildWeekDaysRow() : _buildMonthGrid(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FooterMenu(
        currentIndex: 0,
        onTap: (index) {
          // Handle footer navigation if needed.
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header: back button, title, notification icon.
            Container(
              color: const Color(0xFF2F3D85),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Thời Khóa Biểu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: open notification screen.
                    },
                    icon: Image.asset(
                      "assets/images/notification.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Sub-header with toggle and week/month selection.
            _buildSubHeader(),
            // Body: show filtered class list from scheduleFuture.
            Expanded(
              child: Container(
                color: Colors.grey.shade100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: FutureBuilder<List<Map<String, String>>>(
                  future: _scheduleFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      if (snapshot.error
                          .toString()
                          .contains("Phiên đăng nhập hết hạn")) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showTokenExpiredAndNavigate();
                        });
                      }
                      return const Center(
                          child: Text("Error loading schedule"));
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      final classes = snapshot.data!;
                      final filtered = _filterClasses(classes);
                      if (filtered.isEmpty) {
                        return const Center(
                            child: Text("No classes scheduled"));
                      }
                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _buildClassItem(item);
                        },
                      );
                    }
                    return const Center(child: Text("No data"));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
