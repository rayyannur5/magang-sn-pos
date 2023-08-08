import 'package:flutter/material.dart';
import 'package:sn_pos/login/auth.dart';
import 'package:sn_pos/menu.dart';
import 'package:sn_pos/no_internet_screen.dart';
import 'package:sn_pos/styles/general_button.dart';
import 'package:sn_pos/styles/navigator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordVisible = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -45,
            left: -40,
            child: Material(
              color: const Color(0xff03045E),
              shape: const CircleBorder(),
              elevation: 10,
              child: SizedBox(
                height: size.height / 3.5,
                width: size.height / 3.5,
                child: Center(
                  child: Image.asset('assets/image/logo.png', scale: 2),
                ),
              ),
            ),
          ),
          Positioned(
            top: -38,
            left: 160,
            child: Material(
              color: const Color(0xffCAF0F8),
              shape: const CircleBorder(),
              elevation: 10,
              child: SizedBox(
                height: size.height / 6,
                width: size.height / 6,
              ),
            ),
          ),
          Container(
              height: size.height,
              width: size.width,
              padding: EdgeInsets.fromLTRB(size.width / 15, size.height / 4, size.width / 15, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Selamat Datang, ", style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w700)),
                  const Text("Silahkan Login untuk melanjutkan", style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                  const SizedBox(height: 50),
                  TextField(
                    controller: email,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff0077B6)),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: password,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    obscureText: !passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
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
                  const SizedBox(height: 50),
                  GeneralButton(
                      text: 'Login',
                      onTap: () {
                        if (email.text == '' || password.text == '') {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  icon: Icon(Icons.warning, color: Colors.amber.shade800),
                                  content: const Text('Email / Password tidak boleh kosong'),
                                );
                              });
                          return;
                        }

                        Auth().login(email.text, password.text).then((value) => {
                              if (value == '3')
                                {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(icon: Icon(Icons.warning, color: Colors.amber.shade800), content: const Text('Email tidak ditemukan', textAlign: TextAlign.center));
                                    },
                                  )
                                }
                              else if (value == '2')
                                {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(icon: Icon(Icons.warning, color: Colors.amber.shade800), content: const Text('Password salah', textAlign: TextAlign.center));
                                    },
                                  )
                                }
                              else if (value == '404')
                                {Nav.materialPushReplacement(context, const NoInternetScreen())}
                              else
                                {Nav.materialPushReplacement(context, const MenuScreen(initialPage: 0))}
                            });
                      }),
                ],
              ))
        ],
      ),
    );
  }
}
