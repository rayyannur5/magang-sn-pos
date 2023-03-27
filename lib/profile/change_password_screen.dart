import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/constants.dart';
import 'package:sn_pos/login/auth.dart';
import 'package:http/http.dart' as http;
import 'package:sn_pos/login/login_screen.dart';

import '../styles/general_button.dart';
import '../styles/navigator.dart';

class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({super.key});

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  bool passwordVisible = false;

  Future getNama() async {
    var pref = await SharedPreferences.getInstance();
    return {
      'name': pref.getString('name'),
      'email': pref.getString('email'),
    };
  }

  Future changePassword(password) async {
    var pref = await SharedPreferences.getInstance();
    var user_id = pref.getString('id_user');
    try {
      var response = await http.post(Uri.parse(Constants.urlChangePassword), body: {
        'user_id': user_id,
        'key': Constants.key,
        'password': password,
      });
      return response.body;
    } catch (e) {
      print(e);
      return '404';
    }
  }

  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var newPasswordController = TextEditingController();
  var newPassword2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder<dynamic>(
          future: getNama(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            nameController.text = snapshot.data['name'];
            emailController.text = snapshot.data['email'];
            return Column(
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
                      const Text('Ubah Password', style: TextStyle(fontFamily: 'Poppins', fontSize: 25, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: TextField(
                    style: const TextStyle(fontFamily: 'Poppins'),
                    controller: nameController,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0077B6)),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: TextField(
                    style: const TextStyle(fontFamily: 'Poppins'),
                    controller: emailController,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0077B6)),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: TextField(
                    style: const TextStyle(fontFamily: 'Poppins'),
                    controller: passwordController,
                    obscureText: !passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password Lama',
                      suffixIcon: IconButton(
                          onPressed: () {
                            passwordVisible = !passwordVisible;
                            setState(() {});
                          },
                          icon: Icon(
                            passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.black,
                          )),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0077B6)),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: TextField(
                    style: const TextStyle(fontFamily: 'Poppins'),
                    obscureText: !passwordVisible,
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      suffixIcon: IconButton(
                          onPressed: () {
                            passwordVisible = !passwordVisible;
                            setState(() {});
                          },
                          icon: Icon(
                            passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.black,
                          )),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0077B6)),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: TextField(
                    style: const TextStyle(fontFamily: 'Poppins'),
                    obscureText: !passwordVisible,
                    controller: newPassword2Controller,
                    decoration: InputDecoration(
                      labelText: 'Ketik Ulang Password',
                      suffixIcon: IconButton(
                          onPressed: () {
                            passwordVisible = !passwordVisible;
                            setState(() {});
                          },
                          icon: Icon(
                            passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.black,
                          )),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0077B6)),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width / 15),
                  child: GeneralButton(
                      text: 'Simpan',
                      onTap: () {
                        if (passwordController.text == "" || newPasswordController.text == "" || newPassword2Controller.text == "") {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  content: Text('Kolom Password Tidak Boleh Kosong', textAlign: TextAlign.center),
                                );
                              });
                          return;
                        }
                        if (newPasswordController.text != newPassword2Controller.text) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  content: Text('Ketik ulang password salah', textAlign: TextAlign.center),
                                );
                              });
                          return;
                        }
                        Auth().login(emailController.text, passwordController.text).then((value) {
                          if (value == '2') {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const AlertDialog(
                                    content: Text('Password Lama salah', textAlign: TextAlign.center),
                                  );
                                });
                          } else if (value.contains('aytech--')) {
                            changePassword(newPasswordController.text).then((value) {
                              if (value == 'password-') {
                                Auth().logout().then((value) {
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                                    return LoginScreen();
                                  }), (r) {
                                    return false;
                                  });
                                });
                              }
                            });
                          }
                        });
                      }),
                ),
                const SizedBox(height: 50),
              ],
            );
          }),
    );
  }
}
