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
import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/models.dart';
import 'package:blue_print_pos/receipt/receipt.dart';

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

  final BluePrintPos _bluePrintPos = BluePrintPos.instance;
  List<BlueDevice> _blueDevices = <BlueDevice>[];
  BlueDevice? _selectedDevice;

  Future getDevice() async {
    return await _bluePrintPos.scan();
  }

  void pilihPrinter() {
    _bluePrintPos.disconnect();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, refresh) => Dialog(
                child: Container(
                  height: 400,
                  child: FutureBuilder<dynamic>(
                      future: getDevice(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        _blueDevices = snapshot.data;
                        return Column(
                          children: [
                            SizedBox(
                              height: 350,
                              child: ListView(
                                  children: List<Widget>.generate(
                                _blueDevices.length,
                                (index) => ListTile(
                                  onTap: () {
                                    _selectedDevice = _blueDevices[index];
                                    _bluePrintPos.connect(_selectedDevice!).then((value) {
                                      if (value == ConnectionStatus.connected) {
                                        Nav.pop(context);
                                        setState(() {});
                                      }
                                      ;
                                    });
                                  },
                                  title: Text(_blueDevices[index].name),
                                  subtitle: Text(_blueDevices[index].address),
                                ),
                              )),
                            ),
                            SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.search),
                                    onPressed: () {
                                      refresh(() {});
                                    },
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        Nav.pop(context);
                                        setState(() {});
                                      },
                                      child: Text('Batal')),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ),
            ));
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
                  ElevatedButton(onPressed: pilihPrinter, child: Text('Pilih Printer')),
                  Text(_selectedDevice == null ? 'Pilih Printer' : _selectedDevice!.name),
                  ElevatedButton(
                      onPressed: !_bluePrintPos.isConnected
                          ? null
                          : () {
                              _bluePrintPos.disconnect();
                              setState(() {});
                            },
                      style: ButtonStyle(backgroundColor: _bluePrintPos.isConnected ? MaterialStatePropertyAll(Colors.red) : MaterialStatePropertyAll(Colors.grey.shade200)),
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
                  onPressed: !_bluePrintPos.isConnected
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

                          // final ByteData logoBytes = await rootBundle.load(
                          //   'assets/image/logo-print.png',
                          // );
                          // final ByteData textBytes = await rootBundle.load(
                          //   'assets/image/text-print.png',
                          // );

                          // final Uint8List logo = logoBytes.buffer.asUint8List(logoBytes.offsetInBytes, logoBytes.lengthInBytes);
                          // final Uint8List text = textBytes.buffer.asUint8List(textBytes.offsetInBytes, textBytes.lengthInBytes);

                          // printer.printImageBytes(logo);
                          // printer.printImageBytes(text);
                          // printer.printCustom('-- $brand_store --', 1, 1);
                          // printer.printCustom('-- $name_store --', 1, 1);
                          // printer.printCustom(tanggal, 1, 1);
                          // printer.printNewLine();
                          // printer.printCustom('Kasir     : $name', 1, 0);
                          // printer.printCustom('Pelanggan : -', 1, 0);
                          // printer.printCustom('--------------------------------', 1, 1);
                          // for (var i in itemManagement.getItemsSelected()) {
                          //   String namaProduk = '${i['count']}x ${i['name']}';
                          //   if (namaProduk.length < 21) {
                          //     for (int i = namaProduk.length; i < 21; i++) {
                          //       namaProduk += ' ';
                          //     }
                          //     print(namaProduk);
                          //   } else if (namaProduk.length > 21) {
                          //     namaProduk = namaProduk.substring(0, 21);
                          //   }
                          //   String harga = numberFormat.format(i['price']);
                          //   String space = '';
                          //   if (harga.length == 4) {
                          //     space = '      ';
                          //   } else if (harga.length == 5) {
                          //     space = '     ';
                          //   } else if (harga.length == 6) {
                          //     space = '    ';
                          //   } else if (harga.length == 7) {
                          //     space = '   ';
                          //   } else if (harga.length == 8) {
                          //     space = '   ';
                          //   }
                          //   printer.printCustom('$namaProduk$space$harga', 1, 0);
                          // }
                          // printer.printCustom('--------------------------------', 1, 1);

                          // printer.printCustom('TOTAL', 2, 1);
                          // printer.printCustom(numberFormat.format(itemManagement.getPrice()).toString(), 2, 1);
                          // printer.printCustom('--------------------------------', 1, 1);
                          // printer.printCustom(message_store, 1, 1);
                          // printer.printCustom(address_store, 1, 1);
                          // printer.printCustom(phone_store, 1, 1);
                          // printer.printNewLine();
                          // printer.printCustom(widget.id, 1, 1);
                          // printer.printNewLine();
                          // printer.printNewLine();

                          final ByteData logoBytes = await rootBundle.load('assets/image/logo-print.png');
                          final ByteData textBytes = await rootBundle.load('assets/image/text-print.png');

                          final ReceiptSectionText receiptText = ReceiptSectionText();
                          receiptText.addImage(
                            base64.encode(Uint8List.view(logoBytes.buffer)),
                            width: 100,
                          );
                          receiptText.addImage(
                            base64.encode(Uint8List.view(textBytes.buffer)),
                            width: 200,
                          );

                          receiptText.addText('-- $brand_store --', size: ReceiptTextSizeType.small);
                          receiptText.addText('-- $name_store --', size: ReceiptTextSizeType.small);
                          receiptText.addSpacer();
                          receiptText.addText('Kasir     : $name', alignment: ReceiptAlignment.left, size: ReceiptTextSizeType.small);
                          receiptText.addText('Pelanggan : -', alignment: ReceiptAlignment.left, size: ReceiptTextSizeType.small);
                          receiptText.addSpacer(useDashed: true);
                          for (var i in itemManagement.getItemsSelected()) {
                            String namaProduk = '${i['count']}x ${i['name']}';
                            String harga = numberFormat.format(i['price']);

                            receiptText.addLeftRightText(namaProduk, harga, leftSize: ReceiptTextSizeType.small, rightSize: ReceiptTextSizeType.small);
                          }
                          receiptText.addSpacer(useDashed: true);
                          receiptText.addText('TOTAL');
                          receiptText.addText(numberFormat.format(itemManagement.getPrice()).toString());
                          receiptText.addSpacer(useDashed: true);
                          receiptText.addText(message_store, size: ReceiptTextSizeType.small);
                          receiptText.addText(address_store, size: ReceiptTextSizeType.small);
                          receiptText.addSpacer();
                          receiptText.addText(widget.id, size: ReceiptTextSizeType.small);
                          receiptText.addSpacer();
                          receiptText.addSpacer();

                          await _bluePrintPos.printReceiptText(receiptText);
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
