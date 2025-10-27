import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/transaction_service.dart';
import './widgets/balance_card_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/spending_summary_widget.dart';

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
    // Use a shrink-wrapped ListView.builder so we don't build all children
    // into a large Column which can be expensive for long lists. Also keep
    // the visual header as part of this widget.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        transactions.isEmpty
            ? Text(
                'No recent transactions',
                style: Theme.of(context).textTheme.bodySmall,
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (ctx, index) {
                  final transaction = transactions[index];
                  return ListTile(
                    title: Text(transaction['title'].toString()),
                    subtitle: Text(transaction['category'].toString()),
                    trailing: Text('\$${transaction['amount'].toString()}'),
                    onTap: () => onEditTransaction(transaction),
                    onLongPress: () => onCategorizeTransaction(transaction),
                  );
                },
              ),
      ],
    );
  }
}

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}
class _DashboardHomeScreenState extends State<DashboardHomeScreen>
  with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _refreshAnimationController;
  late Animation<double> _refreshAnimation;

  bool _isBalanceVisible = true;
  bool _isRefreshing = false;
  int _selectedTabIndex = 0;
  DateTime _lastUpdated = DateTime.now();

  final double _totalBalance = 4250.75;
  final double _monthlyBudget = 3000.00;
  final double _spentAmount = 1847.32;

  List<Map<String, dynamic>> _recentTransactions = [];
  String? _error;

  final TransactionService _transactionService = TransactionService();
void _handleTabSelection(int index) {
  setState(() {
    _selectedTabIndex = index;
  });
}

void _toggleBalanceVisibility() {
  setState(() {
    _isBalanceVisible = !_isBalanceVisible;
  });
}

void _handleAddExpense() {
  print("Add Expense tapped");
}

void _handleAddIncome() {
  print("Add Income tapped");
}

void _handleViewBudgets() {
  print("View Budgets tapped");
}

void _handleViewReports() {
  print("View Reports tapped");
}

void _handleEditTransaction(Map<String, dynamic> txn) {
  print("Edit Transaction: $txn");
}

void _handleDeleteTransaction(Map<String, dynamic> txn) {
  print("Delete Transaction: $txn");
}

void _handleCategorizeTransaction(Map<String, dynamic> txn) {
  print("Categorize Transaction: $txn");
}

 @override
void initState() {
  super.initState();

  _tabController = TabController(length: 4, vsync: this);
  _tabController.addListener(() {
    _handleTabSelection(_tabController.index);
  });

  _refreshAnimationController = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  );

  _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _refreshAnimationController,
      curve: Curves.easeInOut,
    ),
  );

  _loadTransactions();
}


  Future<void> _loadTransactions() async {
    try {
      final txns = await _transactionService.fetchTransactions();
      setState(() {
        _recentTransactions = txns;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await _loadTransactions();
    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
    });
    Fluttertoast.showToast(msg: "Transactions updated successfully");
  }

  // ... keep the rest of your UI methods (toggle, edit, delete, etc.) unchanged ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _error != null
            ? Center(child: Text("Error: $_error"))
            : _recentTransactions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        BalanceCardWidget(
                          totalBalance: _totalBalance,
                          isBalanceVisible: _isBalanceVisible,
                          onToggleVisibility: _toggleBalanceVisibility,
                        ),
                        QuickActionsWidget(
                          onAddExpense: _handleAddExpense,
                          onAddIncome: _handleAddIncome,
                          onViewBudgets: _handleViewBudgets,
                          onViewReports: _handleViewReports,
                        ),
                        SpendingSummaryWidget(
                          monthlyBudget: _monthlyBudget,
                          spentAmount: _spentAmount,
                          categoryBreakdown: [],
                        ),
                        RecentTransactionsWidget(
                          transactions: _recentTransactions,
                          onEditTransaction: _handleEditTransaction,
                          onDeleteTransaction: _handleDeleteTransaction,
                          onCategorizeTransaction: _handleCategorizeTransaction,
                        ),
                        SizedBox(height: 2.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            'Last updated: ${_lastUpdated.toLocal().toString().split(".")[0]}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

