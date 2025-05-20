import 'package:barber/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Input field for email
class PhoneInputField extends StatelessWidget {
  const PhoneInputField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تسجيل الدخول',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ادخل رقم الهاتف لارسال رمز التحقق لك',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
        ),
        const SizedBox(height: 32),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFD1D5DB)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.phone, color: Colors.grey),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,

                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration.collapsed(
                      hintText: '+970566123456',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
