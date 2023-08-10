// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/constants.dart';
import 'package:sn_pos/home/itemProvider.dart';
import 'package:sn_pos/menu.dart';
import 'package:sn_pos/styles/general_button.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:sn_pos/styles/receipt_widget_pdf.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../FTP.dart';
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
      String blName = pref.getString('BL_NAME') ?? '';
      String blAddress = pref.getString('BL_ADDRESS') ?? '';
      if (blAddress.isNotEmpty) {
        selectedDevice = BluetoothDevice(blName, blAddress);
      }
      setState(() {
        isConnect = true;
      });
    } else {
      var pref = await SharedPreferences.getInstance();
      String blName = pref.getString('BL_NAME') ?? '';
      String blAddress = pref.getString('BL_ADDRESS') ?? '';
      if (blAddress.isNotEmpty) {
        selectedDevice = BluetoothDevice(blName, blAddress);
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
              height: size.height / 3.8,
              child: ListView(children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: const Row(
                    children: [
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
                      Text(numberFormat.format(itemManagement.getPrice()), style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600))
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tunai/Cash', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                      Text(numberFormat.format(widget.cash), style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600))
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kembalian', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
                      Text(numberFormat.format(widget.cash - itemManagement.getPrice()), style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600))
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
                      hint: const Text('Pilih Printer'),
                      isExpanded: true,
                      value: selectedDevice,
                      items: devices
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name!),
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
                          child: const Text('Hubungkan'))
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
                          child: const Text('Putuskan')),
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
                          String brandStore = pref.getString('brand_store') ?? '';
                          String addressStore = pref.getString('address_store') ?? '';
                          String nameStore = pref.getString('name_store') ?? '';
                          String phoneStore = pref.getString('phone_store') ?? '';
                          String messageStore = pref.getString('message_store') ?? '';
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
                          printer.printCustom('-- $brandStore --', 1, 1);
                          printer.printCustom('-- $nameStore --', 1, 1);
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
                          printer.printCustom(messageStore, 1, 1);
                          printer.printCustom(addressStore, 1, 1);
                          printer.printCustom(phoneStore, 1, 1);
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
              padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
              child: ElevatedButton(
                  onPressed: () async {
                    var formKey = GlobalKey<FormState>();
                    var phone = TextEditingController();

                    try {
                      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

                      var res = await http.post(Uri.parse(Constants.urlCheckRecipe), body: {'no_trx': widget.id});
                      if (res.body == '1') {
                        Nav.pop(context);
                        sendToWhatsapp(context, formKey, phone, "https://recipe.mirovtech.id/${widget.id}.pdf");
                      } else {
                        Map data = {};

                        var pref = await SharedPreferences.getInstance();
                        data['tanggal'] = DateFormat('d MMMM y | HH:mm').format(widget.date);

                        final numberFormat = NumberFormat("#,##0", "en_US");

                        data['id_trx'] = widget.id;
                        data['brand_store'] = pref.getString('brand_store') ?? '';
                        data['address_store'] = pref.getString('address_store') ?? '';
                        data['name_store'] = pref.getString('name_store') ?? '';
                        data['phone_store'] = pref.getString('phone_store') ?? '';
                        data['message_store'] = pref.getString('message_store') ?? '';
                        data['name'] = pref.getString('name') ?? '';
                        data['total'] = numberFormat.format(itemManagement.getPrice()).toString();
                        data['data'] = [];
                        for (var i in itemManagement.getItemsSelected()) {
                          data['data'].add({
                            'name': '${i['count']}x ${i['name']}',
                            'harga': numberFormat.format(i['price']),
                          });
                        }

                        final dir = await getTemporaryDirectory();

                        final file = await File('${dir.path}/${widget.id}.pdf').writeAsBytes(await ReceiptWidgetPDF.makePDF(data));

                        var res = await FTP.sendReceiptFTP(file);
                        if (res['success']) {
                          await http.post(Uri.parse(Constants.urlCreateRecipe), body: {'no_trx': widget.id});
                          Nav.pop(context);
                          sendToWhatsapp(context, formKey, phone, res['link']);
                        } else {
                          Nav.pop(context);
                          showDialog(context: context, builder: (context) => const AlertDialog(content: Text('Gagal Upload Gambar')));
                        }
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                  style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll(10),
                    minimumSize: const MaterialStatePropertyAll(Size.fromHeight(50)),
                    backgroundColor: MaterialStateProperty.all(Colors.greenAccent),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
                  ),
                  child: const Text('Bagikan', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.black))),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(size.width / 15, 0, size.width / 15, size.height / 20),
              child: GeneralButton(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                      itemManagement.reset();
                      return const MenuScreen(initialPage: 0);
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

  Future<dynamic> sendToWhatsapp(BuildContext context, GlobalKey<FormState> formKey, TextEditingController phone, String link) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Kolom Tidak Boleh Kosong";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(labelText: 'Nomor Whatsapp', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 10),
              GeneralButton(
                  text: "Kirim",
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      if (phone.text.startsWith('0')) {
                        phone.text = '62${phone.text.substring(1)}';
                      }
                      var url = "whatsapp://send?phone=${phone.text}&text=${Uri.encodeComponent("Klik link berikut untuk melihat nota anda\n\n$link")}";
                      try {
                        launch(url);
                      } catch (e) {
                        //To handle error and display error message
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
