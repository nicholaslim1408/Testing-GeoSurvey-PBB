import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraPreviewScreen extends StatefulWidget {
  const CameraPreviewScreen({super.key});

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isReady = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera([int cameraIndex = 0]) async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada kamera yang tersedia.')),
          );
          Navigator.pop(context);
        }
        return;
      }

      // Pastikan index valid
      if (cameraIndex >= _cameras.length) {
        cameraIndex = 0;
      }
      _selectedCameraIndex = cameraIndex;

      _controller = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka kamera: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return; // Tidak ada kamera lain
    
    setState(() => _isReady = false);
    await _controller?.dispose();
    
    // Toggle index
    int newIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initCamera(newIndex);
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile photo = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full Camera Preview
          Center(
            child: CameraPreview(_controller!),
          ),
          
          // 2. Dark Overlay for 1:1 Square Ratio
          CustomPaint(
            painter: _SquareOverlayPainter(),
          ),
          
          // Tombol Kembali
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Tombol Jepret
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: _takePicture,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Tombol Putar Kamera (Switch Camera)
          if (_cameras.length > 1)
            Positioned(
              bottom: 55,
              right: 30,
              child: IconButton(
                icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 36),
                onPressed: _switchCamera,
              ),
            ),
          
          // Panduan
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Arahkan kamera ke bangunan',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter untuk overlay gelap di atas & bawah area 1:1
class _SquareOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.62);

    // Kita buat ukuran cutout 1:1 (persegi) selebar layar
    final cutoutSize = size.width;
    final cy = size.height / 2;
    
    final top = cy - (cutoutSize / 2);
    final bottom = cy + (cutoutSize / 2);

    // Gambar area gelap di atas dan di bawah kotak persegi
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, top), paint); // atas
    canvas.drawRect(Rect.fromLTRB(0, bottom, size.width, size.height), paint); // bawah
    
    // (Garis tepi / border kuning atau biru opsional)
    final borderPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    canvas.drawRect(Rect.fromLTRB(0, top, size.width, bottom), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
