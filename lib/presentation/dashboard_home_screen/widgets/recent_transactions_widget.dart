import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

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
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/transaction-history-screen'),
                child: Text(
                  'See All',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          transactions.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length > 5 ? 5 : transactions.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTransactionItem(context, transaction);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'receipt_long',
            color: Colors.grey.shade400,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No transactions yet',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start tracking your expenses to see them here',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, Map<String, dynamic> transaction) {
    final String title = transaction['title'] as String;
    final String category = transaction['category'] as String;
    final double amount = transaction['amount'] as double;
    final DateTime date = transaction['date'] as DateTime;
    final String type = transaction['type'] as String; // 'expense' or 'income'
    final Color categoryColor = transaction['categoryColor'] as Color;

    return Slidable(
      key: ValueKey(transaction['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onEditTransaction(transaction),
            backgroundColor: Colors.blue.shade400,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (context) => onCategorizeTransaction(transaction),
            backgroundColor: Colors.orange.shade400,
            foregroundColor: Colors.white,
            icon: Icons.category,
            label: 'Category',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (context) => onDeleteTransaction(transaction),
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context, transaction),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: _getCategoryIcon(category),
                  color: categoryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Text(
                          category,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          width: 1.w,
                          height: 1.w,
                          decoration: BoxDecoration(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            borderRadius: BorderRadius.circular(0.5.w),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          _formatDate(date),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '${type == 'expense' ? '-' : '+'}\$${amount.toStringAsFixed(2)}',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: type == 'expense'
                      ? Colors.red.shade600
                      : Colors.green.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(
      BuildContext context, Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: Colors.blue.shade600,
                size: 24,
              ),
              title: Text('Edit Transaction'),
              onTap: () {
                Navigator.pop(context);
                onEditTransaction(transaction);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'category',
                color: Colors.orange.shade600,
                size: 24,
              ),
              title: Text('Change Category'),
              onTap: () {
                Navigator.pop(context);
                onCategorizeTransaction(transaction);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: Colors.red.shade600,
                size: 24,
              ),
              title: Text('Delete Transaction'),
              onTap: () {
                Navigator.pop(context);
                onDeleteTransaction(transaction);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return 'restaurant';
      case 'transport':
        return 'directions_car';
      case 'shopping':
        return 'shopping_bag';
      case 'entertainment':
        return 'movie';
      case 'bills':
        return 'receipt';
      case 'health':
        return 'local_hospital';
      case 'income':
        return 'attach_money';
      default:
        return 'category';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
