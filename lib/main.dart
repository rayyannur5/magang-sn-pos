import 'package:flutter/material.dart';
import 'package:sn_pos/home/home_screen.dart';
import 'package:sn_pos/login/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SN POS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLogin() ? const HomeScreen() : const LoginScreen(),
    );
  }

  bool isLogin() {
    return true;
  }
}
