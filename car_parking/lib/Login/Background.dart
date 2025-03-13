import 'package:flutter/material.dart';

class BackgroundScreen extends StatelessWidget {
  final Widget child;

  const BackgroundScreen({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/image-parkit.jpg"),
          fit: BoxFit.cover, // Cover full screen
        ),
      ),
      child: child, // Your main screen content
    );
  }
}
