import 'package:barber/core/constants/app_path.dart';
import 'package:barber/feature/auth/auth_cubit/auth_cubit.dart';
import 'package:barber/feature/company_mode/screens/appointments_page.dart';
import 'package:barber/feature/company_mode/screens/services_page.dart';
import 'package:barber/feature/company_mode/widget/settings_widget.dart';
import 'package:barber/feature/company_mode/widget/today_appointments_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CompanyHome extends StatefulWidget {
  const CompanyHome({super.key});

  @override
  _CompanyHomeState createState() => _CompanyHomeState();
}

class _CompanyHomeState extends State<CompanyHome> {
  int _currentIndex = 0;

  List<Widget> _buildPages(String userId) => [
    TodayAppointmentsWidget(),
    AppointmentsPage(userId: userId),
    ServicesPage(userId: userId),
    SettingsWidget(),
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
        if (state is AuthCompany) {
          final String userId = state.userId;
          _fabActions.addAll([
            null,
            () {
              context.push(AppPath.appointmentsAdd,extra: {'userId': userId});
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
          return const Center(
            child: Text('غير مصرح لك بالوصول إلى هذه الصفحة'),
          );
        }
      },
    );
  }
}
