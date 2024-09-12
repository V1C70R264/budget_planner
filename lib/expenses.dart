import 'package:budget_planner/expense_summary.dart';
import 'package:budget_planner/models/expense.dart';
import 'package:budget_planner/notification_service.dart';
import 'package:budget_planner/widgets/expenses_list.dart';
import 'package:budget_planner/widgets/new_expense.dart';
import 'package:budget_planner/expense_summary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Expenses extends StatefulWidget {
  const Expenses({super.key});
  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
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
    var depositBalance = double.tryParse(_depositAmountController.text) ?? 0.0;
    double sumOfAmount = 0;

    for (var expense in _registeredExpenses) {
      sumOfAmount += expense.amount;
    }
    balanceRemained = depositBalance - sumOfAmount;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WalletSummaryPortal(
          depositedAmount: depositBalance,
          amountUsed: sumOfAmount,
          balanceRemained: balanceRemained,
        ),
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
           const SnackBar(content: Text('Insufficient balance for this edit')),
          );
        }
      }
    });
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
      balanceRemained -= expense.amount;
    });
    
    // Convert deposited amount to double for comparison
    double depositedAmount = double.tryParse(_depositAmountController.text) ?? 0.0;
    
    // Show a notification when an expense is added
    if (balanceRemained <= depositedAmount / 2) {
      NotificationService().showBalanceNotification(balanceRemained, depositedAmount);
    }
    
    // Or schedule a reminder for tomorrow
    
  }

  void _removeExpense(Expense expense) {
    setState(() {
      _registeredExpenses.remove(expense);
    });
  }

  void _depositAmount() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.all(24),
                  children: [
                    _buildCurrentBalance(),
                    SizedBox(height: 24),
                    _buildDepositInput(),
                    SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: AppColors.onPrimary, size: 30),
            SizedBox(width: 16),
            Text(
              'Deposit Management',
              style: TextStyle(
                color: AppColors.onPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBalance() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'TZS ${formatter.format(double.tryParse(_depositAmountController.text) ?? 0)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositInput() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Deposit Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _depositAmountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 18, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'TZS 0.00',
                prefixIcon: Icon(Icons.attach_money, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _showDepositConfirmation();
          },
          child: Text('Deposit Amount', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: Size(double.infinity, 55),
          ),
        ),
        SizedBox(height: 16),
        OutlinedButton(
          onPressed: _resetAmount,
          child: Text('Reset Amount', style: TextStyle(fontSize: 18)),
          style: OutlinedButton.styleFrom(
            primary: AppColors.error,
            side: BorderSide(color: AppColors.error),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: Size(double.infinity, 55),
          ),
        ),
      ],
    );
  }

  void _showDepositConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Deposit Confirmation'),
        content: Text(
          'Deposited Amount: TZS ${formatter.format(double.tryParse(_depositAmountController.text))}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  void _resetAmount() {
    setState(() {
      _depositAmountController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deposit amount has been reset')),
    );
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    // Add the owner's name here
    const String ownerName = "MONITAFRICA SOLUTIONS COMPANY";

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          double totalDebit = _registeredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
          double totalCredit = double.tryParse(_depositAmountController.text) ?? 0.0;
          double balance = totalCredit - totalDebit;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Expense Receipt', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
              pw.SizedBox(height: 30),
              pw.Text('Credit (Deposit)', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Initial Deposit'),
                  pw.Text('TZS ${formatter.format(totalCredit)}'),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Debit (Expenses)', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              ..._registeredExpenses.map((expense) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(expense.title, style:const pw.TextStyle(fontSize: 16)),
                      pw.Text('TZS ${formatter.format(expense.amount)}', style: const pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                  pw.Text(DateFormat('yyyy-MM-dd HH:mm').format(expense.date), style:const pw.TextStyle(color: PdfColors.grey700, fontSize: 12)),
                  pw.SizedBox(height: 5),
                ],
              )).toList(),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Credit:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('TZS ${formatter.format(totalCredit)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Debit:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('TZS ${formatter.format(totalDebit)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Balance:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('TZS ${formatter.format(balance)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Spacer(), // This will push the following content to the bottom
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Issued by:', style: pw.TextStyle(fontSize: 14)),
                  pw.Text(ownerName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: ownerName,
                  width: 100,
                  height: 100,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text('Scan for owner\'s details', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              ),
            ],
          );
        },
      ),
    );

    // Simulate a download process
    for (int i = 0; i <= 100; i += 10) {
      await NotificationService().showProgressNotification(i);
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate processing time
    }

    // Save the PDF file
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/moneyminder_report.pdf");
    await file.writeAsBytes(await pdf.save());

    // Show completed notification with file path
    await NotificationService().showCompletedNotification(file.path);
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyMinder'),
        actions: [
          IconButton(onPressed: _depositAmount, icon: const Icon(Icons.money)),
          IconButton(onPressed: _obtainExpenseSummary, icon: const Icon(Icons.wallet)),
          IconButton(onPressed: _generatePDF, icon: const Icon(Icons.print)),
          IconButton(onPressed: _openAddExpenseOverlay, icon: const Icon(Icons.add))
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
