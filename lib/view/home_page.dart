import 'package:barber/constants.dart';
import 'package:barber/helper/help_metod.dart';
import 'package:barber/view/splash_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'provider/schedule/add_schedule_page.dart';
import 'provider/schedule/schedule_page.dart';

import 'provider/services/add_service_page.dart';
import 'provider/services/services_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text('حجوزات اليوم')),
    Center(child: SchedulePage()),
    Center(child: ServicesPage()),
    Center(child: Text('المزيد')),
  ];

  @override
  Widget build(BuildContext context) {
    final List<FloatingActionButton?> _fabs = [
      null,
      FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => AddSchedulePage()));
        },
        child: Icon(Icons.edit_calendar),
      ),
      FloatingActionButton(
        onPressed: () {
          // إضافة خدمة جديدة
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => AddServicePage()));
        },
        child: Icon(Icons.add_task),
      ),
      FloatingActionButton(
        onPressed: () async{
        
           
              await FirebaseAuth.instance.signOut();
              // بعدها مثلاً ترجع لصفحة تسجيل الدخول
              gotoPage(context, SplashPage());
          
        },
        child: Icon(Icons.logout),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(kAppName)),
      body: _screens[_selectedIndex],
      floatingActionButton: _fabs[_selectedIndex],
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap:
          (index) => setState(() {
            _selectedIndex = index;
          }),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.today), label: 'اليوم'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'المواعيد',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.design_services),
          label: 'الخدمات',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'المزيد'),
      ],
    );
  }
}
