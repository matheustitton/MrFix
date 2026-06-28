import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_request_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import '../widgets/app_widgets.dart';
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
      context.read<ServiceRequestProvider>().loadRequests();
    });
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = context.watch<ServiceRequestProvider>();

    final active    = p.requests.where((r) =>
        r.status == 'pending' || r.status == 'accepted' || r.status == 'in_progress').toList();
    final completed = p.requests.where((r) => r.status == 'completed').toList();
    final cancelled = p.requests.where((r) => r.status == 'cancelled').toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppConstants.primary,
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.home_repair_service_rounded,
              color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          Text('MisterFix',
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800,
              color: isDark
                  ? AppConstants.textPrimaryDark
                  : AppConstants.textPrimaryLight,
              letterSpacing: -0.3)),
        ]),
        actions: [
          Icon(Icons.notifications_none_rounded,
            color: isDark
                ? AppConstants.textSecondaryDark
                : AppConstants.textSecondaryLight),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tab,
            indicatorColor: AppConstants.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppConstants.primary,
            unselectedLabelColor: isDark
                ? AppConstants.textSecondaryDark
                : AppConstants.textSecondaryLight,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14),
            tabs: const [
              Tab(text: 'Ativas'),
              Tab(text: 'Concluídas'),
              Tab(text: 'Canceladas'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _RequestList(requests: active),
          _RequestList(requests: completed),
          _RequestList(requests: cancelled),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<ServiceRequestEntity> requests;
  const _RequestList({required this.requests});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 56,
            color: AppConstants.primary.withOpacity(0.25)),
          const SizedBox(height: 12),
          const Text('Nenhum pedido aqui',
            style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 15,
              color: AppConstants.textSecondaryLight)),
        ],
      ));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: requests.length,
      itemBuilder: (ctx, i) {
        final req = requests[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TappableCard(
            onTap: () {
              context.read<ServiceRequestProvider>().selectRequest(req);
              Navigator.push(ctx, MaterialPageRoute(
                builder: (_) => RequestDetailScreen(requestId: req.id)));
            },
            child: _RequestRow(request: req),
          ),
        );
      },
    );
  }
}

class _RequestRow extends StatelessWidget {
  final ServiceRequestEntity request;
  const _RequestRow({required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: AppConstants.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14)),
        child: Icon(
          AppConstants.categoryIcons[request.category?.icon]
              ?? Icons.build_rounded,
          color: AppConstants.primary, size: 22)),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(request.title,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: isDark
                  ? AppConstants.textPrimaryDark
                  : AppConstants.textPrimaryLight,
            )),
          const SizedBox(height: 3),
          Text(request.provider?.name ?? 'Aguardando prestador',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppConstants.textSecondaryDark
                  : AppConstants.textSecondaryLight,
            )),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.calendar_today_rounded, size: 11,
              color: isDark
                  ? AppConstants.textSecondaryDark
                  : AppConstants.textSecondaryLight),
            const SizedBox(width: 4),
            Text(request.scheduledAt != null
                ? '${request.scheduledAt!.day}/${request.scheduledAt!.month}, ${request.scheduledAt!.hour}h'
                : 'Sem data',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppConstants.textSecondaryDark
                    : AppConstants.textSecondaryLight,
              )),
            const SizedBox(width: 10),
            Icon(Icons.location_on_rounded, size: 11,
              color: isDark
                  ? AppConstants.textSecondaryDark
                  : AppConstants.textSecondaryLight),
            const SizedBox(width: 4),
            Expanded(child: Text(request.address,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppConstants.textSecondaryDark
                    : AppConstants.textSecondaryLight,
              ))),
          ]),
        ],
      )),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        StatusBadge(status: request.status),
        if (request.agreedPrice != null) ...[
          const SizedBox(height: 6),
          Text('R\$ ${request.agreedPrice!.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: AppConstants.primary)),
        ],
        const SizedBox(height: 4),
        Icon(Icons.chevron_right_rounded, size: 18,
          color: isDark
              ? AppConstants.textSecondaryDark
              : AppConstants.textSecondaryLight),
      ]),
    ]);
  }
}