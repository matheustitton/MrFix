import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_request_provider.dart';
import '../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';
import '../widgets/app_widgets.dart';

class NewRequestScreen extends StatefulWidget {
  final String? preselectedCategoryId;
  const NewRequestScreen({super.key, this.preselectedCategoryId});
  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen>
    with TickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _addrCtrl  = TextEditingController();
  final _descCtrl  = TextEditingController();

  String? _selectedCategoryId;
  String _preferredGender = 'any';
  bool _femaleOnly = false;

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.preselectedCategoryId;
    _slideCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1), end: Offset.zero)
      .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _addrCtrl.dispose(); _descCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      _showError('Selecione um tipo de serviço');
      return;
    }
    final p = context.read<ServiceRequestProvider>();
    final created = await p.createRequest(
      categoryId:      _selectedCategoryId!,
      title:           _titleCtrl.text.trim(),
      address:         _addrCtrl.text.trim(),
      description:     _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      preferredGender: _femaleOnly ? 'female' : _preferredGender,
    );
    if (created != null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Pedido criado! Aguardando prestador...'),
          ]),
          backgroundColor: AppConstants.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (p.error != null && mounted) {
      _showError(p.error!);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(msg),
        ]),
        backgroundColor: AppConstants.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnim,
      child: Scaffold(
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
          title: Text('Novo Pedido',
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: isDark
                  ? AppConstants.textPrimaryDark
                  : AppConstants.textPrimaryLight,
            )),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Icon(Icons.help_outline_rounded,
                size: 20,
                color: isDark
                    ? AppConstants.textSecondaryDark
                    : AppConstants.textSecondaryLight),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  //────────────── Tipo de serviço ────────────────────────────────────────────
                  _SectionLabel(
                    label: 'Tipo de Serviço',
                    icon: Icons.category_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  Consumer<ServiceRequestProvider>(
                    builder: (_, p, __) {
                      if (p.categories.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppConstants.primary, strokeWidth: 2));
                      }
                      return Wrap(
                        spacing: 8, runSpacing: 8,
                        children: p.categories.map((cat) {
                          final selected = _selectedCategoryId == cat.id;
                          return _CategoryChip(
                            category: cat,
                            selected: selected,
                            isDark: isDark,
                            onTap: () => setState(
                                () => _selectedCategoryId = cat.id),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ────── Detalhes ────────────────────────────────────────────────────────
                  _SectionLabel(
                    label: 'Detalhes do problema',
                    icon: Icons.edit_note_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _StyledTextArea(
                    controller: _titleCtrl,
                    hint: 'Descreva o que precisa...\nEx: Minha torneira está pingando muito na cozinha.',
                    isDark: isDark,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Descreva o problema' : null,
                  ),
                  const SizedBox(height: 24),

                  // ────── Endereço ────────────────────────────────────────────────────────
                  _SectionLabel(
                    label: 'Endereço do Serviço',
                    icon: Icons.location_on_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _StyledField(
                    controller: _addrCtrl,
                    hint: 'Av. Paulista, 1000 - Bela Vista',
                    prefixIcon: Icons.location_on_rounded,
                    isDark: isDark,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Endereço obrigatório' : null,
                  ),
                  const SizedBox(height: 12),

                  // ────── Mapa placeholder ────────────────────────────────────────────────
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppConstants.surface2Dark
                          : AppConstants.borderLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppConstants.borderDark
                            : AppConstants.borderLight),
                    ),
                    child: Stack(children: [
                      Center(child: Icon(Icons.map_outlined,
                        size: 40,
                        color: isDark
                            ? AppConstants.textSecondaryDark
                            : AppConstants.textSecondaryLight)),
                      Positioned(
                        bottom: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppConstants.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.my_location_rounded,
                                color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('Usar minha localização',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                )),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(Icons.location_pin,
                          color: AppConstants.primary, size: 32)),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // ────── Agendamento ────────────────────────────────────────────────────────
                  _SectionLabel(
                    label: 'Agendar para...',
                    icon: Icons.calendar_month_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _DateField(isDark: isDark)),
                    const SizedBox(width: 12),
                    Expanded(child: _TimeField(isDark: isDark)),
                  ]),
                  const SizedBox(height: 24),

                  // ────── Atendimento Feminino ────────────────────────────────────────────────
                  GestureDetector(
                    onTap: () => setState(() {
                      _femaleOnly = !_femaleOnly;
                      _preferredGender = _femaleOnly ? 'female' : 'any';
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _femaleOnly
                            ? AppConstants.primary.withOpacity(0.08)
                            : (isDark
                                ? AppConstants.surfaceDark
                                : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _femaleOnly
                              ? AppConstants.primary.withOpacity(0.4)
                              : (isDark
                                  ? AppConstants.borderDark
                                  : AppConstants.borderLight)),
                        boxShadow: _femaleOnly
                            ? []
                            : (isDark
                                ? AppConstants.cardShadowDark
                                : AppConstants.cardShadowLight),
                      ),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: _femaleOnly
                                ? AppConstants.primary.withOpacity(0.15)
                                : (isDark
                                    ? AppConstants.surface2Dark
                                    : AppConstants.bgLight),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.shield_rounded,
                            color: _femaleOnly
                                ? AppConstants.primary
                                : (isDark
                                    ? AppConstants.textSecondaryDark
                                    : AppConstants.textSecondaryLight),
                            size: 20)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Atendimento Feminino',
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: _femaleOnly
                                    ? AppConstants.primary
                                    : (isDark
                                        ? AppConstants.textPrimaryDark
                                        : AppConstants.textPrimaryLight),
                              )),
                            Text('Segurança e conforto',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppConstants.textSecondaryDark
                                    : AppConstants.textSecondaryLight,
                              )),
                          ],
                        )),
                        // ────── Animação para o botão ────────────────────────────────────────────────
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 48, height: 26,
                          decoration: BoxDecoration(
                            color: _femaleOnly
                                ? AppConstants.primary
                                : (isDark
                                    ? AppConstants.borderDark
                                    : AppConstants.borderLight),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: _femaleOnly
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 22, height: 22,
                              margin: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ────── Botão confirmar ────────────────────────────────────────────────────────
                  Consumer<ServiceRequestProvider>(
                    builder: (_, p, __) => PrimaryButton(
                      label: 'Confirmar Pedido',
                      icon: Icons.send_rounded,
                      loading: p.creating,
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  const _SectionLabel({
    required this.label, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: AppConstants.primary),
      const SizedBox(width: 8),
      Text(label,
        style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700,
          color: isDark
              ? AppConstants.textPrimaryDark
              : AppConstants.textPrimaryLight,
          letterSpacing: -0.2,
        )),
    ]);
  }
}

class _CategoryChip extends StatefulWidget {
  final ServiceCategoryEntity category;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.category, required this.selected,
    required this.isDark, required this.onTap,
  });
  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppConstants.primary
                : (widget.isDark ? AppConstants.surface2Dark : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.selected
                  ? AppConstants.primary
                  : (widget.isDark
                      ? AppConstants.borderDark
                      : AppConstants.borderLight)),
            boxShadow: widget.selected ? AppConstants.primaryShadow : [],
          ),
          child: Text(widget.category.name,
            style: TextStyle(
              color: widget.selected
                  ? Colors.white
                  : (widget.isDark
                      ? AppConstants.textSecondaryDark
                      : AppConstants.textSecondaryLight),
              fontWeight: widget.selected
                  ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            )),
        ),
      ),
    );
  }
}

class _StyledTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final String? Function(String?)? validator;
  const _StyledTextArea({
    required this.controller, required this.hint,
    required this.isDark, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      validator: validator,
      style: TextStyle(
        fontSize: 14,
        color: isDark
            ? AppConstants.textPrimaryDark
            : AppConstants.textPrimaryLight,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark
              ? AppConstants.textSecondaryDark
              : AppConstants.textSecondaryLight,
          fontSize: 13,
        ),
        filled: true,
        fillColor: isDark ? AppConstants.surfaceDark : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppConstants.borderDark : AppConstants.borderLight)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppConstants.borderDark : AppConstants.borderLight)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppConstants.primary, width: 2)),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool isDark;
  final String? Function(String?)? validator;
  const _StyledField({
    required this.controller, required this.hint,
    required this.prefixIcon, required this.isDark, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(
        fontSize: 14,
        color: isDark
            ? AppConstants.textPrimaryDark
            : AppConstants.textPrimaryLight,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark
              ? AppConstants.textSecondaryDark
              : AppConstants.textSecondaryLight,
          fontSize: 13),
        prefixIcon: Icon(prefixIcon, color: AppConstants.primary, size: 18),
        filled: true,
        fillColor: isDark ? AppConstants.surfaceDark : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppConstants.borderDark : AppConstants.borderLight)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppConstants.borderDark : AppConstants.borderLight)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppConstants.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final bool isDark;
  const _DateField({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppConstants.borderDark : AppConstants.borderLight)),
      child: Row(children: [
        const SizedBox(width: 12),
        Icon(Icons.calendar_today_rounded,
          size: 16, color: AppConstants.primary),
        const SizedBox(width: 8),
        Text('dd/mm/aaaa',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppConstants.textSecondaryDark
                : AppConstants.textSecondaryLight)),
      ]),
    );
  }
}

class _TimeField extends StatelessWidget {
  final bool isDark;
  const _TimeField({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppConstants.borderDark : AppConstants.borderLight)),
      child: Row(children: [
        const SizedBox(width: 12),
        Icon(Icons.access_time_rounded,
          size: 16, color: AppConstants.primary),
        const SizedBox(width: 8),
        Text('--:--',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppConstants.textSecondaryDark
                : AppConstants.textSecondaryLight)),
      ]),
    );
  }
}