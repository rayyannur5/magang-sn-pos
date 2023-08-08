import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/constants.dart';
import 'package:sn_pos/profile/detail_transactions_screen.dart';
import '../menu.dart';
import '../styles/navigator.dart';

class LaporanPenjualanScreen extends StatefulWidget {
  const LaporanPenjualanScreen({super.key});

  @override
  State<LaporanPenjualanScreen> createState() => _LaporanPenjualanScreenState();
}

class _LaporanPenjualanScreenState extends State<LaporanPenjualanScreen> {
  var begin_date = DateTime.now();
  var end_date = DateTime.now();
  final numberFormat = NumberFormat("#,##0", "en_US");

  Future getPenjualan() async {
    var pref = await SharedPreferences.getInstance();
    var idUser = pref.getString('id_user');
    String formattedBeginDate = DateFormat('yyyy-MM-dd').format(begin_date);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(end_date);

    try {
      var response = await http.get(Uri.parse('${Constants.urlPenjualanReport}?user_id=$idUser&key=${Constants.key}&begin_date=$formattedBeginDate&end_date=$formattedEndDate'));
      return jsonDecode(response.body);
    } catch (e) {
      print(e);
      return '404';
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder<dynamic>(
          future: getPenjualan(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

            if (snapshot.data == '404') {
              return Center(
                child: Image.asset('assets/image/no-internet.png'),
              );
            }
            List dataResponse = snapshot.data;
            int omset = 0;
            for (int i = 0; i < dataResponse.length; i++) {
              omset += int.parse(dataResponse[i]['total']);
            }
            return Column(
              children: [
                Container(
                  height: (size.height) / 7,
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.fromLTRB(size.width / 30, 0, size.width / 15, 10),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () => Nav.pushReplacement(context, const MenuScreen(initialPage: 2)),
                          icon: const Icon(
                            Icons.navigate_before,
                            size: 25,
                          )),
                      const Text('Laporan Penjualan', style: TextStyle(fontFamily: 'Poppins', fontSize: 25, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        DateTimeRange? date = await showDateRangePicker(context: context, firstDate: DateTime.parse('20200101'), lastDate: DateTime.parse('20300101'));
                        begin_date = date!.start;
                        end_date = date.end;
                        setState(() {});
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 40,
                          width: size.width / 2 - 50,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(child: Text(begin_date.toString().substring(0, 10), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
                        ),
                        Container(
                          height: 40,
                          width: size.width / 2 - 50,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(child: Text(end_date.toString().substring(0, 10), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: size.height / 6,
                  width: size.width,
                  padding: EdgeInsets.fromLTRB(size.width / 15, size.height / 25, size.width / 15, 0),
                  child: Container(
                    padding: EdgeInsets.all(size.width / 15),
                    decoration: BoxDecoration(
                      color: const Color(0xff03045E),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Banyak Penjualan : ${dataResponse.length} transaksi', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('Omset                             : ${numberFormat.format(omset)}',
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height - (size.height / 6) - (size.height / 7) - 100,
                  width: size.width,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: dataResponse.isNotEmpty
                        ? ListView.builder(
                            itemCount: dataResponse.length,
                            itemBuilder: (context, index) => cardLaporanPenjualan(size, dataResponse[index]),
                          )
                        : ListView(
                            children: [Image.asset('assets/image/no-data.png')],
                          ),
                  ),
                )
              ],
            );
          }),
    );
  }

  Container cardLaporanPenjualan(Size size, dataResponse) {
    print(dataResponse);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width / 15),
      margin: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        elevation: 10,
        child: InkWell(
          onTap: () {
            Nav.push(
                context,
                DetailTransactionsScreen(
                  store_id: dataResponse['store_id_trx'],
                  number_trx: dataResponse['number_trx'],
                  date: dataResponse['created_at_trx'],
                  customer_trx: dataResponse['customer_trx'],
                ));
          },
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: size.width,
            height: size.height / 12,
            child: Row(
              children: [
                Container(
                  width: size.width / 2,
                  padding: EdgeInsets.only(left: size.width / 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dataResponse['name_store'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(dataResponse['created_at_trx'].toString().substring(0, 16), style: const TextStyle(fontFamily: 'Poppins', fontSize: 10)),
                    ],
                  ),
                ),
                Container(
                  width: size.width - (size.width / 2) - 2 * (size.width / 15),
                  padding: EdgeInsets.all(size.width / 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff0077B6),
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                    child: Center(
                      child: Text(
                        (numberFormat.format(int.parse(dataResponse['total']))),
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
