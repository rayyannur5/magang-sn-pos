import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jpeg_encode/jpeg_encode.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/FTP.dart';
import 'package:sn_pos/constants.dart';
// ignore: depend_on_referenced_packages
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles/general_button.dart';
import '../styles/navigator.dart';
import '../styles/receipt_widget.dart';

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

  final ScreenshotController _screenshotController = ScreenshotController();

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
                          numberFormat.format(count[i] * int.parse(dataProses[i]['harga'])),
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
                      const Text('Total', style: TextStyle(fontFamily: 'Poppins', fontSize: 20)),
                      Text(numberFormat.format(total), style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700)),
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
                        hint: const Text('Pilih Printer'),
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
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
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
                                String brandStore = pref.getString('brand_store') ?? '';
                                String addressStore = pref.getString('address_store') ?? '';
                                String nameStore = pref.getString('name_store') ?? '';
                                String phoneStore = pref.getString('phone_store') ?? '';
                                String messageStore = pref.getString('message_store') ?? '';
                                String name = pref.getString('name') ?? '';

                                final ByteData logoBytes = await rootBundle.load('assets/image/logo-print.png');
                                final ByteData textBytes = await rootBundle.load('assets/image/text-print.png');

                                final Uint8List logo = logoBytes.buffer.asUint8List(logoBytes.offsetInBytes, logoBytes.lengthInBytes);
                                final Uint8List text = textBytes.buffer.asUint8List(textBytes.offsetInBytes, textBytes.lengthInBytes);

                                printer.printImageBytes(logo);
                                printer.printImageBytes(text);
                                printer.printCustom('-- $brandStore --', 1, 1);
                                printer.printCustom('-- $nameStore --', 1, 1);
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
                                printer.printCustom(messageStore, 1, 1);
                                printer.printCustom(addressStore, 1, 1);
                                printer.printCustom(phoneStore, 1, 1);
                                printer.printNewLine();
                                printer.printCustom(widget.number_trx, 1, 1);
                                printer.printNewLine();
                                printer.printNewLine();
                              }
                            },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(side: const BorderSide(width: 1), borderRadius: BorderRadius.circular(15.0))),
                      ),
                      child: const Text('Cetak Transaksi', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, color: Colors.black)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: ElevatedButton(
                      onPressed: () async {
                        var formKey = GlobalKey<FormState>();
                        var phone = TextEditingController();
                        try {
                          showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));

                          var res = await http.post(Uri.parse(Constants.urlCheckRecipe), body: {'no_trx': widget.number_trx});
                          if (res.body == '1') {
                            Nav.pop(context);
                            sendToWhatsapp(context, formKey, phone, "https://recipe.mirovtech.id/${widget.number_trx}.gif");
                          } else {
                            Map data = {};

                            var pref = await SharedPreferences.getInstance();
                            data['tanggal'] = DateFormat('d MMMM y | H:m').format(DateTime.parse(widget.date));
                            final numberFormat = NumberFormat("#,##0", "en_US");

                            data['id_trx'] = widget.number_trx;
                            data['brand_store'] = pref.getString('brand_store') ?? '';
                            data['address_store'] = pref.getString('address_store') ?? '';
                            data['name_store'] = pref.getString('name_store') ?? '';
                            data['phone_store'] = pref.getString('phone_store') ?? '';
                            data['message_store'] = pref.getString('message_store') ?? '';
                            data['name'] = pref.getString('name') ?? '';
                            data['total'] = numberFormat.format(total).toString();
                            data['data'] = [];
                            for (int i = 0; i < dataProses.length; i++) {
                              data['data'].add({
                                'name': '${count[i]}x ${dataProses[i]['name']}',
                                'harga': numberFormat.format(count[i] * int.parse(dataProses[i]['harga'])).toString(),
                              });
                            }

                            var image = await _screenshotController.captureFromLongWidget(receiptWidget(data: data), delay: const Duration(milliseconds: 200));

                            final dir = await getTemporaryDirectory();

                            final codec = await instantiateImageCodec(image);
                            final frame = await codec.getNextFrame();
                            final tes = frame.image;
                            final finalImage = await tes.toByteData(format: ImageByteFormat.rawRgba);
                            final jpg = JpegEncoder().compress(finalImage!.buffer.asUint8List(), tes.width, tes.height, 90);
                            final file = await File('${dir.path}/${widget.number_trx}.jpg').writeAsBytes(jpg);

                            var formKey = GlobalKey<FormState>();
                            var phone = TextEditingController();
                            var res = await FTP.sendReceiptFTP(file);
                            if (res['success']) {
                              await http.post(Uri.parse(Constants.urlCreateRecipe), body: {'no_trx': widget.number_trx});
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
                    padding: EdgeInsets.fromLTRB(size.width / 15, 10, size.width / 15, size.height / 20),
                    child: GeneralButton(
                        onTap: () {
                          Nav.pop(context);
                        },
                        text: 'Kembali'))
              ],
            );
          }),
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
