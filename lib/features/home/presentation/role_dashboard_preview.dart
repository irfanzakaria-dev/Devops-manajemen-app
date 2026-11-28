import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/online_sync_service.dart';
import '../../../core/services/background_task_service.dart';
import '../../auth/models/user_session.dart';
import '../../auth/presentation/welcome_screen.dart';
import '../../work_notes/presentation/work_notes_screen.dart';
import '../../reminders/presentation/reminders_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class RoleDashboardPreview extends StatefulWidget {
  const RoleDashboardPreview({super.key});

  @override
  State<RoleDashboardPreview> createState() => _RoleDashboardPreviewState();
}

class _RoleDashboardPreviewState extends State<RoleDashboardPreview> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([UserSession.instance, OnlineSyncService.instance]),
      builder: (context, _) {
        final session = UserSession.instance;
        final currentRole = session.role;

        return Scaffold(
          backgroundColor: AppTheme.bg(context),
          appBar: _currentNavIndex == 0 ? _buildAppBar(context, session) : null,
          body: IndexedStack(
            index: _currentNavIndex,
            children: [
              // Tab 0: Beranda Role Dashboard
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Info Akun & Role yang Terkunci
                      _buildUserRoleBanner(context, session),
                      const SizedBox(height: 20),

                      // Tampilan Khusus Hanya Untuk Role Yang Sedang Login
                      if (currentRole == UserRole.lead)
                        _buildLeadDashboard(context, session)
                      else if (currentRole == UserRole.developer)
                        _buildDeveloperDashboard(context, session)
                      else
                        _buildQADashboard(context, session),
                    ],
                  ),
                ),
              ),
              // Tab 1: Catatan Kerja Tim (SQLite Database)
              const WorkNotesScreen(),
              // Tab 2: Pengingat & Alarm Berjadwal (Tahap 3 Selesai)
              const RemindersScreen(),
              // Tab 3: Pengaturan & Preferensi SharedPreferences (Tahap 4 Selesai)
              const SettingsScreen(),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(context),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, UserSession session) {
    final sync = OnlineSyncService.instance;

    return AppBar(
      backgroundColor: AppTheme.bg(context),
      title: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: sync.isOnline ? AppTheme.primaryMint : AppTheme.sev2Warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              session.workspace,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.text(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _showCloudSyncModal(context),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated(context),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    sync.isOnline ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                    size: 11,
                    color: sync.isOnline ? AppTheme.primaryMint : AppTheme.sev2Warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    sync.isOnline ? 'Online' : 'Offline',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: sync.isOnline ? AppTheme.primaryMint : AppTheme.sev2Warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Sinkronisasi Cloud',
          icon: Icon(Icons.cloud_sync_rounded, size: 20, color: AppTheme.textSubtle(context)),
          onPressed: () => _showCloudSyncModal(context),
        ),
        IconButton(
          tooltip: 'Keluar (Logout)',
          icon: Icon(Icons.logout_rounded, size: 20, color: AppTheme.textSubtle(context)),
          onPressed: () => _confirmSignOut(context, session),
        ),
      ],
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
          'Untuk berganti peran (Lead / Developer / QA), Anda harus keluar dan masuk kembali.',
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

  Widget _buildUserRoleBanner(BuildContext context, UserSession session) {
    final role = session.role;
    Color roleColor = role == UserRole.lead
        ? AppTheme.roleLead
        : role == UserRole.developer
            ? AppTheme.roleDeveloper
            : AppTheme.roleQA;

    String roleIndo = role == UserRole.lead 
        ? 'Ketua Tim (Lead)' 
        : role == UserRole.developer 
            ? 'Programmer (Developer)' 
            : 'Penguji (QA Engineer)';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: roleColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
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
                const SizedBox(height: 3),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        roleIndo,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: roleColor,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 12, color: AppTheme.textMutedColor(context)),
                        const SizedBox(width: 3),
                        Text(
                          'Akses Terkunci',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppTheme.textMutedColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // KARTU SINKRONISASI ONLINE & CLOUD API (TAHAP 5)
  // ==========================================
  Widget _buildOnlineSyncCard(BuildContext context) {
    final sync = OnlineSyncService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'SINKRONISASI ONLINE & CLOUD API', AppTheme.primaryMint),
        const SizedBox(height: 10),
        _buildCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: sync.isOnline ? AppTheme.primaryMint : AppTheme.sev2Warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sync.isOnline ? 'Cloud REST API: Terhubung' : 'Cloud REST API: Offline',
                    style: GoogleFonts.inter(
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
                      'Online Sync ✓',
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
                sync.lastSyncMessage,
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSubtle(context)),
              ),
              const SizedBox(height: 3),
              Text(
                'Terakhir sinkronisasi: ${sync.lastSyncTimeFormatted}',
                style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMutedColor(context)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: sync.isSyncing
                          ? null
                          : () async {
                              final success = await sync.syncLocalTasksToCloud();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: success ? AppTheme.primaryMint : AppTheme.sev2Warning,
                                  content: Text(
                                    success
                                        ? 'Sinkronisasi Cloud Berhasil! (${sync.syncedItemCount} data tersinkron).'
                                        : 'Mode Offline: Data aman tersimpan di SQLite lokal.',
                                    style: TextStyle(
                                      color: success ? const Color(0xFF0A0E17) : Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            },
                      icon: sync.isSyncing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A0E17)),
                            )
                          : const Icon(Icons.cloud_upload_rounded, size: 16),
                      label: Text(sync.isSyncing ? 'Sinkron...' : 'Sinkron ke Cloud'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryMint,
                        foregroundColor: const Color(0xFF0A0E17),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await BackgroundTaskService.instance.triggerImmediateSync();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Background task dieksekusi! Notifikasi latar belakang dikirim.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.sync_rounded, size: 16),
                      label: const Text('Background Task'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.border(context)),
                        foregroundColor: AppTheme.text(context),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 1. TAMPILAN KHUSUS LEAD (KETUA TIM)
  // ==========================================
  Widget _buildLeadDashboard(BuildContext context, UserSession session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'RINGKASAN PROGRES TIM', AppTheme.roleLead),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricBox(context, '5 Selesai', 'Tugas coding beres', AppTheme.primaryMint),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricBox(context, '1 Siap Rilis', 'Menunggu persetujuan', AppTheme.roleLead),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionTitle(context, 'PERSETUJUAN RILIS (DEPLOY)', AppTheme.primaryMint),
        const SizedBox(height: 10),
        _buildCard(
          context,
          borderColor: AppTheme.primaryMint.withValues(alpha: 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Aplikasi Mobile v1.2.0',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMint.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Lolos Uji QA ✓',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.primaryMint,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Diajukan oleh Sarah Chen (Developer) · 3 perbaikan bug siap diluncurkan.',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSubtle(context)),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Permintaan rilis ditolak.')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.border(context)),
                        foregroundColor: AppTheme.text(context),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        NotificationService.instance.showNotification(
                          id: 301,
                          title: '🎉 Rilis Disetujui oleh Lead',
                          body: 'Aplikasi Mobile v1.2.0 berhasil disetujui dan siap deploy ke server produksi!',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppTheme.primaryMint,
                            content: Text(
                              'Rilis berhasil disetujui oleh Lead! Notifikasi terkirim.',
                              style: TextStyle(color: Color(0xFF0A0E17), fontWeight: FontWeight.w700),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryMint,
                        foregroundColor: const Color(0xFF0A0E17),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Setujui Rilis ✓', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Integrasi Sinkronisasi Online & Cloud (Tahap 5)
        _buildOnlineSyncCard(context),
      ],
    );
  }

  // ==========================================
  // 2. TAMPILAN KHUSUS DEVELOPER (PROGRAMMER)
  // ==========================================
  Widget _buildDeveloperDashboard(BuildContext context, UserSession session) {
    final sync = OnlineSyncService.instance;
    final latestCommit = sync.recentCommits.isNotEmpty ? sync.recentCommits.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'STATUS KODING & PUSH TERAKHIR', AppTheme.roleDeveloper),
        const SizedBox(height: 10),
        _buildCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primaryMint, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'devops-api / main',
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
                      'GitHub Synced',
                      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.primaryMint, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                latestCommit != null
                    ? latestCommit.message
                    : 'Perbaikan bug koneksi database lokal & autentikasi',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.text(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                latestCommit != null
                    ? 'Commit #${latestCommit.sha} oleh ${latestCommit.author}'
                    : 'Dipush 20 menit lalu oleh ${session.displayName}',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMutedColor(context)),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    NotificationService.instance.showNotification(
                      id: 101,
                      title: '🚀 Fitur Baru Diajukan ke QA',
                      body: 'Sarah Chen mengajukan fitur database & autentikasi untuk diverifikasi QA.',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppTheme.roleDeveloper,
                        content: Text(
                          'Fitur berhasil diajukan ke QA! Notifikasi terkirim.',
                          style: TextStyle(color: Color(0xFF0A0E17), fontWeight: FontWeight.w700),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Ajukan ke QA untuk Diuji'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.roleDeveloper,
                    foregroundColor: const Color(0xFF0A0E17),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildSectionTitle(context, 'CATATAN KERJA (SQLITE)', AppTheme.primaryMint),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => setState(() => _currentNavIndex = 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Buka SQLite',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryMint),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppTheme.primaryMint),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppTheme.primaryMint, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Daftar Tugas Programmer',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text(context),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppTheme.primaryMint),
                    onPressed: () => setState(() => _currentNavIndex = 1),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildTaskItem(context, 'Membuat form login & validasi token', true),
              _buildTaskItem(context, 'Menyimpan catatan kerja ke database SQLite', true),
              _buildTaskItem(context, 'Sinkronisasi online cloud & background task', true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Integrasi Sinkronisasi Online & Cloud (Tahap 5)
        _buildOnlineSyncCard(context),
      ],
    );
  }

  // ==========================================
  // 3. TAMPILAN KHUSUS QA ENGINEER (PENGUJI)
  // ==========================================
  Widget _buildQADashboard(BuildContext context, UserSession session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'FITUR BARU YANG PERLU DIUJI', AppTheme.roleQA),
        const SizedBox(height: 10),
        _buildCard(
          context,
          borderColor: AppTheme.roleQA,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.roleQA.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'VERIFIKASI RILIS v1.2.0',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.roleQA,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Siap Diuji',
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primaryMint),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Pengujian Fitur: Autentikasi & Database SQLite',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pastikan data tersimpan di SQLite lokal dan bisa disinkronkan ke server online.',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSubtle(context)),
              ),
              const SizedBox(height: 14),
              _buildTaskItem(context, 'Uji fungsi login pengguna', true),
              _buildTaskItem(context, 'Uji simpan data catatan ke SQLite', true),
              _buildTaskItem(context, 'Uji sinkronisasi online & background task', true),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Catatan bug dikembalikan ke Developer!')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.sev1Critical),
                        foregroundColor: AppTheme.sev1Critical,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Ada Bug (Tolak)'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        NotificationService.instance.showNotification(
                          id: 201,
                          title: '✅ Fitur Lolos Uji QA',
                          body: 'Verifikasi rilis v1.2.0 telah lolos uji dan diteruskan ke Lead untuk persetujuan akhir.',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppTheme.roleQA,
                            content: Text(
                              'Pengujian selesai! Dikirim ke Lead untuk approval.',
                              style: TextStyle(color: Color(0xFF0A0E17), fontWeight: FontWeight.w700),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.roleQA,
                        foregroundColor: const Color(0xFF0A0E17),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Lolos Uji QA ✓', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Integrasi Sinkronisasi Online & Cloud (Tahap 5)
        _buildOnlineSyncCard(context),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, Color accent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 4, height: 14, color: accent),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppTheme.textSubtle(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBox(BuildContext context, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSubtle(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child, Color? borderColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppTheme.border(context), width: 1.2),
      ),
      child: child,
    );
  }

  Widget _buildTaskItem(BuildContext context, String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isDone ? AppTheme.primaryMint : AppTheme.textMutedColor(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? AppTheme.textMutedColor(context) : AppTheme.text(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        border: Border(top: BorderSide(color: AppTheme.border(context))),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryMint,
        unselectedItemColor: AppTheme.textSubtle(context),
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note_rounded), label: 'Catatan Kerja'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm_rounded), label: 'Pengingat'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Pengaturan'),
        ],
      ),
    );
  }

  void _showCloudSyncModal(BuildContext context) {
    final sync = OnlineSyncService.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMint.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_sync_rounded, color: AppTheme.primaryMint, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DevOps Cloud Synchronization',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text(ctx)),
                        ),
                        Text(
                          'REST API & Android WorkManager',
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSubtle(ctx)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20, color: AppTheme.textSubtle(ctx)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated(ctx),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border(ctx)),
                ),
                child: Column(
                  children: [
                    _buildModalRow(ctx, 'Status Jaringan', sync.isOnline ? 'Terhubung (Online)' : 'Terputus (Offline)'),
                    const SizedBox(height: 8),
                    _buildModalRow(ctx, 'Terakhir Sinkron', sync.lastSyncTimeFormatted),
                    const SizedBox(height: 8),
                    _buildModalRow(ctx, 'Total Catatan Cloud', '${sync.syncedItemCount} Data'),
                    const SizedBox(height: 8),
                    _buildModalRow(ctx, 'Background Task', 'WorkManager Aktif (15m)'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await sync.syncLocalTasksToCloud();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppTheme.primaryMint,
                        content: Text('Sinkronisasi cloud online berhasil dieksekusi!', style: TextStyle(color: Color(0xFF0A0E17), fontWeight: FontWeight.w700)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Sinkronkan Sekarang ke Cloud'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMint,
                    foregroundColor: const Color(0xFF0A0E17),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSubtle(context))),
        Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text(context))),
      ],
    );
  }
}
