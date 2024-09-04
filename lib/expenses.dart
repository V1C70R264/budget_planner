import 'package:budget_planner/models/expense.dart';
import 'package:budget_planner/widgets/expenses_list.dart';
import 'package:budget_planner/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final formatter = NumberFormat("#,##0.00", "en_US");
  final List<double> enteredAmounts = [];
   double balanceRemained  = 0;
  void _obtainExpenseSummary() {
    var depositBalance = double.tryParse(_depositAmountController.text);
    double sumOfAmount = 0;

    for (var i = 0; i < _registeredExpenses.length; i++) {
      enteredAmounts.add(_registeredExpenses[i].amount);
      sumOfAmount += _registeredExpenses[i].amount;
    }
    balanceRemained = depositBalance! - sumOfAmount;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Summary',
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Amount Used: TZS ${formatter.format(sumOfAmount)}/= \nAmount Remained: TZS ${formatter.format(balanceRemained)}/=',
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

  void _openAddExpenseOverlay({Expense? expenseToEdit}) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (ctx) => NewExpense(
              onAddExpense: _addExpense,
              onEditExpense: _editExpense,
              currentBalanceRemained: balanceRemained,
              expenseToEdit: expenseToEdit,
            ));
  }

  void _editExpense(Expense oldExpense, Expense newExpense) {
    setState(() {
      int index = _registeredExpenses.indexOf(oldExpense);
      if (index != -1) {
        double amountDifference = newExpense.amount - oldExpense.amount;
        if (amountDifference <= balanceRemained) {
          _registeredExpenses[index] = newExpense;
          balanceRemained -= amountDifference;
        } else {
          // Show error dialog or snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Insufficient balance for this edit')),
          );
        }
      }
    });
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
                        child: const Text('Okay')),
                  )
                ],
              ));
      return;
    }
    if (_depositAmountController.text.isNotEmpty) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                content: Text(
                  'Deposited Amount: TZS ${formatter.format(double.tryParse(_depositAmountController.text))}/=',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: _resetAmount, child: const Text('Reset Amount')),
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
   void _resetAmount() {
    final formKey = GlobalKey<FormFieldState>();
    bool isValidAmount = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Reset Amount'),
            content: TextFormField(
              key: formKey,
              controller: _depositAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Deposit Amount',
                prefixText: "TZS ",
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                double? amount = double.tryParse(value);
                if (amount == null || amount < balanceRemained) {
                  return 'Amount less than TZS ${formatter.format(balanceRemained)}';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  isValidAmount = formKey.currentState!.validate();
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: isValidAmount
                    ? () {
                        double newAmount = double.tryParse(_depositAmountController.text) ?? 0;
                        this.setState(() {
                          balanceRemained = newAmount;
                        });
                        Navigator.pop(context); // Close the dialog
                        Navigator.pop(context); // Return to the expenses screen
                      }
                    : null,
                child: const Text('Confirm'),
              ),
            ],
          );
        }
      ),
    );
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
          IconButton(
              onPressed: _openAddExpenseOverlay, icon: const Icon(Icons.add))
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: ExpensesList(
            registeredExpenses: _registeredExpenses,
            onRemoveExpense: _removeExpense,
            onEditExpense: _editExpense,
          ))
        ],
      ),
    );
  }
}
