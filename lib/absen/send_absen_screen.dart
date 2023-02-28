import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sn_pos/styles/general_button.dart';

import '../styles/navigator.dart';

class SendAbsenScreen extends StatefulWidget {
  const SendAbsenScreen({super.key});

  @override
  State<SendAbsenScreen> createState() => _SendAbsenScreenState();
}

class _SendAbsenScreenState extends State<SendAbsenScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: (size.height) / 5,
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.fromLTRB(size.width / 30, 0, size.width / 15, 10),
            child: Row(
              children: [
                IconButton(
                    onPressed: () => Nav.pop(context),
                    icon: const Icon(
                      Icons.navigate_before,
                      size: 35,
                    )),
                const Text('Absensi', style: TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              height: size.height / 4,
              width: size.width / 2,
              child: Icon(Icons.account_circle_outlined, size: size.width / 2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
            child: const Text('Outlet', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          Container(
            width: size.width,
            // height: 70,
            padding: EdgeInsets.symmetric(horizontal: size.width / 15),
            child: DropdownButton(
              isExpanded: true,
              dropdownColor: Colors.amber,
              hint: Text('  Pilih Outlet'),
              underline: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xff0077B6)),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              borderRadius: BorderRadius.circular(15),
              onChanged: (value) {},
              items: ['Pilih Outlet', 'Tanggulangin'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
            child: const Text('Shift', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 50,
                  width: size.width / 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Text(
                      'Shift 1',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  width: size.width / 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xff0077B6),
                  ),
                  child: const Center(
                    child: Text(
                      'Shift 2',
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  width: size.width / 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Text(
                      'Shift 3',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width / 15, vertical: 10),
            child: GeneralButton(text: 'Kirim', onTap: () {}),
          ),
          const SizedBox(height: 40)
        ],
      ),
    );
  }
}
