import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_request_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

class NewRequestScreen extends StatefulWidget {
  final String? preselectedCategoryId;
  const NewRequestScreen({super.key, this.preselectedCategoryId});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _addrCtrl  = TextEditingController();
  final _descCtrl  = TextEditingController();

  String? _selectedCategoryId;
  String _preferredGender = 'any';

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.preselectedCategoryId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceRequestProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _addrCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria'), backgroundColor: AppConstants.error),
      );
      return;
    }

    final provider = context.read<ServiceRequestProvider>();
    final created = await provider.createRequest(
      categoryId:      _selectedCategoryId!,
      title:           _titleCtrl.text.trim(),
      address:         _addrCtrl.text.trim(),
      description:     _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      preferredGender: _preferredGender,
    );

    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação criada! Aguardando prestador...'),
          backgroundColor: AppConstants.success,
        ),
      );
      Navigator.pop(context);
    } else if (provider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: AppConstants.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        foregroundColor: AppConstants.primary,
        title: const Text('Nova solicitação',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Categoria
                const _SectionLabel(label: 'Tipo de serviço', icon: Icons.category_outlined),
                const SizedBox(height: 8),
                Consumer<ServiceRequestProvider>(
                  builder: (_, provider, __) {
                    if (provider.categories.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(color: AppConstants.primary),
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 8, runSpacing: 8,
                      children: provider.categories.map((cat) {
                        final selected = _selectedCategoryId == cat.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategoryId = cat.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppConstants.primary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? AppConstants.primary : AppConstants.border,
                              ),
                            ),
                            child: Text(cat.name,
                              style: TextStyle(
                                color: selected ? Colors.white : AppConstants.textSecondary,
                                fontWeight: FontWeight.w500, fontSize: 13,
                              )),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Título
                const _SectionLabel(label: 'Descreva o problema', icon: Icons.edit_outlined),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Título obrigatório' : null,
                  decoration: _inputDecoration(
                    label: 'Ex: Instalação de 3 tomadas na sala',
                    icon: Icons.title,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    label: 'Detalhes adicionais (opcional)',
                    icon: Icons.description_outlined,
                  ),
                ),
                const SizedBox(height: 20),

                // Endereço
                const _SectionLabel(label: 'Endereço do serviço', icon: Icons.location_on_outlined),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addrCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Endereço obrigatório' : null,
                  decoration: _inputDecoration(
                    label: 'Rua, número, bairro, cidade',
                    icon: Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(height: 20),

                // Filtro de gênero (funcionalidade de segurança)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppConstants.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shield_rounded, color: AppConstants.primary, size: 20),
                          SizedBox(width: 8),
                          Text('Preferência de profissional',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppConstants.textPrimary,
                              fontSize: 15,
                            )),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Por segurança, você pode solicitar apenas profissionais mulheres',
                        style: TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      ...AppConstants.genderLabels.entries.map((e) =>
                        RadioListTile<String>(
                          value: e.key,
                          groupValue: _preferredGender,
                          title: Text(e.value,
                            style: const TextStyle(fontSize: 14)),
                          subtitle: e.key == 'female'
                            ? const Text('Recomendado para mais segurança',
                                style: TextStyle(fontSize: 11, color: AppConstants.success))
                            : null,
                          activeColor: AppConstants.primary,
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          onChanged: (v) => setState(() => _preferredGender = v!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit
                Consumer<ServiceRequestProvider>(
                  builder: (_, provider, __) => SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: provider.creating ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: provider.creating
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Solicitar serviço',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppConstants.primary, size: 20),
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primary, width: 2)),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppConstants.primary),
        const SizedBox(width: 6),
        Text(label,
          style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppConstants.textPrimary,
          )),
      ],
    );
  }
}
