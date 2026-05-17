// lib/screens/task_list_screen.dart
// ============================================================
// Halaman daftar Survey Task — enumerator pilih properti
// yang akan disurvei dari sini
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../models/formulir_model.dart';
import '../services/formulir_service.dart';
import 'formulir_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  List<SurveyTask> _tasks      = [];
  bool             _isLoading  = true;
  String?          _errorMsg;
  String           _filterStatus = ''; // '' = semua
  final _searchCtrl = TextEditingController();

  late TabController _tabController;

  final _tabs = const [
    ('Semua',       ''),
    ('Pending',     'pending'),
    ('Proses',      'in_progress'),
    ('Selesai',     'completed'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _filterStatus = _tabs[_tabController.index].$2);
        _loadTasks();
      }
    });
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() { _isLoading = true; _errorMsg = null; });

    final result = await FormulirService.getAllTasks(
      status: _filterStatus.isEmpty ? null : _filterStatus,
      search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.success) {
        _tasks    = result.data ?? [];
      } else {
        _errorMsg = result.message;
      }
    });
  }

  // Warna chip status
  Color _statusColor(String status) {
    switch (status) {
      case 'completed':   return AppColors.accent;
      case 'in_progress': return AppColors.warning;
      default:            return AppColors.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':   return 'Selesai';
      case 'in_progress': return 'Proses';
      default:            return 'Pending';
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':   return Icons.check_circle_rounded;
      case 'in_progress': return Icons.pending_rounded;
      default:            return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor:  AppColors.surface,
        elevation:        0,
        title: Text(
          'Daftar Survey Task',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color:      AppColors.textPrimary,
            fontSize:   18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller:  _searchCtrl,
                  onSubmitted: (_) => _loadTasks(),
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: InputDecoration(
                    hintText:    'Cari NOP, nama WP, atau alamat...',
                    hintStyle:   GoogleFonts.plusJakartaSans(
                      color: AppColors.textHint, fontSize: 13,
                    ),
                    prefixIcon:  const Icon(Icons.search_rounded,
                        size: 20, color: AppColors.textSecondary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                size: 18, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchCtrl.clear();
                              _loadTasks();
                            },
                          )
                        : null,
                    filled:    true,
                    fillColor:  AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:   BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Tab bar
              TabBar(
                controller:        _tabController,
                labelStyle:        GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13),
                labelColor:        AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor:    AppColors.primary,
                indicatorWeight:   2.5,
                tabs: _tabs
                    .map((t) => Tab(text: t.$1))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon:      const Icon(Icons.refresh_rounded,
                color: AppColors.textPrimary),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMsg != null) {
      return _buildErrorState();
    }

    if (_tasks.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      color:     AppColors.primary,
      child: ListView.separated(
        padding:   const EdgeInsets.all(16),
        itemCount: _tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) => _buildTaskCard(_tasks[i]),
      ),
    );
  }

  Widget _buildTaskCard(SurveyTask task) {
    final statusColor = _statusColor(task.statusTask);
    final syncDone    = task.formulirStatus == 'synced';

    return InkWell(
      onTap: () async {
        final refresh = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => FormulirScreen(task: task),
          ),
        );
        if (refresh == true) _loadTasks();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding:    const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color:       Colors.black.withOpacity(0.04),
              blurRadius:  8,
              offset:      const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: NOP + status chip
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.nop,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize:   13,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.primary,
                    ),
                  ),
                ),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:        statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(task.statusTask),
                          size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(task.statusTask),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize:   11,
                          fontWeight: FontWeight.w600,
                          color:      statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Nama WP
            Text(
              task.namaWp,
              style: GoogleFonts.plusJakartaSans(
                fontSize:   15,
                fontWeight: FontWeight.w700,
                color:      AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Alamat
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.alamatOp,
                    maxLines:  2,
                    overflow:  TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color:    AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            // Sync badge (jika sudah ada formulir)
            if (task.formulirId != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    syncDone
                        ? Icons.cloud_done_rounded
                        : Icons.edit_note_rounded,
                    size:  14,
                    color: syncDone ? AppColors.accent : AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    syncDone
                        ? 'Formulir sudah disubmit'
                        : 'Formulir tersimpan (draft)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color:    syncDone
                          ? AppColors.accent
                          : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppColors.textHint),
                ],
              ),
            ] else ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Belum ada formulir',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppColors.textHint,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppColors.textHint),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined,
              size: 64, color: AppColors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'Tidak ada task ditemukan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchCtrl.text.isNotEmpty
                ? 'Coba kata kunci lain'
                : 'Belum ada task yang ditugaskan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 56, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              _errorMsg!,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary, fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadTasks,
              icon:      const Icon(Icons.refresh_rounded, size: 18),
              label:     const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(140, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}