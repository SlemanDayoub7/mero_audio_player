import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/search_filter_widget.dart';

class AudioBooksPage extends StatelessWidget {
  final List<_AudioBook> _audioBooks = const [
    _AudioBook(title: 'Flutter Mastery', author: 'John Doe', duration: '7 hrs'),
    _AudioBook(
      title: 'Dart Essentials',
      author: 'Jane Smith',
      duration: '5 hrs 30 mins',
    ),
    _AudioBook(
      title: 'Effective UI Design',
      author: 'Emily Johnson',
      duration: '6 hrs 15 mins',
    ),
    _AudioBook(
      title: 'Mobile Development in Depth',
      author: 'Michael Green',
      duration: '8 hrs 10 mins',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final iconColor = theme.iconTheme.color ?? Colors.blueGrey;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            SearchFilterWidget(),
            Expanded(
              child: ListView.separated(
                itemCount: _audioBooks.length,
                separatorBuilder:
                    (_, __) => Divider(
                      height: 1.h,
                      color: theme.dividerColor.withOpacity(0.3),
                    ),
                itemBuilder: (context, index) {
                  final book = _audioBooks[index];
                  return Card(
                    color: theme.cardColor,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      leading: Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.headset,
                          color: iconColor.withOpacity(0.75),
                          size: 30.w,
                        ),
                      ),
                      title: Text(
                        book.title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(book.author, style: textTheme.bodyMedium),
                      trailing: Text(
                        book.duration,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall!.color!.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                      onTap: () {
                        // Navigate to detailed audio book player page or show controls (to implement)
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioBook {
  final String title;
  final String author;
  final String duration;

  const _AudioBook({
    required this.title,
    required this.author,
    required this.duration,
  });
}
