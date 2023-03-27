import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../absen/absen.dart';
import '../constants.dart';

class Item {
  getItem() async {
    try {
      var pref = await SharedPreferences.getInstance();
      // ignore: non_constant_identifier_names
      var id_user = pref.get('id_user');
      // print('user id : ${id_user}');
      var response = await http.get(Uri.parse('${Constants.urlKatalog}?user_id=$id_user'));
      var cekAbsen = await Absen().cekAbsenHariIni();

      if (cekAbsen == 'BELUM_ABSEN_MASUK' || cekAbsen == 'SUDAH_ABSEN_KELUAR') {
        return 'XXXX--';
      } else {
        return response.body;
      }
    } catch (e) {
      print('tidak ada koneksi internet');
      return '404';
    }
  }
}
