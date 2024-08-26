import 'package:budget_planner/models/expense.dart';
import 'package:budget_planner/widgets/expense_item.dart';
import 'package:flutter/material.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList(
      {super.key,
      required this.registeredExpenses,
      required this.onRemoveExpense});
  final List<Expense> registeredExpenses;
  final void Function(Expense expense) onRemoveExpense;
  @override
  Widget build(context) {
    return ListView.builder(
        itemCount: registeredExpenses.length,
        itemBuilder: (ctx, index) => Dismissible(
            key: ValueKey(registeredExpenses[index]),
            onDismissed: (direction) {
              onRemoveExpense(registeredExpenses[index]);
            },
            child: ExpenseItem(registeredExpenses[index])));
  }
}
