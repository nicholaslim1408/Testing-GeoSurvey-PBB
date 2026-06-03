// lib/screens/nop_result_screen.dart
// ============================================================
// Halaman Hasil Scan NOP
// Tampil setelah scanner berhasil menemukan task di database
// Enumerator bisa langsung buka formulir dari sini
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../models/formulir_model.dart';
import 'formulir_screen.dart';

class NopResultScreen extends StatelessWidget {
  final SurveyTask task;
  final bool       hasFormulir;

  const NopResultScreen({
    super.key,
    required this.task,
    required this.hasFormulir,
  });

  Color _statusColor(String s) {
    switch (s) {
      case 'completed':   return AppColors.accent;
      case 'in_progress': return AppColors.warning;
      default:            return AppColors.textSecondary;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'completed':   return 'Selesai';
      case 'in_progress': return 'Sedang Diproses';
      default:            return 'Belum Dikerjakan';
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'completed':   return Icons.check_circle_rounded;
      case 'in_progress': return Icons.pending_rounded;
      default:            return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.statusTask == 'completed';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation:       0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Hasil Scan NOP',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header sukses scan ──────────────────────────
            _buildSuccessHeader(),
            const SizedBox(height: 20),

            // ── Kartu info properti ─────────────────────────
            _buildPropertyCard(),
            const SizedBox(height: 16),

            // ── Status formulir ─────────────────────────────
            _buildFormulirStatusCard(),
            const SizedBox(height: 24),

            // ── Tombol aksi ──────────────────────────────────
            if (!isCompleted)
              SizedBox(
                width:  double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FormulirScreen(task: task),
                      ),
                    );
                  },
                  icon:  Icon(
                    hasFormulir
                        ? Icons.edit_note_rounded
                        : Icons.assignment_add,
                    size: 20,
                  ),
                  label: Text(
                    hasFormulir
                        ? 'Lanjut Edit Formulir'
                        : 'Mulai Isi Formulir',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),

            if (isCompleted) ...[
              Container(
                padding:    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        AppColors.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.accent, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Formulir sudah disubmit dan selesai. '
                      'Tidak perlu pengisian ulang.',
                      style: GoogleFonts.plusJakartaSans(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width:  double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FormulirScreen(task: task)),
                  ),
                  icon:  const Icon(Icons.visibility_outlined, size: 18),
                  label: Text('Lihat Detail Formulir',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side:  const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            // Tombol kembali scan lagi
            SizedBox(
              width:  double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon:  const Icon(Icons.qr_code_scanner_rounded, size: 18),
                label: Text('Scan NOP Lain',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side:  const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header sukses ─────────────────────────────────────────
  Widget _buildSuccessHeader() {
    return Container(
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:     const LinearGradient(
          colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          padding:    const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:  AppColors.accent.withOpacity(0.15),
            shape:  BoxShape.circle,
          ),
          child: const Icon(Icons.qr_code_2_rounded,
              color: AppColors.accent, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scan Berhasil!',
                style: GoogleFonts.plusJakartaSans(
                    fontSize:   16,
                    fontWeight: FontWeight.w800,
                    color:      AppColors.accent)),
            const SizedBox(height: 2),
            Text('Data properti ditemukan dalam database.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color:    AppColors.accent.withOpacity(0.8))),
          ],
        )),
      ]),
    );
  }

  // ── Kartu info properti ────────────────────────────────────
  Widget _buildPropertyCard() {
    final statusColor = _statusColor(task.statusTask);

    return Container(
      padding:    const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(
          color:      Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, 2),
        )],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header kartu + status chip
        Row(children: [
          const Icon(Icons.home_work_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text('Informasi Properti',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontSize: 14)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:        statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_statusIcon(task.statusTask),
                  size: 12, color: statusColor),
              const SizedBox(width: 4),
              Text(_statusLabel(task.statusTask),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: statusColor)),
            ]),
          ),
        ]),

        const SizedBox(height: 14),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 14),

        // Detail rows
        _detailRow(Icons.tag_rounded,       'NOP',    task.nop),
        _detailRow(Icons.person_rounded,    'Nama WP', task.namaWp),
        _detailRow(Icons.location_on_rounded,'Alamat', task.alamatOp),
        _detailRow(Icons.grid_3x3_rounded,  'Blok/Urut',
            '${task.kdBlok} / ${task.noUrut}'),

        if (task.latitude != null && task.longitude != null) ...[
          const SizedBox(height: 4),
          _detailRow(Icons.my_location_rounded, 'Koordinat',
              '${task.latitude!.toStringAsFixed(6)}, '
              '${task.longitude!.toStringAsFixed(6)}'),
        ],
      ]),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text('$label',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: AppColors.textSecondary)),
        ),
        Text(': ',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.textSecondary)),
        Expanded(
          child: Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ),
      ]),
    );
  }

  // ── Status formulir card ───────────────────────────────────
  Widget _buildFormulirStatusCard() {
    final icon  = hasFormulir
        ? Icons.assignment_turned_in_rounded
        : Icons.assignment_outlined;
    final color = hasFormulir ? AppColors.warning : AppColors.textSecondary;
    final title = hasFormulir ? 'Formulir Sudah Ada (Draft)' : 'Belum Ada Formulir';
    final desc  = hasFormulir
        ? 'Formulir sudah pernah diisi dan tersimpan sebagai draft. '
          'Kamu bisa melanjutkan pengisian atau langsung submit.'
        : 'Belum ada data yang diisi untuk properti ini. '
          'Mulai isi formulir pendataan sekarang.';

    return Container(
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: color, fontSize: 13)),
            const SizedBox(height: 4),
            Text(desc,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.textSecondary,
                    height: 1.5)),
          ],
        )),
      ]),
    );
  }
}