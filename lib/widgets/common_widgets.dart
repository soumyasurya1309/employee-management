import 'package:flutter/material.dart';


// ── Dark theme colors ────────────────────────────────────────────────────────
class DarkColors {
  static const bg = Color(0xFF0F0F1A);
  static const surface = Color(0xFF161625);
  static const border = Color(0xFF252538);
  static const accent = Color(0xFF6C63FF);
  static const accentEnd = Color(0xFF4FACFE);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF888899);
  static const textMuted = Color(0xFF444455);
}

// ── Loading overlay ──────────────────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: SizedBox(
                width: 48, height: 48,
                child: CircularProgressIndicator(
                  color: DarkColors.accent,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Custom text field ────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 0.8,
            color: DarkColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          style: const TextStyle(color: DarkColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: DarkColors.textMuted, fontSize: 13),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon != null
                ? IconTheme(
                    data: const IconThemeData(color: DarkColors.accent, size: 18),
                    child: prefixIcon!,
                  )
                : null,
            filled: true,
            fillColor: DarkColors.bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: DarkColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: DarkColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: DarkColors.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFF87171)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: DarkColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DarkColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: DarkColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      color: DarkColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DarkColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: DarkColors.accent),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600,
                color: DarkColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: DarkColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.add),
                label: Text(buttonLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DarkColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Avatar initials ──────────────────────────────────────────────────────────
class AvatarInitials extends StatelessWidget {
  final String name;
  final double radius;
  final double fontSize;

  const AvatarInitials({
    super.key,
    required this.name,
    this.radius = 24,
    this.fontSize = 14,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Color _bgColor(String name) {
    final colors = [
      const Color(0xFF1A1040),
      const Color(0xFF0A2010),
      const Color(0xFF201800),
      const Color(0xFF200A0A),
      const Color(0xFF0A1A20),
      const Color(0xFF1A0A20),
    ];
  
   
    int hash = name.codeUnits.fold(0, (prev, e) => prev + e);
    return colors[hash % colors.length];
  }

  Color _fgColor(String name) {
    final fgColors = [
      const Color(0xFF6C63FF),
      const Color(0xFF34D399),
      const Color(0xFFFBBF24),
      const Color(0xFFF87171),
      const Color(0xFF38BDF8),
      const Color(0xFFE879F9),
    ];
    int hash = name.codeUnits.fold(0, (prev, e) => prev + e);
    return fgColors[hash % fgColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: _bgColor(name),
        borderRadius: BorderRadius.circular(radius * 0.45),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: _fgColor(name),
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Department badge ─────────────────────────────────────────────────────────
class DepartmentBadge extends StatelessWidget {
  final String department;

  const DepartmentBadge({super.key, required this.department});

  Color _color(String dept) {
    final map = {
      'Engineering': const Color(0xFF6C63FF),
      'Design': const Color(0xFF34D399),
      'Marketing': const Color(0xFFFBBF24),
      'HR': const Color(0xFFF87171),
      'Finance': const Color(0xFF38BDF8),
      'Sales': const Color(0xFFE879F9),
    };
    return map[dept] ?? const Color(0xFF6C63FF);
  }

  Color _bg(String dept) {
    final map = {
      'Engineering': const Color(0xFF1A1040),
      'Design': const Color(0xFF0A2010),
      'Marketing': const Color(0xFF201800),
      'HR': const Color(0xFF200A0A),
      'Finance': const Color(0xFF0A1A20),
      'Sales': const Color(0xFF1A0A20),
    };
    return map[dept] ?? const Color(0xFF1A1040);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bg(department),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        department,
        style: TextStyle(
          fontSize: 10,
          color: _color(department),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Gradient button ──────────────────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [DarkColors.accent, DarkColors.accentEnd],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
String formatCurrency(double amount) {
  if (amount >= 1000) {
    return '\$${(amount / 1000).toStringAsFixed(1)}k';
  }
  return '\$${amount.toStringAsFixed(0)}';
}