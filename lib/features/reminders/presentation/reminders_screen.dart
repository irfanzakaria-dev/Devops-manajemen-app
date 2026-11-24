import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/notification_service.dart';
import '../models/reminder_item.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<ReminderItem> _reminders = [
    ReminderItem(
      id: 101,
      title: 'Daily Standup Meeting Tim IT',
      description: 'Sinkronisasi progres harian antar Developer, QA, dan Lead.',
      hour: 9,
      minute: 0,
      isEnabled: true,
      category: 'Standup',
      daysSummary: 'Senin - Jumat',
    ),
    ReminderItem(
      id: 102,
      title: 'Jadwal Pengujian & Verifikasi QA',
      description: 'Memeriksa build staging dan menandatangani sign-off rilis.',
      hour: 15,
      minute: 30,
      isEnabled: true,
      category: 'Pengujian QA',
      daysSummary: 'Senin - Jumat',
    ),
    ReminderItem(
      id: 103,
      title: 'Pengingat Isi Catatan Kerja Harian',
      description: 'Perbarui tugas koding hari ini ke dalam database SQLite.',
      hour: 17,
      minute: 0,
      isEnabled: true,
      category: 'Catatan Kerja',
      daysSummary: 'Senin - Jumat',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAlarms();
  }

  Future<void> _initAlarms() async {
    await NotificationService.instance.init();
    await NotificationService.instance.requestPermissions();
    _rescheduleAllActiveAlarms();
  }

  void _rescheduleAllActiveAlarms() {
    for (final r in _reminders) {
      if (r.isEnabled) {
        NotificationService.instance.scheduleDailyAlarm(
          id: r.id,
          title: '⏰ Pengingat Tim: ${r.title}',
          body: r.description,
          hour: r.hour,
          minute: r.minute,
        );
      }
    }
  }

  Future<void> _testImmediateNotification() async {
    await NotificationService.instance.showNotification(
      id: 999,
      title: '🔔 Uji Notifikasi Tim DevOps Berhasil!',
      body: 'Notifikasi pop-up dan suara lokal berjalan lancar di perangkat Anda.',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.primaryMint,
        content: Text(
          'Notifikasi lokal terkirim! Silakan periksa status bar HP Anda.',
          style: TextStyle(color: Color(0xFF0A0E17), fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _pickTime(ReminderItem reminder) async {
    final isDark = AppTheme.isDark(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppTheme.primaryMint,
                    onPrimary: Color(0xFF0A0E17),
                    surface: AppTheme.bgSurface,
                    onSurface: AppTheme.textPrimary,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppTheme.primaryMint,
                    onPrimary: Colors.white,
                    surface: AppTheme.bgLightSurface,
                    onSurface: AppTheme.textLightPrimary,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        reminder.hour = picked.hour;
        reminder.minute = picked.minute;
      });

      if (reminder.isEnabled) {
        await NotificationService.instance.scheduleDailyAlarm(
          id: reminder.id,
          title: '⏰ Pengingat Tim: ${reminder.title}',
          body: reminder.description,
          hour: reminder.hour,
          minute: reminder.minute,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surfaceElevated(context),
          content: Text(
            'Jadwal "${reminder.title}" diubah menjadi ${reminder.formattedTime}',
            style: TextStyle(color: AppTheme.text(context)),
          ),
        ),
      );
    }
  }

  void _toggleReminder(ReminderItem reminder, bool value) async {
    setState(() {
      reminder.isEnabled = value;
    });

    if (value) {
      await NotificationService.instance.scheduleDailyAlarm(
        id: reminder.id,
        title: '⏰ Pengingat Tim: ${reminder.title}',
        body: reminder.description,
        hour: reminder.hour,
        minute: reminder.minute,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alarm "${reminder.title}" diaktifkan.')),
      );
    } else {
      await NotificationService.instance.cancelAlarm(reminder.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alarm "${reminder.title}" dinonaktifkan.')),
      );
    }
  }

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    String category = 'Standup';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Tambah Pengingat / Alarm Baru',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.text(modalContext),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 20, color: AppTheme.textSubtle(modalContext)),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.inter(color: AppTheme.text(modalContext), fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Nama Pengingat / Agenda',
                        labelStyle: TextStyle(color: AppTheme.textSubtle(modalContext)),
                        hintText: 'Contoh: Evaluasi Sprint Mingguan',
                        hintStyle: TextStyle(color: AppTheme.textMutedColor(modalContext)),
                        filled: true,
                        fillColor: AppTheme.surfaceElevated(modalContext),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.border(modalContext)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.border(modalContext)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: GoogleFonts.inter(color: AppTheme.text(modalContext), fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Keterangan Agenda',
                        labelStyle: TextStyle(color: AppTheme.textSubtle(modalContext)),
                        hintText: 'Tuliskan deskripsi pengingat...',
                        hintStyle: TextStyle(color: AppTheme.textMutedColor(modalContext)),
                        filled: true,
                        fillColor: AppTheme.surfaceElevated(modalContext),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.border(modalContext)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.border(modalContext)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('PILIH JAM ALARM', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textMutedColor(modalContext))),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: modalContext,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setModalState(() => selectedTime = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated(modalContext),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.border(modalContext)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: AppTheme.primaryMint, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} WIB',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.text(modalContext),
                              ),
                            ),
                            const Spacer(),
                            const Text('Ubah Jam', style: TextStyle(color: AppTheme.primaryMint, fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryMint,
                          foregroundColor: const Color(0xFF0A0E17),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) return;

                          final newId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                          final newItem = ReminderItem(
                            id: newId,
                            title: titleController.text.trim(),
                            description: descController.text.trim().isEmpty
                                ? 'Pengingat jadwal kerja tim DevOps'
                                : descController.text.trim(),
                            hour: selectedTime.hour,
                            minute: selectedTime.minute,
                            category: category,
                            isEnabled: true,
                          );

                          setState(() {
                            _reminders.add(newItem);
                          });

                          NotificationService.instance.scheduleDailyAlarm(
                            id: newItem.id,
                            title: '⏰ Pengingat Tim: ${newItem.title}',
                            body: newItem.description,
                            hour: newItem.hour,
                            minute: newItem.minute,
                          );

                          Navigator.pop(modalContext);
                        },
                        child: Text(
                          'Pasang Alarm & Jadwalkan',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _reminders.where((r) => r.isEnabled).length;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        title: Text(
          'Pengingat & Alarm Tim',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppTheme.text(context),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // Banner Status Scheduler & Tombol Uji Notifikasi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryMint.withValues(alpha: 0.3)),
              ),
              child: Column(
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
                        child: const Icon(Icons.alarm_on_rounded, color: AppTheme.primaryMint, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scheduler & Alarm Aktif',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.text(context),
                              ),
                            ),
                            Text(
                              '$activeCount jadwal alarm harian berulang diatur',
                              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSubtle(context)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: AppTheme.border(context), height: 1),
                  const SizedBox(height: 10),
                  // Tombol Coba Notifikasi Langsung (Untuk Pembuktian Tugas)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _testImmediateNotification,
                      icon: const Icon(Icons.notifications_active_rounded, size: 16, color: AppTheme.primaryMint),
                      label: Text(
                        'Uji Notifikasi Pop-Up Sekarang',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryMint,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryMint.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Judul List Alarm
            Row(
              children: [
                Container(width: 4, height: 14, color: AppTheme.primaryMint),
                const SizedBox(width: 8),
                Text(
                  'DAFTAR ALARM & JADWAL HARIAN',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.textSubtle(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Item List Pengingat
            ..._reminders.map((reminder) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: reminder.isEnabled
                        ? AppTheme.primaryMint.withValues(alpha: 0.4)
                        : AppTheme.border(context),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Jam Alarm (Bisa diklik untuk mengubah jam)
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _pickTime(reminder),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: reminder.isEnabled
                                  ? AppTheme.primaryMint.withValues(alpha: 0.15)
                                  : AppTheme.surfaceElevated(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: reminder.isEnabled
                                    ? AppTheme.primaryMint
                                    : AppTheme.border(context),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_filled_rounded,
                                  size: 14,
                                  color: reminder.isEnabled ? AppTheme.primaryMint : AppTheme.textMutedColor(context),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  reminder.formattedTime,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: reminder.isEnabled ? AppTheme.primaryMint : AppTheme.textMutedColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Switch On / Off
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: reminder.isEnabled,
                            activeThumbColor: AppTheme.primaryMint,
                            activeTrackColor: AppTheme.primaryMint.withValues(alpha: 0.3),
                            inactiveThumbColor: AppTheme.textMutedColor(context),
                            inactiveTrackColor: AppTheme.surfaceElevated(context),
                            onChanged: (val) => _toggleReminder(reminder, val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      reminder.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: reminder.isEnabled ? AppTheme.text(context) : AppTheme.textMutedColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reminder.description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSubtle(context),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated(context),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            reminder.category,
                            style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSubtle(context)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '📅 ${reminder.daysSummary}',
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMutedColor(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 60),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReminderDialog,
        backgroundColor: AppTheme.primaryMint,
        foregroundColor: const Color(0xFF0A0E17),
        icon: const Icon(Icons.alarm_add_rounded, size: 20),
        label: Text(
          'Tambah Alarm',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }
}
