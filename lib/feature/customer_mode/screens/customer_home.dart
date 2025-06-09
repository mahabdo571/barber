import 'package:barber/core/constants/app_path.dart';
import 'package:barber/feature/auth/auth_cubit/auth_cubit.dart';
import 'package:barber/feature/company_mode/screens/services_page.dart';
import 'package:barber/feature/company_mode/widget/settings_widget.dart';
import 'package:barber/feature/company_mode/widget/today_appointments_widget.dart';
import 'package:barber/feature/customer_mode/screens/favorites_page.dart';
import 'package:barber/feature/customer_mode/screens/user_search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _currentIndex = 0;

  List<Widget> _buildPages(String userId) => [
    UserSearchView(),
    FavoritesPage(),
    Text('dd'),
    Text('dd'),
  ];

  final List<IconData?> _fabIcons = [null, Icons.add, Icons.add, null];

  final List<VoidCallback?> _fabActions = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthCustomer) {
          final String userId = state.userId;
          _fabActions.addAll([
            null,
            () {
              context.push(AppPath.appointmentsAdd);
            },
            () {
              context.push(AppPath.addService, extra: {'userId': userId});
            },
            null,
          ]);
          final List<Widget> _pages = _buildPages(userId);

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
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'المفضلة',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.timelapse),
                  label: 'مواعيدي',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'الإعدادات',
                ),
              ],
            ),
            floatingActionButton:
                (_fabIcons[_currentIndex] != null &&
                        _fabActions[_currentIndex] != null)
                    ? FloatingActionButton(
                      child: Icon(_fabIcons[_currentIndex]!),
                      onPressed: _fabActions[_currentIndex],
                    )
                    : null,
          );
        } else if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('erorr'));
        }
      },
    );
  }
}
