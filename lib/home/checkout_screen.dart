import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sn_pos/home/checkout.dart';
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
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Consumer<ItemManagement>(builder: (context, itemManagement, child) {
        print(itemManagement.getItems());
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
            for (var i in itemManagement.getItems())
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
                  Text('Rp ' + itemManagement.getPrice().toString(), style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kembalian', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                  Text('Rp ' + ((int.tryParse(cash.text) is int ? int.parse(cash.text) : 0) - itemManagement.getPrice()).toString(),
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
              child: const TextField(
                maxLines: 1,
                decoration: InputDecoration(
                    label: Text(
                  'Plat Kendaraan',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
                )),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: size.height / 20),
              child: GeneralButton(onTap: () => Nav.push(context, const SuccessTransactionScreen()), text: 'Bayar'),
            )
          ],
        );
      }),
    );
  }
}
