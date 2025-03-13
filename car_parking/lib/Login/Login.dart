import 'package:car_parking/Login/Background.dart';
import 'package:car_parking/Login/Signup.dart';
import 'package:car_parking/Login/loginpage.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackgroundScreen(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF1D749A), Color(0xFF296093)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          Navigator.push(context,MaterialPageRoute(builder: (ctx)=>Loginpage()));
                        },
                        child: Text(
                          "Sign In",
                          style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                // ignore: avoid_unnecessary_containers
                child: SizedBox(
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF1D749A), Color(0xFF296093)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight
                        ),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          Navigator.push(context,MaterialPageRoute(builder: (ctx)=>Signup()));
                        },
                        child: Text(
                          "Create an account",
                          style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
    );
  }
}
