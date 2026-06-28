import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_request_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import '../widgets/app_widgets.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;
  const RequestDetailScreen({super.key, required this.requestId});
  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ServiceRequestProvider>()
          .loadRequest(widget.requestId);
      _fadeCtrl.forward();
    });
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  Future<void> _cancelRequest() async {
    final confirm = await _showConfirmDialog(
      'Cancelar pedido',
      'Tem certeza que deseja cancelar este pedido?',
      confirmLabel: 'Cancelar pedido',
      confirmColor: AppConstants.primary,
    );
    if (confirm != true || !mounted) return;

    final ok = await context.read<ServiceRequestProvider>()
        .cancelRequest(widget.requestId, reason: 'Cancelado pelo cliente');
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pedido cancelado.'),
          backgroundColor: AppConstants.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _submitRating(ServiceRequestEntity request) async {
    int score = 5;
    final commentCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppConstants.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppConstants.borderLight,
                  borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 20),

              const Text('Avaliar prestador',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text(
                'Como foi o serviço de ${request.provider?.name ?? 'prestador'}?',
                style: const TextStyle(
                  color: AppConstants.textSecondaryLight, fontSize: 14)),
              const SizedBox(height: 24),

              // ──────── Avaliação ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => set(() => score = i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      i < score
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: i < score
                          ? AppConstants.accent
                          : AppConstants.borderLight,
                      size: 44,
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 8),
              Center(child: Text(
                ['', 'Péssimo', 'Ruim', 'Regular', 'Bom', 'Excelente!'][score],
                style: const TextStyle(
                  color: AppConstants.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ))),
              const SizedBox(height: 20),

              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Deixe um comentário (opcional)',
                  hintStyle: const TextStyle(
                    color: AppConstants.textSecondaryLight, fontSize: 13),
                  filled: true,
                  fillColor: AppConstants.bgLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),

              PrimaryButton(
                label: 'Enviar avaliação',
                onPressed: () async {
                  Navigator.pop(ctx);
                  final ok = await context.read<ServiceRequestProvider>()
                      .submitRating(
                        requestId: request.id,
                        score: score,
                        comment: commentCtrl.text.trim().isEmpty
                            ? null : commentCtrl.text.trim(),
                      );
                  if (ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(children: [
                          Icon(Icons.star_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Avaliação enviada! Obrigado.'),
                        ]),
                        backgroundColor: AppConstants.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(
    String title, String content, {
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar',
              style: TextStyle(color: AppConstants.textSecondaryLight))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(0, 40),
            ),
            child: Text(confirmLabel)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppConstants.bgDark : AppConstants.bgLight,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppConstants.surface2Dark
                  : AppConstants.bgLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_rounded,
              size: 20,
              color: isDark
                  ? AppConstants.textPrimaryDark
                  : AppConstants.textPrimaryLight),
          ),
        ),
        title: Text('Detalhes do Pedido',
          style: TextStyle(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: isDark
                ? AppConstants.textPrimaryDark
                : AppConstants.textPrimaryLight,
          )),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
              color: isDark
                  ? AppConstants.textSecondaryDark
                  : AppConstants.textSecondaryLight),
            onPressed: () => context.read<ServiceRequestProvider>()
                .loadRequest(widget.requestId),
          ),
        ],
      ),
      body: Consumer<ServiceRequestProvider>(
        builder: (_, p, __) {
          final request = p.selected;

          if (p.loading && request == null) {
            return const Center(child: CircularProgressIndicator(
              color: AppConstants.primary, strokeWidth: 2));
          }
          if (request == null) {
            return const Center(child: Text('Pedido não encontrado'));
          }

          return FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ──────────── Status card ────────────────────────────────────────
                  _StatusCard(request: request, isDark: isDark),
                  const SizedBox(height: 16),

                  // ────── Progress steps ────────────────────────────────────────────────
                  if (!request.isCancelled)
                    _ProgressSteps(status: request.status, isDark: isDark),
                  if (!request.isCancelled) const SizedBox(height: 16),

                  // ────── Info card ────────────────────────────────────────────────────
                  _InfoCard(request: request, isDark: isDark),
                  const SizedBox(height: 16),

                  // ────── Provider card ────────────────────────────────────────────────
                  if (request.provider != null) ...[
                    _ProviderCard(provider: request.provider!, isDark: isDark),
                    const SizedBox(height: 16),
                  ],

                  // ────── Polling indicator ────────────────────────────────────────────────
                  if (!request.isCompleted && !request.isCancelled) ...[
                    _PollingIndicator(isDark: isDark),
                    const SizedBox(height: 24),
                  ] else
                    const SizedBox(height: 8),

                  // ────── Actions ──────────────────────────────────────────────────────────
                  if (request.isPending) ...[
                    PrimaryButton(
                      label: 'Cancelar pedido',
                      color: AppConstants.secondary,
                      onPressed: _cancelRequest,
                    ),
                  ],
                  if (request.isCompleted && request.provider != null) ...[
                    PrimaryButton(
                      label: 'Avaliar prestador',
                      icon: Icons.star_rounded,
                      color: AppConstants.accent,
                      onPressed: () => _submitRating(request),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Status Card ────────────────────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final ServiceRequestEntity request;
  final bool isDark;
  const _StatusCard({required this.request, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.statusColors[request.status] ?? Colors.grey;
    final bg = isDark
        ? AppConstants.statusBgColorsDark[request.status]
            ?? AppConstants.surface2Dark
        : AppConstants.statusBgColors[request.status]
            ?? AppConstants.bgLight;
    final label = AppConstants.statusLabels[request.status] ?? request.status;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? AppConstants.cardShadowDark
            : AppConstants.cardShadowLight,
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: Icon(_statusIcon(request.status), color: color, size: 26)),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.title,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: isDark
                    ? AppConstants.textPrimaryDark
                    : AppConstants.textPrimaryLight,
              )),
            const SizedBox(height: 4),
            StatusBadge(status: request.status),
          ],
        )),
      ]),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':     return Icons.hourglass_empty_rounded;
      case 'accepted':    return Icons.thumb_up_rounded;
      case 'in_progress': return Icons.build_rounded;
      case 'completed':   return Icons.check_circle_rounded;
      case 'cancelled':   return Icons.cancel_rounded;
      default:            return Icons.info_outline;
    }
  }
}

// ── Progress Steps ─────────────────────────────────────────────────────────
class _ProgressSteps extends StatelessWidget {
  final String status;
  final bool isDark;
  const _ProgressSteps({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('pending',     'Aguardando', Icons.hourglass_empty_rounded),
      ('accepted',    'Aceito',     Icons.thumb_up_rounded),
      ('in_progress', 'Em andamento', Icons.build_rounded),
      ('completed',   'Concluído',  Icons.check_circle_rounded),
    ];
    final currentIdx = steps.indexWhere((s) => s.$1 == status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? AppConstants.cardShadowDark
            : AppConstants.cardShadowLight,
      ),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final idx  = e.key;
          final step = e.value;
          final done = idx <= currentIdx;
          final isLast = idx == steps.length - 1;

          return Expanded(child: Row(children: [
            Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: done
                      ? AppConstants.primary
                      : (isDark
                          ? AppConstants.surface2Dark
                          : AppConstants.bgLight),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done
                        ? AppConstants.primary
                        : (isDark
                            ? AppConstants.borderDark
                            : AppConstants.borderLight),
                    width: 2),
                ),
                child: Icon(
                  done ? Icons.check_rounded : step.$3,
                  size: 14,
                  color: done
                      ? Colors.white
                      : (isDark
                          ? AppConstants.textSecondaryDark
                          : AppConstants.textSecondaryLight)),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 64,
                child: Text(step.$2,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                    color: done
                        ? AppConstants.primary
                        : (isDark
                            ? AppConstants.textSecondaryDark
                            : AppConstants.textSecondaryLight),
                  ))),
            ]),
            if (!isLast) Expanded(child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 2,
              color: idx < currentIdx
                  ? AppConstants.primary
                  : (isDark
                      ? AppConstants.borderDark
                      : AppConstants.borderLight),
            )),
          ]));
        }).toList(),
      ),
    );
  }
}

// ── Info Card ──────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final ServiceRequestEntity request;
  final bool isDark;
  const _InfoCard({required this.request, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? AppConstants.cardShadowDark
            : AppConstants.cardShadowLight,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Informações',
          style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700,
            color: isDark
                ? AppConstants.textPrimaryDark
                : AppConstants.textPrimaryLight,
          )),
        const SizedBox(height: 12),
        _Row(Icons.category_rounded,
          request.category?.name ?? '-', isDark: isDark),
        const SizedBox(height: 8),
        _Row(Icons.location_on_rounded,
          request.address, isDark: isDark),
        if (request.description != null) ...[
          const SizedBox(height: 8),
          _Row(Icons.description_outlined,
            request.description!, isDark: isDark),
        ],
        if (request.preferredGender == 'female') ...[
          const SizedBox(height: 8),
          _Row(Icons.shield_rounded, 'Solicitou atendimento feminino',
            isDark: isDark, color: AppConstants.primary),
        ],
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  final Color? color;
  const _Row(this.icon, this.text, {required this.isDark, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark
        ? AppConstants.textSecondaryDark
        : AppConstants.textSecondaryLight);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 15, color: c),
      const SizedBox(width: 10),
      Expanded(child: Text(text,
        style: TextStyle(fontSize: 13, color: c))),
    ]);
  }
}

// ── Provider Card ──────────────────────────────────────────────────────────
class _ProviderCard extends StatelessWidget {
  final UserEntity provider;
  final bool isDark;
  const _ProviderCard({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? AppConstants.cardShadowDark
            : AppConstants.cardShadowLight,
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppConstants.primary,
          child: Text(
            provider.name.isNotEmpty ? provider.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800, fontSize: 20))),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider.name,
              style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15,
                color: isDark
                    ? AppConstants.textPrimaryDark
                    : AppConstants.textPrimaryLight)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.star_rounded,
                size: 14, color: AppConstants.accent),
              const SizedBox(width: 3),
              Text('${provider.averageRating.toStringAsFixed(1)} '
                '(${provider.ratingCount} avaliações)',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppConstants.textSecondaryDark
                      : AppConstants.textSecondaryLight)),
            ]),
            if (provider.gender == 'female') ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppConstants.successLight,
                  borderRadius: BorderRadius.circular(6)),
                child: const Text('✓ Profissional mulher',
                  style: TextStyle(
                    fontSize: 10, color: AppConstants.success,
                    fontWeight: FontWeight.w700))),
            ],
          ],
        )),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppConstants.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.chat_bubble_outline_rounded,
            color: AppConstants.primary, size: 18)),
      ]),
    );
  }
}

// ── Polling Indicator ──────────────────────────────────────────────────────
class _PollingIndicator extends StatelessWidget {
  final bool isDark;
  const _PollingIndicator({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppConstants.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        SizedBox(
          width: 14, height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppConstants.primary.withOpacity(0.7))),
        const SizedBox(width: 10),
        Text('Atualizando automaticamente a cada 5s...',
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.primary.withOpacity(0.8))),
      ]),
    );
  }
}