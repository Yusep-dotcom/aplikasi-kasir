import 'package:aplikasi_kasir/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final box = GetStorage();

  CustomHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final kasirName = GetStorage().read('userName') ?? 'Admin';
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            '${_getDayName()} | Kasir: $kasirName',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

String _getDayName() {
  final now = DateTime.now();

  final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
}
