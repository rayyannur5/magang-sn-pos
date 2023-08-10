import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_pos/absen/send_absen_screen.dart';
import 'package:geolocator/geolocator.dart';

import '../menu.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;

  Future<void> initializeCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.low);
    await controller.initialize();
  }

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
    return Scaffold(
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
                  return Stack(
                    children: [
                      Column(
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
                                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
                                          return const MenuScreen(initialPage: 1);
                                        }), (r) {
                                          return false;
                                        });
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

                                      var namaGambar = '$idUser1000$year$month$day$hour$minute$second.jpg';

                                      File newImage = changeFileNameOnlySync(File(image.path), namaGambar);

                                      pref.setString("gambar_absen_path", newImage.path);
                                      pref.setString("gambar_absen", namaGambar);
                                      // If the picture was taken, display it on a new screen.
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => SendAbsenScreen(
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
                                const Spacer(flex: 3)
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(
                        width: size.height,
                        height: size.width * controller.value.aspectRatio,
                        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/image/face-screen.png'), fit: BoxFit.fill)),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          }),
    );
  }
}
