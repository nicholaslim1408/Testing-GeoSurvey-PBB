// lib/screens/register_screen.dart
// ============================================================
// Halaman Register - Form pendaftaran enumerator baru
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey          = GlobalKey<FormState>();
  final _fullNameCtrl     = TextEditingController();
  final _usernameCtrl     = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _passwordCtrl     = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();

  bool _isLoading         = false;
  bool _obscurePassword   = true;
  bool _obscureConfirm    = true;
  String? _errorMessage;
  bool _registerSuccess   = false;

  late AnimationController _animController;
  late Animation<double>    _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Password strength checker ────────────────────────────
  bool get _passwordValid {
    final p = _passwordCtrl.text;
    return p.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(p) &&
        RegExp(r'[a-z]').hasMatch(p) &&
        RegExp(r'\d').hasMatch(p)    &&
        RegExp(r'[@$!%*?&_\-#]').hasMatch(p);
  }

  // ── Handler Register ─────────────────────────────────────
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    final result = await AuthService.register(
      username: _usernameCtrl.text,
      email:    _emailCtrl.text,
      password: _passwordCtrl.text,
      fullName: _fullNameCtrl.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      setState(() => _registerSuccess = true);
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation:       0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 64 : 24,
            vertical:   16,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _registerSuccess
                  ? _buildSuccessState()
                  : _buildRegisterForm(),
            ),
          ),
        ),
      ),
    );
  }

  // ── Success State ─────────────────────────────────────────
  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding:    const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:        AppColors.accent.withOpacity(0.1),
            shape:        BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: AppColors.accent, size: 64),
        ),
        const SizedBox(height: 24),
        Text(
          'Pendaftaran Berhasil!',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Akun kamu sudah terdaftar dan sedang menunggu\npersetujuan dari admin.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15, color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Kembali ke Login',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15, fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Register Form ─────────────────────────────────────────
  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Buat Akun Baru',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Daftarkan diri kamu sebagai enumerator GeoSurvey PBB',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14, color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),

        // Error banner
        if (_errorMessage != null) ...[
          _buildErrorBanner(_errorMessage!),
          const SizedBox(height: 16),
        ],

        // Form
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Lengkap
              _buildTextField(
                controller: _fullNameCtrl,
                label:      'Nama Lengkap',
                hint:       'Contoh: Budi Santoso',
                icon:       Icons.badge_outlined,
                validator:  (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama lengkap wajib diisi';
                  }
                  if (v.trim().length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Username
              _buildTextField(
                controller: _usernameCtrl,
                label:      'Username',
                hint:       'Contoh: budi_santoso',
                icon:       Icons.alternate_email_rounded,
                validator:  (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Username wajib diisi';
                  }
                  if (v.trim().length < 3) {
                    return 'Username minimal 3 karakter';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                    return 'Username hanya boleh huruf, angka, dan underscore';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Email
              _buildTextField(
                controller:  _emailCtrl,
                label:       'Email',
                hint:        'Contoh: budi@email.com',
                icon:        Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator:   (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email wajib diisi';
                  }
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Password
              _buildTextField(
                controller: _passwordCtrl,
                label:      'Password',
                hint:       'Min. 8 karakter',
                icon:       Icons.lock_outline_rounded,
                isPassword: true,
                obscure:    _obscurePassword,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                  if (!_passwordValid) {
                    return 'Password tidak memenuhi syarat';
                  }
                  return null;
                },
              ),

              // Password strength indicator
              if (_passwordCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildPasswordStrengthIndicator(),
              ],
              const SizedBox(height: 14),

              // Konfirmasi Password
              _buildTextField(
                controller: _confirmPassCtrl,
                label:      'Konfirmasi Password',
                hint:       'Ulangi password kamu',
                icon:       Icons.lock_outline_rounded,
                isPassword: true,
                obscure:    _obscureConfirm,
                onToggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Konfirmasi password wajib diisi';
                  }
                  if (v != _passwordCtrl.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Tombol Register
              SizedBox(
                width:  double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white,
                          ),
                        )
                      : Text(
                          'Daftar Sekarang',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15, fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Password requirement info
        _buildPasswordRequirements(),
      ],
    );
  }

  // ── Password Strength Indicator ───────────────────────────
  Widget _buildPasswordStrengthIndicator() {
    final p      = _passwordCtrl.text;
    int strength = 0;
    if (p.length >= 8)                         strength++;
    if (RegExp(r'[A-Z]').hasMatch(p))          strength++;
    if (RegExp(r'[a-z]').hasMatch(p))          strength++;
    if (RegExp(r'\d').hasMatch(p))             strength++;
    if (RegExp(r'[@$!%*?&_\-#]').hasMatch(p)) strength++;

    final labels = ['', 'Sangat Lemah', 'Lemah', 'Cukup', 'Kuat', 'Sangat Kuat'];
    final colors = [
      Colors.transparent,
      AppColors.error,
      Colors.orange,
      AppColors.warning,
      AppColors.accentLight,
      AppColors.accent,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) => Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
              decoration: BoxDecoration(
                color: i < strength
                    ? colors[strength]
                    : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        const SizedBox(height: 4),
        Text(
          strength > 0 ? labels[strength] : '',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: strength > 0 ? colors[strength] : Colors.transparent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Password Requirements ─────────────────────────────────
  Widget _buildPasswordRequirements() {
    final p = _passwordCtrl.text;
    final requirements = [
      ('Minimal 8 karakter',       p.length >= 8),
      ('Mengandung huruf besar',   RegExp(r'[A-Z]').hasMatch(p)),
      ('Mengandung huruf kecil',   RegExp(r'[a-z]').hasMatch(p)),
      ('Mengandung angka',         RegExp(r'\d').hasMatch(p)),
      ('Mengandung simbol (@\$!%*?&_-#)',
                                   RegExp(r'[@$!%*?&_\-#]').hasMatch(p)),
    ];

    return Container(
      padding:    const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Syarat Password:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...requirements.map((req) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  req.$2
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size:  14,
                  color: req.$2 ? AppColors.accent : AppColors.textHint,
                ),
                const SizedBox(width: 8),
                Text(
                  req.$1,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: req.$2
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ── Reusable TextField ─────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword             = false,
    bool obscure                = false,
    TextInputType? keyboardType,
    VoidCallback? onToggleObscure,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller:   controller,
      obscureText:  obscure,
      keyboardType: keyboardType,
      onChanged:    onChanged,
      validator:    validator,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14, color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText:  label,
        hintText:   hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size:  20,
                  color: AppColors.textSecondary,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
  }

  // ── Error Banner ──────────────────────────────────────────
  Widget _buildErrorBanner(String message) {
    return Container(
      padding:    const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.errorLight,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}