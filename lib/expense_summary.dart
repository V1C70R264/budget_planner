import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budget_planner/models/expense.dart';

class ExpenseSummary extends StatelessWidget {
  final List<Expense> expenses;
  final double depositedAmount;
  final double remainingBalance;

  const ExpenseSummary({
    required this.expenses,
    required this.depositedAmount,
    required this.remainingBalance,
  });

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _calculateCategoryTotals();

    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Summary'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAmountCard(),
            SizedBox(height: 20),
            _buildPieChart(categoryTotals),
            SizedBox(height: 20),
            _buildCategoryList(categoryTotals),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Amount Deposited: \$${depositedAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Remaining Balance: \$${remainingBalance.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<Category, double> categoryTotals) {
    return Container(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: categoryTotals.entries.map((entry) {
            return PieChartSectionData(
              color: _getCategoryColor(entry.key),
              value: entry.value,
              title: '${entry.key.toString().split('.').last}\n${entry.value.toStringAsFixed(2)}',
              radius: 100,
              titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
          sectionsSpace: 0,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildCategoryList(Map<Category, double> categoryTotals) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: categoryTotals.length,
      itemBuilder: (context, index) {
        final category = categoryTotals.keys.elementAt(index);
        final amount = categoryTotals[category]!;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getCategoryColor(category),
          ),
          title: Text(category.toString().split('.').last),
          trailing: Text('\$${amount.toStringAsFixed(2)}'),
        );
      },
    );
  }

  Map<Category, double> _calculateCategoryTotals() {
    final totals = <Category, double>{};
    for (var expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  Color _getCategoryColor(Category category) {
    switch (category) {
      case Category.food:
        return Colors.red;
      case Category.travel:
        return Colors.blue;
      case Category.leisure:
        return Colors.green;
      case Category.work:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}