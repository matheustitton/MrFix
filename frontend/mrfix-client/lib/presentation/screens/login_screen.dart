import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/app_widgets.dart';
import 'register_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey  = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;
  bool _isClient = true;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>()
        .login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    if (ok && mounted) {
      Navigator.pushReplacement(context,
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
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // ────────── Header ────────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('MisterFix',
                        style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark
                              ? AppConstants.textPrimaryDark
                              : AppConstants.textPrimaryLight,
                        )),
                      Text('Sua casa em boas mãos, sempre.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppConstants.textSecondaryDark
                              : AppConstants.textSecondaryLight,
                        )),
                    ]),
                    // ──────── Dark mode ──────────────────────────────────────────────────────
                    GestureDetector(
                      onTap: theme.toggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppConstants.surface2Dark
                              : AppConstants.bgLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: isDark
                              ? AppConstants.textSecondaryDark
                              : AppConstants.textSecondaryLight,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ────── Cliente / Prestador ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppConstants.surface2Dark : AppConstants.bgLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    Expanded(child: _TabBtn(
                      label: 'Sou Cliente',
                      selected: _isClient,
                      onTap: () => setState(() => _isClient = true))),
                    Expanded(child: _TabBtn(
                      label: 'Sou Prestador',
                      selected: !_isClient,
                      onTap: () => setState(() => _isClient = false))),
                  ]),
                ),
                const SizedBox(height: 32),

                Form(key: _formKey, child: Column(children: [
                  AppTextField(
                    controller: _emailCtrl,
                    label: 'E-mail',
                    hint: 'nome@exemplo.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'E-mail inválido' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passCtrl,
                    label: 'Senha',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: isDark
                            ? AppConstants.textSecondaryDark
                            : AppConstants.textSecondaryLight,
                        size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure)),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Mínimo 6 caracteres' : null,
                  ),
                ])),
                const SizedBox(height: 8),

                // ────── Preferência de Gênero ────────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppConstants.surface2Dark : AppConstants.bgLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppConstants.borderDark : AppConstants.borderLight),
                  ),
                  child: Row(children: [
                    Icon(Icons.shield_outlined,
                      color: AppConstants.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preferência de Gênero (Filtro de Segurança)',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppConstants.textSecondaryDark
                                : AppConstants.textSecondaryLight,
                          )),
                        const SizedBox(height: 10),
                        Row(children: [
                          _GenderChip(label: '♂ Masculino', selected: false, onTap: () {}),
                          const SizedBox(width: 8),
                          _GenderChip(label: '♀ Feminino', selected: true, onTap: () {}),
                          const SizedBox(width: 8),
                          _GenderChip(label: '⊕ Outro', selected: false, onTap: () {}),
                        ]),
                      ],
                    )),
                  ]),
                ),

                // ────── Error ────────────────────────────────────────────────────────
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => auth.error != null
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline,
                            color: AppConstants.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(auth.error!,
                            style: const TextStyle(
                              color: AppConstants.primary, fontSize: 13))),
                        ]))
                    : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                Consumer<AuthProvider>(
                  builder: (_, auth, __) => PrimaryButton(
                    label: 'Entrar',
                    loading: auth.loading,
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 16),

                // ────── Divisor ────────────────────────────────────────────────────────
                Row(children: [
                  Expanded(child: Divider(
                    color: isDark ? AppConstants.borderDark : AppConstants.borderLight)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ou acesso com',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppConstants.textSecondaryDark
                            : AppConstants.textSecondaryLight,
                      ))),
                  Expanded(child: Divider(
                    color: isDark ? AppConstants.borderDark : AppConstants.borderLight)),
                ]),
                const SizedBox(height: 16),

                // ────── Google button (Não Implementado :<) ────────────────────────────────────────────────
                _OutlineButton(
                  label: 'Entrar com Google',
                  icon: Icons.g_mobiledata_rounded,
                  onTap: () {},
                ),
                const SizedBox(height: 24),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Não possui uma conta? ',
                    style: TextStyle(
                      color: isDark
                          ? AppConstants.textSecondaryDark
                          : AppConstants.textSecondaryLight,
                      fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('Criar conta',
                      style: TextStyle(
                        color: AppConstants.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ))),
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

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppConstants.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppConstants.textSecondaryLight,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          )),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GenderChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppConstants.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppConstants.primary : AppConstants.borderLight),
        ),
        child: Text(label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : AppConstants.textSecondaryLight,
            fontWeight: FontWeight.w600,
          )),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? AppConstants.surface2Dark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppConstants.borderDark : AppConstants.borderLight),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 22,
            color: isDark
                ? AppConstants.textPrimaryDark
                : AppConstants.textPrimaryLight),
          const SizedBox(width: 10),
          Text(label,
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: isDark
                  ? AppConstants.textPrimaryDark
                  : AppConstants.textPrimaryLight,
            )),
        ]),
      ),
    );
  }
}