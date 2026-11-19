import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/user_session.dart';
import 'role_selection_screen.dart';

class WorkspaceSelectionScreen extends StatefulWidget {
  const WorkspaceSelectionScreen({super.key});

  @override
  State<WorkspaceSelectionScreen> createState() => _WorkspaceSelectionScreenState();
}

class _WorkspaceSelectionScreenState extends State<WorkspaceSelectionScreen> {
  String _selectedWorkspace = 'acme-platform';
  final Set<String> _selectedRepos = {'devops-api', 'mobile-client', 'websocket-service'};

  final List<Map<String, dynamic>> _workspaces = [
    {
      'id': 'acme-platform',
      'name': 'acme-platform',
      'repos': 12,
      'status': 'App installed',
      'icon': Icons.business_center_rounded,
    },
    {
      'id': 'acme-labs',
      'name': 'acme-labs',
      'repos': 8,
      'status': 'Request access',
      'icon': Icons.biotech_rounded,
    },
    {
      'id': 'personal',
      'name': 'personal-workspace',
      'repos': 4,
      'status': 'App installed',
      'icon': Icons.person_rounded,
    },
  ];

  final List<Map<String, String>> _availableRepos = [
    {
      'name': 'devops-api',
      'branch': 'main',
      'lang': 'TypeScript',
      'ci': 'Actions enabled',
    },
    {
      'name': 'mobile-client',
      'branch': 'main',
      'lang': 'Flutter',
      'ci': 'Actions enabled',
    },
    {
      'name': 'websocket-service',
      'branch': 'main',
      'lang': 'Go',
      'ci': 'Actions enabled',
    },
    {
      'name': 'infrastructure',
      'branch': 'main',
      'lang': 'Terraform',
      'ci': 'Actions enabled',
    },
  ];

  void _continue() async {
    await UserSession.instance.setWorkspaceAndRepos(
      _selectedWorkspace,
      _selectedRepos.toList(),
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RoleSelectionScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          'Choose Workspace',
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
                    // Connected status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, size: 16, color: AppTheme.primaryMint),
                          const SizedBox(width: 10),
                          Text(
                            'CONNECTED AS @${UserSession.instance.username}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ORGANIZATION / WORKSPACE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._workspaces.map((ws) {
                      final isSelected = _selectedWorkspace == ws['id'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryMint : AppTheme.borderSubtle,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() => _selectedWorkspace = ws['id']);
                          },
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.bgSurfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(ws['icon'] as IconData, size: 20, color: isSelected ? AppTheme.primaryMint : AppTheme.textSecondary),
                          ),
                          title: Text(
                            ws['name'],
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '${ws['repos']} repositories · ${ws['status']}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryMint, size: 20)
                              : const Icon(Icons.radio_button_unchecked_rounded, color: AppTheme.textMuted, size: 20),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Text(
                      'MONITORED REPOSITORIES',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._availableRepos.map((repo) {
                      final isChecked = _selectedRepos.contains(repo['name']);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isChecked ? AppTheme.primaryMint.withValues(alpha: 0.5) : AppTheme.borderSubtle,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: isChecked,
                          activeColor: AppTheme.primaryMint,
                          checkColor: const Color(0xFF0A0E17),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedRepos.add(repo['name']!);
                              } else {
                                if (_selectedRepos.length > 1) {
                                  _selectedRepos.remove(repo['name']);
                                }
                              }
                            });
                          },
                          title: Text(
                            repo['name']!,
                            style: GoogleFonts.jetBrainsMono(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '${repo['branch']} · ${repo['lang']} · ${repo['ci']}',
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Bottom Action Bar
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
                  onPressed: _selectedRepos.isEmpty ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMint,
                    foregroundColor: const Color(0xFF0A0E17),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Monitor ${_selectedRepos.length} Repositories →',
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
}
