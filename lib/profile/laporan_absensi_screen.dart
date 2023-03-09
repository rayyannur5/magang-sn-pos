import 'package:flutter/material.dart';
import '../styles/navigator.dart';

class LaporanAbsensiScreen extends StatelessWidget {
  const LaporanAbsensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
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
                const Text('Laporan Absensi', style: TextStyle(fontFamily: 'Poppins', fontSize: 25, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width / 15),
            child: GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (context) => DateRangePickerDialog(firstDate: DateTime.parse('20200101'), lastDate: DateTime.parse('20300101')),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40,
                    width: size.width / 2 - 50,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(child: Text('06/06/2023', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
                  ),
                  Container(
                    height: 40,
                    width: size.width / 2 - 50,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(child: Text('06/06/2023', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: size.height / 6,
            width: size.width,
            padding: EdgeInsets.fromLTRB(size.width / 15, size.height / 25, size.width / 15, 0),
            child: Container(
              padding: EdgeInsets.all(size.width / 15),
              decoration: BoxDecoration(
                color: const Color(0xff03045E),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Tepat waktu    : 1 kali', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text('Terlambat         : 1 kali', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
          SizedBox(
            height: size.height - (size.height / 6) - (size.height / 7) - 40,
            width: size.width,
            child: ListView(
              children: [
                cardLaporanAbsensi(size),
                cardLaporanAbsensi(size),
                cardLaporanAbsensi(size),
                cardLaporanAbsensi(size),
                cardLaporanAbsensi(size),
              ],
            ),
          )
        ],
      ),
    );
  }

  Container cardLaporanAbsensi(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width / 15),
      margin: const EdgeInsets.only(bottom: 15),
      child: Container(
        width: size.width,
        height: size.height / 12,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: size.width / 2.3,
              padding: EdgeInsets.only(left: size.width / 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Tanggulangin', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('Masuk : 14/02/2023 06.53\nKeluar : 14/02/2023 16.53', style: TextStyle(fontFamily: 'Poppins', fontSize: 10)),
                ],
              ),
            ),
            Container(
              width: size.width - (size.width / 2.3) - 2 * (size.width / 15),
              padding: EdgeInsets.all(size.width / 35),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: size.height / 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(7.5),
                        ),
                        child: const Center(child: Text('Shift 1', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        height: size.height / 40,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(7.5),
                        ),
                        child: const Center(child: Text('Tepat waktu', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: size.height / 40,
                    decoration: BoxDecoration(
                      color: const Color(0xff0077B6),
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                    child: const Center(
                      child: Text(
                        'Rp 6.000,00',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
