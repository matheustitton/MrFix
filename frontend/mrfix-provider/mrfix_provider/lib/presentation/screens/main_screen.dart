import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import 'home_screen.dart';
import 'requests_screen.dart';
import 'add_specialty_screen.dart';
import 'profile_screen.dart';

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
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Polling gerenciado aqui, no widget que vive enquanto o usuário está logado.
    // O HomeScreen não chama mais startPolling/stopPolling.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ServiceRequestProvider>();
      p.loadAll();
      p.loadMySpecialties();
      p.startPolling();
    });
  }

  @override
  void dispose() {
    context.read<ServiceRequestProvider>().stopPolling();
    super.dispose();
  }

  void _openAddSpecialty() async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AddSpecialtyScreen(),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(
              parent: anim, curve: Curves.easeOutCubic)),
          child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _index = index);
    // Ao voltar para Início, zera o badge
    if (index == 0) {
      context.read<ServiceRequestProvider>().clearBadge();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSpecialty,
        backgroundColor: AppConstants.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        tooltip: 'Adicionar especialidade',
        child: const Icon(Icons.build_rounded, size: 26),
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
            child: Consumer<ServiceRequestProvider>(
              builder: (_, p, __) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Início',
                    selected: _index == 0,
                    badge: _index != 0 ? p.newRequestCount : 0,
                    onTap: () => _onNavTap(0)),
                  _NavItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Pedidos',
                    selected: _index == 1,
                    onTap: () => _onNavTap(1)),
                  const SizedBox(width: 56), // espaço do FAB
                  _NavItem(
                    icon: Icons.build_circle_outlined,
                    label: 'Especialidades',
                    selected: false,
                    onTap: _openAddSpecialty),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Perfil',
                    selected: _index == 2,
                    onTap: () => _onNavTap(2)),
                ],
              ),
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
  final int badge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? AppConstants.primary
        : (isDark
            ? AppConstants.textSecondaryDark
            : AppConstants.textSecondaryLight);

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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: 22),
              if (badge > 0)
                Positioned(
                  top: -5,
                  right: -7,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4A61E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppConstants.surfaceDark : Colors.white,
                        width: 1.5),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
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
