import 'package:flutter/material.dart';
import 'package:sn_pos/profile/change_password_screen.dart';
import 'package:sn_pos/profile/laporan_absensi_screen.dart';
import 'package:sn_pos/profile/laporan_penjualan_screen.dart';
import 'package:sn_pos/profile/laporan_setoran_screen.dart';
import 'package:sn_pos/styles/navigator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Duwi Putra', style: TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('duwi_put@gmail.com', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: size.height / 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                child: InkWell(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  onTap: () => Nav.push(context, const LaporanPenjualanScreen()),
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
                  onTap: () => Nav.push(context, const LaporanAbsensiScreen()),
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
                  onTap: () => Nav.push(context, const LaporanSetoranScreen()),
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
                  onTap: () {},
                  child: Container(
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
