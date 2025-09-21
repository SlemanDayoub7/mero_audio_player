import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/core/themes/text_styles.dart';

class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;
  const SearchField({
    super.key,
    required this.onChanged,
    required this.hintText,
    required this.controller,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged(query);
    });
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      margin: EdgeInsets.only(right: 8.w, left: 8.w),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),

      child: TextField(
        cursorColor: Colors.white,
        controller: widget.controller,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        style: TextStyles.titleMedium.copyWith(color: Colors.white),
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),

          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
          contentPadding: EdgeInsets.all(5.r),
          hintText: widget.hintText,
          hintStyle: TextStyles.titleMedium.copyWith(color: Colors.white),
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
