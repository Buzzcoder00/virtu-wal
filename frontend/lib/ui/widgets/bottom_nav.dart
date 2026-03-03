import 'package:flutter/material.dart';

import '../dashboard.dart';
import '../generate_qr.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context: context,
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            onTap: () {
              if (currentIndex != 0) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()));
              }
            },
          ),
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.add_circle_outline,
            activeIcon: Icons.add_circle,
            label: 'Generate',
            onTap: () {
              if (currentIndex != 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const GenerateQRScreen()));
              }
            },
          ),
          _buildNavItem(
            context: context,
            index: 2,
            icon: Icons.history,
            activeIcon: Icons.history,
            label: 'History',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isActive = currentIndex == index;
    final color = isActive ? const Color(0xFF6A3CE8) : Colors.grey[600];

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFF6A3CE8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16))
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: color),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
