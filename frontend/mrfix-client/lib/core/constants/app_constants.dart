import 'package:flutter/material.dart';

class AppConstants {
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration pollingInterval = Duration(seconds: 5);

  // ── Light Theme Colors ────────────────────────────────────────────────────
  static const Color primary        = Color(0xFFC82828);
  static const Color primaryDark    = Color(0xFF9B1B1B);
  static const Color primaryLight   = Color(0xFFFF4444);
  static const Color secondary      = Color(0xFF424242);
  static const Color tertiary       = Color(0xFFF5F5F5);
  static const Color accent         = Color(0xFFF4A61E);
  static const Color success        = Color(0xFF2E7D32);
  static const Color successLight   = Color(0xFFE8F5E9);
  static const Color error          = Color(0xFFC82828);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color warningLight   = Color(0xFFFFF8E1);

  // Light
  static const Color bgLight        = Color(0xFFF5F5F5);
  static const Color surfaceLight   = Color(0xFFFFFFFF);
  static const Color textPrimaryLight   = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color borderLight    = Color(0xFFE8E8E8);
  static const Color dividerLight   = Color(0xFFF0F0F0);

  // Dark
  static const Color bgDark         = Color(0xFF121212);
  static const Color surfaceDark    = Color(0xFF1E1E1E);
  static const Color surface2Dark   = Color(0xFF2A2A2A);
  static const Color textPrimaryDark    = Color(0xFFF5F5F5);
  static const Color textSecondaryDark  = Color(0xFF9E9E9E);
  static const Color borderDark     = Color(0xFF333333);
  static const Color dividerDark    = Color(0xFF2A2A2A);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Map<String, String> statusLabels = {
    'pending':     'Aguardando',
    'accepted':    'Aceito',
    'in_progress': 'Em andamento',
    'completed':   'Concluído',
    'cancelled':   'Cancelado',
  };

  static const Map<String, Color> statusColors = {
    'pending':     Color(0xFFF59E0B),
    'accepted':    Color(0xFF1565C0),
    'in_progress': Color(0xFF6A1B9A),
    'completed':   Color(0xFF2E7D32),
    'cancelled':   Color(0xFFC82828),
  };

  static const Map<String, Color> statusBgColors = {
    'pending':     Color(0xFFFFF8E1),
    'accepted':    Color(0xFFE3F2FD),
    'in_progress': Color(0xFFF3E5F5),
    'completed':   Color(0xFFE8F5E9),
    'cancelled':   Color(0xFFFFEBEE),
  };

  static const Map<String, Color> statusBgColorsDark = {
    'pending':     Color(0xFF3D2E00),
    'accepted':    Color(0xFF0D2137),
    'in_progress': Color(0xFF2D1040),
    'completed':   Color(0xFF0D2E10),
    'cancelled':   Color(0xFF3D0D0D),
  };

  // ── Gender Labels ─────────────────────────────────────────────────────────
  static const Map<String, String> genderLabels = {
    'any':    'Qualquer profissional',
    'female': 'Apenas mulheres',
    'male':   'Apenas homens',
  };

  // ── Category Icons ────────────────────────────────────────────────────────
  static const Map<String, IconData> categoryIcons = {
    'bolt':         Icons.bolt_rounded,
    'water_drop':   Icons.water_drop_rounded,
    'construction': Icons.construction_rounded,
    'format_paint': Icons.format_paint_rounded,
    'chair':        Icons.chair_rounded,
    'ac_unit':      Icons.ac_unit_rounded,
    'fence':        Icons.fence_rounded,
    'yard':         Icons.yard_rounded,
  };

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: const Color(0xFFC82828).withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}