import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/home/itemProvider.dart';
import 'package:sn_pos/styles/general_button.dart';
import 'package:geolocator/geolocator.dart';

import '../menu.dart';
import '../no_internet_screen.dart';
import '../styles/navigator.dart';
import 'absen.dart';

class SendAbsenScreen extends StatefulWidget {
  const SendAbsenScreen({super.key, required this.imagePath, required this.imageName, required this.position});
  final String imagePath;
  final String imageName;
  final Position position;

  @override
  State<SendAbsenScreen> createState() => _SendAbsenScreenState();
}

class _SendAbsenScreenState extends State<SendAbsenScreen> {
  int shift = 1;
  String outletTerpilih = "Pilih Outlet";
  List dataOutlet = [];
  double? distance;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder<dynamic>(
          future: Absen().cekAbsenHariIni(),
          builder: (context, cekAbsen) {
            if (!cekAbsen.hasData) return const Center(child: CircularProgressIndicator());
            print(cekAbsen.data);
            if (cekAbsen.data == '404' || cekAbsen.data == 'error') {
              print('masuk sini');
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                  return const NoInternetScreen();
                }), (r) {
                  return false;
                });
              });
            }
            return Column(
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
                      const Text('Absensi', style: TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w700)),
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
                // Center(
                //     child: outletTerpilih != 'Pilih Outlet'
                //         ? Container(
                //             height: 20,
                //             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                //             decoration: BoxDecoration(color: distance! > 50 ? Colors.redAccent : Colors.green, borderRadius: BorderRadius.circular(10)),
                //             child: Text(
                //               distance! > 50 ? 'Diluar Jangkauan' : 'Didalam Jangkauan',
                //               style: const TextStyle(color: Colors.white),
                //             ),
                //           )
                //         : const SizedBox(height: 20)),
                cekAbsen.data != 'SUDAH_ABSEN_MASUK'
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
                        child: const Text('Outlet', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800)),
                      )
                    : const SizedBox(),
                cekAbsen.data != 'SUDAH_ABSEN_MASUK'
                    ? FutureBuilder<dynamic>(
                        future: Absen().getOutlet(),
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
                            dataOutlet = snapshot.data['data'];
                          } catch (e) {
                            dataOutlet = [];
                          }
                          List<String> outlet = [];
                          outlet.add('Pilih Outlet');
                          for (int i = 0; i < dataOutlet.length; i++) {
                            outlet.add(dataOutlet[i]['name_store']);
                          }
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                            child: DropdownButtonFormField(
                              value: outletTerpilih,
                              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
                              items: outlet.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                outletTerpilih = value ?? "Pilih Outlet";
                                for (int i = 0; i < dataOutlet.length; i++) {
                                  if (dataOutlet[i]['name_store'] == outletTerpilih) {
                                    distance = Geolocator.distanceBetween(
                                        widget.position.latitude, widget.position.longitude, double.parse(dataOutlet[i]['lat_store']), double.parse(dataOutlet[i]['long_store']));
                                  }
                                }
                                setState(() {});
                              },
                            ),
                          );
                        })
                    : const SizedBox(),
                cekAbsen.data != 'SUDAH_ABSEN_MASUK'
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
                        child: const Text('Shift', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800)),
                      )
                    : const SizedBox(),
                cekAbsen.data != 'SUDAH_ABSEN_MASUK'
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() {
                                shift = 1;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 50,
                                width: size.width / 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: shift == 1 ? const Color(0xff0077B6) : Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    'Shift 1',
                                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: shift == 1 ? Colors.white : Colors.black, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                shift = 2;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 50,
                                width: size.width / 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: shift == 2 ? const Color(0xff0077B6) : Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    'Shift 2',
                                    style: TextStyle(fontFamily: 'Poppins', color: shift == 2 ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                shift = 3;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 50,
                                width: size.width / 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: shift == 3 ? const Color(0xff0077B6) : Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    'Shift 3',
                                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: shift == 3 ? Colors.white : Colors.black, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: Text('Absen Keluar', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w800))),
                      ),
                const Spacer(),
                Consumer<ItemManagement>(
                  builder: (context, itemManagement, child) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
                    child: GeneralButton(
                        text: 'Kirim',
                        onTap: () async {
                          var pref = await SharedPreferences.getInstance();
                          if (cekAbsen.data != 'SUDAH_ABSEN_MASUK') {
                            if (outletTerpilih == 'Pilih Outlet') {
                              // ignore: use_build_context_synchronously
                              showDialog(
                                  context: context,
                                  builder: (context) => const AlertDialog(
                                      icon: Icon(Icons.warning_amber),
                                      content: Text(
                                        'Pilih Outlet terlebih dahulu',
                                        textAlign: TextAlign.center,
                                      )));
                              return;
                            }
                            // else if (distance! > 50) {
                            //   // ignore: use_build_context_synchronously
                            //   showDialog(
                            //       context: context,
                            //       builder: (context) => const AlertDialog(
                            //           icon: Icon(Icons.warning_amber),
                            //           content: Text(
                            //             'Diluar Jangkauan',
                            //             textAlign: TextAlign.center,
                            //           )));
                            //   return;
                            // }

                            var storeId;
                            for (int i = 0; i < dataOutlet.length; i++) {
                              if (dataOutlet[i]['name_store'] == outletTerpilih) {
                                storeId = dataOutlet[i]['id_store'];
                              }
                            }
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return Dialog(
                                  child: Container(
                                    margin: const EdgeInsets.all(20),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        CircularProgressIndicator(),
                                        Text('Mengirim Absen ', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            pref.setBool('ready_kirim', true);
                            Absen().sendAbsenMasuk(storeId, shift, widget.imageName, widget.position.latitude, widget.position.longitude).then((value) {
                              if (value == '1') {
                                itemManagement.setItems([], 0);
                                Nav.pop(context);
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                                  return const MenuScreen(initialPage: 0);
                                }), (r) {
                                  return false;
                                });
                              }
                            });
                          } else {
                            // Absen().sendFTP(widget.imagePath, context).then((image) {
                            // });
                            pref.setBool('ready_kirim', true);

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return Dialog(
                                  child: Container(
                                    margin: const EdgeInsets.all(20),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        CircularProgressIndicator(),
                                        Text('Mengirim Absen ', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            Absen().sendAbsenKeluar(shift, widget.imageName).then((value) {
                              if (value == 'out***') {
                                itemManagement.setItems([], 0);
                                Nav.pop(context);

                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                                  return const MenuScreen(initialPage: 0);
                                }), (r) {
                                  return false;
                                });
                              }
                            });
                          }
                        }),
                  ),
                ),
                const SizedBox(height: 40)
              ],
            );
          }),
    );
  }
}
