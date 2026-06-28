import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_request_provider.dart';
import '../../core/constants/app_constants.dart';

class AddSpecialtyScreen extends StatefulWidget {
  const AddSpecialtyScreen({super.key});
  @override
  State<AddSpecialtyScreen> createState() => _AddSpecialtyScreenState();
}

class _AddSpecialtyScreenState extends State<AddSpecialtyScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _expCtrl   = TextEditingController();
  final _bioCtrl   = TextEditingController();

  String? _selectedCategoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _expCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      _showSnack('Selecione uma categoria', error: true);
      return;
    }
    setState(() => _saving = true);

    final ok = await context.read<ServiceRequestProvider>().addSpecialty(
      categoryId:      _selectedCategoryId!,
      averagePrice:    double.tryParse(_priceCtrl.text),
      experienceYears: int.tryParse(_expCtrl.text),
      bio:             _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
    );

    setState(() => _saving = false);

    if (ok && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      final err = context.read<ServiceRequestProvider>().error ?? 'Erro ao salvar';
      _showSnack(err, error: true);
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppConstants.error : AppConstants.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p      = context.watch<ServiceRequestProvider>();

    // Remove categorias que o prestador já tem
    final existingIds = p.mySpecialties.map((s) => s.categoryId).toSet();
    final available   = p.categories.where((c) => !existingIds.contains(c.id)).toList();

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
            child: const Icon(Icons.arrow_back_rounded,
                size: 20, color: Colors.white)),
        ),
        title: const Text('Nova Especialidade',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Categoria
              _Label('Tipo de serviço', isDark: isDark),
              const SizedBox(height: 10),
              available.isEmpty && p.categories.isEmpty
                ? const Center(child: CircularProgressIndicator(
                    color: AppConstants.primary, strokeWidth: 2))
                : available.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppConstants.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppConstants.success.withOpacity(0.3))),
                      child: const Row(children: [
                        Icon(Icons.check_circle_rounded,
                            color: AppConstants.success, size: 18),
                        SizedBox(width: 10),
                        Text('Você já cadastrou todas as categorias!',
                          style: TextStyle(
                            color: AppConstants.success,
                            fontWeight: FontWeight.w600)),
                      ]))
                  : DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      hint: const Text('Selecione a categoria'),
                      decoration: _deco('Categoria', Icons.build_outlined, isDark: isDark),
                      items: available
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                      validator: (v) => v == null ? 'Selecione uma categoria' : null,
                    ),
              const SizedBox(height: 20),

              // Preço
              _Label('Preço médio (R\$)', isDark: isDark),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _deco('Ex: 150.00', Icons.attach_money, isDark: isDark),
              ),
              const SizedBox(height: 20),

              // Experiência
              _Label('Anos de experiência', isDark: isDark),
              const SizedBox(height: 10),
              TextFormField(
                controller: _expCtrl,
                keyboardType: TextInputType.number,
                decoration: _deco('Ex: 3', Icons.work_outline, isDark: isDark),
              ),
              const SizedBox(height: 20),

              // Bio
              _Label('Descrição (opcional)', isDark: isDark),
              const SizedBox(height: 10),
              TextFormField(
                controller: _bioCtrl,
                maxLines: 3,
                decoration: _deco(
                  'Conte um pouco sobre sua experiência nesta área...',
                  Icons.info_outline, isDark: isDark),
              ),
              const SizedBox(height: 32),

              // Botão
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: (_saving || available.isEmpty) ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded, size: 20),
                  label: Text(_saving ? 'Salvando...' : 'Salvar Especialidade',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _deco(String hint, IconData icon, {required bool isDark}) =>
    InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppConstants.primary, size: 20),
      filled: true,
      fillColor: isDark ? AppConstants.surfaceDark : Colors.white,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
}

class _Label extends StatelessWidget {
  final String text;
  final bool isDark;
  const _Label(this.text, {required this.isDark});
  @override
  Widget build(BuildContext context) => Text(text,
    style: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w700,
      color: isDark ? AppConstants.textPrimaryDark : AppConstants.textPrimaryLight));
}