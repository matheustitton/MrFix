import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_request_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;
  final bool isAvailable;

  const RequestDetailScreen({
    super.key,
    required this.requestId,
    required this.isAvailable,
  });

  @override
  State<RequestDetailScreen> createState() => _State();
}

class _State extends State<RequestDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<ServiceRequestProvider>()
          .loadRequest(widget.requestId);
      _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<bool?> _confirm(String title, String content) =>
      showDialog<bool>(
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
              child: const Text('Cancelar',
                  style: TextStyle(
                      color: AppConstants.textSecondaryLight))),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );

  Future<void> _accept() async {
    final ok = await context
        .read<ServiceRequestProvider>()
        .acceptRequest(widget.requestId);
    if (ok && mounted) {
      _showSnack(
          '✅ Solicitação aceita! O cliente foi notificado.',
          AppConstants.success);
    }
  }

  Future<void> _reject() async {
    if (await _confirm('Recusar',
            'Deseja recusar esta solicitação?') !=
        true) return;
    final ok = await context
        .read<ServiceRequestProvider>()
        .rejectRequest(widget.requestId);
    if (ok && mounted) {
      Navigator.pop(context);
      _showSnack('Solicitação recusada.', AppConstants.secondary);
    }
  }

  Future<void> _start() async {
    final ok = await context
        .read<ServiceRequestProvider>()
        .startService(widget.requestId);
    if (ok && mounted) {
      _showSnack(
          '🔧 Serviço iniciado!', AppConstants.primary);
    }
  }

  Future<void> _complete() async {
    if (await _confirm('Concluir serviço',
            'Confirmar conclusão? O cliente poderá avaliar em seguida.') !=
        true) return;
    final ok = await context
        .read<ServiceRequestProvider>()
        .completeService(widget.requestId);
    if (ok && mounted) {
      _showSnack('🎉 Serviço concluído!', AppConstants.success);
    }
  }

  Future<void> _rate(ServiceRequestEntity req) async {
    int score = 5;
    final ctrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            color: isDark
                ? AppConstants.surfaceDark
                : Colors.white,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppConstants.borderLight,
                    borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Avaliar cliente',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text(
                'Como foi atender ${req.client?.name ?? 'o cliente'}?',
                style: TextStyle(
                  color: isDark
                      ? AppConstants.textSecondaryDark
                      : AppConstants.textSecondaryLight,
                  fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
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
                        size: 44))),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  ['', 'Péssimo', 'Ruim', 'Regular', 'Bom',
                      'Excelente!'][score],
                  style: const TextStyle(
                    color: AppConstants.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16))),
              const SizedBox(height: 20),
              TextField(
                controller: ctrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Deixe um comentário (opcional)',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppConstants.textSecondaryDark
                        : AppConstants.textSecondaryLight,
                    fontSize: 13),
                  filled: true,
                  fillColor: isDark
                      ? AppConstants.surface2Dark
                      : AppConstants.bgLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final ok = await context
                      .read<ServiceRequestProvider>()
                      .submitRating(
                        requestId: req.id,
                        score: score,
                        comment: ctrl.text.trim().isEmpty
                            ? null
                            : ctrl.text.trim(),
                      );
                  if (ok && mounted) {
                    _showSnack('Avaliação enviada!',
                        AppConstants.success);
                  }
                },
                child: const Text('Enviar avaliação',
                    style:
                        TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

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
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_rounded,
                size: 20))),
        title: const Text('Detalhes do Serviço',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context
                .read<ServiceRequestProvider>()
                .loadRequest(widget.requestId)),
        ],
      ),
      body: Consumer<ServiceRequestProvider>(
        builder: (_, p, __) {
          final req = p.selected;

          if (p.loading && req == null) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppConstants.primary,
                    strokeWidth: 2));
          }
          if (req == null) {
            return const Center(
                child: Text('Solicitação não encontrada'));
          }

          return FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // Status banner
                  _StatusBanner(
                      status: req.status, isDark: isDark),
                  const SizedBox(height: 16),

                  // Info do serviço
                  _InfoCard(request: req, isDark: isDark),
                  const SizedBox(height: 16),

                  // Cliente
                  if (req.client != null) ...[
                    _ClientCard(
                        client: req.client!, isDark: isDark),
                    const SizedBox(height: 16),
                  ],

                  // Polling indicator
                  if (!req.isCompleted && !req.isCancelled) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppConstants.primary
                            .withOpacity(0.06),
                        borderRadius:
                            BorderRadius.circular(12)),
                      child: Row(children: [
                        SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppConstants.primary
                                .withOpacity(0.7))),
                        const SizedBox(width: 10),
                        Text(
                          'Atualizando automaticamente a cada 5s...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.primary
                                .withOpacity(0.8))),
                      ]),
                    ),
                    const SizedBox(height: 24),
                  ] else
                    const SizedBox(height: 8),

                  // Ações
                  if (p.actionLoading)
                    const Center(
                      child: CircularProgressIndicator(
                          color: AppConstants.primary,
                          strokeWidth: 2))
                  else if (req.isPending)
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        _ActionBtn(
                          label: 'Aceitar solicitação',
                          icon: Icons.check_circle_rounded,
                          color: AppConstants.success,
                          onPressed: _accept),
                        const SizedBox(height: 10),
                        _ActionBtn(
                          label: 'Recusar',
                          icon: Icons.cancel_outlined,
                          color: AppConstants.error,
                          outlined: true,
                          onPressed: _reject),
                      ],
                    )
                  else if (req.isAccepted)
                    _ActionBtn(
                      label: 'Iniciar serviço',
                      icon: Icons.play_circle_rounded,
                      color: AppConstants.primary,
                      onPressed: _start)
                  else if (req.isInProgress)
                    _ActionBtn(
                      label: 'Concluir serviço',
                      icon: Icons.check_circle_rounded,
                      color: AppConstants.success,
                      onPressed: _complete)
                  else if (req.isCompleted &&
                      req.client != null)
                    _ActionBtn(
                      label: 'Avaliar cliente',
                      icon: Icons.star_rounded,
                      color: AppConstants.accent,
                      onPressed: () => _rate(req)),

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

// ── Sub-widgets ────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final String status;
  final bool isDark;
  const _StatusBanner(
      {required this.status, required this.isDark});

  IconData get _icon {
    switch (status) {
      case 'pending':     return Icons.hourglass_empty_rounded;
      case 'accepted':    return Icons.thumb_up_rounded;
      case 'in_progress': return Icons.build_rounded;
      case 'completed':   return Icons.check_circle_rounded;
      default:            return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.statusColors[status]
        ?? AppConstants.textSecondaryLight;
    final bg = isDark
        ? AppConstants.statusBgColorsDark[status]
            ?? AppConstants.surface2Dark
        : AppConstants.statusBgColors[status]
            ?? AppConstants.bgLight;
    final label =
        AppConstants.statusLabels[status] ?? status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? AppConstants.cardShadowDark
            : AppConstants.cardShadowLight),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14)),
          child: Icon(_icon, color: color, size: 26)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text('Status atual',
            style: TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryLight)),
          Text(label,
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: color, letterSpacing: -0.3)),
        ]),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ServiceRequestEntity request;
  final bool isDark;
  const _InfoCard(
      {required this.request, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? AppConstants.cardShadowDark
            : AppConstants.cardShadowLight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(request.title,
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: isDark
                  ? AppConstants.textPrimaryDark
                  : AppConstants.textPrimaryLight)),
          if (request.description != null) ...[
            const SizedBox(height: 6),
            Text(request.description!,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppConstants.textSecondaryDark
                    : AppConstants.textSecondaryLight)),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _Row(Icons.category_rounded,
              request.category?.name ?? '-',
              isDark: isDark),
          const SizedBox(height: 6),
          _Row(Icons.location_on_rounded, request.address,
              isDark: isDark),
          if (request.preferredGender == 'female') ...[
            const SizedBox(height: 6),
            _Row(Icons.shield_rounded,
                'Solicitou atendimento feminino',
                isDark: isDark,
                color: AppConstants.success),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  final Color? color;
  const _Row(this.icon, this.text,
      {required this.isDark, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ??
        (isDark
            ? AppConstants.textSecondaryDark
            : AppConstants.textSecondaryLight);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: c),
        const SizedBox(width: 10),
        Expanded(child: Text(text,
            style: TextStyle(fontSize: 13, color: c))),
      ],
    );
  }
}

class _ClientCard extends StatelessWidget {
  final UserEntity client;
  final bool isDark;
  const _ClientCard(
      {required this.client, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? AppConstants.cardShadowDark
            : AppConstants.cardShadowLight),
      child: Row(children: [
        CircleAvatar(
          radius: 24,
          backgroundColor:
              AppConstants.primary.withOpacity(0.12),
          child: Text(
            client.name.isNotEmpty
                ? client.name[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: AppConstants.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cliente',
                style: TextStyle(
                  fontSize: 11,
                  color: AppConstants.textSecondaryLight)),
              Text(client.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark
                      ? AppConstants.textPrimaryDark
                      : AppConstants.textPrimaryLight)),
              if (client.phone != null)
                Text(client.phone!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppConstants.textSecondaryDark
                        : AppConstants.textSecondaryLight)),
            ],
          ),
        ),
        Row(children: [
          const Icon(Icons.star_rounded,
              size: 14, color: AppConstants.accent),
          const SizedBox(width: 3),
          Text(client.averageRating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppConstants.textSecondaryDark
                  : AppConstants.textSecondaryLight)),
        ]),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool outlined;
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 20),
        label: Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size.fromHeight(52),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
      ),
    );
  }
}