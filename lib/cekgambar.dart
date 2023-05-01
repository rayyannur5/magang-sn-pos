import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class CekGambar extends StatelessWidget {
  const CekGambar({super.key, required this.imagePath});
  final imagePath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [Image.file(File(imagePath)), Text(imagePath)],
        ),
      ),
    );
  }
}
