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
    await Future.delayed(Duration(milliseconds: 3000), () {});
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: new Container(
          alignment: Alignment.center,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              

              Text('Banknote Detection 💵',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:25.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              ),

              SizedBox(height: 20),

              SpinKitCubeGrid(
                color: Colors.black,
                size: 50.0,
              ),

            ],

          )
          ));
  }
}
