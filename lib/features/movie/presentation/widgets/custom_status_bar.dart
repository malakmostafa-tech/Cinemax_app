import 'package:flutter/material.dart';

class CustomStatusBar extends StatelessWidget {
  const CustomStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '19:27',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: const [
              Icon(Icons.signal_cellular_4_bar_rounded, color: Colors.white, size: 15),
              SizedBox(width: 6),
              Icon(Icons.wifi_rounded, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Icon(Icons.battery_full_rounded, color: Colors.white, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
