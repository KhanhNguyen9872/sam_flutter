import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../headers/header_child.dart';
import '../api.dart'; // Assuming this contains API calls

// Model for academic results
class AcademicResult {
  final String subject;
  final double score;
  final String semester;

  AcademicResult({
    required this.subject,
    required this.score,
    required this.semester,
  });

  factory AcademicResult.fromJson(Map<String, dynamic> json) {
    return AcademicResult(
      subject: json['subject'],
      score: json['score'],
      semester: json['semester'],
    );
  }
}

class KetQuaHocTap extends StatefulWidget {
  const KetQuaHocTap({Key? key}) : super(key: key);

  @override
  _KetQuaHocTapState createState() => _KetQuaHocTapState();
}

class _KetQuaHocTapState extends State<KetQuaHocTap> {
  List<AcademicResult> results = [];
  bool isLoading = true;
  String? errorMessage;
  String? selectedSemester;
  String sortBy = 'subject';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Retrieve token from local storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken'); // Match key with header_child.dart
  }

  // Fetch academic results from API using token
  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found. Please log in.');
      }
      final data = await Api.getAcademicResults(accessToken: token);
      setState(() {
        results = data.map((e) => AcademicResult.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load results: $error';
      });
      if (error.toString().contains('No token found') ||
          error.toString().contains('Phiên đăng nhập hết hạn')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/welcome');
        });
      }
    }
  }

  // Get unique semesters for filtering
  List<String> getUniqueSemesters() {
    return results.map((e) => e.semester).toSet().toList();
  }

  // Filter results by selected semester
  List<AcademicResult> getFilteredResults() {
    if (selectedSemester == null) return results;
    return results.where((e) => e.semester == selectedSemester).toList();
  }

  // Sort results based on criteria
  void sortResults(String criteria) {
    setState(() {
      sortBy = criteria;
      results.sort((a, b) {
        if (criteria == 'subject') return a.subject.compareTo(b.subject);
        if (criteria == 'score')
          return b.score.compareTo(a.score); // Descending
        return a.semester.compareTo(b.semester);
      });
    });
  }

  // Calculate average score
  double getAverageScore() {
    if (results.isEmpty) return 0.0;
    final total = results.fold(0.0, (sum, item) => sum + item.score);
    return total / results.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          HeaderChild(
            title: 'Kết Quả Học Tập',
            onBack: () => Navigator.pop(context),
            actions: [
              IconButton(
                icon: const Icon(Icons.sort, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Sort by Subject'),
                          onTap: () {
                            sortResults('subject');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Sort by Score (High to Low)'),
                          onTap: () {
                            sortResults('score');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Sort by Semester'),
                          onTap: () {
                            sortResults('semester');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('All Semesters'),
                          onTap: () {
                            setState(() => selectedSemester = null);
                            Navigator.pop(context);
                          },
                        ),
                        ...getUniqueSemesters().map(
                          (semester) => ListTile(
                            title: Text(semester),
                            onTap: () {
                              setState(() => selectedSemester = semester);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchData,
              color: Colors.blueAccent,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _fetchData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : getFilteredResults().isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'No results available.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: getFilteredResults().length,
                              itemBuilder: (context, index) {
                                final result = getFilteredResults()[index];
                                return Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              result.subject,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Semester: ${result.semester}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Score: ${result.score.toStringAsFixed(1)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
          if (!isLoading && errorMessage == null && results.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Average Score:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    getAverageScore().toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchData,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
