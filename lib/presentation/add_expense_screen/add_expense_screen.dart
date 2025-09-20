import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/amount_input_widget.dart';
import './widgets/category_selector_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/description_input_widget.dart';
import './widgets/more_details_widget.dart';
import './widgets/receipt_capture_widget.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Form data
  double amount = 0.0;
  Map<String, dynamic>? selectedCategory;
  String description = '';
  DateTime selectedDate = DateTime.now();
  XFile? capturedReceipt;
  Map<String, dynamic> moreDetails = {
    'paymentMethod': 'Cash',
    'tags': <String>[],
    'notes': '',
    'location': '',
  };

  bool _isSaving = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start slide animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onAmountChanged(double newAmount) {
    setState(() {
      amount = newAmount;
    });
  }

  void _onCategorySelected(Map<String, dynamic> category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void _onDescriptionChanged(String newDescription) {
    setState(() {
      description = newDescription;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void _onImageCaptured(XFile? image) {
    setState(() {
      capturedReceipt = image;
    });
  }

  void _onMoreDetailsChanged(Map<String, dynamic> details) {
    setState(() {
      moreDetails = details;
    });
  }

  bool _validateForm() {
    if (amount <= 0) {
      _showErrorMessage('Please enter a valid amount');
      return false;
    }
    if (selectedCategory == null) {
      _showErrorMessage('Please select a category');
      return false;
    }
    if (description.trim().isEmpty) {
      _showErrorMessage('Please add a description');
      return false;
    }
    return true;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            const Text('Expense saved successfully!'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    if (!_validateForm()) return;

    setState(() {
      _isSaving = true;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    try {
      // Simulate saving expense
      await Future.delayed(const Duration(milliseconds: 1500));

      // Create expense data
      // final expenseData = {
      //  'id': DateTime.now().millisecondsSinceEpoch,
      //   'amount': amount,
      //   'category': selectedCategory,
      //   'description': description,
      //   'date': selectedDate.toIso8601String(),
      //   'receipt': capturedReceipt?.path,
      //   'paymentMethod': moreDetails['paymentMethod'],
     //    'tags': moreDetails['tags'],
     //    'notes': moreDetails['notes'],
     //    'location': moreDetails['location'],
     //    'createdAt': DateTime.now().toIso8601String(),
     //  };

      // Show success message
      _showSuccessMessage();

      // Navigate back to dashboard with success animation
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard-home-screen');
      }
    } catch (e) {
      _showErrorMessage('Failed to save expense. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _closeScreen() {
    _slideController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppTheme.lightTheme.scaffoldBackgroundColor.withValues(alpha: 0.95),
      body: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: 100.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
                AppTheme.lightTheme.scaffoldBackgroundColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          AmountInputWidget(
                            onAmountChanged: _onAmountChanged,
                            initialAmount: amount > 0 ? amount : null,
                          ),
                          SizedBox(height: 3.h),
                          CategorySelectorWidget(
                            onCategorySelected: _onCategorySelected,
                            selectedCategory: selectedCategory,
                          ),
                          SizedBox(height: 3.h),
                          DescriptionInputWidget(
                            onDescriptionChanged: _onDescriptionChanged,
                            initialDescription:
                                description.isNotEmpty ? description : null,
                          ),
                          SizedBox(height: 3.h),
                          DatePickerWidget(
                            onDateSelected: _onDateSelected,
                            selectedDate: selectedDate,
                          ),
                          SizedBox(height: 3.h),
                          ReceiptCaptureWidget(
                            onImageCaptured: _onImageCaptured,
                            capturedImage: capturedReceipt,
                          ),
                          SizedBox(height: 3.h),
                          MoreDetailsWidget(
                            onDetailsChanged: _onMoreDetailsChanged,
                            initialDetails: moreDetails,
                          ),
                          SizedBox(height: 10.h), // Space for floating button
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildSaveButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: _closeScreen,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Expense',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Track your spending',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'today',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${selectedDate.month}/${selectedDate.day}',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: 90.w,
      height: 7.h,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor:
              AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
        child: _isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Saving...',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'save',
                    color: Colors.white,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Save Expense',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
