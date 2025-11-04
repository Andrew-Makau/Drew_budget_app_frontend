
import 'package:flutter/material.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(Map<String, dynamic>) onEditTransaction;
  final Function(Map<String, dynamic>) onDeleteTransaction;
  final Function(Map<String, dynamic>) onCategorizeTransaction;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
    required this.onEditTransaction,
    required this.onDeleteTransaction,
    required this.onCategorizeTransaction,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          'No recent transactions.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }
    // NOTE: This widget is rendered inside a SingleChildScrollView on the dashboard.
    // To avoid "Vertical viewport was given unbounded height" and similar layout
    // exceptions, disable inner scrolling and enable shrinkWrap here.
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final txn = transactions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: txn['categoryColor'] ?? Colors.blueAccent,
            child: Icon(
              txn['type'] == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white,
            ),
          ),
          title: Text(txn['title'] ?? ''),
          subtitle: Text(txn['category'] ?? ''),
          trailing: Text(
            '${txn['type'] == 'income' ? '+' : '-'} ' + (txn['amount']?.toStringAsFixed(2) ?? '0.00'),
            style: TextStyle(
              color: txn['type'] == 'income' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => onEditTransaction(txn),
          onLongPress: () => onDeleteTransaction(txn),
        );
      },
    );
  }
}
