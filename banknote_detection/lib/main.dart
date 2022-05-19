
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:banknote_detection/home.dart';
import 'package:banknote_detection/loading.dart';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;


  runApp(MaterialApp(
    theme: ThemeData(),
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const Loading(),
      '/home': (context) => TakePictureScreen(camera: firstCamera),
    },
  ));
}
