import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
          //begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xCC0A0930),
            Colors.black.withOpacity(0.0),
          ]).createShader(rect),
      blendMode: BlendMode.darken,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              // begin: Alignment.topLeft,
              // end: Alignment.bottomRight,
              colors: [
                const Color(0xCC0A0930),
                Colors.black.withOpacity(0.0),
              ]),
        ),
        // child: BackdropFilter(
        //   filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
        //   child: Center(child: Text('')),
        // ),
      ),
    );
  }
}
