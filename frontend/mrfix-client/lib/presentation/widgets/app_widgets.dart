import 'package:flutter/material.dart';
import 'package:misterfix_client/core/constants/app_constants.dart';

// ── Botão Primário Animado ─────────────────────────────────────────────────
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bg = widget.color ?? AppConstants.primary;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onPressed?.call(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: widget.loading ? bg.withOpacity(0.7) : bg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.onPressed != null
                ? AppConstants.primaryShadow : [],
          ),
          child: Center(
            child: widget.loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      )),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}

// ── Input Field ────────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark
            ? AppConstants.textPrimaryDark
            : AppConstants.textPrimaryLight,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppConstants.primary, size: 20),
        suffixIcon: suffix,
        labelStyle: TextStyle(
          color: isDark
              ? AppConstants.textSecondaryDark
              : AppConstants.textSecondaryLight,
        ),
      ),
    );
  }
}

// ── Status Badge ───────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppConstants.statusColors[status] ?? Colors.grey;
    final bg = isDark
        ? AppConstants.statusBgColorsDark[status] ?? Colors.grey.shade900
        : AppConstants.statusBgColors[status] ?? Colors.grey.shade100;
    final label = AppConstants.statusLabels[status] ?? status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          )),
      ]),
    );
  }
}

// ── Tappable Card ──────────────────────────────────────────────────────────
class TappableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const TappableCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
  });

  @override
  State<TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<TappableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppConstants.surfaceDark : Colors.white,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            boxShadow: isDark
                ? AppConstants.cardShadowDark
                : AppConstants.cardShadowLight,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppConstants.textPrimaryDark
                : AppConstants.textPrimaryLight,
            letterSpacing: -0.3,
          )),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!,
              style: const TextStyle(
                fontSize: 13,
                color: AppConstants.primary,
                fontWeight: FontWeight.w600,
              )),
          ),
      ],
    );
  }
}