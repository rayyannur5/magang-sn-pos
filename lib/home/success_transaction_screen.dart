import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sn_pos/home/checkout.dart';
import 'package:sn_pos/menu.dart';
import 'package:sn_pos/styles/general_button.dart';

class SuccessTransactionScreen extends StatefulWidget {
  const SuccessTransactionScreen({super.key});

  @override
  State<SuccessTransactionScreen> createState() => _SuccessTransactionScreenState();
}

class _SuccessTransactionScreenState extends State<SuccessTransactionScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Consumer<ItemManagement>(
        builder: (context, itemManagement, child) => Column(
          children: [
            Container(
              height: size.height / 2.4,
              width: size.width,
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff023C89), Color(0xff0077B6)]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(size.width / 2), bottomRight: Radius.circular(size.width / 2)),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  const Text(
                    'Transaksi Sukses',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/image/icon-success.png',
                    scale: 2,
                  )
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: SizedBox(
                width: size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(side: const BorderSide(width: 1, color: Color(0xff0077B6)), borderRadius: BorderRadius.circular(15.0))),
                  ),
                  child: const Text('Cetak Transaksi', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.black)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(size.width / 15, 20, size.width / 15, size.height / 20),
              child: GeneralButton(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                      itemManagement.reset();
                      return MenuScreen();
                    }), (r) {
                      return false;
                    });
                  },
                  text: 'Kembali'),
            )
          ],
        ),
      ),
    );
  }
}
