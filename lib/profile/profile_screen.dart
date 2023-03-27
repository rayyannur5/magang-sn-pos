import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/home/itemProvider.dart';
import 'package:sn_pos/login/auth.dart';
import 'package:sn_pos/login/login_screen.dart';
import 'package:sn_pos/menu.dart';
import 'package:sn_pos/profile/change_password_screen.dart';
import 'package:sn_pos/styles/navigator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  getDataPengguna() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List data = [];
    data.add(pref.getString('name'));
    data.add(pref.getString('email'));
    return data;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: const Color(0xffF6F8FE),
        body: Column(
          children: [
            Container(
              height: size.height / 3,
              width: size.width,
              padding: EdgeInsets.all(size.height / 25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xff023C89), Color(0xff0077B6)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: FutureBuilder<dynamic>(
                  future: getDataPengguna(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(snapshot.data[0], style: const TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text(snapshot.data[1], style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    );
                  }),
            ),
            SizedBox(height: size.height / 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                child: InkWell(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  onTap: () => Nav.pushReplacement(context, MenuScreen(initialPage: 3)),
                  child: Container(
                    width: size.width,
                    height: size.height / 20,
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: size.width / 15),
                    child: const Text('Laporan Penjualan', textAlign: TextAlign.start, style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () => Nav.pushReplacement(context, MenuScreen(initialPage: 4)),
                  child: Container(
                    width: size.width,
                    height: size.height / 20,
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: size.width / 15),
                    child: const Text('Laporan Absensi', textAlign: TextAlign.start, style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () => Nav.pushReplacement(context, MenuScreen(initialPage: 5)),
                  child: Container(
                    width: size.width,
                    height: size.height / 20,
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1, color: Colors.grey)),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: size.width / 15),
                    child: const Text('Laporan Setoran', textAlign: TextAlign.start, style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                child: InkWell(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                  onTap: () => Nav.push(context, const UbahPasswordScreen()),
                  child: Container(
                    width: size.width,
                    height: size.height / 20,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: size.width / 15),
                    child: const Text('Ubah Password', textAlign: TextAlign.start, style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              alignment: Alignment.centerRight,
              child: Material(
                elevation: 10,
                color: const Color(0xff0077B6),
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(title: const Text('Yakin logout ?'), actions: [
                        TextButton(onPressed: () => Nav.pop(context), child: const Text('Batal')),
                        Consumer<ItemManagement>(
                          builder: (context, value, child) => TextButton(
                              onPressed: () {
                                value.setItems([], 0);
                                Auth().logout().then((value) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                                      return const LoginScreen();
                                    }), (r) {
                                      return false;
                                    }));
                              },
                              child: const Text('Logout')),
                        ),
                      ]),
                    );
                  },
                  child: SizedBox(
                    height: size.height / 20,
                    width: size.width / 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout, color: Colors.white),
                        Text(
                          'Logout',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
