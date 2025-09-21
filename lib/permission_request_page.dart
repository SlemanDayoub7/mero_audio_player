import 'package:flutter/material.dart';
import 'package:mero_audio_player/main_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'injection.dart'; // ملف Injection اللي عندك

class PermissionRequestPage extends StatefulWidget {
  const PermissionRequestPage({super.key});

  @override
  State<PermissionRequestPage> createState() => _PermissionRequestPageState();
}

class _PermissionRequestPageState extends State<PermissionRequestPage> {
  bool _isRequesting = false;

  Future<void> _requestStoragePermission() async {
    setState(() => _isRequesting = true);

    var status = await Permission.storage.request();

    if (status.isGranted) {
      // صلاحيات منحت → init Injection

      // اذهب للصفحة الرئيسية بعد تهيئة كل شيء
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    } else {
      // رفض → اغلق التطبيق
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('الصلاحية مطلوبة'),
              content: const Text(
                'يجب منح الصلاحيات للوصول إلى الملفات للاستمرار في استخدام التطبيق.',
              ),
              actions: [
                TextButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: const Text('خروج'),
                ),
              ],
            ),
      );
    }

    setState(() => _isRequesting = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_special, size: 120, color: Colors.orangeAccent),
              const SizedBox(height: 40),
              const Text(
                'نحتاج إذنك للوصول للملفات',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'التطبيق يحتاج الوصول إلى ملفات الصوت لتشغيل قوائم التشغيل والكتب الصوتية.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRequesting ? null : _requestStoragePermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isRequesting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'منح الصلاحية',
                            style: TextStyle(fontSize: 18),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
