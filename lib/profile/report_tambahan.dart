import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/constants.dart';

class ReportTambahan {
  static Future getData(DateTime begin, DateTime end) async {
    try {
      var beginDate = begin.toString().substring(0, 10);
      var endDate = end.toString().substring(0, 10);
      var pref = await SharedPreferences.getInstance();
      var userId = pref.getString("id_user");
      var resp = await get(Uri.parse("${Constants.urlGetReportTambahan}?user_id=$userId&start_date=$beginDate&end_date=$endDate"));
      return jsonDecode(resp.body);
    } catch (e) {
      print(e);
    }
  }

  static getKategori() async {
    try {
      var pref = await SharedPreferences.getInstance();
      var idUser = pref.get('id_user');
      print(idUser);
      var response = await get(Uri.parse('${Constants.urlDataKategori}?key=$idUser'));
      print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      print('tidak ada koneksi internet');
      return '404';
    }
  }

  static Future sendLaporanTambahan(image, lat, lon, idKat, deskripsi) async {
    try {
      var pref = await SharedPreferences.getInstance();
      String idUser = pref.getString('id_user') ?? "0";
      String shift = pref.getString('shift') ?? "0";
      String storeId = pref.getString('store_id_active') ?? "0";
      String key = Constants.key;

      var response = await post(Uri.parse(Constants.urlCreateReportTambahan), body: {
        'user_id': idUser,
        'store_id': storeId,
        'kategori_id': idKat.toString(),
        'shift': shift.toString(),
        'deskripsi': deskripsi,
        'image': image,
        'lat': lat.toString(),
        'lon': lon.toString(),
        'key': key,
      });

      print(response.statusCode);
      // List listResponse = strResponse.split('in***');
      // await pref.setString('store_id_active', store_id);
      // await pref.setString('shift', shift.toString());
      // await pref.setString('name_store', listResponse[0]);
      // await pref.setString('name_store', listResponse[0]);
      // await pref.setString('address_store', listResponse[1]);
      // await pref.setString('phone_store', listResponse[2]);
      // await pref.setString('message_store', listResponse[3]);
      // await pref.setString('brand_store', listResponse[4]);
      // await pref.setBool('ready_kirim', true);
      return response.body;
    } catch (e) {
      print(e);
      print('tidak ada koneksi internet');
      return '404';
    }
  }
}
