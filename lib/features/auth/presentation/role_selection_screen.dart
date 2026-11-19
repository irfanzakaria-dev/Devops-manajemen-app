import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/user_session.dart';
import '../../home/presentation/role_dashboard_preview.dart';

class RoleSelectionScreen extends StatefulWidget {
  final bool isDirectDemo;
  const RoleSelectionScreen({super.key, this.isDirectDemo = false});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.developer;

  @override
  void initState() {
    super.initState();
    _selectedRole = UserSession.instance.role;
  }

  void _confirmRole() async {
    if (widget.isDirectDemo) {
      await UserSession.instance.signIn(
        username: _selectedRole == UserRole.lead
            ? 'alexmorgan'
            : _selectedRole == UserRole.developer
                ? 'sarahchen'
                : 'rakapratama',
        displayName: _selectedRole == UserRole.lead
            ? 'Alex Morgan (Lead)'
            : _selectedRole == UserRole.developer
                ? 'Sarah Chen (Developer)'
                : 'Raka Pratama (QA)',
        role: _selectedRole,
      );
    } else {
      await UserSession.instance.setRole(_selectedRole);
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const RoleDashboardPreview(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          widget.isDirectDemo ? 'Demo Role Selection' : 'Select Team Role',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WORKSPACE ACCESS',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.primaryMint,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose Your DevOps Role',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Each role provides customized views for monitoring, task notes, and release gates.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Lead Role Card
                    _buildRoleCard(
                      role: UserRole.lead,
                      title: 'Lead / Engineering Manager',
                      badge: 'LEAD',
                      badgeColor: AppTheme.roleLead,
                      icon: Icons.shield_rounded,
                      permissions: [
                        'Review & approve production deployment requests',
                        'SEV-1 Critical incident escalation & rollback',
                        'Team workload & On-Call schedule overview',
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Developer Role Card
                    _buildRoleCard(
                      role: UserRole.developer,
                      title: 'Software Developer',
                      badge: 'DEVELOPER',
                      badgeColor: AppTheme.roleDeveloper,
                      icon: Icons.code_rounded,
                      permissions: [
                        'Monitor personal push history & PR status',
                        'Submit production deployment requests',
                        'Local work logs & incident action notes (SQLite)',
                      ],
                    ),
                    const SizedBox(height: 14),
                    // QA Engineer Role Card
                    _buildRoleCard(
                      role: UserRole.qa,
                      title: 'QA / Test Engineer',
                      badge: 'QA ENGINEER',
                      badgeColor: AppTheme.roleQA,
                      icon: Icons.fact_check_rounded,
                      permissions: [
                        'Verify staging test runs & flaky test tracking',
                        'Approve or block release sign-off (Gate)',
                        'Link bug reports and QA test checklists',
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Action
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.bgSurface,
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _confirmRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMint,
                    foregroundColor: const Color(0xFF0A0E17),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Enter Workspace as ${_selectedRole.title} →',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required List<String> permissions,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedRole = role);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.bgSurfaceElevated : AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? badgeColor : AppTheme.borderSubtle,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: badgeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? badgeColor : AppTheme.textMuted,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppTheme.borderSubtle, height: 1),
            const SizedBox(height: 12),
            ...permissions.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_right_rounded, size: 18, color: badgeColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        p,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
