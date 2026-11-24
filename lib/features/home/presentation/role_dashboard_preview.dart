import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/models/user_session.dart';
import '../../auth/presentation/welcome_screen.dart';
import '../../work_notes/presentation/work_notes_screen.dart';
import '../../reminders/presentation/reminders_screen.dart';

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
      animation: UserSession.instance,
      builder: (context, _) {
        final session = UserSession.instance;
        final currentRole = session.role;

        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          appBar: _currentNavIndex == 0 ? _buildAppBar(session) : null,
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
                      _buildUserRoleBanner(session),
                      const SizedBox(height: 20),

                      // Tampilan Khusus Hanya Untuk Role Yang Sedang Login
                      if (currentRole == UserRole.lead)
                        _buildLeadDashboard(session)
                      else if (currentRole == UserRole.developer)
                        _buildDeveloperDashboard(session)
                      else
                        _buildQADashboard(session),
                    ],
                  ),
                ),
              ),
              // Tab 1: Catatan Kerja Tim (SQLite Database)
              const WorkNotesScreen(),
              // Tab 2: Pengingat & Alarm Berjadwal (Tahap 3 Selesai)
              const RemindersScreen(),
              // Tab 3: Pengaturan (Tahap 4)
              _buildPlaceholderScreen(
                'Pengaturan & Preferensi',
                'Fitur SharedPreferences & Pengaturan Tema (Tahap 4)',
                Icons.settings_rounded,
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildPlaceholderScreen(String title, String desc, IconData icon) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56, color: AppTheme.primaryMint),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(UserSession session) {
    return AppBar(
      backgroundColor: AppTheme.bgDark,
      title: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryMint,
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
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.bgSurfaceElevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Text(
              'Online',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppTheme.primaryMint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Keluar (Logout)',
          icon: const Icon(Icons.logout_rounded, size: 20, color: AppTheme.textSecondary),
          onPressed: () => _confirmSignOut(session),
        ),
      ],
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
          'Untuk berganti peran (Lead / Developer / QA), Anda harus keluar dan masuk kembali.',
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

  Widget _buildUserRoleBanner(UserSession session) {
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
        color: AppTheme.bgSurface,
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
                    color: AppTheme.textPrimary,
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
                        const Icon(Icons.lock_outline_rounded, size: 12, color: AppTheme.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          'Akses Terkunci',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppTheme.textMuted,
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
  // 1. TAMPILAN KHUSUS LEAD (KETUA TIM)
  // ==========================================
  Widget _buildLeadDashboard(UserSession session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('RINGKASAN PROGRES TIM', AppTheme.roleLead),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricBox('5 Selesai', 'Tugas coding beres', AppTheme.primaryMint),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricBox('1 Siap Rilis', 'Menunggu persetujuan', AppTheme.roleLead),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionTitle('PERSETUJUAN RILIS (DEPLOY)', AppTheme.primaryMint),
        const SizedBox(height: 10),
        _buildCard(
          borderColor: AppTheme.primaryMint.withValues(alpha: 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Aplikasi Mobile v1.2.0',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
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
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
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
                        side: const BorderSide(color: AppTheme.borderSubtle),
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
                            content: Text('Rilis berhasil disetujui oleh Lead! Notifikasi terkirim.'),
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
      ],
    );
  }

  // ==========================================
  // 2. TAMPILAN KHUSUS DEVELOPER (PROGRAMMER)
  // ==========================================
  Widget _buildDeveloperDashboard(UserSession session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('STATUS KODING & PUSH TERAKHIR', AppTheme.roleDeveloper),
        const SizedBox(height: 10),
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primaryMint, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'devops-api / main',
                    style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    'Kompilasi Berhasil',
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primaryMint, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Perbaikan bug koneksi database lokal & autentikasi',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Dipush 20 menit lalu oleh ${session.displayName}',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
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
                        content: Text('Fitur berhasil diajukan ke QA! Notifikasi terkirim.'),
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
              child: _buildSectionTitle('CATATAN KERJA (SQLITE)', AppTheme.primaryMint),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppTheme.primaryMint, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Daftar Tugas Programmer',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppTheme.primaryMint),
                    onPressed: () => setState(() => _currentNavIndex = 1),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildTaskItem('Membuat form login & validasi token', true),
              _buildTaskItem('Menyimpan catatan kerja ke database SQLite', false),
              _buildTaskItem('Memasang alarm pengingat jam kerja', false),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. TAMPILAN KHUSUS QA ENGINEER (PENGUJI)
  // ==========================================
  Widget _buildQADashboard(UserSession session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('FITUR BARU YANG PERLU DIUJI', AppTheme.roleQA),
        const SizedBox(height: 10),
        _buildCard(
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
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Pastikan data tersimpan di SQLite lokal dan bisa dibuka saat HP offline.',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              _buildTaskItem('Uji fungsi login pengguna', true),
              _buildTaskItem('Uji simpan data catatan ke SQLite', true),
              _buildTaskItem('Uji notifikasi pengingat jam kerja', false),
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
                            content: Text('Pengujian selesai! Dikirim ke Lead untuk approval.'),
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
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color accent) {
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
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
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
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, Color? borderColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppTheme.borderSubtle, width: 1.2),
      ),
      child: child,
    );
  }

  Widget _buildTaskItem(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isDone ? AppTheme.primaryMint : AppTheme.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? AppTheme.textMuted : AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgSurface,
        border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryMint,
        unselectedItemColor: AppTheme.textSecondary,
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
}
