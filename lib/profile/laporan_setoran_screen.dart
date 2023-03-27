import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sn_pos/constants.dart';

import '../menu.dart';
import '../styles/navigator.dart';

class LaporanSetoranScreen extends StatelessWidget {
  LaporanSetoranScreen({super.key});
  final numberFormat = NumberFormat("#,##0", "en_US");
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder<dynamic>(
          future: getSetoran(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

            var dataResponse = snapshot.data;
            return Column(
              children: [
                Container(
                  height: (size.height) / 7,
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.fromLTRB(size.width / 30, 0, size.width / 15, 10),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () => Nav.pushReplacement(context, MenuScreen(initialPage: 2)),
                          icon: const Icon(
                            Icons.navigate_before,
                            size: 25,
                          )),
                      const Text('Laporan Setoran', style: TextStyle(fontFamily: 'Poppins', fontSize: 25, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                //   child: GestureDetector(
                //     onTap: () => showDialog(
                //       context: context,
                //       builder: (context) => DateRangePickerDialog(firstDate: DateTime.parse('20200101'), lastDate: DateTime.parse('20300101')),
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Container(
                //           height: 40,
                //           width: size.width / 2 - 50,
                //           decoration: BoxDecoration(
                //             color: Colors.grey,
                //             borderRadius: BorderRadius.circular(15),
                //           ),
                //           child: const Center(child: Text('06/06/2023', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
                //         ),
                //         Container(
                //           height: 40,
                //           width: size.width / 2 - 50,
                //           decoration: BoxDecoration(
                //             color: Colors.grey,
                //             borderRadius: BorderRadius.circular(15),
                //           ),
                //           child: const Center(child: Text('06/06/2023', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700))),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Container(
                  height: size.height / 7,
                  width: size.width,
                  padding: EdgeInsets.fromLTRB(size.width / 15, 0, size.width / 15, 0),
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
                      children: [
                        Text('Tabungan\n${numberFormat.format(dataResponse['total_tabungan'])}',
                            textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height - (size.height / 7) - (size.height / 7) - 60,
                  width: size.width,
                  child: dataResponse['value'].isNotEmpty
                      ? ListView.builder(
                          itemCount: dataResponse['value'].length,
                          itemBuilder: (context, index) => cardLaporanSetoran(size, dataResponse['value'][index]),
                        )
                      : ListView(
                          children: [Image.asset('assets/image/no-data.png')],
                        ),
                )
              ],
            );
          }),
    );
  }

  Container cardLaporanSetoran(Size size, dataSetoran) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width / 15),
      margin: const EdgeInsets.only(bottom: 15),
      child: Container(
        width: size.width,
        height: size.height / 12,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]),
        child: Row(
          children: [
            Container(
              width: size.width / 2,
              padding: EdgeInsets.only(left: size.width / 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dataSetoran['city'].toString(), style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(dataSetoran['created_at'].toString().substring(0, 16), style: const TextStyle(fontFamily: 'Poppins', fontSize: 10)),
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
                    '${numberFormat.format(int.parse(dataSetoran['total_setor']))}',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
