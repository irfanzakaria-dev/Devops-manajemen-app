import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/online_sync_service.dart';
import '../../../core/services/background_task_service.dart';
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
          backgroundColor: AppTheme.bg(context),
          appBar: AppBar(
            backgroundColor: AppTheme.bg(context),
            title: Text(
              'Pengaturan & Preferensi',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: AppTheme.text(context),
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              children: [
                // 1. Profil Pengguna
                _buildSectionHeader(context, 'PROFIL & SESI KERJA'),
                _buildProfileCard(context, session),
                const SizedBox(height: 20),

                // 2. Tampilan Tema
                _buildSectionHeader(context, 'TAMPILAN & TEMA'),
                _buildThemeCard(context, settings),
                const SizedBox(height: 20),

                // 3. Notifikasi & Alarm
                _buildSectionHeader(context, 'PREFERENSI NOTIFIKASI & ALARM'),
                _buildNotificationPrefsCard(context, settings),
                const SizedBox(height: 20),

                // 4. Sinkronisasi & Background Task
                _buildSectionHeader(context, 'SINKRONISASI & BACKGROUND TASK'),
                _buildSyncPrefsCard(context, settings),
                const SizedBox(height: 20),

                // 5. Database SQLite Lokal
                _buildSectionHeader(context, 'DATABASE LOKAL SQLITE'),
                _buildDatabaseCard(context),
                const SizedBox(height: 20),

                // 6. Tentang Aplikasi
                _buildSectionHeader(context, 'TENTANG APLIKASI'),
                _buildAboutCard(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
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
              color: AppTheme.textSubtle(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserSession session) {
    final role = session.role;
    Color roleColor = role == UserRole.lead
        ? AppTheme.roleLead
        : role == UserRole.developer
            ? AppTheme.roleDeveloper
            : AppTheme.roleQA;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border(context)),
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
                        color: AppTheme.text(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${session.username} · ${session.workspace}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: AppTheme.textSubtle(context),
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
          Divider(color: AppTheme.border(context), height: 1),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmSignOut(context, session),
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

  Widget _buildThemeCard(BuildContext context, SettingsService settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border(context)),
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
                    color: AppTheme.text(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  settings.isDarkMode ? 'Tema gelap DevOps aktif' : 'Tema terang aktif',
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSubtle(context)),
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
                  backgroundColor: AppTheme.surfaceElevated(context),
                  content: Text(
                    val ? 'Mode Gelap diaktifkan' : 'Mode Terang diaktifkan',
                    style: TextStyle(color: AppTheme.text(context)),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPrefsCard(BuildContext context, SettingsService settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.volume_up_rounded, color: AppTheme.primaryMint, size: 20),
            title: Text(
              'Bunyi Notifikasi Tim',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.text(context)),
            ),
            subtitle: Text(
              'Putar suara saat ada tugas baru atau approval rilis',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSubtle(context)),
            ),
            value: settings.soundEnabled,
            activeThumbColor: AppTheme.primaryMint,
            activeTrackColor: AppTheme.primaryMint.withValues(alpha: 0.3),
            onChanged: (val) => settings.setSoundEnabled(val),
          ),
          Divider(color: AppTheme.border(context), height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.vibration_rounded, color: AppTheme.primaryMint, size: 20),
            title: Text(
              'Getaran Alarm & Scheduler',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.text(context)),
            ),
            subtitle: Text(
              'Getarkan perangkat saat alarm jadwal kerja tiba',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSubtle(context)),
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

  Widget _buildSyncPrefsCard(BuildContext context, SettingsService settings) {
    final syncService = OnlineSyncService.instance;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border(context)),
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
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.text(context)),
                    ),
                    Text(
                      'Sinkronkan data berkala di latar belakang (WorkManager)',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSubtle(context)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.autoSyncEnabled,
                activeThumbColor: AppTheme.primaryMint,
                activeTrackColor: AppTheme.primaryMint.withValues(alpha: 0.3),
                onChanged: (val) async {
                  settings.setAutoSyncEnabled(val);
                  if (val) {
                    await BackgroundTaskService.instance.registerPeriodicSync(
                      intervalMinutes: settings.syncIntervalMinutes,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Background task berkala diaktifkan via WorkManager.')),
                    );
                  } else {
                    await BackgroundTaskService.instance.cancelPeriodicSync();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Background task dinonaktifkan.')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppTheme.border(context), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: AppTheme.primaryMint, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Interval Background Task:',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.text(context)),
                ),
              ),
              DropdownButton<int>(
                value: settings.syncIntervalMinutes,
                dropdownColor: AppTheme.surfaceElevated(context),
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(value: 15, child: Text('15 Menit', style: TextStyle(fontSize: 12, color: AppTheme.text(context)))),
                  DropdownMenuItem(value: 30, child: Text('30 Menit', style: TextStyle(fontSize: 12, color: AppTheme.text(context)))),
                  DropdownMenuItem(value: 60, child: Text('1 Jam', style: TextStyle(fontSize: 12, color: AppTheme.text(context)))),
                ],
                onChanged: (val) async {
                  if (val != null) {
                    settings.setSyncInterval(val);
                    if (settings.autoSyncEnabled) {
                      await BackgroundTaskService.instance.registerPeriodicSync(intervalMinutes: val);
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Interval background task diatur ke $val menit.')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppTheme.border(context), height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Terakhir Sinkron:', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMutedColor(context))),
              Text(
                syncService.lastSyncTimeFormatted,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.text(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mengeksekusi Background Task...')),
                );
                await BackgroundTaskService.instance.triggerImmediateSync();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.primaryMint,
                    content: Text(
                      'Background Task berhasil dijalankan! Notifikasi sistem dikirim.',
                      style: TextStyle(color: Color(0xFF0A0E17), fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: const Text('Uji Eksekusi Background Task Sekarang'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.border(context)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                foregroundColor: AppTheme.text(context),
                textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border(context)),
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
                  color: AppTheme.text(context),
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
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSubtle(context), height: 1.3),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _resetSampleData(context),
              icon: const Icon(Icons.restart_alt_rounded, size: 16),
              label: const Text('Reset Contoh Data Tugas SQLite'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.border(context)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                foregroundColor: AppTheme.text(context),
                textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border(context)),
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
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Aplikasi mobile pemantauan kerja, catatan tugas harian, dan estafet rilis tim IT berbasis 3 peran (Lead, Developer, QA).',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSubtle(context), height: 1.3),
          ),
          const SizedBox(height: 12),
          Divider(color: AppTheme.border(context), height: 1),
          const SizedBox(height: 10),
          _buildInfoRow(context, 'Versi Aplikasi', '1.0.0+1 (Release)'),
          const SizedBox(height: 6),
          _buildInfoRow(context, 'Pengembang', 'Irfan Zakaria (@irfanzakaria-dev)'),
          const SizedBox(height: 6),
          _buildInfoRow(context, 'Lisensi', 'MIT License'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMutedColor(context))),
        Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.text(context))),
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

  void _confirmSignOut(BuildContext context, UserSession session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar dari Akun?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.text(context)),
        ),
        content: Text(
          'Anda akan diarahkan ke layar pemilihan peran untuk masuk sebagai Lead, Developer, atau QA.',
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSubtle(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.inter(color: AppTheme.textMutedColor(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.sev1Critical,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await session.signOut();
              if (!context.mounted) return;
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
