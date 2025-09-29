import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/balance_card_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_transactions_widget.dart';
import './widgets/spending_summary_widget.dart';

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
  final String _userName = "Alex";
  DateTime _lastUpdated = DateTime.now();

  // Mock data
  final double _totalBalance = 4250.75;
  final double _monthlyBudget = 3000.00;
  final double _spentAmount = 1847.32;

  final List<Map<String, dynamic>> _categoryBreakdown = [
    {
      "name": "Food & Dining",
      "amount": 687.50,
      "color": Colors.orange.shade400,
    },
    {
      "name": "Transportation",
      "amount": 425.80,
      "color": Colors.blue.shade400,
    },
    {
      "name": "Shopping",
      "amount": 312.45,
      "color": Colors.purple.shade400,
    },
    {
      "name": "Entertainment",
      "amount": 234.67,
      "color": Colors.green.shade400,
    },
    {
      "name": "Bills & Utilities",
      "amount": 186.90,
      "color": Colors.red.shade400,
    },
  ];

  final List<Map<String, dynamic>> _recentTransactions = [
    {
      "id": 1,
      "title": "Starbucks Coffee",
      "category": "Food",
      "amount": 12.50,
      "date": DateTime.now().subtract(const Duration(hours: 2)),
      "type": "expense",
      "categoryColor": Colors.orange.shade400,
    },
    {
      "id": 2,
      "title": "Uber Ride",
      "category": "Transport",
      "amount": 18.75,
      "date": DateTime.now().subtract(const Duration(hours: 5)),
      "type": "expense",
      "categoryColor": Colors.blue.shade400,
    },
    {
      "id": 3,
      "title": "Salary Deposit",
      "category": "Income",
      "amount": 2500.00,
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "type": "income",
      "categoryColor": Colors.green.shade400,
    },
    {
      "id": 4,
      "title": "Amazon Purchase",
      "category": "Shopping",
      "amount": 89.99,
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "type": "expense",
      "categoryColor": Colors.purple.shade400,
    },
    {
      "id": 5,
      "title": "Netflix Subscription",
      "category": "Entertainment",
      "amount": 15.99,
      "date": DateTime.now().subtract(const Duration(days: 3)),
      "type": "expense",
      "categoryColor": Colors.red.shade400,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _refreshAnimationController, curve: Curves.easeInOut),
    );

    // Debug: check if token is stored
    AuthService().getToken().then((token) {
      print("🔑 Stored token: $token");
    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _refreshAnimationController.forward();
    HapticFeedback.mediumImpact();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
    });

    _refreshAnimationController.reset();

    Fluttertoast.showToast(
      msg: "Data updated successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green.shade600,
      textColor: Colors.white,
    );
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
    HapticFeedback.lightImpact();
  }

  void _handleAddExpense() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/add-expense-screen');
  }

  void _handleAddIncome() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/add-expense-screen');
  }

  void _handleViewBudgets() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/budget-categories-screen');
  }

  void _handleViewReports() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/transaction-history-screen');
  }

  void _handleEditTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Edit transaction: ${transaction['title']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleDeleteTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Transaction'),
        content:
            Text('Are you sure you want to delete "${transaction['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _recentTransactions
                    .removeWhere((t) => t['id'] == transaction['id']);
              });
              Fluttertoast.showToast(
                msg: "Transaction deleted",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red.shade600,
                textColor: Colors.white,
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleCategorizeTransaction(Map<String, dynamic> transaction) {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Categorize transaction: ${transaction['title']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _formatLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()}, $_userName!',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Last updated: ${_formatLastUpdated()}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Fluttertoast.showToast(
                        msg: "No new notifications",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          CustomIconWidget(
                            iconName: 'notifications',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 24,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 2.w,
                              height: 2.w,
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(1.w),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: AppTheme.lightTheme.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),

                      // Balance Card
                      BalanceCardWidget(
                        totalBalance: _totalBalance,
                        isBalanceVisible: _isBalanceVisible,
                        onToggleVisibility: _toggleBalanceVisibility,
                      ),

                      // Quick Actions
                      QuickActionsWidget(
                        onAddExpense: _handleAddExpense,
                        onAddIncome: _handleAddIncome,
                        onViewBudgets: _handleViewBudgets,
                        onViewReports: _handleViewReports,
                      ),

                      // Spending Summary
                      SpendingSummaryWidget(
                        monthlyBudget: _monthlyBudget,
                        spentAmount: _spentAmount,
                        categoryBreakdown: _categoryBreakdown,
                      ),

                      // Recent Transactions
                      RecentTransactionsWidget(
                        transactions: _recentTransactions,
                        onEditTransaction: _handleEditTransaction,
                        onDeleteTransaction: _handleDeleteTransaction,
                        onCategorizeTransaction: _handleCategorizeTransaction,
                      ),

                      SizedBox(height: 10.h), // Bottom padding for tab bar
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Tab Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
            HapticFeedback.lightImpact();

            // Navigate to different screens based on tab
            switch (index) {
              case 0:
                // Already on home
                break;
              case 1:
                Navigator.pushNamed(context, '/transaction-history-screen');
                break;
              case 2:
                Navigator.pushNamed(context, '/budget-categories-screen');
                break;
              case 3:
                Navigator.pushNamed(context, '/login-screen');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.lightTheme.cardColor,
          selectedItemColor: AppTheme.lightTheme.primaryColor,
          unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          selectedLabelStyle:
              AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle:
              AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
          ),
          items: [
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'home',
                color: _selectedTabIndex == 0
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'history',
                color: _selectedTabIndex == 1
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'pie_chart',
                color: _selectedTabIndex == 2
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              label: 'Budget',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'person',
                color: _selectedTabIndex == 3
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddExpense,
        backgroundColor: AppTheme.lightTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        child: AnimatedBuilder(
          animation: _refreshAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _refreshAnimation.value * 2 * 3.14159,
              child: CustomIconWidget(
                iconName: _isRefreshing ? 'refresh' : 'add',
                color: Colors.white,
                size: 28,
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
