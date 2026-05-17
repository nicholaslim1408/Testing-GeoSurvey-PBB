// lib/screens/dashboard_screen.dart
// ============================================================
// UPDATE Phase 2: tambah statistik task & navigasi ke formulir
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../services/formulir_service.dart';
import '../utils/storage_helper.dart';
import '../models/user_model.dart';
import '../models/formulir_model.dart';
import 'login_screen.dart';
import 'task_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserModel? _user;
  TaskStats? _stats;
  bool _isLoadingUser  = true;
  bool _isLoadingStats = true;
  int  _selectedNav    = 0; // 0=Dashboard, 1=Formulir, ...

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStats();
  }

  Future<void> _loadUser() async {
    final user = await StorageHelper.getUser();
    if (mounted) setState(() { _user = user; _isLoadingUser = false; });
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    final result = await FormulirService.getStats();
    if (mounted) {
      setState(() {
        _stats          = result.success ? result.data : null;
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Konfirmasi Logout',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('Apakah kamu yakin ingin keluar?',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text('Logout',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(children: [
        _buildSidebar(),
        Expanded(child: _buildContent()),
      ]),
    );
  }

  // ── Sidebar ────────────────────────────────────────────────
  Widget _buildSidebar() {
    final navItems = [
      (Icons.dashboard_rounded,      'Dashboard',          false),
      (Icons.assignment_rounded,     'Formulir Pendataan', false), // aktif Phase 2
      (Icons.qr_code_scanner_rounded,'Scanner NOP',        true),  // Phase 3
      (Icons.camera_alt_rounded,     'Kamera & GPS',       true),  // Phase 4
      (Icons.satellite_alt_rounded,  'Citra Satelit',      true),  // Phase 5
    ];

    return Container(
      width: 260,
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Column(children: [
        // Logo
        Container(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Row(children: [
            Container(
              padding:    const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:        Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.map_rounded,
                  size: 24, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('GeoSurvey',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w700)),
              Text('PBB System',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ]),
          ]),
        ),

        const Divider(color: Colors.white24, height: 1),

        // User info
        Container(
          padding:    const EdgeInsets.all(16),
          margin:     const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:        Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            CircleAvatar(
              radius:          20,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Text(
                (_user?.fullName.isNotEmpty == true)
                    ? _user!.fullName[0].toUpperCase()
                    : 'U',
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_user?.fullName ?? 'User',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Container(
                  margin:     const EdgeInsets.only(top: 2),
                  padding:    const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:        Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_user?.role ?? 'enumerator',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white, fontSize: 10)),
                ),
              ],
            )),
          ]),
        ),

        // Nav items
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(children: navItems.asMap().entries.map((entry) {
              final i    = entry.key;
              final item = entry.value;
              final isActive  = _selectedNav == i;
              final isComingSoon = item.$3;

              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  dense:   true,
                  leading: Icon(item.$1,
                      size:  20,
                      color: isActive
                          ? Colors.white
                          : Colors.white60),
                  title: Text(item.$2,
                      style: GoogleFonts.plusJakartaSans(
                          color: isActive ? Colors.white : Colors.white70,
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400)),
                  trailing: isComingSoon
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:        Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Soon',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 9)),
                        )
                      : null,
                  tileColor: isActive
                      ? Colors.white.withOpacity(0.15)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onTap: isComingSoon ? null : () {
                    setState(() => _selectedNav = i);
                    if (i == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TaskListScreen()),
                      ).then((_) => _loadStats()); // refresh stats setelah kembali
                    }
                  },
                ),
              );
            }).toList()),
          ),
        ),

        // Logout
        Padding(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap:        _handleLogout,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding:    const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:        Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.logout_rounded,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 10),
                Text('Keluar',
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70, fontSize: 14)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Main Content ───────────────────────────────────────────
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header greeting
        Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, ${_user?.fullName ?? 'User'}! 👋',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 24, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Selamat datang di GeoSurvey PBB',
                  style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary)),
            ],
          )),
          // Refresh button
          IconButton(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary),
          ),
        ]),
        const SizedBox(height: 28),

        // ── Statistik Task ─────────────────────────────────
        Text('Statistik Survey',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        _buildStatsRow(),
        const SizedBox(height: 28),

        // ── Quick Action ──────────────────────────────────
        Text('Aksi Cepat',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        _buildQuickActions(),
        const SizedBox(height: 28),

        // ── Phase Status ──────────────────────────────────
        Text('Status Pengembangan',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        _buildPhaseCards(),
      ]),
    );
  }

  // ── Stats Row ──────────────────────────────────────────────
  Widget _buildStatsRow() {
    final cards = [
      ('Total Task',  _stats?.total,      AppColors.primary,       Icons.assignment_rounded),
      ('Pending',     _stats?.pending,    AppColors.textSecondary, Icons.radio_button_unchecked_rounded),
      ('Proses',      _stats?.inProgress, AppColors.warning,       Icons.pending_rounded),
      ('Selesai',     _stats?.completed,  AppColors.accent,        Icons.check_circle_rounded),
    ];

    return Wrap(spacing: 14, runSpacing: 14, children: cards.map((c) {
      return Container(
        width:      170,
        padding:    const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8, offset: const Offset(0, 2),
          )],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(c.$4, color: c.$3, size: 22),
          const SizedBox(height: 10),
          _isLoadingStats
              ? Container(
                  width: 40, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(6),
                  ),
                )
              : Text('${c.$2 ?? 0}',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 28, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(c.$1,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: AppColors.textSecondary)),
        ]),
      );
    }).toList());
  }

  // ── Quick Actions ──────────────────────────────────────────
  Widget _buildQuickActions() {
    return Wrap(spacing: 14, runSpacing: 14, children: [
      _buildActionCard(
        icon:    Icons.assignment_add,
        label:   'Isi Formulir',
        desc:    'Mulai pendataan properti',
        color:   AppColors.primary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskListScreen()),
        ).then((_) => _loadStats()),
      ),
      _buildActionCard(
        icon:    Icons.list_alt_rounded,
        label:   'Lihat Semua Task',
        desc:    'Cek status survey task',
        color:   AppColors.accent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskListScreen()),
        ).then((_) => _loadStats()),
      ),
    ]);
  }

  Widget _buildActionCard({
    required IconData  icon,
    required String    label,
    required String    desc,
    required Color     color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width:      200,
        padding:    const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8, offset: const Offset(0, 2),
          )],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding:    const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:        color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(desc,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }

  // ── Phase Cards ────────────────────────────────────────────
  Widget _buildPhaseCards() {
    final phases = [
      ('Phase 1', 'Setup & Auth',    Icons.lock_rounded,           true),
      ('Phase 2', 'Formulir',        Icons.assignment_rounded,     true),  // ← selesai
      ('Phase 3', 'Scanner NOP',     Icons.qr_code_rounded,        false),
      ('Phase 4', 'Kamera & GPS',    Icons.camera_alt_rounded,     false),
      ('Phase 5', 'Citra Satelit',   Icons.satellite_alt_rounded,  false),
    ];

    return Wrap(spacing: 14, runSpacing: 14, children: phases.map((p) {
      final isDone = p.$4;
      return Container(
        width:      180,
        padding:    const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        isDone
              ? AppColors.accent.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone
                ? AppColors.accent.withOpacity(0.3)
                : AppColors.border,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(p.$3,
                size:  18,
                color: isDone ? AppColors.accent : AppColors.textSecondary),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.accent.withOpacity(0.15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(isDone ? '✓ Done' : 'Soon',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: isDone
                          ? AppColors.accent
                          : AppColors.textSecondary)),
            ),
          ]),
          const SizedBox(height: 10),
          Text(p.$1,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, color: AppColors.textSecondary)),
          Text(p.$2,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ]),
      );
    }).toList());
  }
}