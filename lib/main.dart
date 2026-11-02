import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Palet warna tema "Purple Cloud".
class CloudColors {
  static const Color deep = Color(0xFF3B2373);
  static const Color primary = Color(0xFF7C5CE0);
  static const Color soft = Color(0xFFB9A4F5);
  static const Color mist = Color(0xFFEFE9FF);
  static const Color night = Color(0xFF1E1233);
}

/// Daftar kamera yang tersedia di perangkat.
List<CameraDescription> _cameras = <CameraDescription>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Gagal membaca daftar kamera: ${e.code} ${e.description}');
  }
  runApp(const PurpleCloudApp());
}

class PurpleCloudApp extends StatelessWidget {
  const PurpleCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: CloudColors.primary,
      brightness: Brightness.light,
    ).copyWith(primary: CloudColors.primary);

    return MaterialApp(
      title: 'Purple Cloud Camera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: CloudColors.mist,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          foregroundColor: CloudColors.deep,
          titleTextStyle: TextStyle(
            color: CloudColors.deep,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: CloudColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

/// Latar belakang gradasi ungu dengan awan-awan putih transparan.
class CloudBackground extends StatelessWidget {
  const CloudBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFD9CCFF), Color(0xFFEFE9FF), Colors.white],
        ),
      ),
      child: CustomPaint(painter: _CloudPainter(), child: child),
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    _cloud(canvas, Offset(size.width * 0.05, size.height * 0.10), 1.0, paint);
    _cloud(canvas, Offset(size.width * 0.60, size.height * 0.20), 0.8, paint);
    _cloud(canvas, Offset(size.width * 0.15, size.height * 0.78), 1.2, paint);
    _cloud(canvas, Offset(size.width * 0.65, size.height * 0.88), 0.9, paint);
  }

  void _cloud(Canvas canvas, Offset o, double s, Paint p) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(o.dx, o.dy + 20 * s, 120 * s, 36 * s),
        Radius.circular(18 * s),
      ),
      p,
    );
    canvas.drawCircle(Offset(o.dx + 38 * s, o.dy + 20 * s), 24 * s, p);
    canvas.drawCircle(Offset(o.dx + 72 * s, o.dy + 12 * s), 30 * s, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Halaman utama: menampilkan hasil foto dan tombol untuk membuka kamera.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _imagePath;

  Future<void> _openCamera() async {
    if (_cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamera tidak ditemukan pada perangkat ini.')),
      );
      return;
    }
    final String? path = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => CameraScreen(cameras: _cameras),
      ),
    );
    if (path != null && mounted) {
      setState(() => _imagePath = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CloudBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Purple Cloud Camera')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: <Widget>[
                Expanded(child: Center(child: _PreviewCard(path: _imagePath))),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _openCamera,
                  icon: const Icon(Icons.photo_camera_rounded),
                  label: Text(_imagePath == null ? 'Buka Kamera' : 'Ambil Foto Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(32),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: CloudColors.primary.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: path == null
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.cloud_rounded, size: 96, color: CloudColors.soft),
                    SizedBox(height: 12),
                    Text(
                      'Belum ada foto',
                      style: TextStyle(
                        color: CloudColors.deep,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tekan tombol di bawah untuk membuka kamera',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CloudColors.primary),
                    ),
                  ],
                ),
              )
            : Image.file(File(path!), fit: BoxFit.cover),
      ),
    );
  }
}

/// Halaman kamera: preview langsung, tombol shutter, dan ganti kamera.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initFuture;
  int _index = 0;
  bool _capturing = false;
  bool _paused = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFuture = _setup(_index);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? c = _controller;
    if (c == null || !c.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _paused = true;
      c.dispose();
      if (mounted) setState(() => _initFuture = null);
    } else if (state == AppLifecycleState.resumed && _paused) {
      _paused = false;
      if (mounted) {
        setState(() {
          _error = null;
          _initFuture = _setup(_index);
        });
      }
    }
  }

  Future<void> _setup(int index) async {
    final CameraController? previous = _controller;
    final CameraController controller = CameraController(
      widget.cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller = controller;
    await previous?.dispose();
    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _error = e.code == 'CameraAccessDenied'
          ? 'Izin kamera ditolak. Aktifkan izin kamera di pengaturan perangkat.'
          : 'Kamera gagal dibuka: ${e.description ?? e.code}';
    }
  }

  void _switchCamera() {
    if (widget.cameras.length < 2 || _capturing) return;
    _index = (_index + 1) % widget.cameras.length;
    setState(() {
      _error = null;
      _initFuture = _setup(_index);
    });
  }

  Future<void> _capture() async {
    final CameraController? c = _controller;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture || _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final XFile file = await c.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(file.path);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _capturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: ${e.description ?? e.code}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CloudColors.night,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: ColoredBox(
                    color: Colors.black,
                    child: FutureBuilder<void>(
                      future: _initFuture,
                      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                        final CameraController? c = _controller;
                        if (_error != null) {
                          return _Message(text: _error!);
                        }
                        if (snapshot.connectionState != ConnectionState.done ||
                            c == null ||
                            !c.value.isInitialized) {
                          return const Center(
                            child: CircularProgressIndicator(color: CloudColors.soft),
                          );
                        }
                        return Center(
                          child: AspectRatio(
                            aspectRatio: 1 / c.value.aspectRatio,
                            child: CameraPreview(c),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _RoundIconButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _ShutterButton(busy: _capturing, onTap: _capture),
                  widget.cameras.length > 1
                      ? _RoundIconButton(
                          icon: Icons.flip_camera_android_rounded,
                          onTap: _switchCamera,
                        )
                      : const SizedBox(width: 52, height: 52),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off_rounded, size: 64, color: CloudColors.soft),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[CloudColors.soft, CloudColors.primary],
            ),
          ),
          child: busy
              ? const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
