import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import 'login_screen.dart';
import 'request_detail_screen.dart';
import 'profile_screen.dart';
import 'add_specialty_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth   = context.watch<AuthProvider>();
    final theme  = context.watch<ThemeProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppConstants.surfaceDark : AppConstants.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8, offset: const Offset(0, 2))
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(
                      auth.user?.name.isNotEmpty == true
                          ? auth.user!.name[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, ${auth.user?.name.split(' ').first ?? 'Prestador'} 👷',
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800,
                        color: Colors.white)),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Color(0xFFF4A61E)),
                      const SizedBox(width: 3),
                      Text(
                        '${auth.user?.averageRating.toStringAsFixed(1) ?? '0.0'} '
                        '(${auth.user?.ratingCount ?? 0} avaliações)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12)),
                    ]),
                  ],
                )),
                GestureDetector(
                  onTap: theme.toggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36, height: 36,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Colors.white, size: 18)),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  child: Container(
                    width: 36, height: 36,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.person_outline_rounded,
                        color: Colors.white, size: 18)),
                ),
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.logout_rounded,
                        color: Colors.white, size: 18)),
                ),
              ]),
              const SizedBox(height: 16),

              // Tabs
              Consumer<ServiceRequestProvider>(
                builder: (_, p, __) => TabBar(
                  controller: _tab,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: [
                    Tab(child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Disponíveis'),
                        if (p.newRequestCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4A61E),
                              borderRadius: BorderRadius.circular(10)),
                            child: Text('${p.newRequestCount}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white))),
                        ],
                      ],
                    )),
                    const Tab(text: 'Meus serviços'),
                    Tab(child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Especialidades'),
                        const SizedBox(width: 6),
                        Consumer<ServiceRequestProvider>(
                          builder: (_, p, __) => p.mySpecialties.isEmpty
                            ? Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(
                                  color: AppConstants.error,
                                  shape: BoxShape.circle))
                            : const SizedBox.shrink(),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ]),
          ),

          // Polling indicator
          Consumer<ServiceRequestProvider>(
            builder: (_, p, __) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: (!p.loading && p.availableRequests.isNotEmpty) ? 28 : 0,
              color: AppConstants.primary.withOpacity(0.06),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 10, height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppConstants.primary.withOpacity(0.6))),
                  const SizedBox(width: 8),
                  Text('Atualizando a cada 5s...',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppConstants.primary.withOpacity(0.7))),
                ],
              ),
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _AvailableTab(isDark: isDark),
                _MyRequestsTab(isDark: isDark),
                _SpecialtiesTab(isDark: isDark),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Available Tab ──────────────────────────────────────────────────────────
class _AvailableTab extends StatelessWidget {
  final bool isDark;
  const _AvailableTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceRequestProvider>(
      builder: (_, p, __) {
        if (p.loading && p.availableRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator(
              color: AppConstants.primary, strokeWidth: 2));
        }
        if (p.availableRequests.isEmpty) {
          return _EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Nenhuma solicitação disponível',
            subtitle: 'Novas solicitações aparecerão aqui automaticamente',
            isDark: isDark,
          );
        }
        return RefreshIndicator(
          onRefresh: () => p.loadAll(),
          color: AppConstants.primary,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: p.availableRequests.length,
            itemBuilder: (ctx, i) {
              final req = p.availableRequests[i];
              return _AvailableCard(
                request: req,
                isDark: isDark,
                onTap: () {
                  p.selectRequest(req);
                  Navigator.push(ctx, MaterialPageRoute(
                    builder: (_) => RequestDetailScreen(
                        requestId: req.id, isAvailable: true)));
                },
              );
            },
          ),
        );
      },
    );
  }
}

// ── My Requests Tab ────────────────────────────────────────────────────────
class _MyRequestsTab extends StatelessWidget {
  final bool isDark;
  const _MyRequestsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceRequestProvider>(
      builder: (_, p, __) {
        if (p.loading && p.myRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator(
              color: AppConstants.primary, strokeWidth: 2));
        }
        if (p.myRequests.isEmpty) {
          return _EmptyState(
            icon: Icons.work_off_outlined,
            title: 'Nenhum serviço ainda',
            subtitle: 'Aceite uma solicitação para começar',
            isDark: isDark,
          );
        }
        final active = p.myRequests
            .where((r) => !r.isCompleted && !r.isCancelled)
            .toList();
        final done = p.myRequests
            .where((r) => r.isCompleted || r.isCancelled)
            .toList();

        return RefreshIndicator(
          onRefresh: () => p.loadAll(),
          color: AppConstants.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            children: [
              if (active.isNotEmpty) ...[
                _SectionHeader('Em andamento', isDark: isDark),
                ...active.map((r) => _MyCard(
                  request: r, isDark: isDark,
                  onTap: () {
                    p.selectRequest(r);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => RequestDetailScreen(
                          requestId: r.id, isAvailable: false)));
                  })),
                const SizedBox(height: 8),
              ],
              if (done.isNotEmpty) ...[
                _SectionHeader('Histórico', isDark: isDark),
                ...done.map((r) => _MyCard(
                  request: r, isDark: isDark,
                  onTap: () {
                    p.selectRequest(r);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => RequestDetailScreen(
                          requestId: r.id, isAvailable: false)));
                  })),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Specialties Tab ────────────────────────────────────────────────────────
class _SpecialtiesTab extends StatelessWidget {
  final bool isDark;
  const _SpecialtiesTab({required this.isDark});

  void _goToAddSpecialty(BuildContext context) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AddSpecialtyScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceRequestProvider>(
      builder: (_, p, __) {
        if (p.loading && p.mySpecialties.isEmpty) {
          return const Center(child: CircularProgressIndicator(
              color: AppConstants.primary, strokeWidth: 2));
        }
        if (p.mySpecialties.isEmpty) {
          return _EmptyState(
            icon: Icons.build_circle_outlined,
            title: 'Nenhuma especialidade',
            subtitle: 'Toque no + para adicionar sua primeira especialidade e aparecer nas buscas',
            isDark: isDark,
          );
        }
        return RefreshIndicator(
          onRefresh: () => p.loadMySpecialties(),
          color: AppConstants.primary,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: p.mySpecialties.length,
            itemBuilder: (_, i) {
              final s = p.mySpecialties[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDark
                      ? AppConstants.cardShadowDark
                      : AppConstants.cardShadowLight),
                child: Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppConstants.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14)),
                    child: Icon(
                      AppConstants.categoryIcons[s.category?.icon]
                          ?? Icons.build_rounded,
                      color: AppConstants.primary, size: 24)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.category?.name ?? s.categoryName,
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppConstants.textPrimaryDark
                              : AppConstants.textPrimaryLight)),
                      const SizedBox(height: 4),
                      Row(children: [
                        if (s.averagePrice != null) ...[
                          Icon(Icons.attach_money,
                              size: 13, color: AppConstants.success),
                          Text('R\$ ${s.averagePrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppConstants.success,
                              fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                        ],
                        if (s.experienceYears > 0) ...[
                          Icon(Icons.work_outline,
                              size: 13,
                              color: isDark
                                  ? AppConstants.textSecondaryDark
                                  : AppConstants.textSecondaryLight),
                          const SizedBox(width: 3),
                          Text('${s.experienceYears} ano(s)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppConstants.textSecondaryDark
                                  : AppConstants.textSecondaryLight)),
                        ],
                      ]),
                      if (s.bio != null && s.bio!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(s.bio!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppConstants.textSecondaryDark
                                  : AppConstants.textSecondaryLight)),
                        ),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: s.isAvailable
                          ? AppConstants.success.withOpacity(0.1)
                          : AppConstants.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      s.isAvailable ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: s.isAvailable
                            ? AppConstants.success
                            : AppConstants.error))),
                ]),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────

class _AvailableCard extends StatefulWidget {
  final ServiceRequestEntity request;
  final bool isDark;
  final VoidCallback onTap;
  const _AvailableCard({
    required this.request, required this.isDark, required this.onTap});
  @override
  State<_AvailableCard> createState() => _AvailableCardState();
}

class _AvailableCardState extends State<_AvailableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: widget.isDark ? AppConstants.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark
                  ? AppConstants.borderDark
                  : AppConstants.border),
            boxShadow: widget.isDark
                ? [] : [BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.08),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16))),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      AppConstants.categoryIcons[req.category?.icon]
                          ?? Icons.build_rounded,
                      color: const Color(0xFFF59E0B), size: 20)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    req.category?.name ?? 'Serviço',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: widget.isDark
                          ? AppConstants.textPrimaryDark
                          : AppConstants.textPrimaryLight))),
                  if (req.preferredGender == 'female')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                      child: const Text('🔒 Mulher',
                        style: TextStyle(
                          fontSize: 11, color: AppConstants.success,
                          fontWeight: FontWeight.w600))),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15,
                        color: widget.isDark
                            ? AppConstants.textPrimaryDark
                            : AppConstants.textPrimaryLight)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.location_on_outlined,
                        size: 13,
                        color: widget.isDark
                            ? AppConstants.textSecondaryDark
                            : AppConstants.textSecondaryLight),
                      const SizedBox(width: 4),
                      Expanded(child: Text(req.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDark
                              ? AppConstants.textSecondaryDark
                              : AppConstants.textSecondaryLight))),
                    ]),
                    if (req.description != null) ...[
                      const SizedBox(height: 4),
                      Text(req.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDark
                              ? AppConstants.textSecondaryDark
                              : AppConstants.textSecondaryLight)),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity, height: 44,
                      child: ElevatedButton.icon(
                        onPressed: widget.onTap,
                        icon: const Icon(Icons.check_circle_outline_rounded,
                            size: 18),
                        label: const Text('Ver e aceitar',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyCard extends StatelessWidget {
  final ServiceRequestEntity request;
  final bool isDark;
  final VoidCallback onTap;
  const _MyCard({required this.request, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppConstants.statusColors[request.status]
        ?? AppConstants.textSecondaryLight;
    final l = AppConstants.statusLabels[request.status]
        ?? request.status;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppConstants.borderDark : AppConstants.border)),
        child: Row(children: [
          Container(
            width: 4, height: 52,
            decoration: BoxDecoration(
              color: c, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14,
                  color: isDark
                      ? AppConstants.textPrimaryDark
                      : AppConstants.textPrimaryLight)),
              const SizedBox(height: 3),
              Text(request.client?.name ?? '-',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppConstants.textSecondaryDark
                      : AppConstants.textSecondaryLight)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: c.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
            child: Text(l,
              style: TextStyle(
                color: c, fontSize: 11,
                fontWeight: FontWeight.w600))),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionHeader(this.label, {required this.isDark});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label,
      style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5,
        color: isDark
            ? AppConstants.textSecondaryDark
            : AppConstants.textSecondaryLight)));
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  const _EmptyState({
    required this.icon, required this.title,
    required this.subtitle, required this.isDark});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 64, color: AppConstants.primary.withOpacity(0.25)),
        const SizedBox(height: 16),
        Text(title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600,
            color: isDark
                ? AppConstants.textSecondaryDark
                : AppConstants.textSecondaryLight)),
        const SizedBox(height: 8),
        Text(subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppConstants.textSecondaryDark
                : AppConstants.textSecondaryLight)),
      ]),
    ),
  );
}