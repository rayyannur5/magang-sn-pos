import 'package:flutter/material.dart';

class GeneralButton extends StatelessWidget {
  const GeneralButton({super.key, required this.text, required this.onTap});
  final String text;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: 50,
      width: size.width,
      // padding: const EdgeInsets.symmetric(horizontal: 35),
      child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(10),
          backgroundColor: MaterialStateProperty.all(const Color(0xff0077B6)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
        ),
        child: Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 20)),
      ),
    );
  }
}
