import '../Implementation/provider/firestore_service_repository.dart';
import '../Repository/provider/service_repository.dart';
import '../cubit/service_provider_cubit/service_provider_cubit.dart';
import '../helper/help_metod.dart';
import 'provider/services/add_service_page.dart';
import 'provider/services/services_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text('حجوزات اليوم')),
    Center(child: Text('المواعيد')),
    Center(child: ServicesPage()),
    Center(child: Text('المزيد')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('صالون')),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => AddServicePage()));
        },
        child: Icon(Icons.add),
      ),
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
