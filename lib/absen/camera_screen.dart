import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sn_pos/absen/send_absen_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
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
                                    return MenuScreen(initialPage: 1);
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

                                if (!mounted) return;

                                // If the picture was taken, display it on a new screen.
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SendAbsenScreen(
                                      imagePath: image.path,
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
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.lightBlue, border: Border.all(color: Colors.white, strokeAlign: StrokeAlign.outside, width: 4)),
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
      ),
    );
  }
}
