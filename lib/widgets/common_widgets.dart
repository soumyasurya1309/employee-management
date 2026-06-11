import 'package:flutter/material.dart';

// ── Static dark palette (kept for backward compat) ─────────────
class DarkColors {
  static const bg = Color(0xFF0B1020);
  static const surface = Color(0xFF161D35);
  static const elevated = Color(0xFF1C2545);
  static const border = Color(0x14FFFFFF);
  static const accent = Color(0xFF7C3AED);
  static const accentLight = Color(0xFF8B5CF6);
  static const accentEnd = Color(0xFF3B82F6);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFD1D5DB);
  static const textMuted = Color(0xFF9CA3AF);
  static const textDisabled = Color(0xFF6B7280);
  static const inputBg = Color(0xFF1C2545);
}

// ── Dynamic colors — use these in new/updated widgets ──────────
class AppColors {
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0B1020)
          : const Color(0xFFF4F6FB);

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF161D35)
          : Colors.white;

  static Color elevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C2545)
          : const Color(0xFFEEF2FF);

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0x14FFFFFF)
          : const Color(0xFFE5E7EB);

  static Color inputBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C2545)
          : Colors.white;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF1A1A2E);

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFD1D5DB)
          : const Color(0xFF4B5563);

  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF9CA3AF)
          : const Color(0xFF6B7280);

  static Color textDisabled(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF6B7280)
          : const Color(0xFF9CA3AF);

  static const accent = Color(0xFF7C3AED);
  static const accentLight = Color(0xFF8B5CF6);
  static const accentEnd = Color(0xFF3B82F6);

  static Color cardGradientStart(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF18213F)
          : const Color(0xFFFFFFFF);

  static Color cardGradientEnd(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121B36)
          : const Color(0xFFF8F9FF);
}

// ── Theme toggle using provider ────────────────────────────────
class ThemeToggleIconButton extends StatelessWidget {
  final VoidCallback onToggle;
  const ThemeToggleIconButton({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Switch to Light' : 'Switch to Dark',
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => RotationTransition(
          turns: Tween(begin: 0.75, end: 1.0).animate(anim),
          child: child,
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
          color: AppColors.textMuted(context),
          size: 20,
        ),
      ),
      onPressed: onToggle,
    );
  }
}

// ── LoadingOverlay ──────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const LoadingOverlay(
      {super.key, required this.isLoading, required this.child});

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
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── AppTextField ────────────────────────────────────────────────
class AppTextField extends StatefulWidget {
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
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 0.7,
            color: AppColors.textMuted(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.25),
                        blurRadius: 8,
                      )
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              maxLines: widget.maxLines,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              style: TextStyle(
                  color: AppColors.textPrimary(context), fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                    color: AppColors.textDisabled(context), fontSize: 13),
                suffixIcon: widget.suffixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                            color: AppColors.textDisabled(context), size: 18),
                        child: widget.suffixIcon!,
                      )
                    : null,
                prefixIcon: widget.prefixIcon != null
                    ? IconTheme(
                        data: const IconThemeData(
                            color: AppColors.accentLight, size: 18),
                        child: widget.prefixIcon!,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.inputBg(context),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppColors.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppColors.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: AppColors.accent, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFFEF4444)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color(0xFFEF4444), width: 1.5),
                ),
                errorStyle: const TextStyle(
                    color: Color(0xFFEF4444), fontSize: 11),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── StatCard ────────────────────────────────────────────────────
class StatCard extends StatefulWidget {
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
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.diagonal3Values(
            _hovered ? 1.02 : 1.0,
            _hovered ? 1.02 : 1.0,
            1.0,
          ),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.cardGradientStart(context),
                AppColors.cardGradientEnd(context),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? AppColors.accent.withValues(alpha: 0.3)
                  : AppColors.border(context),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              if (_hovered)
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(height: 14),
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── EmptyState ──────────────────────────────────────────────────
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
                color: AppColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(icon, size: 48, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context)),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center),
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onButtonPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentEnd],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(buttonLabel!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── AvatarInitials ──────────────────────────────────────────────
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
      const Color(0xFF1E1040),
      const Color(0xFF0A2818),
      const Color(0xFF201800),
      const Color(0xFF200A0A),
      const Color(0xFF0A1A28),
      const Color(0xFF1A0A28),
    ];
    int hash = name.codeUnits.fold(0, (prev, e) => prev + e);
    return colors[hash % colors.length];
  }

  Color _fgColor(String name) {
    final colors = [
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
      const Color(0xFFEC4899),
    ];
    int hash = name.codeUnits.fold(0, (prev, e) => prev + e);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: _bgColor(name),
        borderRadius: BorderRadius.circular(radius * 0.45),
        border: Border.all(
            color: _fgColor(name).withValues(alpha: 0.3), width: 1),
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

// ── DepartmentBadge ─────────────────────────────────────────────
class DepartmentBadge extends StatelessWidget {
  final String department;
  const DepartmentBadge({super.key, required this.department});

  Color _color(String dept) {
    final map = {
      'Engineering': const Color(0xFF8B5CF6),
      'Product': const Color(0xFF8B5CF6),
      'Design': const Color(0xFF10B981),
      'Marketing': const Color(0xFFF59E0B),
      'HR': const Color(0xFFEF4444),
      'Finance': const Color(0xFF3B82F6),
      'Sales': const Color(0xFFEC4899),
      'Operations': const Color(0xFF06B6D4),
      'Legal': const Color(0xFF8B5CF6),
      'Customer Support': const Color(0xFF10B981),
    };
    return map[dept] ?? const Color(0xFF8B5CF6);
  }

  Color _bg(String dept, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) {
      // Light mode: soft tinted backgrounds
      final map = {
        'Engineering': const Color(0xFFEDE9FE),
        'Product': const Color(0xFFEDE9FE),
        'Design': const Color(0xFFD1FAE5),
        'Marketing': const Color(0xFFFEF3C7),
        'HR': const Color(0xFFFEE2E2),
        'Finance': const Color(0xFFDBEAFE),
        'Sales': const Color(0xFFFCE7F3),
        'Operations': const Color(0xFFCFFAFE),
        'Legal': const Color(0xFFEDE9FE),
        'Customer Support': const Color(0xFFD1FAE5),
      };
      return map[dept] ?? const Color(0xFFEDE9FE);
    }
    final map = {
      'Engineering': const Color(0xFF1E1040),
      'Product': const Color(0xFF1E1040),
      'Design': const Color(0xFF0A2818),
      'Marketing': const Color(0xFF201800),
      'HR': const Color(0xFF200A0A),
      'Finance': const Color(0xFF0A1A28),
      'Sales': const Color(0xFF200A18),
      'Operations': const Color(0xFF0A1A20),
      'Legal': const Color(0xFF1E1040),
      'Customer Support': const Color(0xFF0A2818),
    };
    return map[dept] ?? const Color(0xFF1E1040);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bg(department, context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: _color(department).withValues(alpha: 0.25)),
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

// ── GradientButton ──────────────────────────────────────────────
class GradientButton extends StatefulWidget {
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
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? [
                      const Color(0xFF8B5CF6),
                      const Color(0xFF60A5FA)
                    ]
                  : [AppColors.accent, AppColors.accentEnd],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatCurrency(double amount) {
  if (amount >= 1000) {
    return '\$${(amount / 1000).toStringAsFixed(1)}k';
  }
  return '\$${amount.toStringAsFixed(0)}';
}