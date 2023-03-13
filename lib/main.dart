import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/home/itemProvider.dart';
import 'package:sn_pos/login/auth.dart';
import 'package:sn_pos/login/landing_screen.dart';
import 'package:sn_pos/menu.dart';
import 'package:sn_pos/no_internet_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ItemManagement(),
      child: MaterialApp(
          title: 'SN POS',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: FutureBuilder<dynamic>(
              future: isLogin(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
                // print(snapshot.data);
                if (snapshot.data == '404') return const NoInternetScreen();
                if (snapshot.data == '2' || snapshot.data == '3') return const LandingScreen();
                return MenuScreen(initialPage: 0);
              })),
    );
  }

  isLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    var email = pref.getString('email') ?? '';
    var password = pref.getString('password') ?? '';
    var response = await Auth().login(email, password);
    // print(response);
    return response;
  }
}
