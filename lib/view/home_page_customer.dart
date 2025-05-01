import 'package:barber/constants.dart';
import 'package:barber/helper/help_metod.dart';
import 'package:barber/view/customers/provider_search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePageCustomer extends StatefulWidget {
  final User? authUser;

  const HomePageCustomer({super.key, this.authUser});
  @override
  State<HomePageCustomer> createState() => _HomePageCustomerState();
}

class _HomePageCustomerState extends State<HomePageCustomer> {
  int _selectedIndex = 0;

  final List<Widget> _screensCustomers = [
    Center(child: Text('دوري')),
    Center(child: Text('حجوزاتي')),
    Center(child: ProviderSearchPage()),

    Center(child: Text('المفضلة')),
    Center(child: Text('المزيد')),
  ];

  @override
  Widget build(BuildContext context) {
    final List<FloatingActionButton?> _fabsCustomers = [
      null,
      null,
      null,

      null,
      FloatingActionButton(
        onPressed: () async {
          await logout(context);
        },
        child: Icon(Icons.logout),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(kAppName)),
      body: _screensCustomers[_selectedIndex],
      floatingActionButton: _fabsCustomers[_selectedIndex],
      bottomNavigationBar: _bottomNavigationBarCustomers(),
    );
  }

  BottomNavigationBar _bottomNavigationBarCustomers() {
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
        BottomNavigationBarItem(icon: Icon(Icons.queue), label: 'دوري'),
        BottomNavigationBarItem(icon: Icon(Icons.today), label: 'حجوزاتي'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),

        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'المزيد'),
      ],
    );
  }
}
