import 'package:budget_planner/expenses.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MaterialApp(
    home: Expenses(),
  ));
}
