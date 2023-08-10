import 'dart:io';

import 'package:ftpconnect/ftpconnect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';

class FTP {
  static sendReceiptFTP(File file) async {
    var pref = await SharedPreferences.getInstance();

    var ftphost = pref.getString('ftp_server') ?? '191.101.230.27';
    var ftpuser = pref.getString('ftp_username') ?? 'u431884832.rayyan_tes';
    var ftppassword = pref.getString('ftp_password') ?? 'Unesa123';
    int ftpport = int.parse(pref.getString('ftp_port') ?? '21');

    FTPConnect ftpConnect = FTPConnect(ftphost, user: ftpuser, pass: ftppassword, port: ftpport);

    await ftpConnect.connect();
    //Change directory
    bool change = await ftpConnect.changeDirectory('_FOTO_RESEP');

    bool res = await ftpConnect.uploadFile(file);
    await ftpConnect.disconnect();
    if (res) {
      return {'success': true, 'link': 'https://recipe.mirovtech.id/${basename(file.path)}'};
    } else {
      return {'success': false, 'link': ''};
    }
  }

  static sendReportTambahanFTP(File file) async {
    var pref = await SharedPreferences.getInstance();

    var ftphost = pref.getString('ftp_server') ?? '191.101.230.27';
    var ftpuser = pref.getString('ftp_username') ?? 'u431884832.rayyan_tes';
    var ftppassword = pref.getString('ftp_password') ?? 'Unesa123';
    int ftpport = int.parse(pref.getString('ftp_port') ?? '21');

    FTPConnect ftpConnect = FTPConnect(ftphost, user: ftpuser, pass: ftppassword, port: ftpport);

    await ftpConnect.connect();
    bool res = await ftpConnect.uploadFileWithRetry(
      file,
      pRetryCount: 2,
    );
    await ftpConnect.disconnect();
    return res;
  }
}
