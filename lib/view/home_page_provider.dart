import 'package:barber/constants.dart';
import 'package:barber/cubit/auth/auth_cubit.dart';
import 'package:barber/helper/help_metod.dart';
import 'package:barber/view/provider/selection_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'provider/schedule/add_schedule_page.dart';
import 'provider/schedule/schedule_page.dart';

import 'provider/services/add_service_page.dart';
import 'provider/services/services_page.dart';
import 'package:flutter/material.dart';

class HomePageProvider extends StatefulWidget {
  final User? authUser;

  const HomePageProvider({super.key, this.authUser});
  @override
  State<HomePageProvider> createState() => _HomePageProviderState();
}

class _HomePageProviderState extends State<HomePageProvider> {
  int _selectedIndex = 0;

  final List<Widget> _screensProvider = [
    Center(child: Text('حجوزات اليوم')),
    Center(child: SchedulePage()),
    Center(child: ServicesPage(uid: '')),
    Center(child: Text('المزيد')),
  ];

  @override
  Widget build(BuildContext context) {
    final List<FloatingActionButton?> _fabsProvider = [
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
        onPressed: () async {
          await context.read<AuthCubit>().logout();
          gotoPage_pushReplacement(context, SelectionPage());
        },
        child: Icon(Icons.logout),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(kAppName)),
      body: _screensProvider[_selectedIndex],
      floatingActionButton: _fabsProvider[_selectedIndex],
      bottomNavigationBar: _bottomNavigationBarProvider(),
    );
  }

  BottomNavigationBar _bottomNavigationBarProvider() {
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
