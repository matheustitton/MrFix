import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final auth    = context.watch<AuthProvider>();
    final theme   = context.watch<ThemeProvider>();
    final reqs    = context.watch<ServiceRequestProvider>().requests;
    final user    = auth.user;

    // Estatísticas calculadas localmente
    final completed = reqs.where((r) => r.isCompleted).length;
    final cancelled = reqs.where((r) => r.isCancelled).length;
    final active    = reqs.where((r) => !r.isCompleted && !r.isCancelled).length;

    final initial = user?.name.isNotEmpty == true
        ? user!.name[0].toUpperCase()
        : 'C';

    final bg     = isDark ? AppConstants.bgDark    : AppConstants.bgLight;
    final surf   = isDark ? AppConstants.surfaceDark : Colors.white;
    final txtPri = isDark ? AppConstants.textPrimaryDark   : AppConstants.textPrimaryLight;
    final txtSec = isDark ? AppConstants.textSecondaryDark : AppConstants.textSecondaryLight;
    final bdr    = isDark ? AppConstants.borderDark : AppConstants.borderLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: surf,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(children: [

                  // Topo: título + toggle dark
                  Row(children: [
                    Text('Meu Perfil',
                      style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800,
                        color: txtPri, letterSpacing: -0.4)),
                    const Spacer(),
                    GestureDetector(
                      onTap: theme.toggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppConstants.surface2Dark
                              : AppConstants.bgLight,
                          borderRadius: BorderRadius.circular(10)),
                        child: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          size: 18, color: txtSec)),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Avatar + nome + email
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppConstants.primary,
                      shape: BoxShape.circle,
                      boxShadow: AppConstants.primaryShadow),
                    child: Center(
                      child: Text(initial,
                        style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w800,
                          color: Colors.white)))),
                  const SizedBox(height: 14),
                  Text(user?.name ?? '',
                    style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800,
                      color: txtPri)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '',
                    style: TextStyle(fontSize: 13, color: txtSec)),
                  const SizedBox(height: 8),

                  // Badge de gênero
                  if (user?.gender != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppConstants.primary.withOpacity(0.2))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.person_rounded,
                          size: 13, color: AppConstants.primary),
                        const SizedBox(width: 5),
                        Text(
                          user!.gender == 'female' ? 'Mulher'
                          : user.gender == 'male'   ? 'Homem'
                          : 'Não informado',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppConstants.primary)),
                      ])),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Estatísticas ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Resumo de pedidos', txtSec),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _StatCard(
                        label: 'Ativos',
                        value: '$active',
                        icon: Icons.hourglass_empty_rounded,
                        color: const Color(0xFFF59E0B),
                        isDark: isDark, surf: surf, bdr: bdr)),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(
                        label: 'Concluídos',
                        value: '$completed',
                        icon: Icons.check_circle_rounded,
                        color: AppConstants.success,
                        isDark: isDark, surf: surf, bdr: bdr)),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(
                        label: 'Cancelados',
                        value: '$cancelled',
                        icon: Icons.cancel_rounded,
                        color: AppConstants.error,
                        isDark: isDark, surf: surf, bdr: bdr)),
                    ]),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Informações da conta ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Informações da conta', txtSec),
                    const SizedBox(height: 12),
                    _InfoCard(surf: surf, bdr: bdr, children: [
                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Nome completo',
                        value: user?.name ?? '-',
                        isDark: isDark),
                      _Divider(bdr: bdr),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'E-mail',
                        value: user?.email ?? '-',
                        isDark: isDark),
                      _Divider(bdr: bdr),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Telefone',
                        value: user?.phone ?? 'Não informado',
                        isDark: isDark),
                      _Divider(bdr: bdr),
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Tipo de conta',
                        value: 'Cliente',
                        isDark: isDark),
                    ]),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Preferências ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Preferências', txtSec),
                    const SizedBox(height: 12),
                    _InfoCard(surf: surf, bdr: bdr, children: [
                      _ToggleRow(
                        icon: Icons.dark_mode_outlined,
                        label: 'Modo escuro',
                        value: isDark,
                        onChanged: (_) => theme.toggle,
                        onTap: theme.toggle,
                        isDark: isDark),
                      _Divider(bdr: bdr),
                      _ActionRow(
                        icon: Icons.notifications_outlined,
                        label: 'Notificações',
                        trailing: Text('Ativadas',
                          style: TextStyle(
                            fontSize: 13, color: AppConstants.success,
                            fontWeight: FontWeight.w600)),
                        isDark: isDark,
                        onTap: () {}),
                    ]),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Suporte ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Suporte', txtSec),
                    const SizedBox(height: 12),
                    _InfoCard(surf: surf, bdr: bdr, children: [
                      _ActionRow(
                        icon: Icons.help_outline_rounded,
                        label: 'Central de ajuda',
                        isDark: isDark,
                        onTap: () {}),
                      _Divider(bdr: bdr),
                      _ActionRow(
                        icon: Icons.shield_outlined,
                        label: 'Política de privacidade',
                        isDark: isDark,
                        onTap: () {}),
                      _Divider(bdr: bdr),
                      _ActionRow(
                        icon: Icons.description_outlined,
                        label: 'Termos de uso',
                        isDark: isDark,
                        onTap: () {}),
                    ]),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Logout ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: surf,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: Text('Sair da conta',
                            style: TextStyle(
                              fontWeight: FontWeight.w800, color: txtPri)),
                          content: Text(
                            'Tem certeza que deseja sair?',
                            style: TextStyle(color: txtSec)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancelar',
                                style: TextStyle(color: txtSec))),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sair',
                                style: TextStyle(
                                  color: AppConstants.error,
                                  fontWeight: FontWeight.w700))),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        context.read<ServiceRequestProvider>().stopPolling();
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (_) => false);
                        }
                      }
                    },
                    icon: const Icon(Icons.logout_rounded,
                      color: AppConstants.error, size: 20),
                    label: const Text('Sair da conta',
                      style: TextStyle(
                        color: AppConstants.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppConstants.error, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets internos ───────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionTitle(this.text, this.color);
  @override
  Widget build(BuildContext context) => Text(text,
    style: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w700,
      letterSpacing: 0.5, color: color));
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final Color surf;
  final Color bdr;

  const _StatCard({
    required this.label, required this.value,
    required this.icon,  required this.color,
    required this.isDark, required this.surf, required this.bdr});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    decoration: BoxDecoration(
      color: surf,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: bdr)),
    child: Column(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20)),
      const SizedBox(height: 10),
      Text(value,
        style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w900,
          color: isDark
              ? AppConstants.textPrimaryDark
              : AppConstants.textPrimaryLight)),
      const SizedBox(height: 2),
      Text(label,
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: isDark
              ? AppConstants.textSecondaryDark
              : AppConstants.textSecondaryLight)),
    ]),
  );
}

class _InfoCard extends StatelessWidget {
  final Color surf;
  final Color bdr;
  final List<Widget> children;
  const _InfoCard({required this.surf, required this.bdr, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: surf,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: bdr)),
    child: Column(children: children));
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  const _InfoRow({required this.icon, required this.label,
    required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      Icon(icon, size: 18,
        color: isDark
            ? AppConstants.textSecondaryDark
            : AppConstants.textSecondaryLight),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppConstants.textSecondaryDark
                  : AppConstants.textSecondaryLight)),
          const SizedBox(height: 2),
          Text(value,
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: isDark
                  ? AppConstants.textPrimaryDark
                  : AppConstants.textPrimaryLight)),
        ],
      )),
    ]),
  );
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final bool isDark;
  final VoidCallback onTap;
  const _ActionRow({required this.icon, required this.label,
    required this.isDark, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, size: 18,
          color: isDark
              ? AppConstants.textSecondaryDark
              : AppConstants.textSecondaryLight),
        const SizedBox(width: 14),
        Expanded(child: Text(label,
          style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: isDark
                ? AppConstants.textPrimaryDark
                : AppConstants.textPrimaryLight))),
        trailing ?? Icon(Icons.chevron_right_rounded,
          size: 18,
          color: isDark
              ? AppConstants.textSecondaryDark
              : AppConstants.textSecondaryLight),
      ]),
    ),
  );
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTap;
  final bool isDark;
  const _ToggleRow({required this.icon, required this.label,
    required this.value, required this.onChanged,
    required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Icon(icon, size: 18,
        color: isDark
            ? AppConstants.textSecondaryDark
            : AppConstants.textSecondaryLight),
      const SizedBox(width: 14),
      Expanded(child: Text(label,
        style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: isDark
              ? AppConstants.textPrimaryDark
              : AppConstants.textPrimaryLight))),
      Switch(
        value: value,
        onChanged: (_) => onTap(),
        activeColor: AppConstants.primary,
      ),
    ]),
  );
}

class _Divider extends StatelessWidget {
  final Color bdr;
  const _Divider({required this.bdr});
  @override
  Widget build(BuildContext context) => Divider(
    height: 1, indent: 48, endIndent: 0, color: bdr);
}