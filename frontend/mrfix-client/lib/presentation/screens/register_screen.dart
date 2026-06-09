import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  String _gender = 'prefer_not_to_say';
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      gender: _gender,
    );
    if (ok && mounted) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppConstants.primary,
        title: const Text('Criar conta',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppConstants.textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nome
                _buildField(
                  controller: _nameCtrl,
                  label: 'Nome completo',
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nome obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // Email
                _buildField(
                  controller: _emailCtrl,
                  label: 'E-mail',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'E-mail inválido' : null,
                ),
                const SizedBox(height: 16),

                // Senha
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mínimo 6 caracteres' : null,
                  decoration: _inputDecoration(
                    label: 'Senha',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppConstants.textSecondary),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gênero
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConstants.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: AppConstants.primary, size: 18),
                          SizedBox(width: 8),
                          Text('Gênero',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textPrimary,
                            )),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Usado para o filtro de segurança ao solicitar serviços',
                        style: TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      ...[
                        ('female', 'Feminino'),
                        ('male', 'Masculino'),
                        ('other', 'Outro'),
                        ('prefer_not_to_say', 'Prefiro não informar'),
                      ].map((g) => RadioListTile<String>(
                        value: g.$1,
                        groupValue: _gender,
                        title: Text(g.$2, style: const TextStyle(fontSize: 14)),
                        activeColor: AppConstants.primary,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        onChanged: (v) => setState(() => _gender = v!),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Error
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => auth.error != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(auth.error!,
                          style: const TextStyle(color: AppConstants.error, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Button
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: auth.loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: auth.loading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Criar conta',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Já tem conta? ',
                        style: TextStyle(color: AppConstants.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: const Text('Entrar',
                          style: TextStyle(
                              color: AppConstants.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label: label, icon: icon),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppConstants.primary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
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
