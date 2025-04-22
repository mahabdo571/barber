import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('صالون')),
      body: Text('الرئيسية'),
      floatingActionButton: FloatingActionButton(onPressed: () {}),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (v) {},
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'الرئيسيسة'),
          BottomNavigationBarItem(
            icon: Icon(Icons.abc_outlined),
            label: 'hgl,hud]',
          ),
        ],
      ),
    );
  }
}
