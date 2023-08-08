import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:sn_pos/absen/camera_screen.dart';
import 'package:sn_pos/absen/laporan_tutup_shift_screen.dart';
import 'package:sn_pos/styles/navigator.dart';

import '../no_internet_screen.dart';
import 'absen.dart';
import 'laporan_detail_absen.dart';

class AbsenScreen extends StatefulWidget {
  const AbsenScreen({super.key});

  @override
  State<AbsenScreen> createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen> {
  final numberFormat = NumberFormat("#,##0", "en_US");

  DateTime begin_date = DateTime.now();
  DateTime end_date = DateTime.now();

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
          child: const Text('Absensi', style: TextStyle(fontFamily: 'Poppins', fontSize: 30, fontWeight: FontWeight.w800)),
        ),
        FutureBuilder<dynamic>(
            future: Absen().cekAbsenHariIni(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              print(snapshot.data);
              if (snapshot.data == '404') {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NoInternetScreen()));
                });
              }
              return Container(
                height: size.height / 7,
                width: size.width,
                margin: EdgeInsets.symmetric(horizontal: size.width / 15),
                padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: size.width / 25),
                decoration: BoxDecoration(
                  color: const Color(0xffCAF0F8),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Colors.black26)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.data == 'BELUM_ABSEN_MASUK'
                          ? 'Belum Absen Masuk'
                          : snapshot.data == 'SUDAH_ABSEN_MASUK'
                              ? 'Sudah Absen Masuk'
                              : 'Anda Sudah Absen Keluar',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: size.width / 24, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    snapshot.data != 'SUDAH_ABSEN_KELUAR'
                        ? ElevatedButton(
                            onPressed: () => Nav.push(context, const CameraScreen()),
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5))),
                                backgroundColor: MaterialStateProperty.all(const Color(0xff0077B6))),
                            child: Text(
                              snapshot.data == 'BELUM_ABSEN_MASUK'
                                  ? 'Absen Masuk'
                                  : snapshot.data == 'SUDAH_ABSEN_MASUK'
                                      ? 'Absen Keluar'
                                      : 'error',
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ))
                        : ElevatedButton(
                            onPressed: () {
                              Nav.push(context, const LaporanTutupShiftScreen());
                            },
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5))),
                                backgroundColor: MaterialStateProperty.all(const Color(0xff0077B6))),
                            child: const Text('Cetak Laporan')),
                  ],
                ),
              );
            }),
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
              )
            ],
          ),
        ),
        SizedBox(
          height: size.height - (size.height / 6) - (size.height / 7) - (size.height / 8) - 60,
          child: FutureBuilder<dynamic>(
              future: Absen().absensiReport(begin_date, end_date),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                List hasilAbsensi = snapshot.data;
                return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: hasilAbsensi.isNotEmpty
                        ? ListView.builder(
                            itemCount: hasilAbsensi.length,
                            itemBuilder: (context, index) => cardLaporanAbsensi(size, hasilAbsensi[index]),
                          )
                        : ListView(
                            children: [Image.asset('assets/image/no-data.png')],
                          ));
              }),
        )
      ],
    ));
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
