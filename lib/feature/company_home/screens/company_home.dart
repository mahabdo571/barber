import 'package:barber/feature/company_home/widget/add_appointment_widget.dart';
import 'package:barber/feature/company_home/widget/customer_home.dart';
import 'package:barber/feature/company_home/widget/services_widget.dart';
import 'package:barber/feature/company_home/widget/today_appointments_widget.dart';
import 'package:flutter/material.dart';

class CompanyHome extends StatefulWidget {
  @override
  _CompanyHomeState createState() => _CompanyHomeState();
}

class _CompanyHomeState extends State<CompanyHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    TodayAppointmentsWidget(),
    AddAppointmentWidget(),
    ServicesWidget(),
    SettingsWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('حجوزات')),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'مواعيد اليوم',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'إضافة موعد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: 'الخدمات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
