import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/database/db_helper.dart';
import '../../auth/models/user_session.dart';
import '../../auth/presentation/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final session = UserSession.instance;
    final settings = SettingsService.instance;

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          appBar: AppBar(
            title: Text(
              'Pengaturan & Preferensi',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              children: [
                // 1. Profil Pengguna
                _buildSectionHeader('PROFIL & SESI KERJA'),
                _buildProfileCard(session),
                const SizedBox(height: 20),

                // 2. Tampilan Tema
                _buildSectionHeader('TAMPILAN & TEMA'),
                _buildThemeCard(settings),
                const SizedBox(height: 20),

                // 3. Notifikasi & Alarm
                _buildSectionHeader('PREFERENSI NOTIFIKASI & ALARM'),
                _buildNotificationPrefsCard(settings),
                const SizedBox(height: 20),

                // 4. Sinkronisasi & Background Task
                _buildSectionHeader('SINKRONISASI & BACKGROUND TASK'),
                _buildSyncPrefsCard(settings),
                const SizedBox(height: 20),

                // 5. Database SQLite Lokal
                _buildSectionHeader('DATABASE LOKAL SQLITE'),
                _buildDatabaseCard(context),
                const SizedBox(height: 20),

                // 6. Tentang Aplikasi
                _buildSectionHeader('TENTANG APLIKASI'),
                _buildAboutCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
      child: Row(
        children: [
          Container(width: 4, height: 13, color: AppTheme.primaryMint),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserSession session) {
    final role = session.role;
    Color roleColor = role == UserRole.lead
        ? AppTheme.roleLead
        : role == UserRole.developer
            ? AppTheme.roleDeveloper
            : AppTheme.roleQA;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: roleColor, width: 1.5),
                ),
                child: Icon(
                  role == UserRole.lead
                      ? Icons.shield_rounded
                      : role == UserRole.developer
                          ? Icons.code_rounded
                          : Icons.fact_check_rounded,
                  color: roleColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${session.username} · ${session.workspace}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        role.label.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: roleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppTheme.borderSubtle, height: 1),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmSignOut(session),
              icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: AppTheme.sev1Critical),
              label: Text(
                'Ganti Peran / Keluar Akun',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.sev1Critical,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.sev1Critical.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(SettingsService settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(
            settings.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: AppTheme.primaryMint,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Gelap (Dark Mode)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  settings.isDarkMode ? 'Tema gelap DevOps aktif' : 'Tema terang aktif',
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: settings.isDarkMode,
            activeThumbColor: AppTheme.primaryMint,
            activeTrackColor: AppTheme.primaryMint.withValues(alpha: 0.3),
            onChanged: (val) {
              settings.setDarkMode(val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.bgSurfaceElevated,
                  content: Text(val ? 'Mode Gelap diaktifkan' : 'Mode Terang diaktifkan'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPrefsCard(SettingsService settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.volume_up_rounded, color: AppTheme.primaryMint, size: 20),
            title: Text(
              'Bunyi Notifikasi Tim',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            subtitle: Text(
              'Putar suara saat ada tugas baru atau approval rilis',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
            ),
            value: settings.soundEnabled,
            activeThumbColor: AppTheme.primaryMint,
            activeTrackColor: AppTheme.primaryMint.withValues(alpha: 0.3),
            onChanged: (val) => settings.setSoundEnabled(val),
          ),
          const Divider(color: AppTheme.borderSubtle, height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.vibration_rounded, color: AppTheme.primaryMint, size: 20),
            title: Text(
              'Getaran Alarm & Scheduler',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            subtitle: Text(
              'Getarkan perangkat saat alarm jadwal kerja tiba',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
            ),
            value: settings.vibrationEnabled,
            activeThumbColor: AppTheme.primaryMint,
            activeTrackColor: AppTheme.primaryMint.withValues(alpha: 0.3),
            onChanged: (val) => settings.setVibrationEnabled(val),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncPrefsCard(SettingsService settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync_rounded, color: AppTheme.primaryMint, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sinkronisasi Otomatis',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Sinkronkan data berkala di latar belakang',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.autoSyncEnabled,
                activeThumbColor: AppTheme.primaryMint,
                activeTrackColor: AppTheme.primaryMint.withValues(alpha: 0.3),
                onChanged: (val) => settings.setAutoSyncEnabled(val),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.borderSubtle, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: AppTheme.primaryMint, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Interval Background Task:',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textPrimary),
                ),
              ),
              DropdownButton<int>(
                value: settings.syncIntervalMinutes,
                dropdownColor: AppTheme.bgSurfaceElevated,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15 Menit', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: 30, child: Text('30 Menit', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: 60, child: Text('1 Jam', style: TextStyle(fontSize: 12))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    settings.setSyncInterval(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Interval sinkronisasi diatur ke $val menit.')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storage_rounded, color: AppTheme.primaryMint, size: 20),
              const SizedBox(width: 10),
              Text(
                'devops_management.db',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryMint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SQLite Aktif ✓',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryMint,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Database lokal menyimpan seluruh catatan kerja, log komit, dan status verifikasi tugas secara offline-first.',
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _resetSampleData(context),
              icon: const Icon(Icons.restart_alt_rounded, size: 16),
              label: const Text('Reset Contoh Data Tugas SQLite'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.borderSubtle),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch_rounded, color: AppTheme.primaryMint, size: 20),
              const SizedBox(width: 10),
              Text(
                'DevOps Management Mobile App',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Aplikasi mobile pemantauan kerja, catatan tugas harian, dan estafet rilis tim IT berbasis 3 peran (Lead, Developer, QA).',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.borderSubtle, height: 1),
          const SizedBox(height: 10),
          _buildInfoRow('Versi Aplikasi', '1.0.0+1 (Release)'),
          const SizedBox(height: 6),
          _buildInfoRow('Pengembang', 'Irfan Zakaria (@irfanzakaria-dev)'),
          const SizedBox(height: 6),
          _buildInfoRow('Lisensi', 'MIT License'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
        Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ],
    );
  }

  void _resetSampleData(BuildContext context) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('work_notes');
    // Seed ulang
    final sampleNotes = [
      'Membuat Form Login & Validasi Token',
      'Integrasi Database SQLite Lokal (Offline-First)',
      'Uji Coba Pengujian Fitur Offline Mode',
      'Persetujuan Rilis Aplikasi Versi v1.2',
    ];

    for (int i = 0; i < sampleNotes.length; i++) {
      await db.insert('work_notes', {
        'title': sampleNotes[i],
        'description': 'Contoh data tugas otomatis hasil reset sistem.',
        'category': i == 0 ? 'Fitur Baru' : i == 1 ? 'DevOps & Server' : i == 2 ? 'Pengujian' : 'DevOps & Server',
        'assigned_role': i == 0 || i == 1 ? 'developer' : i == 2 ? 'qa' : 'lead',
        'author_name': 'Tim IT',
        'status': i == 0 ? 'done' : i == 1 ? 'in_progress' : i == 2 ? 'ready_for_qa' : 'todo',
        'priority': i == 1 ? 'Kritis' : 'Tinggi',
        'git_branch': 'feature/sample-task-$i',
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.primaryMint,
        content: Text(
          'Data contoh SQLite berhasil dimuat ulang!',
          style: TextStyle(color: Color(0xFF0A0E17), fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _confirmSignOut(UserSession session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar dari Akun?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        content: Text(
          'Anda akan diarahkan ke layar pemilihan peran untuk masuk sebagai Lead, Developer, atau QA.',
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.inter(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.sev1Critical,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await session.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }
}
