import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/app_widgets.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _gender = 'prefer_not_to_say';
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
          gender: _gender,
        );
    if (ok && mounted) {
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: isDark
                        ? AppConstants.surface2Dark
                        : AppConstants.bgLight,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.arrow_back_rounded,
                    size: 20,
                    color: isDark
                        ? AppConstants.textPrimaryDark
                        : AppConstants.textPrimaryLight))),
        title: Text('Criar conta',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppConstants.textPrimaryDark
                    : AppConstants.textPrimaryLight)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Nome completo',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nome obrigatório'
                      : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _emailCtrl,
                  label: 'E-mail',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'E-mail inválido'
                      : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _passCtrl,
                  label: 'Senha',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscure,
                  suffix: IconButton(
                      icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: isDark
                              ? AppConstants.textSecondaryDark
                              : AppConstants.textSecondaryLight),
                      onPressed: () => setState(() => _obscure = !_obscure)),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mínimo 6 caracteres'
                      : null,
                ),
                const SizedBox(height: 24),

                //────────── Gênero ───────────────────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: isDark ? AppConstants.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isDark
                              ? AppConstants.borderDark
                              : AppConstants.borderLight)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.shield_outlined,
                            color: AppConstants.primary, size: 16),
                        const SizedBox(width: 8),
                        Text('Gênero',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isDark
                                    ? AppConstants.textPrimaryDark
                                    : AppConstants.textPrimaryLight)),
                      ]),
                      const SizedBox(height: 4),
                      Text('Usado no filtro de segurança',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppConstants.textSecondaryDark
                                  : AppConstants.textSecondaryLight)),
                      const SizedBox(height: 12),
                      ...[
                        ('female', 'Feminino'),
                        ('male', 'Masculino'),
                        ('other', 'Outro'),
                        ('prefer_not_to_say', 'Prefiro não informar'),
                      ].map((g) => RadioListTile<String>(
                            value: g.$1,
                            groupValue: _gender,
                            title: Text(g.$2,
                                style: const TextStyle(fontSize: 14)),
                            activeColor: AppConstants.primary,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            onChanged: (v) => setState(() => _gender = v!),
                          )),
                    ],
                  ),
                ),

                // ────── Error ────────────────────────────────────────────────────────────────
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => auth.error != null
                      ? Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: AppConstants.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(children: [
                            const Icon(Icons.error_outline,
                                color: AppConstants.primary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(auth.error!,
                                    style: const TextStyle(
                                        color: AppConstants.primary,
                                        fontSize: 13))),
                          ]))
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                Consumer<AuthProvider>(
                  builder: (_, auth, __) => PrimaryButton(
                    label: 'Criar conta',
                    loading: auth.loading,
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 16),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Já tem conta? ',
                      style: TextStyle(
                          color: isDark
                              ? AppConstants.textSecondaryDark
                              : AppConstants.textSecondaryLight,
                          fontSize: 14)),
                  GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                      child: const Text('Entrar',
                          style: TextStyle(
                              color: AppConstants.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14))),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
