import 'package:flutter/material.dart';

/// Status bar showing time icon
class AppStatusBar extends StatelessWidget {
  const AppStatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 51,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('حجز', style: TextStyle(fontSize: 14)),
          Icon(Icons.approval, size: 18),
        ],
      ),
    );
  }
}
