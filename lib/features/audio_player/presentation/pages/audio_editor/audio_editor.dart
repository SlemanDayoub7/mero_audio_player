import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioTrimPro extends StatefulWidget {
  final String? filePath;
  const AudioTrimPro({super.key, this.filePath});
  @override
  State<AudioTrimPro> createState() => _AudioTrimProState();
}

class _AudioTrimProState extends State<AudioTrimPro> {
  late final PlayerController _playerController;
  bool _loop = false;
  bool _ready = false;
  bool _isDraggingHandle = false;

  // استخدام ValueNotifier لتحسين الأداء
  final ValueNotifier<int> _currentMsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<double> _startFractionNotifier = ValueNotifier<double>(
    0.1,
  );
  final ValueNotifier<double> _endFractionNotifier = ValueNotifier<double>(0.9);

  int _totalMs = 1;

  // تحميل الإعدادات المحفوظة
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _startFractionNotifier.value = prefs.getDouble('startFraction') ?? 0.1;
      _endFractionNotifier.value = prefs.getDouble('endFraction') ?? 0.9;
      _loop = prefs.getBool('loop') ?? false;
    });
  }

  // حفظ الإعدادات
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('startFraction', _startFractionNotifier.value);
    prefs.setDouble('endFraction', _endFractionNotifier.value);
    prefs.setBool('loop', _loop);
  }

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    _loadSettings().then((_) => _initPlayer());
  }

  Future<void> _initPlayer() async {
    try {
      setState(() => _ready = false);

      await _playerController.preparePlayer(
        path: widget.filePath ?? '',
        shouldExtractWaveform: true,
        noOfSamples: 500, // زيادة العينات لدقة أفضل
      );

      final maxDur = await _playerController.getDuration(DurationType.max);
      setState(() => _totalMs = maxDur);

      _playerController.onCurrentDurationChanged.listen((currentMs) {
        if (!_isDraggingHandle) {
          _currentMsNotifier.value = currentMs;
        }

        final endMs = (_totalMs * _endFractionNotifier.value).round();
        if (currentMs >= endMs) {
          if (_loop) {
            final startMs = (_totalMs * _startFractionNotifier.value).round();
            _playerController.seekTo(startMs);
          } else {
            _playerController.pausePlayer();
            _isPlayingNotifier.value = false;
          }
        }
      });

      _playerController.onPlayerStateChanged.listen((state) {
        _isPlayingNotifier.value = state == PlayerState.playing;
      });

      setState(() => _ready = true);
    } catch (e) {
      debugPrint("خطأ في التحميل: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل الملف: ${e.toString()}')),
      );
    }
  }

  // ضبط الوقت بدقة
  void _adjustStartTime(int ms) {
    double newStart = (_startFractionNotifier.value + ms / _totalMs).clamp(
      0,
      _endFractionNotifier.value - 0.01,
    );
    _startFractionNotifier.value = newStart;
    _saveSettings();
  }

  void _adjustEndTime(int ms) {
    final newEnd = (_endFractionNotifier.value + ms / _totalMs).clamp(
      _startFractionNotifier.value + 0.01,
      1.0,
    );
    _endFractionNotifier.value = newEnd;
    _saveSettings();
  }

  @override
  void dispose() {
    _playerController.dispose();
    _currentMsNotifier.dispose();
    _isPlayingNotifier.dispose();
    _startFractionNotifier.dispose();
    _endFractionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Trim Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('تعليمات الاستخدام'),
                      content: const Text(
                        '• اسحب المقابض الخضراء والحمراء لتحديد بداية ونهاية المقطع\n• انقر على الموجة للانتقال إلى وقت محدد\n• استخدم الأزرار للتحكم الدقيق بالوقت',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('حسنًا'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body:
          !_ready
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  const SizedBox(height: 16),

                  // شريط التقدم للمقطع المحدد
                  ValueListenableBuilder<double>(
                    valueListenable: _startFractionNotifier,
                    builder: (context, startFraction, _) {
                      return ValueListenableBuilder<double>(
                        valueListenable: _endFractionNotifier,
                        builder: (context, endFraction, _) {
                          final startMs = (_totalMs * startFraction).round();
                          final endMs = (_totalMs * endFraction).round();

                          return ValueListenableBuilder<int>(
                            valueListenable: _currentMsNotifier,
                            builder: (context, currentMs, _) {
                              final progressValue =
                                  (currentMs - startMs) / (endMs - startMs);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: LinearProgressIndicator(
                                  value:
                                      progressValue.isNaN
                                          ? 0
                                          : progressValue.clamp(0, 1),
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // عرض الأوقات والمتبقي
                  ValueListenableBuilder<double>(
                    valueListenable: _startFractionNotifier,
                    builder: (context, startFraction, _) {
                      return ValueListenableBuilder<double>(
                        valueListenable: _endFractionNotifier,
                        builder: (context, endFraction, _) {
                          final startMs = (_totalMs * startFraction).round();
                          final endMs = (_totalMs * endFraction).round();

                          return ValueListenableBuilder<int>(
                            valueListenable: _currentMsNotifier,
                            builder: (context, currentMs, _) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    _fmt(startMs),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    _fmt(currentMs),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _fmt(endMs),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    "متبقي: ${_fmt(endMs - currentMs)}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // waveform مع مقابض التحكم
                  ValueListenableBuilder<double>(
                    valueListenable: _startFractionNotifier,
                    builder: (context, startFraction, _) {
                      return ValueListenableBuilder<double>(
                        valueListenable: _endFractionNotifier,
                        builder: (context, endFraction, _) {
                          final startMs = (_totalMs * startFraction).round();
                          final endMs = (_totalMs * endFraction).round();

                          return GestureDetector(
                            onTapDown: (details) {
                              final localX = details.localPosition.dx;
                              final frac = (localX / width).clamp(
                                startFraction,
                                endFraction,
                              );
                              final seekMs = (_totalMs * frac).round();
                              _playerController.seekTo(seekMs);
                              _currentMsNotifier.value = seekMs;
                              HapticFeedback.lightImpact();
                            },
                            child: Stack(
                              children: [
                                // Waveform
                                AudioFileWaveforms(
                                  playerController: _playerController,
                                  size: Size(width, 140),
                                  waveformType: WaveformType.fitWidth,
                                  playerWaveStyle: PlayerWaveStyle(
                                    scaleFactor: 100,
                                    fixedWaveColor: Colors.blue,
                                    liveWaveColor: Colors.grey,
                                    showSeekLine: false,
                                    scrollScale: 1.5,
                                  ),
                                ),

                                // خلفية المقطع المحدد
                                Positioned(
                                  left: width * startFraction,
                                  top: 0,
                                  child: Container(
                                    width:
                                        width * (endFraction - startFraction),
                                    height: 140,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.withOpacity(0.2),
                                          Colors.blue.withOpacity(0.1),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      border: Border.symmetric(
                                        vertical: BorderSide(
                                          color: Colors.blue,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Handle البداية
                                _buildHandle(
                                  width: width,
                                  fraction: startFraction,
                                  ms: startMs,
                                  color: Colors.green,
                                  onDragStart: () {
                                    _playerController.pausePlayer();
                                    _isDraggingHandle = true;
                                  },
                                  onDragEnd: () {
                                    _isDraggingHandle = false;
                                    _saveSettings();
                                  },
                                  onDragUpdate: (dx) {
                                    final newF = (startFraction + dx / width)
                                        .clamp(0.0, endFraction - 0.01);
                                    _startFractionNotifier.value = newF;
                                  },
                                ),

                                // Handle النهاية
                                _buildHandle(
                                  width: width,
                                  fraction: endFraction,
                                  ms: endMs,
                                  color: Colors.red,
                                  onDragStart: () {
                                    _playerController.pausePlayer();
                                    _isDraggingHandle = true;
                                  },
                                  onDragEnd: () {
                                    _isDraggingHandle = false;
                                    _saveSettings();
                                  },
                                  onDragUpdate: (dx) {
                                    final newF = (endFraction + dx / width)
                                        .clamp(startFraction + 0.01, 1.0);
                                    _endFractionNotifier.value = newF;
                                  },
                                ),

                                // المؤشر الحالي
                                ValueListenableBuilder<int>(
                                  valueListenable: _currentMsNotifier,
                                  builder: (context, currentMs, _) {
                                    return Positioned(
                                      left:
                                          width *
                                          (currentMs / _totalMs).clamp(
                                            startFraction,
                                            endFraction,
                                          ),
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 3,
                                        decoration: BoxDecoration(
                                          color: Colors.yellow,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // أزرار التحكم الدقيق بالوقت
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_5),
                        tooltip: "تراجع 5 ثواني",
                        onPressed: () => _adjustStartTime(-5000),
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_5),
                        tooltip: "تقديم 5 ثواني",
                        onPressed: () => _adjustEndTime(5000),
                      ),
                      IconButton(
                        icon: const Icon(Icons.abc),
                        tooltip: "تراجع 1 ثانية",
                        onPressed: () => _adjustStartTime(-1000),
                      ),
                      IconButton(
                        icon: const Icon(Icons.abc_outlined),
                        tooltip: "تقديم 1 ثانية",
                        onPressed: () => _adjustEndTime(1000),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // أزرار التحكم الرئيسية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: _isPlayingNotifier,
                        builder: (context, isPlaying, _) {
                          return ValueListenableBuilder<double>(
                            valueListenable: _startFractionNotifier,
                            builder: (context, startFraction, _) {
                              return ElevatedButton(
                                onPressed: () async {
                                  final startMs =
                                      (_totalMs * startFraction).round();
                                  await _playerController.seekTo(startMs);
                                  _playerController.startPlayer();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("تشغيل المقطع"),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(width: 12),

                      ValueListenableBuilder<bool>(
                        valueListenable: _isPlayingNotifier,
                        builder: (context, isPlaying, _) {
                          return ElevatedButton(
                            onPressed:
                                isPlaying
                                    ? () {
                                      _playerController.pausePlayer();
                                      _isPlayingNotifier.value = false;
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("إيقاف"),
                          );
                        },
                      ),

                      const SizedBox(width: 12),

                      ElevatedButton(
                        onPressed: () {
                          _startFractionNotifier.value = 0.0;
                          _endFractionNotifier.value = 1.0;
                          _saveSettings();
                        },
                        child: const Text("إعادة تعيين"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // خيار التكرار
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("تكرار", style: TextStyle(fontSize: 16)),
                      Switch(
                        value: _loop,
                        onChanged: (v) {
                          setState(() => _loop = v);
                          _saveSettings();
                        },
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildHandle({
    required double width,
    required double fraction,
    required int ms,
    required Color color,
    required VoidCallback onDragStart,
    required VoidCallback onDragEnd,
    required Function(double dx) onDragUpdate,
  }) {
    return Positioned(
      left: width * fraction - 15,
      top: 0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _fmt(ms),
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) {
              onDragStart();
              HapticFeedback.heavyImpact();
            },
            onHorizontalDragEnd: (_) => onDragEnd(),
            onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
            child: Container(
              width: 20,
              height: 140,
              color: color.withOpacity(0.7),
              child: Icon(Icons.drag_handle, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int ms) {
    final d = Duration(milliseconds: ms);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
