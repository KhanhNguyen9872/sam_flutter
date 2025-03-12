import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String _selectedLanguage = "English"; // default value
  final String _version = "1.0.0.0";

  // Dictionaries for labels in English and Vietnamese.
  late Map<String, String> labels;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? "English";
      _updateLabels();
    });
  }

  // Save dark mode setting
  Future<void> _saveDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  // Save language setting
  Future<void> _saveLanguage(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', value);
  }

  // Update labels based on the selected language
  void _updateLabels() {
    if (_selectedLanguage == "English") {
      labels = {
        "title": "Settings",
        "darkMode": "Dark Mode",
        "language": "Language",
        "version": "Version",
      };
    } else {
      labels = {
        "title": "Cài đặt",
        "darkMode": "Chế độ tối",
        "language": "Ngôn ngữ",
        "version": "Phiên bản",
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // Choose colors based on dark mode setting
    final backgroundColor = _isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          labels["title"] ?? "",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2F3D85),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark mode toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedLanguage == "English" ? "Dark Mode" : "Chế độ tối",
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
                Switch(
                  value: _isDarkMode,
                  onChanged: (bool value) {
                    setState(() {
                      _isDarkMode = value;
                      _saveDarkMode(value);
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            // Language selection
            Text(
              _selectedLanguage == "English" ? "Language" : "Ngôn ngữ",
              style: TextStyle(fontSize: 16, color: textColor),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedLanguage,
              items: <String>["English", "Tiếng Việt"]
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: textColor),
                        ),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                    _saveLanguage(newValue);
                    _updateLabels();
                  });
                }
              },
            ),
            const Divider(),
            const SizedBox(height: 16),
            // Version info
            Text(
              _selectedLanguage == "English" ? "Version" : "Phiên bản",
              style: TextStyle(fontSize: 16, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              _version,
              style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
