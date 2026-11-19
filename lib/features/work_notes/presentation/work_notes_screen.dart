import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/database/db_helper.dart';
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
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          'Catatan Kerja Tim',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan Data SQLite',
            icon: const Icon(Icons.refresh_rounded, size: 20),
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
                  _buildStatsRow(),
                  // Filter Chips
                  _buildFilterChips(),
                  const SizedBox(height: 10),
                  // List Catatan Kerja
                  Expanded(
                    child: _filteredNotes.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            color: AppTheme.primaryMint,
                            backgroundColor: AppTheme.bgSurface,
                            onRefresh: _loadNotes,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              itemCount: _filteredNotes.length,
                              itemBuilder: (context, index) {
                                final note = _filteredNotes[index];
                                return _buildNoteCard(note, session);
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

  Widget _buildStatsRow() {
    final total = _notes.length;
    final doneCount = _notes.where((n) => n.status == 'done').length;
    final readyForQaCount = _notes.where((n) => n.status == 'ready_for_qa').length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _buildStatItem('Total Catatan', '$total', AppTheme.textPrimary)),
          Container(width: 1, height: 28, color: AppTheme.borderSubtle),
          Expanded(child: _buildStatItem('Siap Diuji QA', '$readyForQaCount', AppTheme.roleQA)),
          Container(width: 1, height: 28, color: AppTheme.borderSubtle),
          Expanded(child: _buildStatItem('Selesai', '$doneCount', AppTheme.primaryMint)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
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
                color: isSelected ? const Color(0xFF0A0E17) : AppTheme.textSecondary,
              ),
              backgroundColor: AppTheme.bgSurface,
              selectedColor: AppTheme.primaryMint,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryMint : AppTheme.borderSubtle,
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

  Widget _buildNoteCard(WorkNote note, UserSession session) {
    Color priorityColor = AppTheme.textSecondary;
    if (note.priority == 'Kritis') priorityColor = AppTheme.sev1Critical;
    if (note.priority == 'Tinggi') priorityColor = AppTheme.sev2Warning;
    if (note.priority == 'Sedang') priorityColor = AppTheme.roleDeveloper;

    String statusText = 'Belum Dikerjakan';
    Color statusColor = AppTheme.textMuted;
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
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: note.status == 'ready_for_qa'
              ? AppTheme.roleQA.withValues(alpha: 0.5)
              : AppTheme.borderSubtle,
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
                    color: AppTheme.bgSurfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Text(
                    note.category,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
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
                icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppTheme.textSecondary),
                color: AppTheme.bgSurfaceElevated,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showAddOrEditNoteDialog(context, note: note);
                  } else if (val == 'delete') {
                    _confirmDelete(context, note);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Catatan')),
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
              color: note.status == 'done' ? AppTheme.textMuted : AppTheme.textPrimary,
            ),
          ),
          if (note.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              note.description,
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
            ),
          ],
          const SizedBox(height: 12),
          // Git Branch & Penulis
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.alt_route_rounded, size: 12, color: AppTheme.primaryMint),
                    const SizedBox(width: 4),
                    Text(
                      note.gitBranch,
                      style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note.authorName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.borderSubtle, height: 1),
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
      SnackBar(backgroundColor: AppTheme.bgSurfaceElevated, content: Text(message)),
    );
  }

  void _confirmDelete(BuildContext context, WorkNote note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSurface,
        title: Text('Hapus Catatan?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Catatan "${note.title}" akan dihapus permanen dari database SQLite.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
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
      backgroundColor: AppTheme.bgDark,
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
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Judul Tugas
                    TextField(
                      controller: titleController,
                      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Judul Tugas / Catatan',
                        hintText: 'Contoh: Perbaiki validasi token login',
                        filled: true,
                        fillColor: AppTheme.bgSurface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Deskripsi
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Keterangan / Catatan Teknis',
                        hintText: 'Tuliskan detail pekerjaan atau kendala...',
                        filled: true,
                        fillColor: AppTheme.bgSurface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Git Branch
                    TextField(
                      controller: branchController,
                      style: GoogleFonts.jetBrainsMono(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Nama Git Branch',
                        prefixIcon: const Icon(Icons.alt_route_rounded, size: 16, color: AppTheme.primaryMint),
                        filled: true,
                        fillColor: AppTheme.bgSurface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Pilihan Kategori
                    Text('KATEGORI', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textMuted)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      dropdownColor: AppTheme.bgSurfaceElevated,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.bgSurface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: ['Fitur Baru', 'Perbaikan Bug', 'Pengujian', 'DevOps & Server']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    // Pilihan Prioritas
                    Text('PRIORITAS', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textMuted)),
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
                                color: isSelected ? AppTheme.primaryMint : AppTheme.bgSurface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryMint : AppTheme.borderSubtle,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  p,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF0A0E17) : AppTheme.textPrimary,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.note_alt_outlined, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          Text(
            'Belum ada catatan kerja',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Klik tombol "+ Catatan Baru" untuk menambahkan tugas ke SQLite.',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
