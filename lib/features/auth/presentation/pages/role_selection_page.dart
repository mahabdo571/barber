import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../cubit/auth_cubit.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختر نوع الحساب'), centerTitle: true),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            if (state.role == AppConstants.roleBusiness) {
              context.go(AppConstants.routeBusinessProfile);
            } else {
              context.go(AppConstants.routeCustomerProfile);
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'مرحباً بك في تطبيق الحلاق',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _RoleCard(
                  title: 'صاحب صالون',
                  description: 'إدارة صالونك وحجوزات عملائك',
                  icon: Icons.business,
                  onTap:
                      () => context.read<AuthCubit>().setUserRole(
                        AppConstants.roleBusiness,
                      ),
                  isLoading: state is AuthLoading,
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  title: 'عميل',
                  description: 'احجز موعدك في أفضل الصالونات',
                  icon: Icons.person,
                  onTap:
                      () => context.read<AuthCubit>().setUserRole(
                        AppConstants.roleCustomer,
                      ),
                  isLoading: state is AuthLoading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
