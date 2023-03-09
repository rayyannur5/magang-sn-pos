import 'package:flutter/material.dart';
import 'package:sn_pos/absen/camera_screen.dart';
import 'package:sn_pos/styles/navigator.dart';

class AbsenScreen extends StatelessWidget {
  const AbsenScreen({super.key});

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
          child: const Text('Absensi', style: TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w800)),
        ),
        Container(
          height: size.height / 5,
          width: size.width,
          margin: EdgeInsets.symmetric(horizontal: size.width / 15),
          padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: size.width / 20),
          decoration: BoxDecoration(
            color: const Color(0xffCAF0F8),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Colors.black26)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Anda belum absen hari ini',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              ElevatedButton(
                  onPressed: () => Nav.push(context, const CameraScreen()),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5))), backgroundColor: MaterialStateProperty.all(const Color(0xff0077B6))),
                  child: const Text(
                    'Absen Masuk',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ))
            ],
          ),
        ),
        Container(
          height: size.height / 8,
          width: size.width,
          padding: EdgeInsets.fromLTRB(size.width / 15, size.width / 20, size.width / 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daftar Absensi', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              GestureDetector(
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
              )
            ],
          ),
        ),
        SizedBox(
          height: size.height - (size.height / 8) - ((size.height) / 5),
          child: ListView(
            children: [
              cardLaporanAbsensi(size),
              cardLaporanAbsensi(size),
              cardLaporanAbsensi(size),
              cardLaporanAbsensi(size),
              cardLaporanAbsensi(size),
              const SizedBox(height: 300),
            ],
          ),
        )
      ],
    ));
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
