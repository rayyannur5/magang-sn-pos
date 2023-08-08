import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/constants.dart';

class Auth {
  Future<String> login(email, password) async {
    try {
      var response = await http.post(Uri.parse(Constants.urlLogin), body: {'email': email, 'password': password});
      if (response.body != '2' && response.body != '3') {
        var dataUser = response.body.split('aytech--');
        print('login sukses : $dataUser');
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('id_user', dataUser[0]);
        pref.setString('name', dataUser[1]);
        pref.setString('email', dataUser[2]);
        pref.setString('image', dataUser[3]);
        pref.setString('created_at_user', dataUser[4]);
        pref.setString('shift', dataUser[5]);
        pref.setString('ftp_1', dataUser[6]);
        pref.setString('ftp_2', dataUser[7]);
        pref.setString('wajib_foto', dataUser[8]);
        pref.setString('ftp_server', dataUser[9]);
        pref.setString('ftp_password', dataUser[10]);
        pref.setString('ftp_port', dataUser[11]);
        pref.setString('ftp_username', dataUser[12]);
        pref.setString('password', password);
        if (dataUser[5] != '0') {
          pref.setString('name_store', dataUser[13]);
          pref.setString('address_store', dataUser[14]);
          pref.setString('message_store', dataUser[15]);
          pref.setString('phone_store', dataUser[16]);
          pref.setString('store_id_active', dataUser[17]);
          pref.setString('brand_store', dataUser[18]);
        } else {
          pref.setString('store_id_active', '0');
        }
        print(dataUser);
        return response.body;
      } else if (response.body == '2' || response.body == '3') {
        return response.body;
      } else {
        return 'error';
      }
    } catch (e) {
      print(e);
      print('tidak ada koneksi internet');
      return '404';
    }
  }

  Future<bool> logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('id_user', '');
    pref.setString('name', '');
    pref.setString('email', '');
    pref.setString('image', '');
    pref.setString('created_at_user', '');
    pref.setString('shift', '');
    pref.setString('ftp_1', '');
    pref.setString('ftp_2', '');
    pref.setString('wajib_foto', '');
    pref.setString('ftp_server', '');
    pref.setString('ftp_password', '');
    pref.setString('ftp_port', '');
    pref.setString('ftp_username', '');
    pref.setString('password', '');
    return true;
  }
}
