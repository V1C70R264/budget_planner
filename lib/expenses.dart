import 'package:budget_planner/models/expense.dart';
import 'package:budget_planner/widgets/expenses_list.dart';
import 'package:budget_planner/widgets/new_expense.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});
  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  final _depositAmountController = TextEditingController();
  final List<Expense> _registeredExpenses = [
    // Expense(
    //     title: 'Learning Programming',
    //     amount: 23.45,
    //     date: DateTime.now(),
    //     category: Category.work),
    // Expense(
    //     title: 'Music',
    //     amount: 12.89,
    //     date: DateTime.now(),
    //     category: Category.leisure)
  ];
  void _openAddExpenseOverlay() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (ctx) => NewExpense(
              onAddExpense: _addExpense,
            ));
  }

  final List<double> enteredAmounts = [];

  void _obtainExpenseSummary() {
    var depositBalance = double.tryParse(_depositAmountController.text);
    double sumOfAmount = 0;

    for (var i = 0; i < _registeredExpenses.length; i++) {
      enteredAmounts.add(_registeredExpenses[i].amount);
      sumOfAmount += _registeredExpenses[i].amount;
    }
    final balanceRemained = depositBalance! - sumOfAmount;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Summary',
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Amount Used: TZS ${sumOfAmount.toString()}/= \nAmount Remained: TZS $balanceRemained/=',
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Okay')),
          )
        ],
      ),
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  void _removeExpense(Expense expense) {
    setState(() {
      _registeredExpenses.remove(expense);
    });
  }

  void _depositAmount() {
    if (_depositAmountController.text.isEmpty) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                content: const Text(
                  "Enter Amount ",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextField(
                    controller: _depositAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        label: Text('Deposit Amount'), prefixText: "TZS "),
                  ),
                  Center(
                    child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Okay')),
                  )
                ],
              ));
      return;
    }
    if (_depositAmountController.text.isNotEmpty) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                content: Text('Deposited Amount: TZS ${_depositAmountController.text}/=', textAlign: TextAlign.center,style: const TextStyle(fontWeight: FontWeight.bold),),
                actions: [
                Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed:(){},
                        child: const Text('Reset Amount')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Okay'))
                  ],
                )
                ],
              ));
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(onPressed: _depositAmount, icon: const Icon(Icons.money)),
          IconButton(
              onPressed: _obtainExpenseSummary, icon: const Icon(Icons.wallet)),
          IconButton(onPressed: _openAddExpenseOverlay, icon: const Icon(Icons.add))
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: ExpensesList(
            registeredExpenses: _registeredExpenses,
            onRemoveExpense: _removeExpense,
          ))
        ],
      ),
    );
  }
}
