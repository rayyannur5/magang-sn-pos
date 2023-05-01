import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:intl/intl.dart';
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

  Future sendFTP(String imagePath) async {
    var pref = await SharedPreferences.getInstance();

    var ftphost = pref.getString('ftp_server') ?? '191.101.230.27';
    var ftpuser = pref.getString('ftp_username') ?? 'u431884832.rayyan_tes';
    var ftppassword = pref.getString('ftp_password') ?? 'Unesa123';
    int ftpport = int.parse(pref.getString('ftp_port') ?? '21');

    // var ftphost = '191.101.230.27';
    // var ftpuser = 'u431884832.rayyan_tes';
    // var ftppassword = 'Unesa123';
    // int ftpport = 21;

    FTPConnect ftpConnect = FTPConnect(ftphost, user: ftpuser, pass: ftppassword, port: ftpport);

    File fileToUpload = File(imagePath);

    await ftpConnect.connect();
    //Change directory
    bool change = await ftpConnect.changeDirectory('retur');
    bool res = await ftpConnect.uploadFileWithRetry(
      fileToUpload,
      pRetryCount: 2,
      onProgress: (progressInPercent, totalReceived, fileSize) {
        print(progressInPercent);
      },
    );
    await ftpConnect.disconnect();
    if (res) {
      // Navigator.pop(context);
      pref.setString('gambar_absen_path', '');
      return imagePath;
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
      pref.setBool('ready_kirim', true);
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

  Future<bool> cekApakahAdaTransaksi() async {
    var pref = await SharedPreferences.getInstance();
    for (var i in pref.getKeys()) {
      if (i.contains('TRX')) {
        return true;
      }
    }
    return false;
  }

  Future absensiReport(begin_date, end_date) async {
    print('get absen report');
    String formattedBeginDate = DateFormat('yyyy-MM-dd').format(begin_date);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(end_date);

    try {
      var pref = await SharedPreferences.getInstance();
      var id_user = pref.getString('id_user');
      var response = await http.get(Uri.parse('${Constants.urlAbsensiReport}?key=${Constants.key}&user_id=$id_user&begin_date=$formattedBeginDate&end_date=$formattedEndDate'));
      List dataAbsen = jsonDecode(response.body);
      return dataAbsen;
    } catch (e) {
      return '404';
    }
  }
}
