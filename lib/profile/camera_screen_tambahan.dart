import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sn_pos/profile/report_tambahan_screen.dart';
import 'package:sn_pos/profile/send_report_tambahan_screen.dart';
import 'package:sn_pos/styles/navigator.dart';

class CameraScreenTambahan extends StatefulWidget {
  const CameraScreenTambahan({super.key});

  @override
  State<CameraScreenTambahan> createState() => _CameraScreenTambahanState();
}

class _CameraScreenTambahanState extends State<CameraScreenTambahan> {
  late CameraController controller;

  Future<void> initializeCamera() async {
    var cameras = await availableCameras();
    print(switchCamera);
    controller = CameraController(cameras[switchCamera], ResolutionPreset.low);
    await controller.initialize();
  }

  int switchCamera = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  File changeFileNameOnlySync(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.renameSync(newPath);
  }

  Future<Position> getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Nav.pushReplacement(context, const ReportTambahanScreen());
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder<Position>(
            future: getPosition(),
            builder: (context, position) {
              if (position.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              print(position.data);
              return FutureBuilder(
                future: initializeCamera(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        SizedBox(
                          width: size.height,
                          height: size.width * controller.value.aspectRatio,
                          child: CameraPreview(controller),
                        ),
                        Container(
                          height: size.height - (size.width * controller.value.aspectRatio),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              const Spacer(),
                              SizedBox(
                                height: 70,
                                width: 70,
                                child: IconButton(
                                    onPressed: () {
                                      Nav.pushReplacement(context, const ReportTambahanScreen());
                                    },
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.white,
                                      size: 50,
                                    )),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () async {
                                  // Take the Picture in a try / catch block. If anything goes wrong,
                                  // catch the error.
                                  print('take picture');
                                  try {
                                    // Attempt to take a picture and get the file `image`
                                    // where it was saved.
                                    final image = await controller.takePicture();

                                    var pref = await SharedPreferences.getInstance();

                                    if (!mounted) return;

                                    var idUser = pref.getString('id_user') ?? '0';
                                    int idUser1000 = 1000 + int.parse(idUser);

                                    var date = DateTime.now();
                                    var year = date.year.toString();
                                    var month = date.month < 10 ? '0${date.month.toString()}' : date.month.toString();
                                    var day = date.day < 10 ? '0${date.day.toString()}' : date.day.toString();
                                    var hour = date.hour < 10 ? '0${date.hour.toString()}' : date.hour.toString();
                                    var minute = date.minute < 10 ? '0${date.minute.toString()}' : date.minute.toString();
                                    var second = date.second < 10 ? '0${date.second.toString()}' : date.second.toString();

                                    var namaGambar = 'RPT_$idUser1000$year$month$day$hour$minute$second.jpg';

                                    File newImage = changeFileNameOnlySync(File(image.path), namaGambar);

                                    // If the picture was taken, display it on a new screen.
                                    await Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => SendReportTambahanScreen(
                                          imagePath: newImage.path,
                                          imageName: namaGambar,
                                          position: position.data!,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    // If an error occurs, log the error to the console.
                                    print(e);
                                  }
                                },
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration:
                                      BoxDecoration(shape: BoxShape.circle, color: Colors.lightBlue, border: Border.all(color: Colors.white, strokeAlign: BorderSide.strokeAlignOutside, width: 4)),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 70,
                                width: 70,
                                child: IconButton(
                                    onPressed: () {
                                      if (switchCamera == 1) {
                                        setState(() {
                                          switchCamera = 0;
                                        });
                                      } else {
                                        setState(() {
                                          switchCamera = 1;
                                        });
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.cameraswitch_rounded,
                                      color: Colors.white,
                                      size: 50,
                                    )),
                              ),
                              const Spacer()
                            ],
                          ),
                        )
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            }),
      ),
    );
  }
}
