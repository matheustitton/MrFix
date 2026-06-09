import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_request_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

class RequestDetailScreen extends StatefulWidget {
  final String requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestProvider>().loadRequest(widget.requestId);
    });
  }

  Future<void> _cancelRequest() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar solicitação'),
        content: const Text('Tem certeza que deseja cancelar esta solicitação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppConstants.error),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final ok = await context.read<ServiceRequestProvider>()
          .cancelRequest(widget.requestId, reason: 'Cancelado pelo cliente');
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação cancelada'),
              backgroundColor: AppConstants.textSecondary),
        );
      }
    }
  }

  Future<void> _submitRating(ServiceRequestEntity request) async {
    int selectedScore = 5;
    final commentCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Avaliar prestador',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Como foi o serviço de ${request.provider?.name ?? 'prestador'}?',
                style: const TextStyle(color: AppConstants.textSecondary)),
              const SizedBox(height: 20),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setSheetState(() => selectedScore = i + 1),
                  child: Icon(
                    i < selectedScore ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppConstants.accent, size: 40,
                  ),
                )),
              ),
              const SizedBox(height: 16),

              // Comment
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Comentário (opcional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppConstants.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final ok = await context.read<ServiceRequestProvider>().submitRating(
                    requestId: request.id,
                    score: selectedScore,
                    comment: commentCtrl.text.trim().isEmpty ? null : commentCtrl.text.trim(),
                  );
                  if (ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Avaliação enviada! Obrigado.'),
                          backgroundColor: AppConstants.success),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Enviar avaliação',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        foregroundColor: AppConstants.primary,
        title: const Text('Detalhe',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ServiceRequestProvider>()
                .loadRequest(widget.requestId),
          ),
        ],
      ),
      body: Consumer<ServiceRequestProvider>(
        builder: (_, provider, __) {
          final request = provider.selected;

          if (provider.loading && request == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppConstants.primary));
          }

          if (request == null) {
            return const Center(child: Text('Solicitação não encontrada'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Status card
                _StatusCard(request: request),
                const SizedBox(height: 16),

                // Info card
                _InfoCard(request: request),
                const SizedBox(height: 16),

                // Provider card
                if (request.provider != null)
                  _ProviderCard(provider: request.provider!),

                // Polling indicator
                if (!request.isCompleted && !request.isCancelled) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppConstants.primary),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Atualizando status automaticamente a cada 5s...',
                            style: TextStyle(
                              fontSize: 12, color: AppConstants.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Actions
                const SizedBox(height: 24),
                if (request.canBeCancelled && request.isPending)
                  OutlinedButton.icon(
                    onPressed: _cancelRequest,
                    icon: const Icon(Icons.cancel_outlined, color: AppConstants.error),
                    label: const Text('Cancelar solicitação',
                        style: TextStyle(color: AppConstants.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppConstants.error),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),

                // Rating button
                if (request.isCompleted && request.provider != null) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _submitRating(request),
                    icon: const Icon(Icons.star_rounded),
                    label: const Text('Avaliar prestador',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ],
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
  const _StatusCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.statusColors[request.status] ?? AppConstants.textSecondary;
    final label = AppConstants.statusLabels[request.status] ?? request.status;

    final steps = ['pending', 'accepted', 'in_progress', 'completed'];
    final currentStep = steps.indexOf(request.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: color),
                    const SizedBox(width: 6),
                    Text(label,
                      style: TextStyle(
                        color: color, fontWeight: FontWeight.w700, fontSize: 14,
                      )),
                  ],
                ),
              ),
            ],
          ),

          if (!request.isCancelled) ...[
            const SizedBox(height: 20),
            // Progress steps
            Row(
              children: steps.asMap().entries.map((e) {
                final idx = e.key;
                final stepLabel = AppConstants.statusLabels[e.value] ?? e.value;
                final isActive  = idx <= currentStep;
                final isLast    = idx == steps.length - 1;

                return Expanded(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: isActive ? AppConstants.primary : AppConstants.border,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isActive ? Icons.check : Icons.circle,
                              size: 12, color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(stepLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: isActive
                                  ? AppConstants.primary
                                  : AppConstants.textSecondary,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            )),
                        ],
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: idx < currentStep
                                ? AppConstants.primary
                                : AppConstants.border,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Info Card ──────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final ServiceRequestEntity request;
  const _InfoCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(request.title,
            style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppConstants.textPrimary,
            )),
          if (request.description != null) ...[
            const SizedBox(height: 6),
            Text(request.description!,
              style: const TextStyle(
                  fontSize: 14, color: AppConstants.textSecondary)),
          ],
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.category_outlined, text: request.category?.name ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.location_on_outlined, text: request.address),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.shield_outlined,
            text: AppConstants.genderLabels[request.preferredGender] ?? request.preferredGender,
            color: request.preferredGender == 'female' ? AppConstants.success : null,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _InfoRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color ?? AppConstants.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
            style: TextStyle(
              fontSize: 13,
              color: color ?? AppConstants.textSecondary,
            )),
        ),
      ],
    );
  }
}

// ── Provider Card ──────────────────────────────────────────────────────────

class _ProviderCard extends StatelessWidget {
  final UserEntity provider;
  const _ProviderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppConstants.primary,
            child: Text(
              provider.name.isNotEmpty ? provider.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15,
                    color: AppConstants.textPrimary,
                  )),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppConstants.accent),
                    const SizedBox(width: 2),
                    Text('${provider.averageRating.toStringAsFixed(1)} (${provider.ratingCount})',
                      style: const TextStyle(
                          fontSize: 12, color: AppConstants.textSecondary)),
                    if (provider.gender == 'female') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('✓ Profissional mulher',
                          style: TextStyle(
                            fontSize: 10, color: AppConstants.success,
                            fontWeight: FontWeight.w600,
                          )),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
