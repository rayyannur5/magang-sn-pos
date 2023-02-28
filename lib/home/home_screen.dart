import 'package:flutter/material.dart';
import 'package:sn_pos/styles/general_button.dart';

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
            height: (size.height) / 5,
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.fromLTRB(size.width / 15, 0, size.width / 15, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Katalog', style: TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w800)),
                isAbsen
                    ? Material(
                        elevation: 10,
                        color: const Color(0xff03045E),
                        borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.all(10),
                            child: const Icon(Icons.shopping_cart, color: Colors.white),
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
                      cardItem(size, true, 'Tambah Angin Motor', 'Rp 2.500,00'),
                      cardItem(size, false, 'Tambah Angin Mobil', 'Rp 4.000,00'),
                      cardItem(size, true, 'Isi Baru Motor', 'Rp 3.500,00'),
                      cardItem(size, false, 'Isi Baru Mobil', 'Rp 7.000,00'),
                      cardItem(size, true, 'Tambal Ban Motor', 'Rp 10.000,00'),
                      cardItem(size, false, 'Tambal Ban Mobil', 'Rp 15.000,00'),
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

  Container cardItem(Size size, isMotor, title, price) {
    return Container(
      height: 95,
      margin: EdgeInsets.symmetric(vertical: 7.5, horizontal: size.width / 15),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: () {},
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
                        GestureDetector(child: Image.asset('assets/image/icon-min.png', scale: 2)),
                        const SizedBox(width: 10),
                        const Text('1', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
                        const SizedBox(width: 10),
                        Image.asset('assets/image/icon-add.png', scale: 2),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
