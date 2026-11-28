import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/db_helper.dart';
import '../../../core/services/online_sync_service.dart';
import '../../auth/models/user_session.dart';
import '../models/work_note.dart';

class WorkNotesScreen extends StatefulWidget {
  const WorkNotesScreen({super.key});

  @override
  State<WorkNotesScreen> createState() => _WorkNotesScreenState();
}

class _WorkNotesScreenState extends State<WorkNotesScreen> {
  List<WorkNote> _notes = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua'; // 'Semua', 'Tugas Saya', 'Siap Diuji', 'Selesai'

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllNotes();
    if (!mounted) return;
    setState(() {
      _notes = data;
      _isLoading = false;
    });
  }

  List<WorkNote> get _filteredNotes {
    final currentRole = UserSession.instance.role.name;
    switch (_selectedFilter) {
      case 'Tugas Saya':
        return _notes.where((n) => n.assignedRole.toLowerCase() == currentRole).toList();
      case 'Siap Diuji':
        return _notes.where((n) => n.status == 'ready_for_qa').toList();
      case 'Selesai':
        return _notes.where((n) => n.status == 'done').toList();
      default:
        return _notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = UserSession.instance;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        title: Text(
          'Catatan Kerja Tim',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppTheme.text(context),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Sinkronkan ke Cloud (REST API)',
            icon: Icon(Icons.cloud_sync_rounded, size: 20, color: AppTheme.text(context)),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menyinkronkan catatan kerja ke server cloud...')),
              );
              final success = await OnlineSyncService.instance.syncLocalTasksToCloud();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: success ? AppTheme.primaryMint : AppTheme.sev2Warning,
                  content: Text(
                    success
                        ? 'Catatan kerja berhasil disinkronkan ke server online!'
                        : 'Offline: Data aman di database SQLite lokal.',
                    style: TextStyle(
                      color: success ? const Color(0xFF0A0E17) : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Segarkan Data SQLite',
            icon: Icon(Icons.refresh_rounded, size: 20, color: AppTheme.text(context)),
            onPressed: _loadNotes,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryMint),
              )
            : Column(
                children: [
                  // Ringkasan Statistik Singkat
                  _buildStatsRow(context),
                  // Filter Chips
                  _buildFilterChips(context),
                  const SizedBox(height: 10),
                  // List Catatan Kerja
                  Expanded(
                    child: _filteredNotes.isEmpty
                        ? _buildEmptyState(context)
                        : RefreshIndicator(
                            color: AppTheme.primaryMint,
                            backgroundColor: AppTheme.surface(context),
                            onRefresh: _loadNotes,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              itemCount: _filteredNotes.length,
                              itemBuilder: (context, index) {
                                final note = _filteredNotes[index];
                                return _buildNoteCard(context, note, session);
                              },
                            ),
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditNoteDialog(context),
        backgroundColor: AppTheme.primaryMint,
        foregroundColor: const Color(0xFF0A0E17),
        icon: const Icon(Icons.add_task_rounded, size: 20),
        label: Text(
          'Catatan Baru',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final total = _notes.length;
    final doneCount = _notes.where((n) => n.status == 'done').length;
    final readyForQaCount = _notes.where((n) => n.status == 'ready_for_qa').length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _buildStatItem(context, 'Total Catatan', '$total', AppTheme.text(context))),
          Container(width: 1, height: 28, color: AppTheme.border(context)),
          Expanded(child: _buildStatItem(context, 'Siap Diuji QA', '$readyForQaCount', AppTheme.roleQA)),
          Container(width: 1, height: 28, color: AppTheme.border(context)),
          Expanded(child: _buildStatItem(context, 'Selesai', '$doneCount', AppTheme.primaryMint)),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSubtle(context)),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = ['Semua', 'Tugas Saya', 'Siap Diuji', 'Selesai'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              selected: isSelected,
              label: Text(f),
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF0A0E17) : AppTheme.textSubtle(context),
              ),
              backgroundColor: AppTheme.surface(context),
              selectedColor: AppTheme.primaryMint,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryMint : AppTheme.border(context),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (val) {
                if (val) setState(() => _selectedFilter = f);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, WorkNote note, UserSession session) {
    Color priorityColor = AppTheme.textSubtle(context);
    if (note.priority == 'Kritis') priorityColor = AppTheme.sev1Critical;
    if (note.priority == 'Tinggi') priorityColor = AppTheme.sev2Warning;
    if (note.priority == 'Sedang') priorityColor = AppTheme.roleDeveloper;

    String statusText = 'Belum Dikerjakan';
    Color statusColor = AppTheme.textMutedColor(context);
    if (note.status == 'in_progress') {
      statusText = 'Sedang Dikerjakan';
      statusColor = AppTheme.roleDeveloper;
    } else if (note.status == 'ready_for_qa') {
      statusText = 'Siap Diuji QA';
      statusColor = AppTheme.roleQA;
    } else if (note.status == 'done') {
      statusText = 'Selesai ✓';
      statusColor = AppTheme.primaryMint;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: note.status == 'ready_for_qa'
              ? AppTheme.roleQA.withValues(alpha: 0.5)
              : AppTheme.border(context),
          width: note.status == 'ready_for_qa' ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Atas: Kategori & Prioritas & Menu
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated(context),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.border(context)),
                  ),
                  child: Text(
                    note.category,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSubtle(context)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    note.priority,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: priorityColor,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 18, color: AppTheme.textSubtle(context)),
                color: AppTheme.surfaceElevated(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showAddOrEditNoteDialog(context, note: note);
                  } else if (val == 'delete') {
                    _confirmDelete(context, note);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit Catatan', style: TextStyle(color: AppTheme.text(context))),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Hapus Catatan', style: TextStyle(color: AppTheme.sev1Critical)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Judul
          Text(
            note.title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              decoration: note.status == 'done' ? TextDecoration.lineThrough : null,
              color: note.status == 'done' ? AppTheme.textMutedColor(context) : AppTheme.text(context),
            ),
          ),
          if (note.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              note.description,
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSubtle(context), height: 1.3),
            ),
          ],
          const SizedBox(height: 12),
          // Git Branch & Penulis
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.alt_route_rounded, size: 12, color: AppTheme.primaryMint),
                    const SizedBox(width: 4),
                    Text(
                      note.gitBranch,
                      style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.text(context)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note.authorName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMutedColor(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppTheme.border(context), height: 1),
          const SizedBox(height: 10),
          // Baris Bawah: Status Badge & Tombol Aksi Estafet Tim
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildRoleActionButton(note, session),
            ],
          ),
        ],
      ),
    );
  }

  // Tombol Aksi Handover sesuai Role
  Widget _buildRoleActionButton(WorkNote note, UserSession session) {
    final role = session.role;

    if (role == UserRole.developer) {
      if (note.status != 'ready_for_qa' && note.status != 'done') {
        return ElevatedButton.icon(
          onPressed: () => _updateStatus(note.id!, 'ready_for_qa', 'Catatan diajukan ke QA untuk diuji!'),
          icon: const Icon(Icons.send_rounded, size: 14),
          label: const Text('Ajukan ke QA'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.roleDeveloper,
            foregroundColor: const Color(0xFF0A0E17),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        );
      }
    } else if (role == UserRole.qa) {
      if (note.status == 'ready_for_qa') {
        return ElevatedButton.icon(
          onPressed: () => _updateStatus(note.id!, 'done', 'Tugas dinyatakan Lolos Uji QA ✓'),
          icon: const Icon(Icons.check_circle_rounded, size: 14),
          label: const Text('Lolos Uji QA ✓'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.roleQA,
            foregroundColor: const Color(0xFF0A0E17),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        );
      }
    } else if (role == UserRole.lead) {
      if (note.status != 'done') {
        return ElevatedButton(
          onPressed: () => _updateStatus(note.id!, 'done', 'Catatan ditandai selesai oleh Lead.'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryMint,
            foregroundColor: const Color(0xFF0A0E17),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          child: const Text('Tandai Selesai'),
        );
      }
    }

    return const SizedBox.shrink();
  }

  Future<void> _updateStatus(int noteId, String newStatus, String message) async {
    await DatabaseHelper.instance.updateNoteStatus(noteId, newStatus);
    await _loadNotes();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppTheme.surfaceElevated(context), content: Text(message, style: TextStyle(color: AppTheme.text(context)))),
    );
  }

  void _confirmDelete(BuildContext context, WorkNote note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface(context),
        title: Text('Hapus Catatan?', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.text(context))),
        content: Text('Catatan "${note.title}" akan dihapus permanen dari database SQLite.', style: GoogleFonts.inter(color: AppTheme.textSubtle(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: AppTheme.textMutedColor(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.sev1Critical),
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseHelper.instance.deleteNote(note.id!);
              await _loadNotes();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddOrEditNoteDialog(BuildContext context, {WorkNote? note}) {
    final isEditing = note != null;
    final titleController = TextEditingController(text: note?.title ?? '');
    final descController = TextEditingController(text: note?.description ?? '');
    final branchController = TextEditingController(text: note?.gitBranch ?? 'feature/new-task');
    String category = note?.category ?? 'Fitur Baru';
    String priority = note?.priority ?? 'Sedang';
    String assignedRole = note?.assignedRole ?? UserSession.instance.role.name;

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
                          isEditing ? 'Edit Catatan Kerja' : 'Tambah Catatan Kerja Baru',
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
                    // Judul Tugas
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.inter(color: AppTheme.text(modalContext), fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Judul Tugas / Catatan',
                        labelStyle: TextStyle(color: AppTheme.textSubtle(modalContext)),
                        hintText: 'Contoh: Perbaiki validasi token login',
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
                    // Deskripsi
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      style: GoogleFonts.inter(color: AppTheme.text(modalContext), fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Keterangan / Catatan Teknis',
                        labelStyle: TextStyle(color: AppTheme.textSubtle(modalContext)),
                        hintText: 'Tuliskan detail pekerjaan atau kendala...',
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
                    // Git Branch
                    TextField(
                      controller: branchController,
                      style: GoogleFonts.jetBrainsMono(color: AppTheme.text(modalContext), fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Nama Git Branch',
                        labelStyle: TextStyle(color: AppTheme.textSubtle(modalContext)),
                        prefixIcon: const Icon(Icons.alt_route_rounded, size: 16, color: AppTheme.primaryMint),
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
                    // Pilihan Kategori
                    Text('KATEGORI', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textMutedColor(modalContext))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      dropdownColor: AppTheme.surfaceElevated(modalContext),
                      style: TextStyle(color: AppTheme.text(modalContext)),
                      decoration: InputDecoration(
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
                      items: ['Fitur Baru', 'Perbaikan Bug', 'Pengujian', 'DevOps & Server']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: AppTheme.text(modalContext)))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    // Pilihan Prioritas
                    Text('PRIORITAS', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textMutedColor(modalContext))),
                    const SizedBox(height: 6),
                    Row(
                      children: ['Rendah', 'Sedang', 'Tinggi', 'Kritis'].map((p) {
                        final isSelected = priority == p;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => priority = p),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryMint : AppTheme.surfaceElevated(modalContext),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryMint : AppTheme.border(modalContext),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  p,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF0A0E17) : AppTheme.text(modalContext),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    // Tombol Simpan ke SQLite
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryMint,
                          foregroundColor: const Color(0xFF0A0E17),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) return;

                          final newNote = WorkNote(
                            id: note?.id,
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            category: category,
                            assignedRole: assignedRole,
                            authorName: isEditing ? note.authorName : '${UserSession.instance.displayName} (${UserSession.instance.role.title})',
                            status: note?.status ?? 'todo',
                            priority: priority,
                            gitBranch: branchController.text.trim(),
                            createdAt: note?.createdAt ?? DateTime.now().toIso8601String(),
                          );

                          if (isEditing) {
                            await DatabaseHelper.instance.updateNote(newNote);
                          } else {
                            await DatabaseHelper.instance.insertNote(newNote);
                          }

                          if (!mounted) return;
                          if (modalContext.mounted) {
                            Navigator.pop(modalContext);
                          }
                          _loadNotes();
                        },
                        child: Text(
                          isEditing ? 'Simpan Perubahan' : 'Simpan ke Database SQLite',
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 48, color: AppTheme.textMutedColor(context)),
          const SizedBox(height: 12),
          Text(
            'Belum ada catatan kerja',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.text(context)),
          ),
          const SizedBox(height: 4),
          Text(
            'Klik tombol "+ Catatan Baru" untuk menambahkan tugas ke SQLite.',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSubtle(context)),
          ),
        ],
      ),
    );
  }
}
