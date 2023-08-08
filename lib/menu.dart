import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sn_pos/absen/absen.dart';
import 'package:sn_pos/absen/absen_screen.dart';
import 'package:sn_pos/home/home_screen.dart';
import 'package:sn_pos/profile/laporan_absensi_screen.dart';
import 'package:sn_pos/profile/laporan_penjualan_screen.dart';
import 'package:sn_pos/profile/laporan_setoran_screen.dart';
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
    const LaporanPenjualanScreen(),
    const LaporanAbsensiScreen(),
    LaporanSetoranScreen(),
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
                        TextButton(onPressed: () => exit(0), child: const Row(children: [Icon(Icons.check, color: Colors.red), Text('Keluar', style: TextStyle(color: Colors.red))])),
                        TextButton(onPressed: () => Nav.pop(context), child: const Row(children: [Icon(Icons.close), Text('Batal')]))
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
            Absen().cekApakahAdaTransaksi().then(
              (value) {
                if (value == 0) {
                  setState(() {
                    currentScreen = const AbsenScreen();
                    currentTab = 1;
                  });
                } else {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                    return const MenuScreen(initialPage: 0);
                  }), (r) {
                    return false;
                  });
                }
              },
            );
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
                    Absen().cekApakahAdaTransaksi().then(
                      (value) {
                        if (value == 0) {
                          setState(() {
                            currentScreen = const ProfileScreen();
                            currentTab = 2;
                          });
                        } else {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                            return const MenuScreen(initialPage: 0);
                          }), (r) {
                            return false;
                          });
                        }
                      },
                    );
                  },
                  icon: Icon(
                    Icons.account_circle_sharp,
                    color: currentTab == 2 ? const Color(0xff03045E) : Colors.grey,
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
