import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  const Loading({Key key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void initState() {
    super.initState();
    navigateHome();
  }

  navigateHome() async {
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body:  Container(
          alignment: Alignment.center,
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/Icon.gif",
                          height: 120,
                          width:120,),
              const Text('PesoReader 💵',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:25.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              ),

              const SizedBox(height: 50),

              const SpinKitFadingCube(
                color: Colors.black,
                size: 50.0,
              ),

            ],

          )
          ));
  }
}
