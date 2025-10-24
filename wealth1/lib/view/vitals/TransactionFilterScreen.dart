import 'package:flutter/material.dart';

class TransactionFilterScreen extends StatefulWidget {
  const TransactionFilterScreen({super.key});

  @override
  State<TransactionFilterScreen> createState() =>
      _TransactionFilterScreenState();
}

class _TransactionFilterScreenState extends State<TransactionFilterScreen> {
  String selectedBank = 'All';
  String selectedCategory = 'All';
  String selectedTransactionType = 'All';

  bool expandBank = false;
  bool expandCategory = false;
  bool expandType = false;

  DateTime selectedDate = DateTime(2017, 8, 15);

  List<String> bankAccounts = [
    'All',
    'Bank of America',
    'Chase',
    'Roobinhood',
    'Coinbase',
    'Other'
  ];
  List<String> categories = ['All', 'Crypto', 'Stocks', 'Funds', 'Other'];
  List<String> types = [
    'All',
    'Income',
    'Expense',
    'Loan',
    'Investments',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Transaction Filter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            )),
        actions: [Container(), Container()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        child: Column(
          children: [
            _buildExpandableSection(
              title: 'Banks Accounts',
              isExpanded: expandBank,
              onToggle: () => setState(() => expandBank = !expandBank),
              options: bankAccounts,
              selected: selectedBank,
              onChanged: (value) => setState(() => selectedBank = value),
            ),
            const Divider(color: Colors.white10),
            _buildExpandableSection(
              title: 'Transaction Category',
              isExpanded: expandCategory,
              onToggle: () => setState(() => expandCategory = !expandCategory),
              options: categories,
              selected: selectedCategory,
              onChanged: (value) => setState(() => selectedCategory = value),
            ),
            const Divider(color: Colors.white10),
            _buildExpandableSection(
              title: 'Transaction Type',
              isExpanded: expandType,
              onToggle: () => setState(() => expandType = !expandType),
              options: types,
              selected: selectedTransactionType,
              onChanged: (value) =>
                  setState(() => selectedTransactionType = value),
            ),
            const Divider(color: Colors.white10),
            const SizedBox(height: 16), // Spacing before date section
            const Text(
              'Filter by Date',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildCalendarSection(),
            const SizedBox(height: 40), // Spacing before button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 45,
        margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom + 10, top: 10),
        padding: EdgeInsets.symmetric(horizontal: 12),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // handle filters
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(46, 173, 165, 1),
            // padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Apply Filters',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 16.0), // Match screenshot spacing
          child: InkWell(
            onTap: onToggle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Column(
            children: options.map((item) {
              return RadioListTile<String>(
                value: item,
                groupValue: selected,
                activeColor: const Color.fromRGBO(46, 173, 165, 1),
                onChanged: (val) => onChanged(val!),
                title: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                contentPadding:
                    EdgeInsets.zero, // Remove padding to match screenshot
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final totalDays =
        DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month);
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final weekdayOffset = firstDayOfMonth.weekday % 7;

    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedDate =
                        DateTime(selectedDate.year, selectedDate.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Text(
                '${_monthName(selectedDate.month)} ${selectedDate.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedDate =
                        DateTime(selectedDate.year, selectedDate.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12), // Increased spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: daysOfWeek.map((d) {
              return SizedBox(
                width: 30,
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500, // Semi-bold
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8), // Increased spacing
          GridView.builder(
            itemCount: totalDays + weekdayOffset,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              if (index < weekdayOffset) return const SizedBox();
              final day = index - weekdayOffset + 1;
              final isSelected = selectedDate.day == day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate =
                        DateTime(selectedDate.year, selectedDate.month, day);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: const Color.fromRGBO(46, 173, 165, 1),
                          shape: BoxShape.circle)
                      : null,
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
