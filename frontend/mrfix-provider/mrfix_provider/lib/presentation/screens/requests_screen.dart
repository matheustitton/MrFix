import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_request_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import 'request_detail_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});
  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = context.watch<ServiceRequestProvider>();

    final pending = p.availableRequests;
    final active = p.myRequests
        .where((r) => r.isAccepted || r.isInProgress)
        .toList();
    final done = p.myRequests
        .where((r) => r.isCompleted || r.isCancelled)
        .toList();

    return Scaffold(
      backgroundColor:
          isDark ? AppConstants.bgDark : AppConstants.bgLight,
      appBar: AppBar(
        title: const Text('Solicitações',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: TabBar(
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
                  const Text('Pendentes'),
                  if (pending.isNotEmpty) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppConstants.accent,
                        borderRadius: BorderRadius.circular(10)),
                      child: Text('${pending.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white))),
                  ],
                ],
              )),
              const Tab(text: 'Em andamento'),
              const Tab(text: 'Histórico'),
            ],
          ),
        ),
      ),
      body: p.loading
        ? const Center(child: CircularProgressIndicator(
            color: AppConstants.primary, strokeWidth: 2))
        : TabBarView(
            controller: _tab,
            children: [
              _RequestList(
                requests: pending,
                emptyTitle: 'Nenhuma solicitação pendente',
                emptySubtitle:
                    'Novas solicitações aparecerão aqui automaticamente',
                isDark: isDark,
                isAvailable: true,
              ),
              _RequestList(
                requests: active,
                emptyTitle: 'Nenhum serviço em andamento',
                emptySubtitle: 'Aceite uma solicitação para começar',
                isDark: isDark,
                isAvailable: false,
              ),
              _RequestList(
                requests: done,
                emptyTitle: 'Nenhum serviço no histórico',
                emptySubtitle:
                    'Serviços concluídos e cancelados aparecem aqui',
                isDark: isDark,
                isAvailable: false,
              ),
            ],
          ),
    );
  }
}

// ── Request List ───────────────────────────────────────────────────────────
class _RequestList extends StatelessWidget {
  final List<ServiceRequestEntity> requests;
  final String emptyTitle;
  final String emptySubtitle;
  final bool isDark;
  final bool isAvailable;

  const _RequestList({
    required this.requests,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.isDark,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_rounded, size: 56,
                color: AppConstants.primary.withOpacity(0.25)),
              const SizedBox(height: 12),
              Text(emptyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppConstants.textSecondaryDark
                      : AppConstants.textSecondaryLight)),
              const SizedBox(height: 6),
              Text(emptySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppConstants.textSecondaryDark
                      : AppConstants.textSecondaryLight)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppConstants.primary,
      onRefresh: () =>
          context.read<ServiceRequestProvider>().loadAll(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (ctx, i) {
          final req = requests[i];
          return _RequestCard(
            request: req,
            isDark: isDark,
            onTap: () {
              context
                  .read<ServiceRequestProvider>()
                  .selectRequest(req);
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => RequestDetailScreen(
                    requestId: req.id,
                    isAvailable: isAvailable,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Request Card ───────────────────────────────────────────────────────────
class _RequestCard extends StatefulWidget {
  final ServiceRequestEntity request;
  final bool isDark;
  final VoidCallback onTap;

  const _RequestCard({
    required this.request,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final statusColor =
        AppConstants.statusColors[req.status]
            ?? AppConstants.textSecondaryLight;
    final statusLabel =
        AppConstants.statusLabels[req.status] ?? req.status;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDark
                ? AppConstants.surfaceDark
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark
                  ? AppConstants.borderDark
                  : AppConstants.border),
            boxShadow: widget.isDark
                ? AppConstants.cardShadowDark
                : AppConstants.cardShadowLight,
          ),
          child: Row(children: [
            // Ícone categoria
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: AppConstants.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(13)),
              child: Icon(
                AppConstants.categoryIcons[req.category?.icon]
                    ?? Icons.build_rounded,
                color: AppConstants.primary, size: 22)),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(req.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: widget.isDark
                          ? AppConstants.textPrimaryDark
                          : AppConstants.textPrimaryLight)),
                  const SizedBox(height: 3),
                  Text(req.client?.name ?? 'Cliente',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDark
                          ? AppConstants.textSecondaryDark
                          : AppConstants.textSecondaryLight)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.location_on_rounded,
                      size: 11,
                      color: widget.isDark
                          ? AppConstants.textSecondaryDark
                          : AppConstants.textSecondaryLight),
                    const SizedBox(width: 3),
                    Expanded(child: Text(req.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isDark
                            ? AppConstants.textSecondaryDark
                            : AppConstants.textSecondaryLight))),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Status + seta
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600))),
                const SizedBox(height: 8),
                if (req.preferredGender == 'female')
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          AppConstants.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                    child: const Text('🔒',
                      style: TextStyle(fontSize: 12))),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right_rounded,
                  size: 18,
                  color: widget.isDark
                      ? AppConstants.textSecondaryDark
                      : AppConstants.textSecondaryLight),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}