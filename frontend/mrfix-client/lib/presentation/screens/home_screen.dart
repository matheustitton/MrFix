import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import '../widgets/app_widgets.dart';
import 'request_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _femaleOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ServiceRequestProvider>();
      p.loadCategories();
      p.loadRequests();
      p.startPolling();
      context.read<NotificationProvider>().startPolling();
    });
  }

  @override
  void dispose() {
    context.read<ServiceRequestProvider>().stopPolling();
    context.read<NotificationProvider>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final notif = context.watch<NotificationProvider>();
    final firstName = auth.user?.name.split(' ').first ?? 'Cliente';

    return Scaffold(
      body: RefreshIndicator(
        color: AppConstants.primary,
        onRefresh: () => context.read<ServiceRequestProvider>().loadRequests(),
        child: CustomScrollView(
          slivers: [
            // ────── App Bar ──────────────────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: isDark ? AppConstants.surfaceDark : Colors.white,
              elevation: 0,
              title: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppConstants.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.home_repair_service_rounded,
                    color: Colors.white, size: 20)),
                const SizedBox(width: 10),
                Text('MisterFix',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppConstants.textPrimaryDark
                        : AppConstants.textPrimaryLight,
                    letterSpacing: -0.3,
                  )),
              ]),
              actions: [
                //──────── Dark mode toggle ────────────────────────────────────
                GestureDetector(
                  onTap: theme.toggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36, height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.surface2Dark : AppConstants.bgLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      size: 18,
                      color: isDark
                          ? AppConstants.textSecondaryDark
                          : AppConstants.textSecondaryLight),
                  ),
                ),
                // ────── Notification ──────────────────────────────────────────
                Stack(children: [
                  Container(
                    width: 36, height: 36,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.surface2Dark : AppConstants.bgLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.notifications_none_rounded,
                      size: 20,
                      color: isDark
                          ? AppConstants.textSecondaryDark
                          : AppConstants.textSecondaryLight)),
                  Positioned(top: 6, right: 18,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppConstants.primary, shape: BoxShape.circle),
                    )),
                ]),
              ],
            ),

                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text('Olá, $firstName 👋',
                  style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: isDark
                        ? AppConstants.textPrimaryDark
                        : AppConstants.textPrimaryLight,
                  )),
                const SizedBox(height: 4),
                Text('Qual serviço você precisa?',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppConstants.textSecondaryDark
                        : AppConstants.textSecondaryLight,
                  )),
                const SizedBox(height: 20),

                // ────── Search bar ──────────────────────────────────────────
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppConstants.surface2Dark : AppConstants.bgLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppConstants.borderDark : AppConstants.borderLight),
                  ),
                  child: Row(children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search_rounded, size: 20,
                      color: isDark
                          ? AppConstants.textSecondaryDark
                          : AppConstants.textSecondaryLight),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Buscar eletricista, pintor...',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppConstants.textSecondaryDark
                            : AppConstants.textSecondaryLight,
                      ))),
                    Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppConstants.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(height: 16),

                // ────── Atendimento feminino ───────────────────────────────────────
                GestureDetector(
                  onTap: () => setState(() => _femaleOnly = !_femaleOnly),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _femaleOnly
                          ? AppConstants.primary.withOpacity(0.08)
                          : (isDark ? AppConstants.surface2Dark : AppConstants.bgLight),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _femaleOnly
                            ? AppConstants.primary.withOpacity(0.3)
                            : (isDark ? AppConstants.borderDark : AppConstants.borderLight)),
                    ),
                    child: Row(children: [
                      Icon(Icons.shield_rounded,
                        size: 18,
                        color: _femaleOnly
                            ? AppConstants.primary
                            : (isDark ? AppConstants.textSecondaryDark : AppConstants.textSecondaryLight)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Apenas prestadoras mulheres',
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: _femaleOnly
                                  ? AppConstants.primary
                                  : (isDark
                                      ? AppConstants.textSecondaryDark
                                      : AppConstants.textSecondaryLight)),
                            const SizedBox(width: 10),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Apenas prestadoras mulheres',
                                  style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700,
                                    color: _femaleOnly
                                        ? AppConstants.primary
                                        : (isDark
                                            ? AppConstants.textPrimaryDark
                                            : AppConstants.textPrimaryLight))),
                                Text('Maior segurança para você 🔒',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppConstants.textSecondaryDark
                                        : AppConstants.textSecondaryLight)),
                              ],
                            )),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 44, height: 24,
                              decoration: BoxDecoration(
                                color: _femaleOnly
                                    ? AppConstants.primary
                                    : (isDark ? AppConstants.borderDark : AppConstants.borderLight),
                                borderRadius: BorderRadius.circular(12)),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                alignment: _femaleOnly
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 20, height: 20,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white, shape: BoxShape.circle)))),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 24),

                // ────── Categorias ──────────────────────────────────────────
                Consumer<ServiceRequestProvider>(
                  builder: (_, p, __) {
                    if (p.categories.isEmpty) return const SizedBox.shrink();
                    return Column(children: [
                      SectionHeader(
                        title: 'Categorias',
                        actionLabel: 'Ver todas',
                        onAction: () {},
                      ),

                //──────── Minhas solicitações ──────────────────────────────────────
                SectionHeader(title: 'Meus Pedidos'),
                const SizedBox(height: 16),
              ]),
            )),

            // ────── Lista de solicitações ──────────────────────────────────────
            Consumer<ServiceRequestProvider>(
              builder: (_, p, __) {
                if (p.loading && p.requests.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: AppConstants.primary))));
                }
                if (p.requests.isEmpty) {
                  return SliverToBoxAdapter(child: _EmptyState());
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final req = p.requests[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: TappableCard(
                          onTap: () {
                            p.selectRequest(req);
                            Navigator.push(ctx, MaterialPageRoute(
                              builder: (_) => RequestDetailScreen(
                                requestId: req.id)));
                          },
                          childCount: p.requests.length,
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),

          // ── Painel de Notificações ──────────────────────────────────────
          if (notif.panelOpen)
            Positioned(
              top: 0, left: 0, right: 0, bottom: 0,
              child: GestureDetector(
                onTap: notif.closePanel,
                child: Container(color: Colors.black.withOpacity(0.3))),
            ),
          if (notif.panelOpen)
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top - 4,
              right: 12,
              width: MediaQuery.of(context).size.width * 0.88,
              child: _NotificationPanel(isDark: isDark),
            ),
        ],
      ),
    );
  }
}

// ── Notification Panel ─────────────────────────────────────────────────────
class _NotificationPanel extends StatelessWidget {
  final bool isDark;
  const _NotificationPanel({required this.isDark});

  IconData _iconForType(String type) {
    switch (type) {
      case 'request_accepted':  return Icons.check_circle_rounded;
      case 'request_started':   return Icons.build_rounded;
      case 'request_completed': return Icons.task_alt_rounded;
      case 'new_rating':        return Icons.star_rounded;
      default:                  return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'request_accepted':  return const Color(0xFF1565C0);
      case 'request_started':   return const Color(0xFF6A1B9A);
      case 'request_completed': return const Color(0xFF2E7D32);
      case 'new_rating':        return const Color(0xFFF59E0B);
      default:                  return AppConstants.primary;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24)   return '${diff.inHours}h atrás';
    return '${diff.inDays}d atrás';
  }

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotificationProvider>();

    return Material(
      elevation: 16,
      borderRadius: BorderRadius.circular(20),
      color: isDark ? AppConstants.surfaceDark : Colors.white,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.55),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppConstants.borderDark : AppConstants.borderLight)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
              child: Row(children: [
                const Icon(Icons.notifications_rounded,
                  color: AppConstants.primary, size: 18),
                const SizedBox(width: 8),
                Text('Notificações',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppConstants.textPrimaryDark
                        : AppConstants.textPrimaryLight)),
                const Spacer(),
                if (notif.notifications.isNotEmpty)
                  GestureDetector(
                    onTap: notif.markAllRead,
                    child: Text('Marcar todas como lidas',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppConstants.primary.withOpacity(0.8),
                        fontWeight: FontWeight.w600))),
              ]),
            ),
            Divider(height: 1,
              color: isDark ? AppConstants.borderDark : AppConstants.borderLight),

            // Lista
            if (notif.notifications.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(children: [
                  Icon(Icons.notifications_off_outlined,
                    size: 40,
                    color: AppConstants.primary.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Text('Nenhuma notificação',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppConstants.textSecondaryDark
                          : AppConstants.textSecondaryLight)),
                ]),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  separatorBuilder: (_, __) => Divider(
                    height: 1, indent: 56,
                    color: isDark
                        ? AppConstants.borderDark
                        : AppConstants.borderLight),
                  itemCount: notif.notifications.length,
                  itemBuilder: (ctx, i) {
                    final n = notif.notifications[i];
                    final color = _colorForType(n.type);
                    return InkWell(
                      onTap: () {
                        notif.markRead(n.id);
                        notif.closePanel();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                        color: n.read
                            ? Colors.transparent
                            : AppConstants.primary.withOpacity(0.04),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle),
                              child: Icon(_iconForType(n.type),
                                color: color, size: 18)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: n.read
                                        ? FontWeight.w500
                                        : FontWeight.w700,
                                    color: isDark
                                        ? AppConstants.textPrimaryDark
                                        : AppConstants.textPrimaryLight)),
                                const SizedBox(height: 2),
                                Text(n.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppConstants.textSecondaryDark
                                        : AppConstants.textSecondaryLight)),
                                const SizedBox(height: 4),
                                Text(_timeAgo(n.createdAt),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppConstants.textSecondaryDark
                                        : AppConstants.textSecondaryLight)),
                              ],
                            )),
                            if (!n.read)
                              Container(
                                width: 8, height: 8,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: const BoxDecoration(
                                  color: AppConstants.primary,
                                  shape: BoxShape.circle)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Category Item ──────────────────────────────────────────────────────────
class _CategoryItem extends StatefulWidget {
  final ServiceCategoryEntity category;
  const _CategoryItem({required this.category});
  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = AppConstants.categoryIcons[widget.category.icon]
        ?? Icons.build_rounded;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: isDark ? AppConstants.surface2Dark : AppConstants.bgLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppConstants.borderDark : AppConstants.borderLight)),
            child: Icon(icon, color: AppConstants.primary, size: 26)),
          const SizedBox(height: 6),
          SizedBox(
            width: 64,
            child: Text(widget.category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w500,
                color: isDark
                    ? AppConstants.textSecondaryDark
                    : AppConstants.textSecondaryLight))),
        ]),
      ),
    );
  }
}

// ── Request Card Content ───────────────────────────────────────────────────
class _RequestCardContent extends StatelessWidget {
  final ServiceRequestEntity request;
  const _RequestCardContent({required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppConstants.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
          child: Icon(
            AppConstants.categoryIcons[request.category?.icon]
                ?? Icons.build_rounded,
            color: AppConstants.primary, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.title,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: isDark
                    ? AppConstants.textPrimaryDark
                    : AppConstants.textPrimaryLight)),
            Text(request.provider?.name ?? 'Aguardando prestador',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppConstants.textSecondaryDark
                    : AppConstants.textSecondaryLight)),
          ],
        )),
        StatusBadge(status: request.status),
      ]),
      const SizedBox(height: 12),
      Divider(height: 1,
        color: isDark ? AppConstants.dividerDark : AppConstants.dividerLight),
      const SizedBox(height: 10),
      Row(children: [
        Icon(Icons.calendar_today_rounded, size: 13,
          color: isDark
              ? AppConstants.textSecondaryDark
              : AppConstants.textSecondaryLight),
        const SizedBox(width: 5),
        Text(request.scheduledAt != null
            ? '${request.scheduledAt!.day}/${request.scheduledAt!.month}, ${request.scheduledAt!.hour}:00'
            : 'Sem data definida',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppConstants.textSecondaryDark
                : AppConstants.textSecondaryLight)),
        const SizedBox(width: 16),
        Icon(Icons.location_on_rounded, size: 13,
          color: isDark
              ? AppConstants.textSecondaryDark
              : AppConstants.textSecondaryLight),
        const SizedBox(width: 4),
        Expanded(child: Text(request.address,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppConstants.textSecondaryDark
                : AppConstants.textSecondaryLight))),
      ]),
    ]);
  }
}

// ── Empty State ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(children: [
        Icon(Icons.home_repair_service_outlined, size: 64,
          color: AppConstants.primary.withOpacity(0.25)),
        const SizedBox(height: 16),
        Text('Nenhum pedido ainda',
          style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600,
            color: isDark
                ? AppConstants.textSecondaryDark
                : AppConstants.textSecondaryLight)),
        const SizedBox(height: 8),
        Text('Toque no + para solicitar seu primeiro serviço',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppConstants.textSecondaryDark
                : AppConstants.textSecondaryLight)),
      ]),
    );
  }
}