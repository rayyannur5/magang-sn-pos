import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sn_pos/absen/absen_screen.dart';
import 'package:sn_pos/home/home_screen.dart';
import 'package:sn_pos/profile/profile_screen.dart';
import 'package:sn_pos/styles/navigator.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.initialPage});
  final int initialPage;
  @override
  State<MenuScreen> createState() => _MenuScreenState(initialPage);
}

class _MenuScreenState extends State<MenuScreen> {
  int initialPage;
  int currentTab = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  late Widget currentScreen;

  List screen = [
    HomeScreen(),
    const AbsenScreen(),
    const ProfileScreen(),
  ];

  _MenuScreenState(this.initialPage) {
    currentTab = initialPage;
    currentScreen = screen[initialPage];
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Apakah anda yakin keluar aplikasi ?', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton(onPressed: () {}, child: const Text('Rating')),
                        const Spacer(),
                        TextButton(onPressed: () => exit(0), child: Row(children: const [Icon(Icons.check, color: Colors.red), Text('Keluar', style: TextStyle(color: Colors.red))])),
                        TextButton(onPressed: () => Nav.pop(context), child: Row(children: const [Icon(Icons.close), Text('Batal')]))
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
        return true;
      },
      child: Scaffold(
        body: PageStorage(
          bucket: bucket,
          child: currentScreen,
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 10,
          onPressed: () {
            setState(() {
              currentScreen = const AbsenScreen();
              currentTab = 2;
            });
          },
          backgroundColor: const Color(0xff03045E),
          child: const Icon(Icons.qr_code_scanner),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          elevation: 10,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                SizedBox(width: size.width / 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentScreen = HomeScreen();
                      currentTab = 0;
                    });
                  },
                  icon: Icon(
                    Icons.home_filled,
                    color: currentTab == 0 ? const Color(0xff03045E) : Colors.grey,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentScreen = const ProfileScreen();
                      currentTab = 3;
                    });
                  },
                  icon: Icon(
                    Icons.account_circle_sharp,
                    color: currentTab == 3 ? const Color(0xff03045E) : Colors.grey,
                  ),
                ),
                SizedBox(width: size.width / 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
