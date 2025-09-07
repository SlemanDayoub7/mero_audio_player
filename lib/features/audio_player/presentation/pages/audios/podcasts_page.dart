import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PodcastsPage extends StatelessWidget {
  final List<_Podcast> _podcasts = const [
    _Podcast(
      title: 'Tech Talk Today',
      subtitle: 'Latest technology trends and news',
      duration: '30 min',
    ),
    _Podcast(
      title: 'Health & Wellness',
      subtitle: 'Tips for living a healthy life',
      duration: '45 min',
    ),
    _Podcast(
      title: 'Business Insights',
      subtitle: 'Expert advice on startups and growth',
      duration: '50 min',
    ),
    _Podcast(
      title: 'Daily Motivation',
      subtitle: 'Boost your day with inspiration',
      duration: '15 min',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final iconColor = theme.iconTheme.color ?? Colors.blueGrey;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        itemCount: _podcasts.length,
        separatorBuilder:
            (_, __) => Divider(
              height: 1.h,
              color: theme.dividerColor.withOpacity(0.3),
            ),
        itemBuilder: (context, index) {
          final podcast = _podcasts[index];
          return Card(
            color: theme.cardColor,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            margin: EdgeInsets.symmetric(vertical: 8.h),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.h,
                horizontal: 16.w,
              ),
              title: Text(
                podcast.title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(podcast.subtitle, style: textTheme.bodyMedium),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill, color: iconColor, size: 36.w),

                  Text(podcast.duration, style: textTheme.bodySmall),
                ],
              ),
              onTap: () {
                // TODO: Implement podcast playback or details navigation
              },
            ),
          );
        },
      ),
    );
  }
}

class _Podcast {
  final String title;
  final String subtitle;
  final String duration;

  const _Podcast({
    required this.title,
    required this.subtitle,
    required this.duration,
  });
}
