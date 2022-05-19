import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tflite/tflite.dart';

int total = 0;
bool counter = true;

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  final picker = ImagePicker();
  String path;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    FlutterTts flutterTts;
    flutterTts = FlutterTts();
    flutterTts.setSpeechRate(0.8);
    flutterTts.awaitSpeakCompletion(true);
    flutterTts.speak("Ready to Detect!");
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) return null;

    setState(() {
      path = image.path;
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        title:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/Icon_Clear.png",height: 55,
                          width:70,),
                const Text('PesoReader', style: TextStyle(color: Colors.black,fontSize: 12)),
              ],
            ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 30),
            onPressed: () {
              setState(() {
                counter = !counter;
              });

              FlutterTts flutterTts;
              flutterTts = FlutterTts();
              flutterTts.setSpeechRate(0.8);
              flutterTts.awaitSpeakCompletion(true);
              if (counter == true) {
                flutterTts.speak("Counter Enabled");
              } else {
                flutterTts.speak("Counter Disabled");
              }
            },
            icon: Icon(Icons.layers_clear,
                color: counter ? Colors.black : Colors.grey, size: 25),
          ),
        ],
      ),

      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      
      body: Stack(children: <Widget>[
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.

              return CameraPreview(_controller);
            } else {
              // Otherwise, display a loading indicator.
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        GestureDetector(onTap: () async {
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,'${DateTime.now()}.png',);

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return DisplayPictureScreen(path);
              } //DisplayPictureScreen(path),
                  ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        }, onLongPress: () async {
          setState(() {
            total = 0;
          });

          FlutterTts flutterTts;
          flutterTts = FlutterTts();
          await flutterTts.setSpeechRate(0.8);
          await flutterTts.awaitSpeakCompletion(true);
          await flutterTts.speak("Your Total has been reset.");
        }),

        ]),

        
        bottomNavigationBar: BottomAppBar(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                primary: Colors.black,
                fixedSize: const Size(1000, 70),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0))),
            label: const Text("Pick from Gallery"),
            icon: const Icon(Icons.photo),
            onPressed: () async {
              await pickGalleryImage();
              print(path);
              if (path != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return DisplayPictureScreen(path);
                  } //DisplayPictureScreen(path),
                      ),
                );
              }
              
            },
          ),
        )

    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  DisplayPictureScreen(this.imagePath);
  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List op;
  Image img;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
    img = Image.file(File(widget.imagePath));
    classifyImage(widget.imagePath);
  }

  @override
  Widget build(BuildContext context) {
//    Image img = Image.file(File(widget.imagePath));
//    classifyImage(widget.imagePath, total);
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).maybePop();
      
    });

    return Scaffold(
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      // appBar: AppBar(
      //   title: Center(child: Text('Banknote Detection')),
      //   automaticallyImplyLeading: false,
      // ),
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/Icon_Clear.png",
                          height: 55,
                          width:70,),
                const Text('Peso Reader', style: TextStyle(color: Colors.black,fontSize: 12)),
              ],
            ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: loading
          ? Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Center(child: Text('${op[0]["label"]} Pesos')),
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      //width: double.infinity,
                      child: Text(
                        '${op[0]["label"]} Pesos',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 65,
                            fontWeight: FontWeight.bold),
                      ),
                      alignment: Alignment.center,
                    ),
                  ),
                  // Expanded(child: Center(child: img)),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // op!=null
                  // ?Text('${op[0]["label"]}')
                  //:Container(),
                ],
              ),
            ),
    );
  }

  Future<void> runTextToSpeech(String outputMoney, int totalMoney) async {
    FlutterTts flutterTts;
    flutterTts = FlutterTts();

    String tot = totalMoney.toString();
    print(tot);
    String speakString = outputMoney;
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.awaitSpeakCompletion(true);
    if (counter == true) {
      await flutterTts.speak('${speakString}! Your total is: ${tot}');
    } else if (counter == false) {
      await flutterTts.speak('${speakString}!');
    }

    // if (outputMoney == "50 pesos") {
    //   String tot = totalMoney.toString();
    //   print(tot);
    //   String speakString = "Fifty Pesos";
    //   await flutterTts.setSpeechRate(0.8);
    //   await flutterTts.awaitSpeakCompletion(true);
    //   await flutterTts.speak(speakString);
    // }
    // if (outputMoney == "100 pesos") {
    //   String tot = totalMoney.toString();
    //   print(tot);
    //   String speakString = "One Hundred Pesos";
    //   await flutterTts.setSpeechRate(0.8);
    //   await flutterTts.awaitSpeakCompletion(true);
    //   await flutterTts.speak(speakString);
    // }
    // if (outputMoney == "200 pesos") {
    //   String tot = totalMoney.toString();
    //   print(tot);
    //   String speakString = "Two Hundred Pesos";
    //   await flutterTts.setSpeechRate(0.8);
    //   await flutterTts.awaitSpeakCompletion(true);
    //   await flutterTts.speak(speakString);
    // }
    // if (outputMoney == "500 pesos") {
    //   String tot = totalMoney.toString();
    //   print(tot);
    //   String speakString = "Five Hundred Pesos";
    //   await flutterTts.setSpeechRate(0.8);
    //   await flutterTts.awaitSpeakCompletion(true);
    //   await flutterTts.speak(speakString);
    // }
    // if (outputMoney == "1000 pesos") {
    //   String tot = totalMoney.toString();
    //   print(tot);
    //   String speakString = "One Thousand Pesos";
    //   await flutterTts.setSpeechRate(0.8);
    //   await flutterTts.awaitSpeakCompletion(true);
    //   await flutterTts.speak(speakString);
    // }
  }

  Future<dynamic> classifyImage(String image) async {
    var output = await Tflite.runModelOnImage(
      path: image,
      numResults: 6,
      threshold: 0.5,
      imageMean: 127.5, //127.5
      imageStd: 127.5, //127.5
    );

    op = output;

    print(op);

    if (op != null) {
      String stringValue = op[0]["label"].toString();
      int totalValue = int.parse(stringValue);

      if (counter == true) {
        total += totalValue;
      }

      runTextToSpeech("$stringValue pesos", total);
    } else {
      runTextToSpeech("No note found", total);
    }

    // if (op != null) {
    //   if (op[0]["label"] == "20") {
    //     total += op[0]["label"];
    //     runTextToSpeech("${op[0]["label"]} pesos", total);
    //   }
    //   if (op[0]["label"] == "50") {
    //     total += 50;
    //     runTextToSpeech("50 pesos", total);
    //   }
    //   if (op[0]["label"] == "100") {
    //     total += 100;
    //     runTextToSpeech("100 pesos", total);
    //   }
    //   if (op[0]["label"] == "200") {
    //     total += 200;
    //     runTextToSpeech("200 pesos", total);
    //   }

    //   if (op[0]["label"] == "500") {
    //     total += 500;
    //     runTextToSpeech("500 pesos", total);
    //   }

    //   if (op[0]["label"] == "1000") {
    //     total += 1000;
    //     runTextToSpeech("1000 pesos", total);
    //   }
    // } else
    //   runTextToSpeech("No note found", total);

    setState(() {
      loading = false;
      op = op;
      total = total;
    });
  }

  loadModel() async {
    try {
      await Tflite.loadModel(
          model: "assets/modelv1.tflite",
          labels: "assets/labels_mislabel.txt");
      print('Model Loaded Succesfully');
    } on PlatformException {
      print('Model Failed to Load');
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
