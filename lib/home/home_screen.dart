import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sn_pos/home/checkout.dart';
import 'package:sn_pos/home/checkout_screen.dart';
import 'package:sn_pos/styles/general_button.dart';
import 'package:sn_pos/styles/navigator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAbsen = true;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: (size.height) / 6,
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.fromLTRB(size.width / 15, 0, size.width / 15, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Katalog', style: TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w800)),
                isAbsen
                    ? Consumer<ItemManagement>(
                        builder: (context, itemManagement, child) => Material(
                          elevation: 10,
                          color: const Color(0xff03045E),
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            onTap: () {
                              if (itemManagement.getPrice() != 0) Nav.push(context, CheckoutScreen());
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 50,
                              width: itemManagement.getPrice() == 0 ? 50 : 100,
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  itemManagement.getPrice() != 0
                                      ? Text(
                                          itemManagement.getPrice().toString(),
                                          style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                                        )
                                      : const SizedBox(),
                                  const Icon(Icons.shopping_cart, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          SizedBox(
            height: size.height - (size.height / 5),
            // width: size.width,
            child: ListView(
              children: isAbsen
                  ? [
                      cardItem(size, true, 'Tambah Angin Motor', 'Rp 2.500,00', 0),
                      cardItem(size, false, 'Tambah Angin Mobil', 'Rp 4.000,00', 1),
                      cardItem(size, true, 'Isi Baru Motor', 'Rp 3.500,00', 2),
                      cardItem(size, false, 'Isi Baru Mobil', 'Rp 7.000,00', 3),
                      cardItem(size, true, 'Tambal Ban Motor', 'Rp 10.000,00', 4),
                      cardItem(size, false, 'Tambal Ban Mobil', 'Rp 15.000,00', 5),
                      const SizedBox(height: 100),
                    ]
                  : [
                      Image.asset('assets/image/belum-absen.png', scale: 2),
                      const Text('Absen dulu ya...', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w800)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
                        child: GeneralButton(text: 'Absen', onTap: () {}),
                      )
                    ],
            ),
          )
        ],
      ),
    );
  }

  Container cardItem(Size size, isMotor, title, price, index) {
    return Container(
      height: 95,
      margin: EdgeInsets.symmetric(vertical: 7.5, horizontal: size.width / 15),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(15),
        child: Consumer<ItemManagement>(builder: (context, itemManagement, child) {
          return InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              int dataItem = itemManagement.getItem(index);
              itemManagement.setItem(index, dataItem + 1);
              setState(() {});
              print(title + ' tambah');
            },
            child: Row(
              children: [
                const SizedBox(width: 10),
                Image.asset(isMotor ? 'assets/image/icon-motor.png' : 'assets/image/icon-mobil.png', scale: 2),
                const SizedBox(width: 10),
                SizedBox(
                  // color: Colors.blue,
                  width: (size.width - 70) / 1.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700)),
                      Text(price, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          itemManagement.getItem(index) != 0
                              ? GestureDetector(
                                  onTap: () {
                                    int dataItem = itemManagement.getItem(index);
                                    itemManagement.setItem(index, dataItem - 1);
                                    setState(() {});
                                    print(title + ' kurang');
                                  },
                                  child: Image.asset('assets/image/icon-min.png', scale: 2))
                              : const SizedBox(),
                          const SizedBox(width: 10),
                          itemManagement.getItem(index) != 0
                              ? Text(itemManagement.getItem(index).toString(), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))
                              : const SizedBox(),
                          const SizedBox(width: 10),
                          Image.asset('assets/image/icon-add.png', scale: 2),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}
