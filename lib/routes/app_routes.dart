import 'package:flutter/material.dart';
import '../presentation/add_expense_screen/add_expense_screen.dart';
import '../presentation/transaction_history_screen/transaction_history_screen.dart';
import '../presentation/dashboard_home_screen/dashboard_home_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/budget_categories_screen/budget_categories_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String addExpense = '/add-expense-screen';
  static const String transactionHistory = '/transaction-history-screen';
  static const String dashboardHome = '/dashboard-home-screen';
  static const String login = '/login-screen';
  static const String budgetCategories = '/budget-categories-screen';
  static const String registration = '/registration-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    addExpense: (context) => const AddExpenseScreen(),
    transactionHistory: (context) => const TransactionHistoryScreen(),
    dashboardHome: (context) => const DashboardHomeScreen(),
    login: (context) => const LoginScreen(),
    budgetCategories: (context) => const BudgetCategoriesScreen(),
    registration: (context) => const RegistrationScreen(),
    // TODO: Add your other routes here
  };
}
