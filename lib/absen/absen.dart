import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class Absen {
  getOutlet() async {
    try {
      var pref = await SharedPreferences.getInstance();
      var id_user = pref.get('id_user');
      print(id_user);
      var response = await http.get(Uri.parse('${Constants.urlDataOutlet}?key=$id_user'));
      print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      print('tidak ada koneksi internet');
      return '404';
    }
  }

  Future<String> cekAbsenHariIni() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var id_user = pref.getString('id_user');
      var store_id_active = pref.getString('store_id_active') ?? '0';
      var response = await http.post(Uri.parse(Constants.urlCekAbsensi), body: {'user_id': id_user, 'key': Constants.key});
      print(store_id_active);

      if (response.body == '2') {
        return 'BELUM_ABSEN_MASUK';
      } else if (response.body == '1' && store_id_active != '0') {
        return 'SUDAH_ABSEN_MASUK';
      } else if (response.body == '1' && store_id_active == '0') {
        return 'SUDAH_ABSEN_KELUAR';
      } else {
        return 'error';
      }
    } catch (e) {
      return '404';
    }
  }

  File changeFileNameOnlySync(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.renameSync(newPath);
  }

  Future sendFTP(String imagePath, BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var id_user = pref.getString('id_user') ?? '0';
    int id_user1000 = 1000 + int.parse(id_user);

    var date = DateTime.now();
    var year = date.year.toString();
    var month = date.month < 10 ? '0${date.month.toString()}' : date.month.toString();
    var day = date.day < 10 ? '0${date.day.toString()}' : date.day.toString();
    var hour = date.hour < 10 ? '0${date.hour.toString()}' : date.hour.toString();
    var minute = date.minute < 10 ? '0${date.minute.toString()}' : date.minute.toString();
    var second = date.second < 10 ? '0${date.second.toString()}' : date.second.toString();

    var namaGambar = '$id_user1000$year$month$day$hour$minute$second.jpg';
    FTPConnect ftpConnect = FTPConnect('hifzanur.com', user: 'u431884832.rayyan_tes', pass: 'Unesa123');
    File fileToUpload = changeFileNameOnlySync(File(imagePath), namaGambar);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('Mengirim foto ', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700)),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
    await ftpConnect.connect();
    //Change directory
    bool change = await ftpConnect.changeDirectory('retur');
    bool res = await ftpConnect.uploadFileWithRetry(fileToUpload, pRetryCount: 2);
    await ftpConnect.disconnect();
    if (res) {
      Navigator.pop(context);
      return namaGambar;
    } else {
      return 'default.jpg';
    }
  }

  Future<String> sendAbsenMasuk(store_id, shift, image_in) async {
    try {
      var pref = await SharedPreferences.getInstance();
      String id_user = pref.getString('id_user') ?? "0";
      String key = Constants.key;
      var response = await http.post(Uri.parse(Constants.urlAbsenMasuk), body: {
        'user_id': id_user,
        'image_in': image_in,
        'shift': shift.toString(),
        'store_id': store_id,
        'key': key,
      });

      String strResponse = response.body;
      List listResponse = strResponse.split('in***');
      pref.setString('store_id_active', store_id);
      pref.setString('shift', shift.toString());
      pref.setString('name_store', listResponse[0]);
      pref.setString('name_store', listResponse[0]);
      pref.setString('address_store', listResponse[1]);
      pref.setString('phone_store', listResponse[2]);
      pref.setString('message_store', listResponse[3]);
      pref.setString('brand_store', listResponse[4]);

      return '1';
    } catch (e) {
      print(e);
      print('tidak ada koneksi internet');
      return '404';
    }
  }

  Future sendAbsenKeluar(shift, image_out) async {
    try {
      var pref = await SharedPreferences.getInstance();
      pref.setString('store_id_active', '0');

      String id_user = pref.getString('id_user') ?? "0";
      String key = Constants.key;
      var response = await http.post(Uri.parse(Constants.urlAbsenKeluar), body: {
        'user_id': id_user,
        'image_out': image_out,
        'shift': shift.toString(),
        'key': key,
      });
      return response.body;
    } catch (e) {
      return '404';
    }
  }
}
