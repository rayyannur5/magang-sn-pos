import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sn_pos/home/itemProvider.dart';
import 'package:sn_pos/menu.dart';
import 'package:sn_pos/styles/general_button.dart';

class SuccessTransactionScreen extends StatefulWidget {
  const SuccessTransactionScreen({super.key, required this.cash});
  final cash;
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: Row(
                children: const [
                  Text('Item', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            for (var i in itemManagement.getItemsSelected())
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // ignore: prefer_interpolation_to_compose_strings
                      "\u2022  " + i['name'] + ' \u2715 ' + i['count'].toString(),
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    ),
                    Text(
                      // ignore: prefer_interpolation_to_compose_strings
                      'Rp ' + i['price'].toString(),
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w900),
                    )
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                  Text('Rp ${itemManagement.getPrice()}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tunai/Cash', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                  Text('Rp ${widget.cash}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kembalian', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                  Text('Rp ${widget.cash - itemManagement.getPrice()}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600))
                ],
              ),
            ),
            const Spacer(),
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
                      return MenuScreen(initialPage: 0);
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
