import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api.dart'; // Ensure the correct path if placed in a different folder
import '../headers/header_child.dart';

// Define the Transaction class with paymentDate
class Transaction {
  final String id;
  final String status;
  final Color statusColor;
  final String description;
  final String amount;
  final String paymentDate; // Added paymentDate for paid transactions

  Transaction({
    required this.id,
    required this.status,
    required this.statusColor,
    required this.description,
    required this.amount,
    required this.paymentDate,
  });
}

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  int _selectedTabIndex = 0; // 0: Tất cả, 1: Đã thanh toán, 2: Chưa thanh toán

  late Future<List<Transaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchTransactions();
  }

  /// Fetch transactions from the API using a token stored locally.
  Future<List<Transaction>> _fetchTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      throw Exception("Phiên đăng nhập hết hạn");
    }
    final transactionsData = await Api.getTransactions(accessToken: token);
    // Map API data to Transaction objects.
    return transactionsData.map((data) {
      return Transaction(
        id: data["id"]!,
        status: data["status"]!,
        statusColor: data["status"]! == "Đã thanh toán"
            ? const Color(0xFF4CAF50)
            : const Color(0xFFE57373),
        description: data["description"]!,
        amount: data["amount"]!,
        paymentDate: data["paymentDate"]!,
      );
    }).toList();
  }

  // Build the tab buttons.
  Widget _buildTabButton(String text, int index, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _selectedTabIndex == index
                ? const Color(0xFF1976D2)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _selectedTabIndex == index ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderChild(
              title: "Học phí",
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Balance Section
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE0B2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFFD4A373),
                            size: 40,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Số dư của học viên',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '1.000.000đ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Tuition Fees to Pay Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCDD2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFFE57373),
                            size: 40,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Học phí cần thanh toán',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '3.500.000đ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Transaction History Section Header
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Lịch sử thanh toán',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildTabButton('Tất cả', 0, flex: 1),
                          const SizedBox(width: 8),
                          _buildTabButton('Đã thanh toán', 1, flex: 2),
                          const SizedBox(width: 8),
                          _buildTabButton('Chưa thanh toán', 2, flex: 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Transaction List using FutureBuilder with animation.
                    FutureBuilder<List<Transaction>>(
                      future: _transactionsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        } else if (snapshot.hasData) {
                          final transactionsData = snapshot.data!;
                          // Filter transactions based on the selected tab.
                          final filteredTransactions = _selectedTabIndex == 0
                              ? transactionsData
                              : transactionsData.where((t) {
                                  if (_selectedTabIndex == 1) {
                                    return t.status == 'Đã thanh toán';
                                  } else {
                                    return t.status == 'Chưa thanh toán';
                                  }
                                }).toList();
                          // AnimatedSwitcher to animate changes when switching tabs.
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: ListView.builder(
                              key: ValueKey(_selectedTabIndex),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredTransactions.length,
                              itemBuilder: (context, index) {
                                final transaction = filteredTransactions[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Row 1: ID and status.
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            transaction.id,
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            transaction.status,
                                            style: TextStyle(
                                              color: transaction.status ==
                                                      'Đã thanh toán'
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Row 2: Description and amount.
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              transaction.description,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            transaction.amount,
                                            style: TextStyle(
                                              color: transaction.status ==
                                                      'Đã thanh toán'
                                                  ? Colors.green
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Show payment date if already paid.
                                      if (transaction.status ==
                                          'Đã thanh toán') ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Ngày thanh toán: ${transaction.paymentDate}',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
