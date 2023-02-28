import 'package:flutter/material.dart';
import 'package:sn_pos/login/login_screen.dart';
import 'package:sn_pos/styles/general_button.dart';
import 'package:sn_pos/styles/navigator.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height / 2.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff0077B6), Color(0xff03045E)]),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(50),
                bottomLeft: Radius.circular(50),
              ),
            ),
          ),
          Container(
            width: size.width,
            margin: EdgeInsets.fromLTRB(0, size.height / 3.2, 0, size.height / 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/image/icon_landing.png', scale: 2),
                const SizedBox(height: 10),
                const Text('SN POS', style: TextStyle(fontFamily: 'Ubuntu', fontSize: 48)),
                const SizedBox(height: 10),
                const Text('Aplikasi Kasir dan Absensi Karyawan', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: GeneralButton(text: 'Lanjutkan', onTap: () => Nav.push(context, const LoginScreen())),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
