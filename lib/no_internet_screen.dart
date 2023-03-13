import 'package:flutter/material.dart';
import 'package:sn_pos/login/auth.dart';
import 'package:sn_pos/main.dart';
import 'package:sn_pos/styles/general_button.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    String error = 'Tidak ada koneksi internet';
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 50),
        child: Column(
          children: [
            Image.asset('assets/image/no-internet.png'),
            Text(error, style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w800)),
            const Spacer(),
            GeneralButton(
                text: 'Refresh',
                onTap: () {
                  Auth().login('email', 'password').then((value) {
                    error = value;
                    if (value != '404') {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                        return const MyApp();
                      }), (r) {
                        return false;
                      });
                    }
                  });
                })
          ],
        ),
      ),
    );
  }
}
