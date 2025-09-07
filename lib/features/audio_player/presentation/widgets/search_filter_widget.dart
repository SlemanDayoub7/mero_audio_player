import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchFilterWidget extends StatelessWidget {
  const SearchFilterWidget({Key? key}) : super(key: key);

  final List<String> _dateOptions = const [
    'Any',
    'Last 24 hours',
    'Last week',
    'Last month',
  ];
  final List<String> _durationOptions = const [
    'Any',
    '< 10 min',
    '10-30 min',
    '> 30 min',
  ];
  final List<String> _nameOptions = const ['Any', 'A-Z', 'Z-A'];

  Widget _buildDropdown(
    BuildContext context,
    String label,
    List<String> options,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          DropdownButtonFormField<String>(
            value: options.first,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            ),
            items:
                options
                    .map(
                      (opt) => DropdownMenuItem(value: opt, child: Text(opt)),
                    )
                    .toList(),
            onChanged: null, // No logic here
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Enter keywords',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            ),
            enabled: false, // Disabled, no logic
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildDropdown(context, 'Date', _dateOptions),
              SizedBox(width: 12.w),
              _buildDropdown(context, 'Duration', _durationOptions),
              SizedBox(width: 12.w),
              _buildDropdown(context, 'Name', _nameOptions),
            ],
          ),
        ],
      ),
    );
  }
}
