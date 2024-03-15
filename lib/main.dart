import 'package:flutter/material.dart';
import 'package:shopping_list/constants/theme.dart';
import 'package:shopping_list/widgets/grocery_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Groceries',
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const GroceryList());
  }
}
