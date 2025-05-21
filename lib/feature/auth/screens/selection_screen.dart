import 'package:barber/core/constants/app_path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Screen to select between Merchant and Customer modes
class SelectionScreen extends StatelessWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  void _onMerchantSelected(BuildContext context) {
    // Navigate to merchant home
    context.go(AppPath.companyHome);
  }

  void _onCustomerSelected(BuildContext context) {
    // Navigate to customer home
    context.go(AppPath.customerHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App icon and name
              Column(
                children: const [
                  Icon(
                    Icons.event_available,
                    size: 64,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'BookingPal',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Prompt text
              const Text(
                'اختر وضع الاستخدام المناسب لك للبدء',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              // Selection options
              SelectionOption(
                icon: Icons.storefront,
                label: 'وضع أصحاب المحلات',
                onTap: () => _onMerchantSelected(context),
              ),
              const SizedBox(height: 32),
              SelectionOption(
                icon: Icons.person,
                label: 'وضع الزبون',
                onTap: () => _onCustomerSelected(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable widget for selection button
class SelectionOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SelectionOption({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
