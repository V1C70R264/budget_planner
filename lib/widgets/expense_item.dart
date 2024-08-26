import 'package:budget_planner/models/expense.dart';
import 'package:flutter/material.dart';

class ExpenseItem extends StatelessWidget {
  const ExpenseItem(this.expense, {super.key});
  final Expense expense;
  @override
  Widget build(context) {
    return Card(
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(expense.title, style: TextStyle(fontWeight: FontWeight.bold),),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text('TZS ${expense.amount.toStringAsFixed(2)}'),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(categoryIcons[expense.category]),
                      const SizedBox(width: 4,),
                      Text(expense.formattedDate)
                    ],
                  ),
                ],
              )
            ],
          )),
    );
  }
}
