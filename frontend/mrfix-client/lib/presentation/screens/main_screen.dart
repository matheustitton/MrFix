import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import 'home_screen.dart';
import 'requests_screen.dart';
import 'new_request_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    RequestsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const NewRequestScreen(),
            transitionsBuilder: (_, anim, __, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1), end: Offset.zero)
                  .animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic)),
                child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        ),
        backgroundColor: AppConstants.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppConstants.surfaceDark : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Início',
                  selected: _index == 0, onTap: () => setState(() => _index = 0)),
                _NavItem(icon: Icons.receipt_long_rounded, label: 'Pedidos',
                  selected: _index == 1, onTap: () => setState(() => _index = 1)),
                const SizedBox(width: 56), // FAB space
                _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Mensagens',
                  selected: false, onTap: () {}),
                _NavItem(icon: Icons.person_outline_rounded, label: 'Perfil',
                  selected: false, onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.label,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? AppConstants.primary
        : (isDark ? AppConstants.textSecondaryDark : AppConstants.textSecondaryLight);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppConstants.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(label,
            style: TextStyle(
              color: color, fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            )),
        ]),
      ),
    );
  }
}