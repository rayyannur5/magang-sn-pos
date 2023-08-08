import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/absen/absen.dart';
import 'package:sn_pos/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sn_pos/home/home_screen.dart';
import 'package:sn_pos/styles/general_button.dart';

import '../menu.dart';
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
          height: (size.height) / 6,
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
        Center(
          child: SizedBox(
            height: size.height / 4,
            width: size.width / 2,
            child: Image.file(File(widget.imagePath)),
          ),
        ),
        FutureBuilder<dynamic>(
          future: getDistance(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Container(
                  height: 20,
                  width: 100,
                  color: Colors.grey.shade300,
                ),
              );
            }
            return Center(
              child: Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(color: distance! > 50 ? Colors.redAccent : Colors.green, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  distance! > 50 ? 'Diluar Jangkauan' : 'Didalam Jangkauan',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
          child: const Text('Kategori', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800)),
        ),
        FutureBuilder<dynamic>(
            future: getKategori(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container(width: size.width, height: 45, color: Colors.grey.shade100, margin: EdgeInsets.symmetric(horizontal: size.width / 15));
              if (snapshot.data == '404') {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                    return NoInternetScreen();
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
          child: Text(
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
        const Spacer(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width / 15),
          child: GeneralButton(
              text: 'Kirim',
              onTap: () async {
                if (kategoriTerpilih == 'Pilih Kategori') {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pilih Kategori Terlebih dahulu')));
                  return;
                }

                if (deskripController.text == "") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tulis Deskripsi Terlebih dahulu')));
                  return;
                }

                if (distance != null) {
                  if (distance! >= 40) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tulis Deskripsi Terlebih dahulu')));
                    return;
                  } else {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
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

                    var id_kat;
                    for (int i = 0; i < dataKategori.length; i++) {
                      if (dataKategori[i]['deskrip_kat'] == kategoriTerpilih) {
                        id_kat = dataKategori[i]['id_kat'];
                      }
                    }
                    var result = await sendLaporanTambahan(widget.imageName, widget.position.latitude, widget.position.longitude, id_kat, deskripController.text);
                    Nav.pop(context);
                    if (result == '1') {
                      // ignore: use_build_context_synchronously
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                        return const MenuScreen(initialPage: 0);
                      }), (r) {
                        return false;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kirim Laporan Gagal')));
                      return;
                    }
                  }
                }
              }),
        ),
        const SizedBox(height: 40)
      ],
    ));
  }

  getKategori() async {
    try {
      var pref = await SharedPreferences.getInstance();
      var id_user = pref.get('id_user');
      print(id_user);
      var response = await http.get(Uri.parse('${Constants.urlDataKategori}?key=$id_user'));
      print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      print('tidak ada koneksi internet');
      return '404';
    }
  }

  sendLaporanTambahan(image_in, lat, long, id_kat, deskrip) async {
    try {
      print(image_in);
      print(lat);
      print(long);
      print(id_kat);
      print(deskrip);
      var pref = await SharedPreferences.getInstance();
      String id_user = pref.getString('id_user') ?? "0";
      String shift = pref.getString('shift') ?? "0";
      String store_id = pref.getString('store_id_active') ?? "0";
      String key = Constants.key;
      var response = await http.post(Uri.parse(Constants.urlReportCreate), body: {
        'user_id': id_user,
        'image_in': image_in,
        'shift': shift.toString(),
        'store_id': store_id,
        'id_kategori': id_kat.toString(),
        'deskrip': deskrip,
        'key': key,
        'lat': lat.toString(),
        'long': long.toString(),
      });

      String strResponse = response.body;
      print(response.statusCode);
      // List listResponse = strResponse.split('in***');
      // await pref.setString('store_id_active', store_id);
      // await pref.setString('shift', shift.toString());
      // await pref.setString('name_store', listResponse[0]);
      // await pref.setString('name_store', listResponse[0]);
      // await pref.setString('address_store', listResponse[1]);
      // await pref.setString('phone_store', listResponse[2]);
      // await pref.setString('message_store', listResponse[3]);
      // await pref.setString('brand_store', listResponse[4]);
      // await pref.setBool('ready_kirim', true);
      return '1';
    } catch (e) {
      print(e);
      print('tidak ada koneksi internet');
      return '404';
    }
  }

  Future getDistance() async {
    var pref = await SharedPreferences.getInstance();
    var store_id = pref.getString('store_id_active');
    var dataOutlet = await Absen().getOutlet();
    var dataOutletTerpilih;
    List listOutlet = dataOutlet['data'];
    listOutlet.forEach((element) {
      if (store_id == element['id_store']) {
        dataOutletTerpilih = element;
      }
    });
    distance = Geolocator.distanceBetween(double.parse(dataOutletTerpilih['lat_store']), double.parse(dataOutletTerpilih['long_store']), widget.position.latitude, widget.position.longitude);
  }
}
