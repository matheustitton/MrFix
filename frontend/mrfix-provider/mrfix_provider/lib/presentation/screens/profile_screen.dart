import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ServiceRequestProvider>();
      p.loadMySpecialties();
      p.loadCategories();
    });
  }

  void _addSpecialty() {
    String? catId;
    final priceCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final bioCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) {
          final p = context.read<ServiceRequestProvider>();
          final existingIds = p.mySpecialties.map((s) => s.categoryId).toSet();
          final available = p.categories
              .where((c) => !existingIds.contains(c.id))
              .toList();

          return Container(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                Text('Adicionar especialidade',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppConstants.textPrimaryDark
                        : AppConstants.textPrimaryLight)),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: catId,
                  hint: const Text('Selecione a categoria'),
                  items: available
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => set(() => catId = v),
                  decoration: _deco('Tipo de serviço', Icons.build_outlined, isDark: isDark),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _deco('Preço médio (R\$)', Icons.attach_money, isDark: isDark),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: expCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _deco('Anos de experiência', Icons.work_outline, isDark: isDark),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: bioCtrl,
                  maxLines: 2,
                  decoration: _deco('Descrição (opcional)', Icons.info_outline, isDark: isDark),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    if (catId == null) return;
                    Navigator.pop(ctx);
                    final ok = await context
                        .read<ServiceRequestProvider>()
                        .addSpecialty(
                          categoryId: catId!,
                          averagePrice: double.tryParse(priceCtrl.text),
                          experienceYears: int.tryParse(expCtrl.text),
                          bio: bioCtrl.text.trim(),
                        );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? 'Especialidade adicionada!'
                            : (context.read<ServiceRequestProvider>().error ?? 'Erro ao adicionar')),
                        backgroundColor: ok ? AppConstants.success : AppConstants.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ));
                    }
                  },
                  child: const Text('Salvar especialidade',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _deco(String label, IconData icon, {required bool isDark}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppConstants.primary, size: 20),
      filled: true,
      fillColor: isDark ? AppConstants.surface2Dark : AppConstants.bgLight,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? AppConstants.borderDark : AppConstants.borderLight)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? AppConstants.borderDark : AppConstants.borderLight)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primary, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppConstants.bgDark : AppConstants.bgLight,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white))),
        title: const Text('Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [
          GestureDetector(
            onTap: theme.toggle,
            child: Container(
              width: 36, height: 36,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: Colors.white, size: 18)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Avatar + info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppConstants.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? AppConstants.cardShadowDark : AppConstants.cardShadowLight),
              child: Column(children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppConstants.primary,
                  child: Text(
                    auth.user?.name.isNotEmpty == true
                        ? auth.user!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 28))),
                const SizedBox(height: 12),
                Text(auth.user?.name ?? '',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: isDark ? AppConstants.textPrimaryDark : AppConstants.textPrimaryLight)),
                Text(auth.user?.email ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppConstants.textSecondaryDark : AppConstants.textSecondaryLight)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: AppConstants.accent, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${auth.user?.averageRating.toStringAsFixed(1) ?? '0.0'} '
                      '(${auth.user?.ratingCount ?? 0} avaliações)',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: isDark ? AppConstants.textPrimaryDark : AppConstants.textPrimaryLight)),
                  ],
                ),
                if (auth.user?.gender == 'female') ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                    child: const Text('✓ Profissional mulher',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.success,
                        fontWeight: FontWeight.w700))),
                ],
              ]),
            ),
            const SizedBox(height: 20),

            // Especialidades
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Minhas especialidades',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: isDark ? AppConstants.textPrimaryDark : AppConstants.textPrimaryLight)),
                GestureDetector(
                  onTap: _addSpecialty,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppConstants.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: AppConstants.primary),
                        SizedBox(width: 4),
                        Text('Adicionar',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppConstants.primary,
                            fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Consumer<ServiceRequestProvider>(
              builder: (_, p, __) {
                if (p.mySpecialties.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isDark ? AppConstants.cardShadowDark : AppConstants.cardShadowLight),
                    child: Column(children: [
                      Icon(Icons.build_circle_outlined,
                        size: 48,
                        color: AppConstants.primary.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text('Nenhuma especialidade',
                        style: TextStyle(
                          color: isDark ? AppConstants.textSecondaryDark : AppConstants.textSecondaryLight,
                          fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        'Adicione suas especialidades para aparecer nas buscas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppConstants.textSecondaryDark : AppConstants.textSecondaryLight)),
                    ]),
                  );
                }

                return Column(
                  children: p.mySpecialties.map((s) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isDark ? AppConstants.cardShadowDark : AppConstants.cardShadowLight),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppConstants.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12)),
                        child: Icon(
                          AppConstants.categoryIcons[s.category?.icon] ?? Icons.build_rounded,
                          color: AppConstants.primary, size: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.category?.name ?? s.categoryName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppConstants.textPrimaryDark : AppConstants.textPrimaryLight)),
                            Row(children: [
                              if (s.averagePrice != null)
                                Text(
                                  'R\$ ${s.averagePrice!.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppConstants.success,
                                    fontWeight: FontWeight.w600)),
                              if (s.averagePrice != null && s.experienceYears > 0)
                                const SizedBox(width: 8),
                              if (s.experienceYears > 0)
                                Text(
                                  '${s.experienceYears} ano(s)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppConstants.textSecondaryDark : AppConstants.textSecondaryLight)),
                            ]),
                            if (s.bio != null && s.bio!.isNotEmpty)
                              Text(s.bio!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppConstants.textSecondaryDark : AppConstants.textSecondaryLight)),
                          ],
                        ),
                      ),
                      Icon(
                        s.isAvailable ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                        color: s.isAvailable ? AppConstants.success : AppConstants.textSecondaryLight,
                        size: 20),
                    ]),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}