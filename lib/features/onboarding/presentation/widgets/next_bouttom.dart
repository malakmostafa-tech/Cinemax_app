import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  final VoidCallback onTap;

  const NextButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          children: [
            Positioned(
              top: 15,
              right: 10,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF38B8C7), width: 5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF38B8C7),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF1F1D2B),
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
