// lib/screens/formulir_screen.dart
// ============================================================
// Halaman Formulir Pendataan Fisik Properti
// Enumerator mengisi data tanah & bangunan di sini
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../models/formulir_model.dart';
import '../services/formulir_service.dart';

class FormulirScreen extends StatefulWidget {
  final SurveyTask task;
  const FormulirScreen({super.key, required this.task});

  @override
  State<FormulirScreen> createState() => _FormulirScreenState();
}

class _FormulirScreenState extends State<FormulirScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers data tanah ─────────────────────────────────
  final _luasBumiCtrl     = TextEditingController();
  final _tahunDibangunCtrl= TextEditingController();
  final _luasBangunanCtrl = TextEditingController();
  final _jumlahLantaiCtrl = TextEditingController(text: '1');
  final _catatanCtrl      = TextEditingController();

  // --- NEW CONTROLLERS ---
  final _tahunRenovasiCtrl = TextEditingController();
  final _lebarJalanCtrl    = TextEditingController();
  // -----------------------

  // ── Dropdown values ────────────────────────────────────────
  String? _jenisBumi;
  String? _kondisiTanah;
  String? _kondisiBangunan;
  String? _materialDinding;
  String? _materialAtap;
  String? _materialLantai;

  // --- NEW DROPDOWN VALUES ---
  String? _penggunaanBangunan;
  String? _statusKepemilikan;
  String? _dayaListrik;
  String? _aksesJalan;
  String? _pagar;
  String? _sumberAir;
  String? _statusHunian;
  // ---------------------------

  // ── Fasilitas (multi-select) ───────────────────────────────
  final _fasilitasOptions = [
    ('telepon',    'Telepon',        Icons.phone_rounded),
    ('internet',   'Internet',       Icons.wifi_rounded),
    ('gas',        'Gas',            Icons.local_fire_department_rounded),
    ('ac',         'AC',             Icons.ac_unit_rounded),
    ('lift',       'Lift',           Icons.elevator_rounded),
    ('kolam_renang','Kolam Renang',  Icons.pool_rounded),
  ];
  final Set<String> _selectedFasilitas = {};

  // ── State ──────────────────────────────────────────────────
  bool    _isLoading      = false;
  bool    _isLoadingExisting = true;
  bool    _hasExisting    = false;
  String? _errorMsg;
  String? _successMsg;
  int?    _existingFormulirId;

  // ── Options ────────────────────────────────────────────────
  final _jenisBumiOptions      = ['Tanah', 'Sawah', 'Kebun', 'Tambak', 'Hutan', 'Lainnya'];
  final _kondisiOptions        = ['baik', 'sedang', 'buruk'];
  final _materialDindingOpts   = ['Beton', 'Bata Merah', 'Bata Ringan', 'Kayu', 'Bambu', 'Lainnya'];
  final _materialAtapOpts      = ['Beton', 'Genteng', 'Seng', 'Asbes', 'Sirap', 'Lainnya'];
  final _materialLantaiOpts    = ['Keramik', 'Granit', 'Marmer', 'Semen', 'Kayu', 'Tanah', 'Lainnya'];

  // --- NEW OPTIONS ---
  final _penggunaanBangunanOpts = ['Rumah Tinggal', 'Ruko', 'Toko', 'Kantor', 'Gudang', 'Industri', 'Kos-kosan', 'Hotel', 'Restoran', 'Lainnya'];
  final _statusKepemilikanOpts  = ['Milik Sendiri', 'Sewa', 'Kontrak', 'Hak Pakai', 'Lainnya'];
  final _dayaListrikOpts        = ['450 VA', '900 VA', '1300 VA', '2200 VA', '> 2200 VA'];
  final _aksesJalanOpts         = ['Aspal', 'Beton', 'Paving', 'Tanah'];
  final _pagarOpts              = ['Tidak Ada', 'Besi', 'Beton', 'Kombinasi'];
  final _sumberAirOpts          = ['PDAM', 'Sumur Bor', 'Sumur Gali', 'Air Isi Ulang', 'Lainnya'];
  final _statusHunianOpts       = ['Dihuni', 'Kosong', 'Disewakan'];
  // -------------------

  @override
  void initState() {
    super.initState();
    _loadExistingFormulir();
  }

  @override
  void dispose() {
    _luasBumiCtrl.dispose();
    _tahunDibangunCtrl.dispose();
    _luasBangunanCtrl.dispose();
    _jumlahLantaiCtrl.dispose();
    _catatanCtrl.dispose();
    
    // --- NEW FIELDS ---
    _tahunRenovasiCtrl.dispose();
    _lebarJalanCtrl.dispose();
    // ------------------
    
    super.dispose();
  }

  // ── Load data yang sudah ada (jika ada) ───────────────────
  Future<void> _loadExistingFormulir() async {
    setState(() => _isLoadingExisting = true);

    final result = await FormulirService.getFormulirByTask(widget.task.id);

    if (!mounted) return;
    setState(() => _isLoadingExisting = false);

    if (result.success && result.data != null) {
      final f = result.data!;
      _hasExisting        = true;
      _existingFormulirId = f.id;

      // Isi form dengan data yang sudah ada
      _luasBumiCtrl.text      = f.luasBumi.toString();
      _luasBangunanCtrl.text  = f.luasBangunan.toString();
      _jumlahLantaiCtrl.text  = f.jumlahLantai.toString();
      if (f.tahunDibangun != null) {
        _tahunDibangunCtrl.text = f.tahunDibangun.toString();
      }
      _catatanCtrl.text       = f.catatan ?? '';
      
      // --- NEW FIELDS TEXT CONTROLLERS ---
      if (f.tahunRenovasi != null) {
        _tahunRenovasiCtrl.text = f.tahunRenovasi.toString();
      }
      if (f.lebarJalan != null) {
        _lebarJalanCtrl.text = f.lebarJalan.toString();
      }
      // -----------------------------------
      
      _jenisBumi       = f.jenisBumi;
      _kondisiTanah    = f.kondisiTanah;
      _kondisiBangunan = f.kondisiBangunan;
      _materialDinding = f.materialDinding;
      _materialAtap    = f.materialAtap;
      _materialLantai  = f.materialLantai;
      
      // --- NEW FIELDS DROPDOWN VALUES ---
      _penggunaanBangunan = f.penggunaanBangunan;
      _statusKepemilikan  = f.statusKepemilikan;
      _dayaListrik        = f.dayaListrik;
      _aksesJalan         = f.aksesJalan;
      _pagar              = f.pagar;
      _sumberAir          = f.sumberAir;
      _statusHunian       = f.statusHunian;
      // ----------------------------------
      _selectedFasilitas.addAll(f.fasilitas);
      setState(() {});
    }
  }

  // ── Simpan draft ──────────────────────────────────────────
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMsg = null; _successMsg = null; });

    final formulir = FormulirModel(
      taskId:          widget.task.id,
      nop:             widget.task.nop,
      luasBumi:        double.tryParse(_luasBumiCtrl.text)    ?? 0,
      jenisBumi:       _jenisBumi,
      kondisiTanah:    _kondisiTanah,
      luasBangunan:    double.tryParse(_luasBangunanCtrl.text) ?? 0,
      jumlahLantai:    int.tryParse(_jumlahLantaiCtrl.text)    ?? 1,
      tahunDibangun:   int.tryParse(_tahunDibangunCtrl.text),
      kondisiBangunan: _kondisiBangunan,
      materialDinding: _materialDinding,
      materialAtap:    _materialAtap,
      materialLantai:  _materialLantai,
      fasilitas:       _selectedFasilitas.toList(),
      catatan:         _catatanCtrl.text.trim(),
      
      // --- NEW FIELDS ---
      penggunaanBangunan: _penggunaanBangunan,
      statusKepemilikan:  _statusKepemilikan,
      tahunRenovasi:      int.tryParse(_tahunRenovasiCtrl.text),
      dayaListrik:        _dayaListrik,
      aksesJalan:         _aksesJalan,
      lebarJalan:         double.tryParse(_lebarJalanCtrl.text),
      pagar:              _pagar,
      sumberAir:          _sumberAir,
      statusHunian:       _statusHunian,
      // ------------------
    );

    final result = await FormulirService.saveFormulir(formulir);

    if (!mounted) return;
    setState(() {
      _isLoading  = false;
      if (result.success) {
        _successMsg  = result.message;
        _hasExisting = true;
      } else {
        _errorMsg = result.message;
      }
    });
  }

  // ── Submit (selesai) ──────────────────────────────────────
  Future<void> _handleSubmit() async {
    // Harus simpan dulu sebelum submit
    if (!_hasExisting) {
      await _handleSave();
      if (_errorMsg != null) return;
    }

    final confirm = await _showConfirmDialog();
    if (confirm != true) return;

    setState(() { _isLoading = true; _errorMsg = null; });

    final result = await FormulirService.submitFormulir(widget.task.id);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _showSuccessDialog();
    } else {
      setState(() => _errorMsg = result.message);
    }
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Submit Formulir?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text(
          'Setelah disubmit, status task akan berubah menjadi '
          '"Completed". Pastikan semua data sudah benar.',
          style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary, fontSize: 14),
        ),
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
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              minimumSize:     Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text('Ya, Submit',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.accent, size: 64),
            const SizedBox(height: 16),
            Text(
              'Formulir Berhasil Disubmit!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Data survei properti ${widget.task.namaWp} '
              'telah berhasil disimpan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true); // kembali ke task list & refresh
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text('Kembali ke Daftar',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor:  AppColors.surface,
        elevation:        0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context, _hasExisting),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Formulir Pendataan',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary, fontSize: 16)),
            Text(widget.task.namaWp,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: _isLoadingExisting
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _buildFormBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Form Body ─────────────────────────────────────────────
  Widget _buildFormBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card properti
            _buildPropertyInfoCard(),
            const SizedBox(height: 16),

            // Pesan sukses/error
            if (_successMsg != null) _buildBanner(
              _successMsg!, AppColors.accent, AppColors.accent.withOpacity(0.08),
              Icons.check_circle_rounded,
            ),
            if (_errorMsg != null) _buildBanner(
              _errorMsg!, AppColors.error, AppColors.errorLight,
              Icons.error_outline_rounded,
            ),
            if (_successMsg != null || _errorMsg != null)
              const SizedBox(height: 12),

            // Section: Data Tanah
            _buildSectionHeader('🌱 Data Tanah', 'Informasi luas dan kondisi tanah'),
            const SizedBox(height: 12),
            _buildNumberField(
              controller: _luasBumiCtrl,
              label:      'Luas Bumi (m²) *',
              hint:       'Contoh: 150.5',
              isRequired: true,
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              value:   _jenisBumi,
              label:   'Jenis Bumi',
              items:   _jenisBumiOptions,
              onChanged: (v) => setState(() => _jenisBumi = v),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              value:    _kondisiTanah,
              label:    'Kondisi Tanah',
              items:    _kondisiOptions,
              onChanged: (v) => setState(() => _kondisiTanah = v),
              labels:   {'baik': 'Baik', 'sedang': 'Sedang', 'buruk': 'Buruk'},
            ),
            
            // --- NEW UI FIELDS (Tanah) ---
            const SizedBox(height: 12),
            _buildDropdown(
              value:    _statusKepemilikan,
              label:    'Status Kepemilikan',
              items:    _statusKepemilikanOpts,
              onChanged: (v) => setState(() => _statusKepemilikan = v),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _buildDropdown(
                  value:    _aksesJalan,
                  label:    'Akses Jalan',
                  items:    _aksesJalanOpts,
                  onChanged: (v) => setState(() => _aksesJalan = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  controller: _lebarJalanCtrl,
                  label:      'Lebar Jalan (m)',
                  hint:       'Contoh: 4.5',
                ),
              ),
            ]),
            // -----------------------------
            const SizedBox(height: 20),

            // Section: Data Bangunan
            _buildSectionHeader('🏠 Data Bangunan', 'Informasi fisik bangunan'),
            const SizedBox(height: 12),
            _buildDropdown(
              value:    _penggunaanBangunan,
              label:    'Penggunaan Bangunan',
              items:    _penggunaanBangunanOpts,
              onChanged: (v) => setState(() => _penggunaanBangunan = v),
            ),
            const SizedBox(height: 12),
            _buildNumberField(
              controller: _luasBangunanCtrl,
              label:      'Luas Bangunan (m²) *',
              hint:       'Contoh: 80.0',
              isRequired: true,
            ),
            const SizedBox(height: 12),

            Row(children: [
              Expanded(
                child: _buildNumberField(
                  controller: _jumlahLantaiCtrl,
                  label:      'Jumlah Lantai *',
                  hint:       '1',
                  isInt:      true,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  controller: _tahunDibangunCtrl,
                  label:      'Tahun Dibangun',
                  hint:       'Contoh: 2010',
                  isInt:      true,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _buildDropdown(
                  value:    _kondisiBangunan,
                  label:    'Kondisi Bangunan',
                  items:    _kondisiOptions,
                  onChanged: (v) => setState(() => _kondisiBangunan = v),
                  labels:   {'baik': 'Baik', 'sedang': 'Sedang', 'buruk': 'Buruk'},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  controller: _tahunRenovasiCtrl,
                  label:      'Tahun Renovasi',
                  hint:       'Contoh: 2023',
                  isInt:      true,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _buildDropdown(
                  value:    _dayaListrik,
                  label:    'Daya Listrik',
                  items:    _dayaListrikOpts,
                  onChanged: (v) => setState(() => _dayaListrik = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  value:    _statusHunian,
                  label:    'Status Hunian',
                  items:    _statusHunianOpts,
                  onChanged: (v) => setState(() => _statusHunian = v),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Section: Material
            _buildSectionHeader('🧱 Material Konstruksi', 'Material utama bangunan'),
            const SizedBox(height: 12),
            _buildDropdown(
              value:    _materialDinding,
              label:    'Material Dinding',
              items:    _materialDindingOpts,
              onChanged: (v) => setState(() => _materialDinding = v),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              value:    _materialAtap,
              label:    'Material Atap',
              items:    _materialAtapOpts,
              onChanged: (v) => setState(() => _materialAtap = v),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              value:    _materialLantai,
              label:    'Material Lantai',
              items:    _materialLantaiOpts,
              onChanged: (v) => setState(() => _materialLantai = v),
            ),
            
            // --- NEW UI FIELDS (Material & Fasilitas Ekstra) ---
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _buildDropdown(
                  value:    _pagar,
                  label:    'Jenis Pagar',
                  items:    _pagarOpts,
                  onChanged: (v) => setState(() => _pagar = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  value:    _sumberAir,
                  label:    'Sumber Air',
                  items:    _sumberAirOpts,
                  onChanged: (v) => setState(() => _sumberAir = v),
                ),
              ),
            ]),
            // --------------------------------------------------
            const SizedBox(height: 20),

            // Section: Fasilitas
            _buildSectionHeader('⚡ Fasilitas', 'Centang fasilitas yang tersedia'),
            const SizedBox(height: 12),
            _buildFasilitasGrid(),
            const SizedBox(height: 20),

            // Section: Catatan
            _buildSectionHeader('📝 Catatan', 'Informasi tambahan (opsional)'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _catatanCtrl,
              maxLines:   4,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Tambahkan catatan atau keterangan tambahan...',
                hintStyle: GoogleFonts.plusJakartaSans(
                    color: AppColors.textHint, fontSize: 13),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 100), // ruang untuk bottom bar
          ],
        ),
      ),
    );
  }

  // ── Bottom Action Bar ──────────────────────────────────────
  Widget _buildBottomBar() {
    final isCompleted = widget.task.statusTask == 'completed';
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset:     const Offset(0, -4),
          ),
        ],
      ),
      child: isCompleted
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Text('Formulir sudah disubmit',
                    style: GoogleFonts.plusJakartaSans(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600)),
              ],
            )
          : Row(children: [
              // Tombol Simpan Draft
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleSave,
                  icon:  const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Simpan Draft'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Tombol Submit
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleSubmit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(_isLoading ? 'Menyimpan...' : 'Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize:     const Size(0, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ]),
    );
  }

  // ── Widget Helpers ─────────────────────────────────────────
  Widget _buildPropertyInfoCard() {
    return Container(
      padding:    const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient:     const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.home_work_rounded,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text('Info Properti',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          _infoRow('NOP',   widget.task.nop),
          _infoRow('Nama',  widget.task.namaWp),
          _infoRow('Alamat',widget.task.alamatOp),
          _infoRow('Status',
              widget.task.statusTask == 'completed' ? 'Selesai'
              : widget.task.statusTask == 'in_progress' ? 'Sedang Diproses'
              : 'Belum Dikerjakan'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text('$label',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          Text(': ', style: GoogleFonts.plusJakartaSans(
              fontSize: 12, color: AppColors.textSecondary)),
          Expanded(
            child: Text(value,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        Text(subtitle,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        const Divider(color: AppColors.border),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    bool isInt      = false,
  }) {
    return TextFormField(
      controller:   controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
      inputFormatters: [
        if (isInt)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      style: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText:  hint,
        hintStyle: GoogleFonts.plusJakartaSans(
            color: AppColors.textHint, fontSize: 13),
      ),
      validator: isRequired
          ? (v) {
              if (v == null || v.trim().isEmpty) {
                return '${label.replaceAll(' *', '')} wajib diisi';
              }
              if (double.tryParse(v) == null) return 'Masukkan angka yang valid';
              if (double.parse(v) < 0) return 'Nilai tidak boleh negatif';
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdown({
    required String?  value,
    required String   label,
    required List<String> items,
    required void Function(String?) onChanged,
    Map<String, String>? labels,
  }) {
    return DropdownButtonFormField<String>(
      value:    value,
      onChanged: onChanged,
      style: GoogleFonts.plusJakartaSans(
          fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label),
      hint: Text('Pilih $label',
          style: GoogleFonts.plusJakartaSans(
              color: AppColors.textHint, fontSize: 13)),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(labels?[item] ?? item,
            style: GoogleFonts.plusJakartaSans(fontSize: 14)),
      )).toList(),
    );
  }

  Widget _buildFasilitasGrid() {
    return Wrap(
      spacing:   10,
      runSpacing: 10,
      children: _fasilitasOptions.map((opt) {
        final isSelected = _selectedFasilitas.contains(opt.$1);
        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected) {
              _selectedFasilitas.remove(opt.$1);
            } else {
              _selectedFasilitas.add(opt.$1);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:  isSelected ? AppColors.primary : AppColors.border,
                width:  isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(opt.$3,
                    size:  16,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(opt.$2,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize:   13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color:      isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBanner(String msg, Color textColor, Color bgColor, IconData icon) {
    return Container(
      padding:    const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: textColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(msg,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: textColor)),
        ),
      ]),
    );
  }
}