import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Iconsax.arrow_right_3, size: 16),
      onTap: onTap,
    );
  }
}
