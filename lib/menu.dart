import 'package:flutter/material.dart';
import 'package:sn_pos/absen/absen_screen.dart';
import 'package:sn_pos/home/home_screen.dart';
import 'package:sn_pos/profile/profile_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int currentTab = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const HomeScreen();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
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
                    currentScreen = const HomeScreen();
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
    );
  }
}
