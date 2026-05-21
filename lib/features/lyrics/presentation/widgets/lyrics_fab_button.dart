import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Floating Action Button for lyrics display
class LyricsFABButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const LyricsFABButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: Colors.white,
      elevation: 4,
      child: isLoading
          ? SizedBox(
              width: 24.sp,
              height: 24.sp,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : Icon(
              Icons.lyrics,
              color: Colors.black,
              size: 24.sp,
            ),
    );
  }
}
