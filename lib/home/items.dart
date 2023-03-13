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

  bayar(List item) async {
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

    var id_trx = id_user1000.toString() + year + month + day + hour + minute + second;

    String dataTerpilih = "";
    for (int i = 0; i < item.length; i++) {
      for (int j = 0; j < item[i]['count']; j++) {
        dataTerpilih += '${item[i]['id_produk']}C';
      }
    }
    print(dataTerpilih);

    pref.setString('TRX-$id_trx', dataTerpilih);
  }
}
