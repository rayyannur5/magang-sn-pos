import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/FTP.dart';
import 'package:sn_pos/absen/absen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sn_pos/profile/report_tambahan.dart';
import 'package:sn_pos/profile/report_tambahan_screen.dart';
import 'package:sn_pos/styles/general_button.dart';

import '../no_internet_screen.dart';
import '../styles/navigator.dart';

class SendReportTambahanScreen extends StatefulWidget {
  const SendReportTambahanScreen({super.key, required this.imagePath, required this.imageName, required this.position});
  final String imagePath;
  final String imageName;
  final Position position;

  @override
  State<SendReportTambahanScreen> createState() => _SendReportTambahanScreenState();
}

class _SendReportTambahanScreenState extends State<SendReportTambahanScreen> {
  int shift = 1;
  String kategoriTerpilih = "Pilih Kategori";
  List dataKategori = [];
  double? distance;
  TextEditingController deskripController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: (size.height) / 8,
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.fromLTRB(size.width / 30, 0, size.width / 15, 10),
          child: Row(
            children: [
              IconButton(
                  onPressed: () => Nav.pop(context),
                  icon: const Icon(
                    Icons.navigate_before,
                    size: 35,
                  )),
              const Text('Laporan Tambahan', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        Expanded(
            child: ListView(
          children: [
            Center(
              child: SizedBox(
                height: size.height / 4,
                width: size.width / 2,
                child: Image.file(File(widget.imagePath)),
              ),
            ),
            // FutureBuilder<dynamic>(
            //   future: getDistance(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return Center(
            //         child: Container(
            //           height: 20,
            //           width: 100,
            //           color: Colors.grey.shade300,
            //         ),
            //       );
            //     }
            //     return Center(
            //       child: Container(
            //         height: 20,
            //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            //         decoration: BoxDecoration(color: distance! > 50 ? Colors.redAccent : Colors.green, borderRadius: BorderRadius.circular(10)),
            //         child: Text(
            //           distance! > 50 ? 'Diluar Jangkauan' : 'Didalam Jangkauan',
            //           style: const TextStyle(color: Colors.white),
            //         ),
            //       ),
            //     );
            //   },
            // ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
              child: const Text('Kategori', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            FutureBuilder<dynamic>(
                future: ReportTambahan.getKategori(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container(width: size.width, height: 45, color: Colors.grey.shade100, margin: EdgeInsets.symmetric(horizontal: size.width / 15));
                  if (snapshot.data == '404') {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                        return const NoInternetScreen();
                      }), (r) {
                        return false;
                      });
                    });
                  }
                  try {
                    dataKategori = snapshot.data['data'];
                  } catch (e) {
                    dataKategori = [];
                  }
                  List<String> kategori = [];
                  kategori.add('Pilih Kategori');
                  for (int i = 0; i < dataKategori.length; i++) {
                    kategori.add(dataKategori[i]['deskrip_kat']);
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                    child: DropdownButtonFormField(
                      value: kategoriTerpilih,
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
                      items: kategori.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          kategoriTerpilih = value!;
                        });
                      },
                    ),
                  );
                }),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
              child: const Text(
                'Deskripsi',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              height: 200,
              child: TextField(
                controller: deskripController,
                maxLines: 3,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
              ),
            ),
          ],
        )),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width / 15),
          child: GeneralButton(
              text: 'Kirim',
              onTap: () async {
                if (kategoriTerpilih == 'Pilih Kategori') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih Kategori Terlebih dahulu')));
                  return;
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [CircularProgressIndicator(), SizedBox(width: 20), Text('Mengirim data')],
                      ),
                    ),
                  ),
                );
                var pref = await SharedPreferences.getInstance();
                await pref.setBool('ready_kirim', true);

                var idKat;
                for (int i = 0; i < dataKategori.length; i++) {
                  if (dataKategori[i]['deskrip_kat'] == kategoriTerpilih) {
                    idKat = dataKategori[i]['id_kat'];
                  }
                }

                var ftp = await FTP.sendReportTambahanFTP(File(widget.imagePath));

                if (ftp) {
                  var result = await ReportTambahan.sendLaporanTambahan(widget.imageName, widget.position.latitude, widget.position.longitude, idKat, deskripController.text);
                  Nav.pop(context);
                  if (result == '1') {
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ReportTambahanScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kirim Laporan Gagal')));
                    return;
                  }
                } else {
                  Nav.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal Unggah Gambar')));
                }
              }),
        ),
        const SizedBox(height: 40)
      ],
    ));
  }

  Future getDistance() async {
    var pref = await SharedPreferences.getInstance();
    var storeId = pref.getString('store_id_active');
    var dataOutlet = await Absen().getOutlet();
    var dataOutletTerpilih;
    List listOutlet = dataOutlet['data'];
    for (var element in listOutlet) {
      if (storeId == element['id_store']) {
        dataOutletTerpilih = element;
      }
    }
    distance = Geolocator.distanceBetween(double.parse(dataOutletTerpilih['lat_store']), double.parse(dataOutletTerpilih['long_store']), widget.position.latitude, widget.position.longitude);
  }
}
