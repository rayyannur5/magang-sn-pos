import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/absen/absen.dart';
import 'package:http/http.dart' as http;
import 'package:sn_pos/constants.dart';
import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/models.dart';
import 'package:blue_print_pos/receipt/receipt.dart';

import '../styles/general_button.dart';
import '../styles/navigator.dart';

class LaporanTutupShiftScreen extends StatefulWidget {
  LaporanTutupShiftScreen({super.key});

  @override
  State<LaporanTutupShiftScreen> createState() => _LaporanTutupShiftScreenState();
}

class _LaporanTutupShiftScreenState extends State<LaporanTutupShiftScreen> {
  final numberFormat = NumberFormat("#,##0", "en_US");
  final BluePrintPos _bluePrintPos = BluePrintPos.instance;
  List<BlueDevice> _blueDevices = <BlueDevice>[];
  BlueDevice? _selectedDevice;
  var dataGlobalResponse;

  _LaporanTutupShiftScreenState();

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

  Future dataShift() async {
    List dataAbsen = await Absen().absensiReport(DateTime.now(), DateTime.now());
    print('dataAbsen dapat');
    List dataTransaksi = await getPenjualan();
    print('dataPenjualan dapat');
    List dataTransaksiSemua = [];
    List dataProsesSemua = [];
    for (var i in dataTransaksi) {
      List transaksi = await getTransaksi(i['number_trx'], dataAbsen.last['store_id']);
      transaksi.sort(((a, b) => a['name'].compareTo(b['name'])));
      String temp = "";
      List dataProses = [];
      List count = [];
      // int total = 0;

      // Dapatkan data transaksi
      for (var i in transaksi) {
        // total += int.parse(i['pay_trolly']);
        if (temp != i['name']) {
          dataProses.add({
            'name': i['name'],
            'harga': i['pay_trolly'],
          });
        }
        temp = i['name'];
      }

      // hitung banyak transaksi
      for (var i in dataProses) {
        int hitung = 0;
        for (var j in transaksi) {
          if (j['name'].toString().contains(i['name'])) {
            hitung++;
          }
        }
        count.add(hitung);
      }

      // tambah ke variabel utama
      for (int i = 0; i < dataProses.length; i++) {
        dataTransaksiSemua.add({'name': dataProses[i]['name'], 'harga': dataProses[i]['harga'], 'count': count[i]});
      }
    }
    dataTransaksiSemua.sort(((a, b) => a['name'].compareTo(b['name'])));

    List jumlahTransaksi = [];

    // Dapatkan data transaksi
    String temp = '';
    for (var i in dataTransaksiSemua) {
      if (temp != i['name']) {
        dataProsesSemua.add({'name': i['name'], 'harga': i['harga']});
      }
      temp = i['name'];
    }

    for (var i in dataProsesSemua) {
      int hitung = 0;
      for (var j in dataTransaksiSemua) {
        if (j['name'].toString().contains(i['name'])) {
          hitung += int.parse(j['count'].toString());
        }
      }
      jumlahTransaksi.add(hitung);
    }

    var pref = await SharedPreferences.getInstance();

    var name = pref.getString('name');
    var tabungan = await getSetoran();
    var dataResponse = {
      'name': name,
      'tabungan': tabungan['total_tabungan'],
      'dataAbsen': dataAbsen.last,
      'dataProses': dataProsesSemua,
      'dataJumlah': jumlahTransaksi,
    };

    dataGlobalResponse = dataResponse;

    // if (mounted) {
    //   getDevice();
    // }

    return dataResponse;
  }

  Future getSetoran() async {
    var pref = await SharedPreferences.getInstance();
    var id_user = pref.getString('id_user');

    try {
      var response = await http.get(Uri.parse('${Constants.urlSetoranReport}?id_user=$id_user'));
      var dataResponse = jsonDecode(response.body);
      return dataResponse;
    } catch (e) {
      print(e);
    }
  }

  Future getPenjualan() async {
    var pref = await SharedPreferences.getInstance();
    var id_user = pref.getString('id_user');
    String formattedBeginDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      var response = await http.get(Uri.parse('${Constants.urlPenjualanReport}?user_id=$id_user&key=${Constants.key}&begin_date=$formattedBeginDate&end_date=$formattedEndDate'));
      return jsonDecode(response.body);
    } catch (e) {
      print(e);
      return '404';
    }
  }

  Future getTransaksi(trx, store_id) async {
    try {
      var response = await http.post(Uri.parse(Constants.urlDetailTransaksi), body: {'key': Constants.key, 'number_trx': trx, 'store_id': store_id});
      return jsonDecode(response.body);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
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
                const Text('Laporan Tutup Shift', style: TextStyle(fontFamily: 'Poppins', fontSize: 25, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: size.width / 15),
            height: size.height / 2,
            child: FutureBuilder<dynamic>(
                future: dataShift(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  var response = snapshot.data;

                  print(response);
                  return ListView(
                    children: [
                      Text('Nama                           : ${response['name']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('Outlet                           : ${response['dataAbsen']['name_store']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('Check in                      : ${response['dataAbsen']['created_at']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('Check out                   : ${response['dataAbsen']['updated_at'] == response['dataAbsen']['created_at'] ? 'BELUM ABSEN' : response['dataAbsen']['updated_at']}',
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('Status                           : ${response['dataAbsen']['description']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('Perolehan Omset    : ${numberFormat.format(response['dataAbsen']['total'])}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('Tabungan Awal       : ${numberFormat.format(response['tabungan'])}', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
                      Text('Total Tabungan       : ${numberFormat.format(response['tabungan'] + response['dataAbsen']['total'])}',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(thickness: 10),
                      ),
                      for (int i = 0; i < response['dataProses'].length; i++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${response['dataJumlah'][i]}x  ${response['dataProses'][i]['name']}',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${numberFormat.format(response['dataJumlah'][i] * int.parse(response['dataProses'][i]['harga']))}',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  );
                }),
          ),
          SizedBox(
            height: size.height / 3,
            child: Column(
              children: [
                Spacer(),
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
                          : dataGlobalResponse == null
                              ? null
                              : () async {
                                  // if ((await printer.isConnected)!) {
                                  //   // var pref = await SharedPreferences.getInstance();
                                  //   // var tanggal = DateFormat('d MMMM y | H:m').format(date);
                                  //   // final numberFormat = NumberFormat("#,##0", "en_US");
                                  //   final ByteData logoBytes = await rootBundle.load('assets/image/logo-print.png');
                                  //   final ByteData textBytes = await rootBundle.load('assets/image/text-print.png');

                                  //   final Uint8List logo = logoBytes.buffer.asUint8List(logoBytes.offsetInBytes, logoBytes.lengthInBytes);
                                  //   final Uint8List text = textBytes.buffer.asUint8List(textBytes.offsetInBytes, textBytes.lengthInBytes);

                                  //   printer.printImageBytes(logo);
                                  //   printer.printImageBytes(text);
                                  //   printer.printCustom('Laporan Tutup SHift', 1, 1);
                                  //   printer.printNewLine();
                                  //   printer.printCustom('Kasir     : ${dataGlobalResponse['name']}', 1, 0);
                                  //   printer.printCustom('Outlet    : ${dataGlobalResponse['dataAbsen']['name_store']}', 1, 0);
                                  //   printer.printCustom('--------------------------------', 1, 1);
                                  //   printer.printCustom('Check in  : ${dataGlobalResponse['dataAbsen']['created_at']}', 1, 0);
                                  //   printer.printCustom(
                                  //       'Check out : ${dataGlobalResponse['dataAbsen']['updated_at'] == dataGlobalResponse['dataAbsen']['created_at'] ? 'BELUM ABSEN' : dataGlobalResponse['dataAbsen']['updated_at']}',
                                  //       1,
                                  //       0);
                                  //   printer.printCustom('Status    : ${dataGlobalResponse['dataAbsen']['description']}', 1, 0);
                                  //   printer.printCustom('--------------------------------', 1, 1);
                                  //   printer.printCustom('RINCIAN', 1, 1);
                                  //   printer.printCustom('--------------------------------', 1, 1);
                                  //   for (int i = 0; i < dataGlobalResponse['dataProses'].length; i++) {
                                  //     String namaProduk = '${dataGlobalResponse['dataJumlah'][i]}x ${dataGlobalResponse['dataProses'][i]['name']}';

                                  //     if (namaProduk.length < 21) {
                                  //       for (int i = namaProduk.length; i < 21; i++) {
                                  //         namaProduk += ' ';
                                  //       }
                                  //     } else if (namaProduk.length > 21) {
                                  //       namaProduk = namaProduk.substring(0, 21);
                                  //     }
                                  //     String harga = numberFormat.format(dataGlobalResponse['dataJumlah'][i] * int.parse(dataGlobalResponse['dataProses'][i]['harga'])).toString();
                                  //     String space = '';
                                  //     if (harga.length == 4) {
                                  //       space = '      ';
                                  //     } else if (harga.length == 5) {
                                  //       space = '     ';
                                  //     } else if (harga.length == 6) {
                                  //       space = '    ';
                                  //     } else if (harga.length == 7) {
                                  //       space = '   ';
                                  //     } else if (harga.length == 8) {
                                  //       space = '  ';
                                  //     }
                                  //     printer.printCustom('$namaProduk$space$harga', 1, 0);
                                  //   }
                                  //   printer.printCustom('--------------------------------', 1, 1);
                                  //   String omset = numberFormat.format(dataGlobalResponse['dataAbsen']['total']).toString();
                                  //   String space = '';
                                  //   if (omset.length == 4) {
                                  //     space = '      ';
                                  //   } else if (omset.length == 5) {
                                  //     space = '     ';
                                  //   } else if (omset.length == 6) {
                                  //     space = '    ';
                                  //   } else if (omset.length == 7) {
                                  //     space = '   ';
                                  //   } else if (omset.length == 8) {
                                  //     space = '  ';
                                  //   }
                                  //   printer.printCustom('Perolehan Omset       $space$omset', 1, 0);

                                  //   String tabungan = numberFormat.format(dataGlobalResponse['tabungan']).toString();
                                  //   if (tabungan.length == 4) {
                                  //     space = '      ';
                                  //   } else if (tabungan.length == 5) {
                                  //     space = '     ';
                                  //   } else if (tabungan.length == 6) {
                                  //     space = '    ';
                                  //   } else if (tabungan.length == 7) {
                                  //     space = '   ';
                                  //   } else if (tabungan.length == 8) {
                                  //     space = '   ';
                                  //   }
                                  //   printer.printCustom('Tabungan Awal         $space$tabungan', 1, 0);
                                  //   printer.printCustom('--------------------------------', 1, 1);
                                  //   String totalTabungan = numberFormat.format(dataGlobalResponse['tabungan'] + dataGlobalResponse['dataAbsen']['total']).toString();
                                  //   if (totalTabungan.length == 4) {
                                  //     space = '      ';
                                  //   } else if (totalTabungan.length == 5) {
                                  //     space = '     ';
                                  //   } else if (totalTabungan.length == 6) {
                                  //     space = '    ';
                                  //   } else if (totalTabungan.length == 7) {
                                  //     space = '   ';
                                  //   } else if (totalTabungan.length == 8) {
                                  //     space = '  ';
                                  //   }
                                  //   printer.printCustom('Total Tabungan       $space$totalTabungan', 1, 0);
                                  //   printer.printCustom('--------------------------------', 1, 1);

                                  //   printer.printNewLine();
                                  //   printer.printCustom('Terima kasih sudah bekerja dengan baik', 1, 1);
                                  //   printer.printCustom('Jangan lupa jaga kesehatan', 1, 1);
                                  //   printer.printNewLine();
                                  //   printer.printNewLine();
                                  // }
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
                                  receiptText.addText('Laporan Tutup SHift');
                                  receiptText.addSpacer();
                                  receiptText.addText('Kasir     : ${dataGlobalResponse['name']}', size: ReceiptTextSizeType.small, alignment: ReceiptAlignment.left);
                                  receiptText.addText('Outlet    : ${dataGlobalResponse['dataAbsen']['name_store']}', size: ReceiptTextSizeType.small, alignment: ReceiptAlignment.left);
                                  receiptText.addSpacer(useDashed: true);

                                  receiptText.addText('Check in  : ${dataGlobalResponse['dataAbsen']['created_at']}', size: ReceiptTextSizeType.small, alignment: ReceiptAlignment.left);
                                  receiptText.addText(
                                      'Check out : ${dataGlobalResponse['dataAbsen']['updated_at'] == dataGlobalResponse['dataAbsen']['created_at'] ? 'BELUM ABSEN' : dataGlobalResponse['dataAbsen']['updated_at']}',
                                      size: ReceiptTextSizeType.small,
                                      alignment: ReceiptAlignment.left);
                                  receiptText.addText('Status    : ${dataGlobalResponse['dataAbsen']['description']}', size: ReceiptTextSizeType.small, alignment: ReceiptAlignment.left);
                                  receiptText.addSpacer(useDashed: true);
                                  receiptText.addText('RINCIAN');
                                  receiptText.addSpacer(useDashed: true);
                                  for (int i = 0; i < dataGlobalResponse['dataProses'].length; i++) {
                                    String namaProduk = '${dataGlobalResponse['dataJumlah'][i]}x ${dataGlobalResponse['dataProses'][i]['name']}';
                                    String harga = numberFormat.format(dataGlobalResponse['dataJumlah'][i] * int.parse(dataGlobalResponse['dataProses'][i]['harga'])).toString();
                                    receiptText.addLeftRightText(namaProduk, harga, leftSize: ReceiptTextSizeType.small, rightSize: ReceiptTextSizeType.small);
                                  }
                                  receiptText.addSpacer(useDashed: true);
                                  String omset = numberFormat.format(dataGlobalResponse['dataAbsen']['total']).toString();
                                  String tabungan = numberFormat.format(dataGlobalResponse['tabungan']).toString();
                                  receiptText.addLeftRightText('Omset', omset, leftSize: ReceiptTextSizeType.small, rightSize: ReceiptTextSizeType.small);
                                  receiptText.addLeftRightText('Tabungan Awal', tabungan, leftSize: ReceiptTextSizeType.small, rightSize: ReceiptTextSizeType.small);
                                  receiptText.addSpacer(useDashed: true);
                                  String totalTabungan = numberFormat.format(dataGlobalResponse['tabungan'] + dataGlobalResponse['dataAbsen']['total']).toString();
                                  receiptText.addLeftRightText('Total Tabungan', totalTabungan, leftSize: ReceiptTextSizeType.small, rightSize: ReceiptTextSizeType.small);
                                  receiptText.addSpacer(useDashed: true);
                                  receiptText.addSpacer();
                                  receiptText.addText('Terimakasih sudah bekerja dengan baik', size: ReceiptTextSizeType.small);
                                  receiptText.addText('Jangan lupa jaga kesehatan', size: ReceiptTextSizeType.small);
                                  receiptText.addSpacer();
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
                  padding: EdgeInsets.fromLTRB(size.width / 15, 20, size.width / 15, 0),
                  child: GeneralButton(
                      onTap: () {
                        Nav.pop(context);
                      },
                      text: 'Kembali'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
