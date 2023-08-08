import 'package:flutter/material.dart';
import 'package:sn_pos/absen/absen.dart';
import 'package:sn_pos/profile/camera_screen_tambahan.dart';
import 'package:sn_pos/styles/navigator.dart';

class ReportTambahan extends StatefulWidget {
  const ReportTambahan({super.key});

  @override
  State<ReportTambahan> createState() => _ReportTambahanState();
}

class _ReportTambahanState extends State<ReportTambahan> {
  DateTime begin_date = DateTime.now().subtract(Duration(days: 7));
  DateTime end_date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FutureBuilder<dynamic>(
          future: Absen().cekAbsenHariIni(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.data == "SUDAH_ABSEN_MASUK") {
              return FloatingActionButton(
                onPressed: () => Nav.push(context, CameraScreenTambahan()),
                child: Icon(Icons.add),
              );
            }
            return SizedBox();
          }),
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
                const Text('Laporan Tambahan', style: TextStyle(fontFamily: 'Poppins', fontSize: 25, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width / 15),
            child: GestureDetector(
              onTap: () async {
                try {
                  DateTimeRange? date = await showDateRangePicker(context: context, firstDate: DateTime.parse('20200101'), lastDate: DateTime.parse('20300101'));
                  begin_date = date!.start;
                  end_date = date.end;
                  setState(() {});
                } catch (e) {
                  print(e);
                }
              },
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
                    child: Center(child: Text(begin_date.toString().substring(0, 10), style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
                  ),
                  Container(
                    height: 40,
                    width: size.width / 2 - 50,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(child: Text(end_date.toString().substring(0, 10), style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
