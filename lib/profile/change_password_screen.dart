import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../styles/general_button.dart';
import '../styles/navigator.dart';

class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({super.key});

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  bool passwordVisible = false;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
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
            child: const TextField(
              style: TextStyle(fontFamily: 'Poppins'),
              decoration: InputDecoration(
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
            child: const TextField(
              style: TextStyle(fontFamily: 'Poppins'),
              decoration: InputDecoration(
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
            child: GeneralButton(text: 'Simpan', onTap: () {}),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
