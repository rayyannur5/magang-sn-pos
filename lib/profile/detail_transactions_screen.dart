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
import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/models.dart';
import 'package:blue_print_pos/receipt/receipt.dart';

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

  Future getTransaksi() async {
    try {
      var response = await http.post(Uri.parse(Constants.urlDetailTransaksi), body: {'key': Constants.key, 'number_trx': widget.number_trx, 'store_id': widget.store_id});
      return jsonDecode(response.body);
    } catch (e) {
      print(e);
    }
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
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: SizedBox(
                    width: size.width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: !_bluePrintPos.isConnected
                          ? null
                          : () async {
                              // if ((await printer.isConnected)!) {

                              var pref = await SharedPreferences.getInstance();
                              var tanggal = DateFormat('d MMMM y | H:m').format(DateTime.parse(widget.date));
                              final numberFormat = NumberFormat("#,##0", "en_US");

                              String brand_store = pref.getString('brand_store') ?? '';
                              String address_store = pref.getString('address_store') ?? '';
                              String name_store = pref.getString('name_store') ?? '';
                              String phone_store = pref.getString('phone_store') ?? '';
                              String message_store = pref.getString('message_store') ?? '';
                              String name = pref.getString('name') ?? '';

                              final ByteData logoBytes = await rootBundle.load('assets/image/logo-print.png');
                              final ByteData textBytes = await rootBundle.load('assets/image/text-print.png');

                              /// Example for Print Text
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
                              receiptText.addText('Pelanggan : ${widget.customer_trx}', alignment: ReceiptAlignment.left, size: ReceiptTextSizeType.small);
                              receiptText.addSpacer(useDashed: true);
                              for (int i = 0; i < dataProses.length; i++) {
                                String namaProduk = '${count[i]}x ${dataProses[i]['name']}';
                                String harga = numberFormat.format(count[i] * int.parse(dataProses[i]['harga'])).toString();

                                receiptText.addLeftRightText(namaProduk, harga, leftSize: ReceiptTextSizeType.small, rightSize: ReceiptTextSizeType.small);
                              }
                              receiptText.addSpacer(useDashed: true);
                              receiptText.addText('TOTAL');
                              receiptText.addText(numberFormat.format(total).toString());
                              receiptText.addSpacer(useDashed: true);
                              receiptText.addText(message_store, size: ReceiptTextSizeType.small);
                              receiptText.addText(address_store, size: ReceiptTextSizeType.small);
                              receiptText.addSpacer();
                              receiptText.addText(widget.number_trx, size: ReceiptTextSizeType.small);
                              receiptText.addSpacer();
                              receiptText.addSpacer();

                              await _bluePrintPos.printReceiptText(receiptText);
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
