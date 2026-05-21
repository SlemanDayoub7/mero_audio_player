import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/lyrics.dart';

/// Widget to display lyrics with smooth scrolling for synced lyrics
class LyricsView extends StatefulWidget {
  final Lyrics lyrics;
  final int? currentLyricIndex;
  final ScrollController scrollController;

  const LyricsView({
    Key? key,
    required this.lyrics,
    this.currentLyricIndex,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController;
    _updateScroll();
  }

  @override
  void didUpdateWidget(LyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLyricIndex != widget.currentLyricIndex) {
      _updateScroll();
    }
  }

  /// Update scroll position to current lyric
  void _updateScroll() {
    if (widget.lyrics.isSynced && widget.currentLyricIndex != null) {
      final targetIndex = widget.currentLyricIndex!;
      final itemHeight = 60.0; // Approximate height of each lyric line
      final scrollOffset = (targetIndex * itemHeight) - (200.h); // Center the lyric

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    // Don't dispose the passed controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
          ],
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        itemCount: widget.lyrics.lines.length,
        itemBuilder: (context, index) {
          final line = widget.lyrics.lines[index];
          final isCurrentLine = widget.currentLyricIndex == index;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Text(
              line.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isCurrentLine ? 18.sp : 14.sp,
                fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.normal,
                color: isCurrentLine ? Colors.white : Colors.grey[400],
                height: 1.5,
              ),
            ),
          );
        },
      ),
    );
  }
}
