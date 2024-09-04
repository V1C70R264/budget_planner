import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budget_planner/models/expense.dart';

class NewExpense extends StatefulWidget {
  const NewExpense(
      {super.key,
      required this.expenseToEdit,
      required this.onEditExpense,
      required this.onAddExpense,
      required this.currentBalanceRemained});
  final void Function(Expense expense) onAddExpense;
  final void Function(Expense oldExpense, Expense newExpense) onEditExpense;
  final double currentBalanceRemained;
  final Expense? expenseToEdit;
  @override
  State<NewExpense> createState() {
    return _NewExpense();
  }
}

class _NewExpense extends State<NewExpense> {
  final _titleController = TextEditingController();
  // final _amountController = TextEditingController();
  bool isButtonActive = true;
  DateTime? _selectedDate;
  Category _selectedCategory = Category.work;
  final _formKey = GlobalKey<FormState>();

  final formatter = DateFormat.yMd();
  void _showDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: firstDate,
        lastDate: now);
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null ||
        enteredAmount <= 0 ||
        enteredAmount > widget.currentBalanceRemained;
    // if (amountIsInvalid) {
    //   _formKey.currentState!.validate();
    //   setState(() {
    //     isButtonActive = false;
    //   });
    //   return;
    // }
    if (_titleController.text.isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text('Invalid Input'),
                content: const Text(
                    'Please make sure a valid title, amount, date and category was entered'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Okay'))
                ],
              ));
      return;
    }
    // if(currentEnteredAmount! ){
    //   showDialog(context: context, builder: (ctx) =>
    //      AlertDialog(
    //       title: const Text('Error'),
    //       content:const  Text('The amount you entered is greater than the one available in your wallet'),
    //       actions: [
    //         TextButton(onPressed: (){
    //           Navigator.pop(context);
    //         }, child: const Text('Okay'))
    //       ],
    //      ));
    //      return;
    //   }
    // }
    widget.onAddExpense(Expense(
        title: _titleController.text,
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory));

    Navigator.pop(context);
  }

  late TextEditingController _amountController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _amountController = TextEditingController();
    _amountController.addListener(() {
      final isButtonActive = double.tryParse(_amountController.text)! <=
              widget.currentBalanceRemained ||
          _amountController.text.isEmpty;
      setState(() {
        this.isButtonActive = isButtonActive;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // void _saveExpense() {

  // }

  @override
  Widget build(context) {
    return Form(
      key: _formKey,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                maxLength: 50,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                decoration: const InputDecoration(label: Text('Title')),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsedValue = double.tryParse(value ?? '');
                        if (parsedValue == null) {
                         return 'This field is required';
                        }
                        if (parsedValue > widget.currentBalanceRemained) {
                          return 'Insufficient Balance \n(TZS ${widget.currentBalanceRemained}) Remained';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        label: Text('Amount'),
                        prefixText: 'TZS ',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(_selectedDate == null
                            ? 'No Selected Date'
                            : formatter.format(_selectedDate!)),
                        IconButton(
                            onPressed: _showDatePicker,
                            icon: const Icon(Icons.calendar_month))
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  DropdownButton(
                    value: _selectedCategory,
                    items: Category.values
                        .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name.toUpperCase())))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const Spacer(),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: isButtonActive ? _submitExpenseData : null,
                      child: const Text('Save Expense')),
                ],
              ),
            ],
          )),
    );
  }
}
