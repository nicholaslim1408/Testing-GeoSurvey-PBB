// lib/screens/scanner_screen.dart
// ============================================================
// Halaman Scanner NOP (Phase 3)
// Menggunakan kamera untuk scan QR Code / Barcode NOP
// Setelah scan berhasil → cari task di database → buka formulir
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../config/app_theme.dart';
import '../services/scanner_service.dart';
import '../models/formulir_model.dart';
import '../widgets/scanner_overlay.dart';
import 'formulir_screen.dart';
import 'nop_result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  // Controller kamera scanner
  final MobileScannerController _scannerCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates, // hindari scan ganda
    facing:         CameraFacing.back,
  );

  // State
  bool    _isProcessing  = false; // sedang kirim ke API
  bool    _isTorchOn     = false;
  bool    _isPaused      = false;
  String? _lastScannedNop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerCtrl.dispose();
    super.dispose();
  }

  // Pause scanner saat app di background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _scannerCtrl.stop();
    } else if (state == AppLifecycleState.resumed && !_isPaused) {
      _scannerCtrl.start();
    }
  }

  // ── Handler saat barcode terdeteksi ─────────────────────────
  void _onDetect(BarcodeCapture capture) async {
    // Abaikan jika sedang proses atau scanner di-pause
    if (_isProcessing || _isPaused) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    // Hindari scan ulang NOP yang sama terus-terusan
    if (rawValue == _lastScannedNop) return;

    // Validasi format dasar NOP sebelum kirim ke API
    if (!ScannerService.isValidNopFormat(rawValue)) {
      _showInvalidFormatSnackbar(rawValue);
      return;
    }

    setState(() {
      _isProcessing  = true;
      _lastScannedNop = rawValue;
      _isPaused       = true;
    });

    // Pause scanner selama proses API
    await _scannerCtrl.stop();

    // Tampilkan loading dialog
    _showLoadingDialog(rawValue);

    // Panggil API cari task by NOP
    final result = await ScannerService.findTaskByNop(rawValue);

    if (!mounted) return;

    // Tutup loading dialog
    Navigator.of(context, rootNavigator: true).pop();

    setState(() => _isProcessing = false);

    if (result.success && result.task != null) {
      // Navigasi ke halaman hasil scan
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NopResultScreen(
            task:        result.task!,
            hasFormulir: result.hasFormulir,
          ),
        ),
      );
      // Setelah kembali dari result screen, resume scanner
      _resumeScanner();
    } else {
      // Tampilkan error & resume scanner
      _showErrorBottomSheet(rawValue, result.message);
    }
  }

  void _resumeScanner() {
    setState(() {
      _isPaused       = false;
      _lastScannedNop = null;
    });
    _scannerCtrl.start();
  }

  // ── Toggle torch / flash ─────────────────────────────────
  void _toggleTorch() {
    _scannerCtrl.toggleTorch();
    setState(() => _isTorchOn = !_isTorchOn);
  }

  // ── Input manual NOP ─────────────────────────────────────
  void _openManualInput() async {
    await _scannerCtrl.stop();
    setState(() => _isPaused = true);

    final nop = await showDialog<String>(
      context: context,
      builder: (ctx) => _ManualInputDialog(),
    );

    if (!mounted) return;

    if (nop != null && nop.trim().isNotEmpty) {
      // Proses NOP dari input manual sama seperti scan
      setState(() => _isProcessing = true);
      _showLoadingDialog(nop.trim());

      final result = await ScannerService.findTaskByNop(nop.trim());

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      setState(() => _isProcessing = false);

      if (result.success && result.task != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NopResultScreen(
              task:        result.task!,
              hasFormulir: result.hasFormulir,
            ),
          ),
        );
      } else {
        _showErrorBottomSheet(nop.trim(), result.message);
      }
    }

    _resumeScanner();
  }

  void _showLoadingDialog(String nop) {
    showDialog(
      context:             context,
      barrierDismissible:  false,
      barrierColor:        Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text('Mencari data NOP...',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 6),
            Text(
              nop,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ]),
        ),
      ),
    );
  }

  void _showInvalidFormatSnackbar(String raw) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Kode "$raw" bukan format NOP yang valid.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        backgroundColor: AppColors.warning,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorBottomSheet(String nop, String message) {
    showModalBottomSheet(
      context:       context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle bar
          Container(
            width:  40, height: 4,
            decoration: BoxDecoration(
              color:        AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Error icon
          Container(
            padding:    const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:        AppColors.errorLight,
              shape:        BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_2_rounded,
                color: AppColors.error, size: 36),
          ),
          const SizedBox(height: 16),

          Text('NOP Tidak Ditemukan',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 8),
          Container(
            padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color:        AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'NOP: $nop',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: AppColors.textSecondary,
                  ),
            ),
          ),
          const SizedBox(height: 24),

          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _resumeScanner();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side:    const BorderSide(color: AppColors.primary),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Scan Ulang',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openManualInput();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize:     const Size(0, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text('Input Manual',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ]),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation:       0,
        title: Text('Scanner NOP',
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          // Toggle torch
          IconButton(
            icon: Icon(
              _isTorchOn
                  ? Icons.flashlight_on_rounded
                  : Icons.flashlight_off_rounded,
              color: _isTorchOn ? AppColors.warning : Colors.white,
            ),
            onPressed: _toggleTorch,
            tooltip: 'Flash',
          ),
          // Input manual
          IconButton(
            icon:    const Icon(Icons.keyboard_alt_outlined, color: Colors.white),
            onPressed: _openManualInput,
            tooltip: 'Input Manual NOP',
          ),
        ],
      ),
      body: Stack(fit: StackFit.expand, children: [
        // ── Kamera scanner ─────────────────────────────────
        MobileScanner(
          controller: _scannerCtrl,
          onDetect:   _onDetect,
        ),

        // ── Overlay viewfinder ──────────────────────────────
        const ScannerOverlay(),

        // ── Teks petunjuk ───────────────────────────────────
        Positioned(
          bottom: 120,
          left:   0, right: 0,
          child: Column(children: [
            Container(
              padding:    const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color:        Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Arahkan kamera ke QR Code / Barcode NOP',
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Atau ketuk ikon keyboard untuk input NOP manual',
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white60, fontSize: 11),
            ),
          ]),
        ),

        // ── Loading indicator saat proses ───────────────────
        if (_isProcessing)
          Container(
            color: Colors.black38,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ]),
    );
  }
}

// ── Dialog Input Manual NOP ───────────────────────────────────
class _ManualInputDialog extends StatefulWidget {
  @override
  State<_ManualInputDialog> createState() => _ManualInputDialogState();
}

class _ManualInputDialogState extends State<_ManualInputDialog> {
  final _ctrl   = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        const Icon(Icons.pin_outlined, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text('Input NOP Manual',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, fontSize: 16)),
      ]),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Masukkan Nomor Objek Pajak (NOP) secara manual.',
            style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller:    _ctrl,
            autofocus:     true,
            keyboardType:  TextInputType.text,
            textCapitalization: TextCapitalization.none,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 15, letterSpacing: 1.2),
            decoration: InputDecoration(
              labelText: 'Nomor Objek Pajak',
              hintText:  '32.04.010.001.001.0001.0',
              hintStyle: GoogleFonts.plusJakartaSans(
                  color: AppColors.textHint, fontSize: 13),
              prefixIcon: const Icon(Icons.tag_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'NOP wajib diisi';
              }
              if (!ScannerService.isValidNopFormat(v.trim())) {
                return 'Format NOP tidak valid (min. 10 digit angka)';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          // Contoh format
          Container(
            padding:    const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:        AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Contoh format NOP:',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('32.04.010.001.001.0001.0',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal',
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _ctrl.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize:     Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text('Cari',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}