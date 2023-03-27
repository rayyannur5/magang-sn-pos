import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/constants.dart';
// ignore: depend_on_referenced_packages
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../menu.dart';
import '../styles/general_button.dart';
import '../styles/navigator.dart';

class DetailTransactionsScreen extends StatefulWidget {
  DetailTransactionsScreen({super.key, required this.store_id, required this.number_trx, required this.date, required this.customer_trx});
  String store_id;
  String number_trx;
  String customer_trx;
  String date;

  @override
  State<DetailTransactionsScreen> createState() => _DetailTransactionsScreenState();
}

class _DetailTransactionsScreenState extends State<DetailTransactionsScreen> {
  final numberFormat = NumberFormat("#,##0", "en_US");
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  bool isConnect = false;

  @override
  void initState() {
    super.initState();
    getDevice();
  }

  Future getTransaksi() async {
    try {
      var response = await http.post(Uri.parse(Constants.urlDetailTransaksi), body: {'key': Constants.key, 'number_trx': widget.number_trx, 'store_id': widget.store_id});
      return jsonDecode(response.body);
    } catch (e) {
      print(e);
    }
  }

  void setDevice(BluetoothDevice device) async {
    if ((await printer.isConnected)!) {
      await printer.disconnect();
      isConnect = false;
    }
    var pref = await SharedPreferences.getInstance();
    pref.setString('BL_NAME', device.name!);
    pref.setString('BL_ADDRESS', device.address!);
    setState(() {
      selectedDevice = device;
    });
  }

  void getDevice() async {
    bool cek = await printer.isConnected ?? false;
    if (cek) {
      var pref = await SharedPreferences.getInstance();
      String BL_NAME = pref.getString('BL_NAME') ?? '';
      String BL_ADDRESS = pref.getString('BL_ADDRESS') ?? '';
      if (BL_ADDRESS.isNotEmpty) {
        selectedDevice = BluetoothDevice(BL_NAME, BL_ADDRESS);
      }
      setState(() {
        isConnect = true;
      });
    } else {
      var pref = await SharedPreferences.getInstance();
      String BL_NAME = pref.getString('BL_NAME') ?? '';
      String BL_ADDRESS = pref.getString('BL_ADDRESS') ?? '';
      if (BL_ADDRESS.isNotEmpty) {
        selectedDevice = BluetoothDevice(BL_NAME, BL_ADDRESS);
        try {
          await printer.connect(selectedDevice!).then((value) {
            if (value) {
              setState(() {
                isConnect = true;
              });
            }
          });
        } catch (e) {}
      }
    }
    devices = await printer.getBondedDevices();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder<dynamic>(
          future: getTransaksi(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            List dataResponse = snapshot.data;
            dataResponse.sort(((a, b) => a['name'].compareTo(b['name'])));

            String temp = "";
            List dataProses = [];
            List count = [];
            int total = 0;
            for (var i in dataResponse) {
              total += int.parse(i['pay_trolly']);
              if (temp != i['name']) {
                dataProses.add({
                  'name': i['name'],
                  'harga': i['pay_trolly'],
                });
              }
              temp = i['name'];
            }
            for (var i in dataProses) {
              int hitung = 0;
              for (var j in dataResponse) {
                if (j['name'].toString().contains(i['name'])) {
                  hitung++;
                }
              }
              count.add(hitung);
            }
            print(dataProses);
            print(count);
            print(total);
            return Column(
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
                      const Text('Detail Transaksi', style: TextStyle(fontFamily: 'Poppins', fontSize: 25, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                for (int i = 0; i < dataProses.length; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // ignore: prefer_interpolation_to_compose_strings
                          "\u2022  " + dataProses[i]['name'] + ' \u2715 ' + count[i].toString(),
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                        ),
                        Text(
                          '${numberFormat.format(count[i] * int.parse(dataProses[i]['harga']))}',
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w900),
                        )
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: TextStyle(fontFamily: 'Poppins', fontSize: 20)),
                      Text('${numberFormat.format(total)}', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<BluetoothDevice>(
                        hint: Text('Pilih Printer'),
                        value: selectedDevice,
                        items: devices
                            .map((e) => DropdownMenuItem(
                                  child: Text(e.name!),
                                  value: e,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setDevice(value!);
                        },
                      ),
                      !isConnect
                          ? ElevatedButton(
                              onPressed: selectedDevice == null
                                  ? null
                                  : () {
                                      try {
                                        printer.connect(selectedDevice!).then((value) {
                                          if (value) {
                                            setState(() {
                                              isConnect = true;
                                            });
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (c) => const AlertDialog(
                                                      content: Text(
                                                        'Gagal terhubung',
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ));
                                          }
                                        });
                                      } catch (e) {
                                        showDialog(
                                            context: context,
                                            builder: (c) => const AlertDialog(
                                                  content: Text(
                                                    'Gagal terhubung',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ));
                                      }
                                    },
                              style: ButtonStyle(shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5)))),
                              child: Text('Hubungkan'))
                          : ElevatedButton(
                              onPressed: () {
                                printer.disconnect().then((value) {
                                  setState(() {
                                    isConnect = false;
                                  });
                                });
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(Colors.red.shade700), shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5)))),
                              child: Text('Putuskan')),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: SizedBox(
                    width: size.width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: !isConnect
                          ? null
                          : () async {
                              if ((await printer.isConnected)!) {
                                var pref = await SharedPreferences.getInstance();
                                var tanggal = DateFormat('d MMMM y | H:m').format(DateTime.parse(widget.date));
                                final numberFormat = NumberFormat("#,##0", "en_US");

                                print(tanggal);
                                String brand_store = pref.getString('brand_store') ?? '';
                                String address_store = pref.getString('address_store') ?? '';
                                String name_store = pref.getString('name_store') ?? '';
                                String phone_store = pref.getString('phone_store') ?? '';
                                String message_store = pref.getString('message_store') ?? '';
                                String name = pref.getString('name') ?? '';

                                final ByteData logoBytes = await rootBundle.load('assets/image/logo-print.png');
                                final ByteData textBytes = await rootBundle.load('assets/image/text-print.png');

                                final Uint8List logo = logoBytes.buffer.asUint8List(logoBytes.offsetInBytes, logoBytes.lengthInBytes);
                                final Uint8List text = textBytes.buffer.asUint8List(textBytes.offsetInBytes, textBytes.lengthInBytes);

                                printer.printImageBytes(logo);
                                printer.printImageBytes(text);
                                printer.printCustom('-- $brand_store --', 1, 1);
                                printer.printCustom('-- $name_store --', 1, 1);
                                printer.printCustom(tanggal, 1, 1);
                                printer.printNewLine();
                                printer.printCustom('Kasir     : $name', 1, 0);
                                printer.printCustom('Pelanggan : ${widget.customer_trx}', 1, 0);
                                printer.printCustom('--------------------------------', 1, 1);
                                for (int i = 0; i < dataProses.length; i++) {
                                  String namaProduk = '${count[i]}x ${dataProses[i]['name']}';
                                  if (namaProduk.length < 21) {
                                    for (int i = namaProduk.length; i < 21; i++) {
                                      namaProduk += ' ';
                                    }
                                  } else if (namaProduk.length > 21) {
                                    namaProduk = namaProduk.substring(0, 21);
                                  }
                                  String harga = numberFormat.format(count[i] * int.parse(dataProses[i]['harga'])).toString();
                                  String space = '';
                                  if (harga.length == 4) {
                                    space = '      ';
                                  } else if (harga.length == 5) {
                                    space = '     ';
                                  } else if (harga.length == 6) {
                                    space = '    ';
                                  } else if (harga.length == 7) {
                                    space = '   ';
                                  } else if (harga.length == 8) {
                                    space = '   ';
                                  }
                                  printer.printCustom('$namaProduk$space$harga', 1, 0);
                                }
                                printer.printCustom('--------------------------------', 1, 1);
                                printer.printCustom('TOTAL', 2, 1);
                                printer.printCustom(numberFormat.format(total).toString(), 2, 1);
                                printer.printCustom('--------------------------------', 1, 1);
                                printer.printCustom(message_store, 1, 1);
                                printer.printCustom(address_store, 1, 1);
                                printer.printCustom(phone_store, 1, 1);
                                printer.printNewLine();
                                printer.printCustom(widget.number_trx, 1, 1);
                                printer.printNewLine();
                                printer.printNewLine();
                              }
                            },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(width: 1), borderRadius: BorderRadius.circular(15.0))),
                      ),
                      child: const Text('Cetak Transaksi', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.black)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(size.width / 15, 20, size.width / 15, size.height / 20),
                  child: GeneralButton(
                      onTap: () {
                        Nav.pop(context);
                      },
                      text: 'Kembali'),
                )
              ],
            );
          }),
    );
  }
}
