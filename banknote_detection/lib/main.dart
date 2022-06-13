import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:banknote_detection/home.dart';
import 'package:banknote_detection/loading.dart';
import 'package:ncnn_yolox_flutter/ncnn_yolox_flutter.dart';
import 'package:flutter/services.dart';

final ncnn = NcnnYolox();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  

  await ncnn.initYolox(
    modelPath: 'assets/yolox/yolox.bin',
    paramPath: 'assets/yolox/yolox.param',
  );

  runApp(MaterialApp(
    showSemanticsDebugger: false,
    theme: ThemeData(),
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const Loading(),
      '/home': (context) => TakePictureScreen(camera: firstCamera, ncnn: ncnn),
    },
  ));
}
