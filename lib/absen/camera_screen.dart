import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sn_pos/absen/send_absen_screen.dart';

import '../styles/navigator.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => Nav.push(context, SendAbsenScreen()), child: Text('Next'));
  }
}
