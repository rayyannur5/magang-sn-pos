import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sn_pos/absen/laporan_detail_absen.dart';
import 'package:sn_pos/menu.dart';
import '../absen/absen.dart';
import '../styles/navigator.dart';

class LaporanAbsensiScreen extends StatefulWidget {
  const LaporanAbsensiScreen({super.key});

  @override
  State<LaporanAbsensiScreen> createState() => _LaporanAbsensiScreenState();
}

class _LaporanAbsensiScreenState extends State<LaporanAbsensiScreen> {
  DateTime begin_date = DateTime.now().subtract(const Duration(days: 7));
  DateTime end_date = DateTime.now();
  List tempHasilAbsen = [];
  int terlambat = 0;
  int tepatwaktu = 0;
  final numberFormat = NumberFormat("#,##0", "en_US");

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder<dynamic>(
          future: Absen().absensiReport(begin_date, end_date),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            List hasilAbsensi = snapshot.data;
            if (tempHasilAbsen != hasilAbsensi) {
              for (int i = 0; i < hasilAbsensi.length; i++) {
                if (hasilAbsensi[i]['description'] == 'Terlambat') {
                  terlambat++;
                } else {
                  tepatwaktu++;
                }
              }
              tempHasilAbsen = hasilAbsensi;
            }
            return Column(
              children: [
                Container(
                  height: (size.height) / 7,
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.fromLTRB(size.width / 30, 0, size.width / 15, 10),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () => Nav.pushReplacement(context, const MenuScreen(initialPage: 2)),
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
                    onTap: () async {
                      try {
                        DateTimeRange? date = await showDateRangePicker(context: context, firstDate: DateTime.parse('20200101'), lastDate: DateTime.parse('20300101'));
                        begin_date = date!.start;
                        end_date = date.end;
                        terlambat = 0;
                        tepatwaktu = 0;
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
                          child: Center(child: Text(begin_date.toString().substring(0, 10), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
                        ),
                        Container(
                          height: 40,
                          width: size.width / 2 - 50,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(child: Text(end_date.toString().substring(0, 10), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
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
                      children: [
                        Text('Tepat waktu    : $tepatwaktu kali', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Terlambat         : $terlambat kali', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height - (size.height / 6) - (size.height / 7) - 100,
                  width: size.width,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                      terlambat = 0;
                      tepatwaktu = 0;
                    },
                    child: hasilAbsensi.isNotEmpty
                        ? ListView.builder(
                            itemCount: hasilAbsensi.length,
                            itemBuilder: (context, index) => cardLaporanAbsensi(size, hasilAbsensi[index]),
                          )
                        : ListView(
                            children: [Image.asset('assets/image/no-data.png')],
                          ),
                  ),
                )
              ],
            );
          }),
    );
  }

  Widget cardLaporanAbsensi(Size size, absensi) {
    return GestureDetector(
      onTap: () {
        DateTime date = DateTime.parse(absensi['created_at']);
        Nav.push(context, LaporanDetailAbsen(date: date));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size.width / 15),
        margin: const EdgeInsets.only(bottom: 15),
        child: Container(
          width: size.width,
          height: 100,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: size.width / 2.3,
                padding: const EdgeInsets.only(left: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(absensi['name_store'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('Masuk : ${absensi['created_at']}\nKeluar : ${absensi['created_at'] == absensi['updated_at'] ? 'BELUM ABSEN' : absensi['updated_at']}',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 10)),
                  ],
                ),
              ),
              Container(
                width: size.width - (size.width / 2.3) - 2 * (size.width / 15),
                padding: EdgeInsets.all(size.width / 35),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 25,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(7.5),
                          ),
                          child: Center(child: Text('Shift ${absensi['shift']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
                        ),
                        absensi['description'] == 'Terlambat'
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                height: 25,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(7.5),
                                ),
                                child: const Center(child: Text('Terlambat', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                height: 25,
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
                      height: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xff0077B6),
                        borderRadius: BorderRadius.circular(7.5),
                      ),
                      child: Center(
                        child: Text(
                          numberFormat.format(absensi['total']),
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
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
