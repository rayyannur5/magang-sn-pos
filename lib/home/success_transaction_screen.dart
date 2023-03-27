// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/home/itemProvider.dart';
import 'package:sn_pos/menu.dart';
import 'package:sn_pos/styles/general_button.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

import '../styles/navigator.dart';

class SuccessTransactionScreen extends StatefulWidget {
  const SuccessTransactionScreen({super.key, required this.cash, required this.date, required this.id});
  final int cash;
  final DateTime date;
  final String id;
  @override
  State<SuccessTransactionScreen> createState() => _SuccessTransactionScreenState();
}

class _SuccessTransactionScreenState extends State<SuccessTransactionScreen> {
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Consumer<ItemManagement>(
        builder: (context, itemManagement, child) => Column(
          children: [
            Container(
              height: size.height / 2.4,
              width: size.width,
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xff023C89), Color(0xff0077B6)]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(size.width / 2), bottomRight: Radius.circular(size.width / 2)),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  const Text(
                    'Transaksi Sukses',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/image/icon-success.png',
                    scale: 2,
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.height / 3.3,
              child: ListView(children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: Row(
                    children: const [
                      Text('Item', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                for (var i in itemManagement.getItemsSelected())
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // ignore: prefer_interpolation_to_compose_strings
                          "\u2022  " + i['name'] + ' \u2715 ' + i['count'].toString(),
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                        ),
                        Text(
                          // ignore: prefer_interpolation_to_compose_strings
                          numberFormat.format(i['price']).toString(),
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w900),
                        )
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                      Text('${numberFormat.format(itemManagement.getPrice())}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600))
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tunai/Cash', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                      Text('${numberFormat.format(widget.cash)}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600))
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kembalian', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                      Text('${numberFormat.format(widget.cash - itemManagement.getPrice())}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600))
                    ],
                  ),
                ),
              ]),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: size.width / 2,
                    child: DropdownButton<BluetoothDevice>(
                      hint: Text('Pilih Printer'),
                      isExpanded: true,
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: SizedBox(
                width: size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: !isConnect
                      ? null
                      : () async {
                          var pref = await SharedPreferences.getInstance();
                          var tanggal = DateFormat('d MMMM y | H:m').format(widget.date);
                          final numberFormat = NumberFormat("#,##0", "en_US");

                          print(tanggal);
                          String brand_store = pref.getString('brand_store') ?? '';
                          String address_store = pref.getString('address_store') ?? '';
                          String name_store = pref.getString('name_store') ?? '';
                          String phone_store = pref.getString('phone_store') ?? '';
                          String message_store = pref.getString('message_store') ?? '';
                          String name = pref.getString('name') ?? '';

                          final ByteData logoBytes = await rootBundle.load(
                            'assets/image/logo-print.png',
                          );
                          final ByteData textBytes = await rootBundle.load(
                            'assets/image/text-print.png',
                          );

                          final Uint8List logo = logoBytes.buffer.asUint8List(logoBytes.offsetInBytes, logoBytes.lengthInBytes);
                          final Uint8List text = textBytes.buffer.asUint8List(textBytes.offsetInBytes, textBytes.lengthInBytes);

                          printer.printImageBytes(logo);
                          printer.printImageBytes(text);
                          printer.printCustom('-- $brand_store --', 1, 1);
                          printer.printCustom('-- $name_store --', 1, 1);
                          printer.printCustom(tanggal, 1, 1);
                          printer.printNewLine();
                          printer.printCustom('Kasir     : $name', 1, 0);
                          printer.printCustom('Pelanggan : -', 1, 0);
                          printer.printCustom('--------------------------------', 1, 1);
                          for (var i in itemManagement.getItemsSelected()) {
                            String namaProduk = '${i['count']}x ${i['name']}';
                            if (namaProduk.length < 21) {
                              for (int i = namaProduk.length; i < 21; i++) {
                                namaProduk += ' ';
                              }
                              print(namaProduk);
                            } else if (namaProduk.length > 21) {
                              namaProduk = namaProduk.substring(0, 21);
                            }
                            String harga = numberFormat.format(i['price']);
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
                          printer.printCustom(numberFormat.format(itemManagement.getPrice()).toString(), 2, 1);
                          printer.printCustom('--------------------------------', 1, 1);
                          printer.printCustom(message_store, 1, 1);
                          printer.printCustom(address_store, 1, 1);
                          printer.printCustom(phone_store, 1, 1);
                          printer.printNewLine();
                          printer.printCustom(widget.id, 1, 1);
                          printer.printNewLine();
                          printer.printNewLine();
                        },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(side: const BorderSide(width: 1, color: Color(0xff0077B6)), borderRadius: BorderRadius.circular(15.0))),
                  ),
                  child: const Text('Cetak Transaksi', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.black)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(size.width / 15, 20, size.width / 15, size.height / 20),
              child: GeneralButton(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                      itemManagement.reset();
                      return MenuScreen(initialPage: 0);
                    }), (r) {
                      return false;
                    });
                  },
                  text: 'Kembali'),
            )
          ],
        ),
      ),
    );
  }
}
