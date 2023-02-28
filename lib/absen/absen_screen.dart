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
          height: (size.height) / 5,
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
                  onPressed: () => Nav.push(context, CameraScreen()),
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
        Container(
          height: size.height - (size.height / 8) - ((size.height) / 5),
          child: ListView(
            children: [
              cardAbsen(size),
              cardAbsen(size),
              cardAbsen(size),
              cardAbsen(size),
              cardAbsen(size),
              const SizedBox(height: 300),
            ],
          ),
        )
      ],
    ));
  }

  Container cardAbsen(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 5),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Colors.black26)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Tanggulangin', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700)),
                Text('Masuk : 06.43\nKeluar : 16.43', style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 30,
                      width: 50,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 20),
                    Container(
                      height: 30,
                      width: 50,
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 30,
                  width: 120,
                  color: Colors.amber,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
