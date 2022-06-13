import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ncnn_yolox_flutter/ncnn_yolox_flutter.dart';

int total = 0;
bool counter = true;

class TakePictureScreen extends StatefulWidget {
  final NcnnYolox ncnn;
  final CameraDescription camera;
  const TakePictureScreen({
    Key key,
    @required this.camera,
    @required this.ncnn,
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
      imageFormatGroup: ImageFormatGroup.yuv420,
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
          excludeHeaderSemantics: true,
          title: Semantics(
            label: 'App Logo',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/Icon_Clear.png",
                  height: 55,
                  width: 70,
                ),
                const Text('PesoReader',
                    style: TextStyle(color: Colors.black, fontSize: 12)),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          actions: [
            Semantics(
              label: 'Counter',
              child: IconButton(
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
                    total = 0;
                  } else {
                    flutterTts.speak("Counter Disabled");
                  }
                },
                icon: Icon(Icons.layers_clear,
                    color: counter ? Colors.black : Colors.grey, size: 25),
              ),
            ),
          ],
        ),

        // Wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner
        // until the controller has finished initializing.
        backgroundColor: Colors.black,
        body: Stack(children: <Widget>[
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                _controller.setFlashMode(FlashMode.off);
                return Center(child: CameraPreview(_controller));
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Semantics(
            label: 'Detect bill',
            onLongPressHint: 'Reset total counter',
            child: GestureDetector(onTap: () async {
              try {
                // Ensure that the camera is initialized.
                await _initializeControllerFuture;

                // Attempt to take a picture and log where it's been saved.
                final image = await _controller.takePicture();

                // If the picture was taken, display it on a new screen.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return DisplayPictureScreen(image.path, widget.ncnn);
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
          ),
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
                    return DisplayPictureScreen(path, widget.ncnn);
                  } //DisplayPictureScreen(path),
                      ),
                );
              }
            },
          ),
        ));
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final NcnnYolox ncnn;
  DisplayPictureScreen(this.imagePath, this.ncnn);
  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List op;
  Image img;
  bool loading = true;
  String bill;

  final List<String> _labels = ['20', '50', '100', '200', '500', '1000'];

  @override
  void initState() {
    super.initState();
    classifyImage(widget.imagePath, widget.ncnn, _labels);
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).maybePop();
    });

    return Scaffold(
      appBar: AppBar(
        excludeHeaderSemantics: true,
        toolbarHeight: 80,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              excluding: true,
              child: Image.asset(
                "assets/Icon_Clear.png",
                height: 55,
                width: 70,
              ),
            ),
            ExcludeSemantics(
              excluding: true,
              child: const Text('PesoReader',
                  style: TextStyle(color: Colors.black, fontSize: 12)),
            ),
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
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      child: counter
                          ? Text('$bill, Total: $total Pesos',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold))
                          : Text(
                              bill,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold),
                            ),
                      alignment: Alignment.center,
                    ),
                  ),
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
      await flutterTts.speak('$speakString! Your total is: $tot');
    } else if (counter == false) {
      await flutterTts.speak('$speakString!');
    }
  }

  Future<dynamic> classifyImage(String image, final ncnn, List labels) async {
    final decodedImage = await decodeImageFromList(
      File(
        widget.imagePath,
      ).readAsBytesSync(),
    );

    final pixels = (await decodedImage.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    ))
        .buffer
        .asUint8List();

    final results = ncnn.detect(
      pixels: pixels,
      pixelFormat: PixelFormat.rgba,
      width: decodedImage.width,
      height: decodedImage.height,
    );

    op = results;
    bill = 'No Banknote Found!';

    print(op);

    if (op.isEmpty == true) {
      runTextToSpeech("No banknote found", total);
    } else if (op != null) {
      int indexLabel = op[0].label;
      bill = labels[indexLabel] + ' Pesos';

      String stringValue = labels[indexLabel].toString();
      int totalValue = int.parse(stringValue);

      print(bill);

      if (counter == true) {
        total += totalValue;
      }

      runTextToSpeech(bill, total);
    } else {
      runTextToSpeech("No note found", total);
    }

    setState(() {
      loading = false;
      op = op;
      total = total;
      bill = bill;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
