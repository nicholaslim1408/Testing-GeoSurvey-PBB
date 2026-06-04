// lib/screens/login_screen.dart
// ============================================================
// Halaman Login - UI modern sesuai color scheme SRS
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _formKey          = GlobalKey<FormState>();
  final _usernameCtrl     = TextEditingController();
  final _passwordCtrl     = TextEditingController();

  // State
  bool _isLoading         = false;
  bool _obscurePassword   = true;
  String? _errorMessage;

  // Animasi
  late AnimationController _animController;
  late Animation<double>    _fadeAnim;
  late Animation<Offset>    _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Handler Login ─────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });

    final result = await AuthService.login(
      username: _usernameCtrl.text,
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) { 
      // Navigasi ke Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800; // Layout lebar untuk web

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // ── Panel Kiri (hanya tampil jika layar lebar) ────
          if (isWide) _buildLeftPanel(size),

          // ── Panel Kanan: Form Login ───────────────────────
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 64 : 24,
                  vertical:   32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildLoginForm(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Left Panel (Branding) ─────────────────────────────────
  Widget _buildLeftPanel(Size size) {
    return Container(
      width: size.width * 0.45,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo / Ikon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.map_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 32),

            // Judul
            Text(
              'GeoSurvey\nPBB',
              style: GoogleFonts.plusJakartaSans(
                fontSize:   48,
                fontWeight: FontWeight.w800,
                color:      Colors.white,
                height:     1.1,
              ),
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              'Sistem Pendataan Properti\nPajak Bumi dan Bangunan',
              style: GoogleFonts.plusJakartaSans(
                fontSize:   16,
                fontWeight: FontWeight.w400,
                color:      Colors.white.withOpacity(0.85),
                height:     1.6,
              ),
            ),
            const SizedBox(height: 48),

            // Feature list
            ...[
              ('📸', 'Foto bangunan 4 sisi'),
              ('📍', 'GPS Auto-tagging'),
              ('📋', 'Formulir digital'),
              ('🛰️', 'Citra satelit'),
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(item.$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Text(
                    item.$2,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ── Login Form ────────────────────────────────────────────
  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Selamat Datang',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 30, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Masuk ke akun enumerator kamu',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15, color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 36),

        // Error banner
        if (_errorMessage != null) ...[
          _buildErrorBanner(_errorMessage!),
          const SizedBox(height: 16),
        ],

        // Form
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Username
              _buildTextField(
                controller:  _usernameCtrl,
                label:       'Username atau Email',
                hint:        'Masukkan username atau email',
                icon:        Icons.person_outline_rounded,
                validator:   (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Username atau email wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              _buildTextField(
                controller:   _passwordCtrl,
                label:        'Password',
                hint:         'Masukkan password',
                icon:         Icons.lock_outline_rounded,
                isPassword:   true,
                obscure:      _obscurePassword,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Tombol Login
              SizedBox(
                width:  double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
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
                          width:  22, height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white,
                          ),
                        )
                      : Text(
                          'Masuk',
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

        // Link ke Register
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Belum punya akun? ',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary, fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: Text(
                'Daftar Sekarang',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontSize:   14,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Info admin approval
        Container(
          padding:     const EdgeInsets.all(14),
          decoration:  BoxDecoration(
            color:        AppColors.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border:       Border.all(
              color: AppColors.warning.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Akun baru memerlukan persetujuan admin sebelum bisa login.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Reusable TextField ─────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure    = false,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller:     controller,
      obscureText:    obscure,
      validator:      validator,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14, color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText:   label,
        hintText:    hint,
        prefixIcon:  Icon(icon, size: 20, color: AppColors.textSecondary),
        suffixIcon:  isPassword
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