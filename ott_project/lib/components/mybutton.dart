import 'package:flutter/material.dart';
import 'package:ott_project/components/pallete.dart';

class MyButton extends StatelessWidget {
  const MyButton(
      {super.key,
      required this.buttonName,
      required void Function() onPressed});

  final String buttonName;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.07,
      width: size.width * 0.8,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: Colors.blueGrey),
      child: TextButton(
          onPressed: () {},
          child: Text(
            buttonName,
            style: kBodyText.copyWith(fontWeight: FontWeight.bold),
          )),
    );
  }
}
