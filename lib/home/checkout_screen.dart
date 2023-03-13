import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sn_pos/home/itemProvider.dart';
import 'package:sn_pos/home/items.dart';
import 'package:sn_pos/home/success_transaction_screen.dart';
import 'package:sn_pos/styles/general_button.dart';

import '../styles/navigator.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  TextEditingController cash = TextEditingController();
  TextEditingController plat = TextEditingController();
  int inputPrice = 0;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Consumer<ItemManagement>(builder: (context, itemManagement, child) {
        print(itemManagement.getItemsSelected());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: (size.height) / 7,
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.fromLTRB(size.width / 30, 0, size.width / 15, 10),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => Nav.pop(context),
                      icon: const Icon(
                        Icons.navigate_before,
                        size: 25,
                      )),
                  const Text('Checkout', style: TextStyle(fontFamily: 'Poppins', fontSize: 25, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: const Text('Item', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
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
                  const Text('Kembalian', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                  Text('Rp ${(int.tryParse(cash.text) is int ? int.parse(cash.text) : 0) - itemManagement.getPrice()}',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
              child: TextField(
                maxLines: 1,
                controller: cash,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => setState(() {}),
                decoration: const InputDecoration(
                    label: Text(
                  'Cash/Tunai',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                )),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: TextField(
                maxLines: 1,
                controller: plat,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+$'))],
                decoration: const InputDecoration(
                    label: Text(
                  'Plat Kendaraan',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                )),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Material(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      // int hargaSekarang = (int.tryParse(cash.text) is int ? int.parse(cash.text) : 0);
                      int hargaSekarang = 5000;
                      cash.text = hargaSekarang.toString();
                      setState(() {});
                    },
                    child: SizedBox(
                      height: 50,
                      width: size.width / 2.5,
                      // color: Colors.amber,
                      child: const Center(
                          child: Text(
                        '5.000',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w900),
                      )),
                    ),
                  ),
                ),
                Material(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      int hargaSekarang = 10000;
                      cash.text = hargaSekarang.toString();
                      setState(() {});
                    },
                    child: SizedBox(
                      height: 50,
                      width: size.width / 2.5,
                      // color: Colors.amber,
                      child: const Center(
                          child: Text(
                        '10.000',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w900),
                      )),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Material(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      int hargaSekarang = 50000;
                      cash.text = hargaSekarang.toString();
                      setState(() {});
                    },
                    child: SizedBox(
                      height: 50,
                      width: size.width / 2.5,
                      // color: Colors.amber,
                      child: const Center(
                          child: Text(
                        '50.000',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w900),
                      )),
                    ),
                  ),
                ),
                Material(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      int hargaSekarang = 100000;
                      cash.text = hargaSekarang.toString();
                      setState(() {});
                    },
                    child: SizedBox(
                      height: 50,
                      width: size.width / 2.5,
                      // color: Colors.amber,
                      child: const Center(
                          child: Text(
                        '100.000',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w900),
                      )),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: size.height / 20),
              child: GeneralButton(
                  onTap: () {
                    if ((int.tryParse(cash.text) is int ? int.parse(cash.text) : 0) - itemManagement.getPrice() < 0) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                              child: Container(
                            margin: const EdgeInsets.all(20),
                            child: const Text('Uang cash masih kurang', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w800)),
                          ));
                        },
                      );
                      return;
                    }
                    if (plat.text == "") {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                              child: Container(
                            margin: const EdgeInsets.all(20),
                            child: const Text('Kolom Nomor Plat masih kosong', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w800)),
                          ));
                        },
                      );
                      return;
                    }
                    Item().bayar(itemManagement.getItemsSelected());
                    Nav.push(context, SuccessTransactionScreen(cash: cash.text));
                  },
                  text: 'Bayar'),
            )
          ],
        );
      }),
    );
  }
}
