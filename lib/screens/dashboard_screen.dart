import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/common_widgets.dart';
import 'departments_screen.dart';
import 'export_screen.dart';
import 'payroll_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DarkColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign out',
            style: TextStyle(
                color: DarkColors.textPrimary, fontSize: 16)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: DarkColors.textMuted, fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: DarkColors.textMuted))),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Sign out',
                  style:
                      TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<EmployeeProvider>().stopListening();
      await context.read<AuthProvider>().signOut();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, EmployeeProvider>(
      builder: (context, auth, emp, _) {
        final isWide = MediaQuery.of(context).size.width > 700;

        return Scaffold(
          backgroundColor: DarkColors.bg,
          appBar: AppBar(
            backgroundColor: DarkColors.bg,
            elevation: 0,
            title: const Text('Dashboard',
                style: TextStyle(
                    color: DarkColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w500)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: DarkColors.textMuted, size: 22),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: DarkColors.textMuted, size: 20),
                onPressed: _confirmLogout,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/employees/add'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            backgroundColor: DarkColors.accent,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: FadeTransition(
            opacity: _fadeAnim,
            child: RefreshIndicator(
              color: DarkColors.accent,
              backgroundColor: DarkColors.surface,
              onRefresh: () async =>
                  context.read<EmployeeProvider>().startListening(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCard(
                        username:
                            auth.user?.email?.split('@').first ?? 'Admin'),
                    const SizedBox(height: 20),
                    const Text('OVERVIEW',
                        style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            color: DarkColors.textDisabled)),
                    const SizedBox(height: 10),
                    isWide
                        ? Row(children: [
                            Expanded(
                                child: _KpiCard(
                              title: 'Employees',
                              value: emp.totalCount.toString(),
                              icon: Icons.people_alt_rounded,
                              color: const Color(0xFF7C3AED),
                              onTap: () => Navigator.pushNamed(
                                  context, '/employees'),
                            )),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _KpiCard(
                              title: 'Departments',
                              value: emp.departmentCounts.length.toString(),
                              icon: Icons.business_rounded,
                              color: const Color(0xFF10B981),
                              onTap: () => Navigator.push(
                                context,
                                _SmoothRoute(page: const DepartmentsScreen()),
                              ),
                            )),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _KpiCard(
                              title: 'Avg Salary',
                              value: emp.totalCount == 0
                                  ? '\$0'
                                  : '\$${(emp.averageSalary / 1000).toStringAsFixed(1)}k',
                              icon: Icons.attach_money_rounded,
                              color: const Color(0xFFF59E0B),
                            )),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _KpiCard(
                              title: 'Total Payroll',
                              value: emp.totalCount == 0
                                  ? '\$0'
                                  : '\$${(emp.totalSalary / 1000).toStringAsFixed(0)}k',
                              icon: Icons.account_balance_wallet_rounded,
                              color: const Color(0xFFEF4444),
                              onTap: () => Navigator.push(
                                context,
                                _SmoothRoute(page: const PayrollScreen()),
                              ),
                            )),
                          ])
                        : Column(children: [
                            Row(children: [
                              Expanded(
                                  child: _KpiCard(
                                title: 'Employees',
                                value: emp.totalCount.toString(),
                                icon: Icons.people_alt_rounded,
                                color: const Color(0xFF7C3AED),
                                onTap: () => Navigator.pushNamed(
                                    context, '/employees'),
                              )),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _KpiCard(
                                title: 'Departments',
                                value:
                                    emp.departmentCounts.length.toString(),
                                icon: Icons.business_rounded,
                                color: const Color(0xFF10B981),
                                onTap: () => Navigator.push(
                                  context,
                                  _SmoothRoute(page: const DepartmentsScreen()),
                                ),
                              )),
                            ]),
                            const SizedBox(height: 10),
                            Row(children: [
                              Expanded(
                                  child: _KpiCard(
                                title: 'Avg Salary',
                                value: emp.totalCount == 0
                                    ? '\$0'
                                    : '\$${(emp.averageSalary / 1000).toStringAsFixed(1)}k',
                                icon: Icons.attach_money_rounded,
                                color: const Color(0xFFF59E0B),
                              )),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _KpiCard(
                                title: 'Total Payroll',
                                value: emp.totalCount == 0
                                    ? '\$0'
                                    : '\$${(emp.totalSalary / 1000).toStringAsFixed(0)}k',
                                icon: Icons.account_balance_wallet_rounded,
                                color: const Color(0xFFEF4444),
                                onTap: () => Navigator.push(
                                  context,
                                  _SmoothRoute(page: const PayrollScreen()),
                                ),
                              )),
                            ]),
                          ]),
                    const SizedBox(height: 20),
                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: _DeptPerformanceCard(
                                    deptCounts: emp.departmentCounts,
                                    total: emp.totalCount),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                flex: 3,
                                child: _QuickActionsCard(),
                              ),
                            ],
                          )
                        : Column(children: [
                            _DeptPerformanceCard(
                                deptCounts: emp.departmentCounts,
                                total: emp.totalCount),
                            const SizedBox(height: 12),
                            const _QuickActionsCard(),
                          ]),
                    const SizedBox(height: 12),
                    const _RecentActivityCard(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final String username;
  const _HeroCard({required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back 👋',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE5E7EB))),
                const SizedBox(height: 4),
                Text(username,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 6),
                const Text(
                  'Manage your organization efficiently and monitor workforce insights.',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFFC7D2FE)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// ── KPI Card ──────────────────────────────────────────────────────────────────
class _KpiCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF18213F), Color(0xFF121B36)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              if (_hovered)
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.15),
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
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(height: 14),
              Text(widget.value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.0,
                  )),
              const SizedBox(height: 5),
              Text(widget.title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Department Performance ────────────────────────────────────────────────────
class _DeptPerformanceCard extends StatelessWidget {
  final Map<String, int> deptCounts;
  final int total;
  const _DeptPerformanceCard(
      {required this.deptCounts, required this.total});

  Color _color(String name) {
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
    return map[name] ?? const Color(0xFF8B5CF6);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DarkColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DarkColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Department Performance',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: DarkColors.textPrimary)),
                  SizedBox(height: 2),
                  Text('Workforce distribution by department',
                      style: TextStyle(
                          fontSize: 12, color: DarkColors.textDisabled)),
                ],
              ),
            ),
            const Text('This month',
                style: TextStyle(
                    fontSize: 11, color: DarkColors.textDisabled)),
          ]),
          const SizedBox(height: 20),
          if (deptCounts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No departments yet',
                    style: TextStyle(
                        color: DarkColors.textDisabled, fontSize: 13)),
              ),
            )
          else
            ...deptCounts.entries.map((e) => _DeptRow(
                  name: e.key,
                  count: e.value,
                  total: total,
                  color: _color(e.key),
                )),
        ],
      ),
    );
  }
}

class _DeptRow extends StatelessWidget {
  final String name;
  final int count;
  final int total;
  final Color color;
  const _DeptRow(
      {required this.name,
      required this.count,
      required this.total,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(children: [
        Row(children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 13, color: DarkColors.textSecondary))),
          Text('$count employees',
              style: const TextStyle(
                  fontSize: 11, color: DarkColors.textDisabled)),
          const SizedBox(width: 8),
          Text('${(pct * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ]),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────
class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DarkColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DarkColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: DarkColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Common tasks',
              style: TextStyle(
                  fontSize: 12, color: DarkColors.textDisabled)),
          const SizedBox(height: 16),
          _ActionBtn(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Add Employee',
            color: const Color(0xFF8B5CF6),
            bg: const Color(0xFF7C3AED),
            onTap: () => Navigator.pushNamed(context, '/employees/add'),
          ),
          const SizedBox(height: 8),
          _ActionBtn(
            icon: Icons.people_alt_outlined,
            label: 'View All Employees',
            color: const Color(0xFF3B82F6),
            bg: const Color(0xFF3B82F6),
            onTap: () => Navigator.pushNamed(context, '/employees'),
          ),
          const SizedBox(height: 8),
          _ActionBtn(
            icon: Icons.bar_chart_rounded,
            label: 'Department Stats',
            color: const Color(0xFF10B981),
            bg: const Color(0xFF10B981),
            onTap: () => Navigator.push(
              context,
              _SmoothRoute(page: const DepartmentsScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _ActionBtn(
            icon: Icons.download_outlined,
            label: 'Export Reports',
            color: const Color(0xFFF59E0B),
            bg: const Color(0xFFF59E0B),
            onTap: () => Navigator.push(
              context,
              _SmoothRoute(page: const ExportScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bg,
      required this.onTap});

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.bg.withValues(alpha: 0.2)
                : widget.bg.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? widget.bg.withValues(alpha: 0.4)
                  : widget.bg.withValues(alpha: 0.25),
            ),
          ),
          child: Row(children: [
            Icon(widget.icon, color: widget.color, size: 16),
            const SizedBox(width: 10),
            Text(widget.label,
                style: TextStyle(
                    color: widget.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                color: widget.color.withValues(alpha: 0.5), size: 11),
          ]),
        ),
      ),
    );
  }
}

// ── Recent Activity ───────────────────────────────────────────────────────────
class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  static const _activities = [
    {
      'icon': Icons.person_add_alt_1_rounded,
      'color': Color(0xFF8B5CF6),
      'title': 'New employee added',
      'time': '2 min ago',
    },
    {
      'icon': Icons.edit_outlined,
      'color': Color(0xFF3B82F6),
      'title': 'Employee profile updated',
      'time': '1 hour ago',
    },
    {
      'icon': Icons.business_rounded,
      'color': Color(0xFF10B981),
      'title': 'Department created',
      'time': '3 hours ago',
    },
    {
      'icon': Icons.delete_outline,
      'color': Color(0xFFEF4444),
      'title': 'Employee record removed',
      'time': 'Yesterday',
    },
    {
      'icon': Icons.notifications_rounded,
      'color': Color(0xFFF59E0B),
      'title': 'Push notification sent',
      'time': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DarkColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DarkColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Activity',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: DarkColors.textPrimary)),
                  SizedBox(height: 2),
                  Text('Latest actions in your system',
                      style: TextStyle(
                          fontSize: 12, color: DarkColors.textDisabled)),
                ],
              ),
            ),
            Text('Last 24 hours',
                style: TextStyle(
                    fontSize: 11, color: DarkColors.textDisabled)),
          ]),
          const SizedBox(height: 16),
          ..._activities.asMap().entries.map((entry) {
            final i = entry.key;
            final a = entry.value;
            return Column(children: [
              Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (a['color'] as Color).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(a['icon'] as IconData,
                      color: a['color'] as Color, size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(a['title'] as String,
                        style: const TextStyle(
                            fontSize: 13,
                            color: DarkColors.textSecondary))),
                Text(a['time'] as String,
                    style: const TextStyle(
                        fontSize: 11, color: DarkColors.textDisabled)),
              ]),
              if (i < _activities.length - 1)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 18, top: 8, bottom: 8),
                  child: Row(children: [
                    Container(
                        width: 1,
                        height: 14,
                        color: Colors.white.withValues(alpha: 0.06)),
                  ]),
                ),
            ]);
          }),
        ],
      ),
    );
  }
}

// ── Smooth Page Transition ────────────────────────────────────────────────────
class _SmoothRoute extends PageRouteBuilder {
  final Widget page;
  _SmoothRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}