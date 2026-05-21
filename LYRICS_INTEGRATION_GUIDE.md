# 🎵 Song Lyrics Feature - Implementation Guide

## Overview

This document provides a comprehensive guide for implementing the song lyrics feature into your existing audio player screens.

## Quick Start

### 1. Update Your Player Screen

Add the lyrics FAB button to your main player screen:

```dart
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_bloc.dart';
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_event.dart';
import 'package:mero_audio_player/features/lyrics/presentation/pages/lyrics_page.dart';
import 'package:mero_audio_player/features/lyrics/presentation/widgets/lyrics_fab_button.dart';

class MyPlayerScreen extends StatefulWidget {
  @override
  State<MyPlayerScreen> createState() => _MyPlayerScreenState();
}

class _MyPlayerScreenState extends State<MyPlayerScreen> {
  late AudioFile currentSong;
  late Duration songDuration;

  void _showLyrics() {
    // Fetch lyrics when user clicks the button
    context.read<LyricsBloc>().add(
      FetchLyricsEvent(
        title: currentSong.title ?? 'Unknown',
        artist: currentSong.artist ?? 'Unknown',
        duration: songDuration,
      ),
    );

    // Navigate to lyrics page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LyricsPage(
          songTitle: currentSong.title ?? 'Unknown',
          songArtist: currentSong.artist ?? 'Unknown',
          songDuration: songDuration,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Your existing player UI...
      floatingActionButton: LyricsFABButton(
        onPressed: _showLyrics,
        isLoading: false,
      ),
    );
  }
}
```

### 2. Sync Lyrics with Playback

To sync lyrics with the current playback position, add a listener to your audio service:

```dart
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_bloc.dart';
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_event.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  StreamSubscription? _positionSubscription;

  void _initPositionListener() {
    _positionSubscription = _audioHandler.playbackState.listen((state) {
      // Update lyrics with current position
      if (_lyricsBloc != null) {
        _lyricsBloc!.add(
          UpdatePositionEvent(state.position ?? Duration.zero),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
```

### 3. Bind LyricsBloc to Your BLoC

In your player screen, make sure to use `BlocListener` to sync lyrics:

```dart
BlocListener<AudioPlayerBloc, AudioPlayerState>(
  listener: (context, state) {
    if (state is AudioPlaying) {
      // Sync lyrics position
      context.read<LyricsBloc>().add(
        UpdatePositionEvent(state.currentPosition),
      );
    }
  },
  child: YourPlayerUI(),
)
```

## File Structure

```
lib/features/lyrics/
├── domain/
│   ├── entities/
│   │   ├── lyric_line.dart
│   │   └── lyrics.dart
│   ├── repositories/
│   │   └── lyrics_repository.dart
│   └── usecases/
│       └── fetch_lyrics.dart
├── data/
│   ├── datasources/
│   │   ├── lyrics_local_datasource.dart
│   │   └── lyrics_remote_datasource.dart
│   ├── models/
│   │   ├── lyric_line_model.dart
│   │   └── lyrics_model.dart
│   └── repositories/
│       └── lyrics_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── lyrics_bloc.dart
    │   ├── lyrics_event.dart
    │   └── lyrics_state.dart
    ├── pages/
    │   └── lyrics_page.dart
    └── widgets/
        ├── lyrics_fab_button.dart
        └── lyrics_view.dart
```

## API Integration

### Supported APIs

#### 1. Lyrics.ovh (Default)
- **URL**: `https://lyrics.ovh/v1/{artist}/{song}`
- **Format**: Plain text
- **Pros**: Free, no auth needed, CORS enabled
- **Cons**: Not all songs available

### Adding Custom API

To add another lyrics API, extend `LyricsRemoteDatasource`:

```dart
class CustomLyricsRemoteDatasource implements LyricsRemoteDatasource {
  final Dio dio;

  CustomLyricsRemoteDatasource(this.dio);

  @override
  Future<LyricsModel?> fetchLyrics({
    required String title,
    required String artist,
    required Duration duration,
  }) async {
    // Your custom implementation
  }
}
```

Update the DI container:

```dart
static void _initLyricsFeature() {
  // Use your custom datasource
  sl.registerSingleton<LyricsRemoteDatasource>(
    CustomLyricsRemoteDatasource(sl<Dio>()),
  );
}
```

## Caching Strategy

The lyrics feature implements a smart caching strategy:

```
1. User requests lyrics
   ↓
2. Check local cache (Hive)
   ├─ Found? Return cached lyrics
   └─ Not found? Continue
3. Check local files (.lrc, .txt)
   ├─ Found? Cache and return
   └─ Not found? Continue
4. Fetch from remote API
   ├─ Success? Cache and return
   └─ Fail? Return null (No lyrics state)
```

### Clear Cache

```dart
// Clear all cached lyrics
await sl<LyricsRepository>().clearCache();

// Delete specific lyrics
await sl<LyricsRepository>().deleteCachedLyrics(
  title: 'Song Title',
  artist: 'Artist Name',
);
```

## States and Events

### Events

- **FetchLyricsEvent**: Triggers lyrics fetch
  ```dart
  FetchLyricsEvent(
    title: 'Song Title',
    artist: 'Artist Name',
    duration: Duration(minutes: 3),
  )
  ```

- **UpdatePositionEvent**: Updates current position (for synced lyrics)
  ```dart
  UpdatePositionEvent(Duration(seconds: 30))
  ```

- **ClearLyricsEvent**: Clears current lyrics
  ```dart
  ClearLyricsEvent()
  ```

### States

- **LyricsInitial**: Initial state
- **LyricsLoading**: Fetching lyrics
- **LyricsLoaded**: Lyrics successfully loaded
- **LyricsNotFound**: No lyrics available
- **LyricsError**: Error occurred

## Error Handling

The feature gracefully handles errors:

```dart
BlocBuilder<LyricsBloc, LyricsState>(
  builder: (context, state) {
    if (state is LyricsError) {
      return Column(
        children: [
          Icon(Icons.error),
          Text('Error: ${state.message}'),
          ElevatedButton(
            onPressed: () {
              // Retry fetching
              context.read<LyricsBloc>().add(
                FetchLyricsEvent(...),
              );
            },
            child: Text('Retry'),
          ),
        ],
      );
    }
    // Handle other states...
  },
)
```

## Testing

### Unit Tests

```dart
test('FetchLyrics returns lyrics when successful', () async {
  // Arrange
  const testTitle = 'Test Song';
  const testArtist = 'Test Artist';
  const testDuration = Duration(minutes: 3);

  // Act
  final result = await fetchLyricsUsecase(
    title: testTitle,
    artist: testArtist,
    duration: testDuration,
  );

  // Assert
  expect(result.isRight(), true);
  final lyrics = result.getOrElse(() => null);
  expect(lyrics, isNotNull);
});
```

### BLoC Tests

```dart
test('emit LyricsLoaded when fetch is successful', () async {
  // Arrange
  final testLyrics = Lyrics(
    title: 'Test',
    artist: 'Test',
    lines: [LyricLine(text: 'Test lyric')],
    duration: Duration(minutes: 3),
  );

  whenListen(
    mockFetchLyrics,
    Stream.value(Right(testLyrics)),
  );

  // Act & Assert
  expect(
    lyricsBloc.stream,
    emits(LyricsLoaded(lyrics: testLyrics)),
  );
});
```

## Performance Tips

1. **Cache aggressively**: Lyrics are cached after first fetch
2. **Lazy load**: Fetch lyrics only when user clicks the button
3. **Timeout handling**: Set reasonable timeout values (10 seconds default)
4. **Pagination**: For very long lyrics, consider pagination

## Troubleshooting

### No lyrics found for available songs
- **Cause**: Lyrics API doesn't have the song
- **Solution**: Add support for multiple APIs or allow manual upload

### Performance issues with long lyrics
- **Cause**: Large list rendering
- **Solution**: Implement pagination or virtualization

### Synced lyrics not updating
- **Cause**: Position listener not connected
- **Solution**: Ensure `UpdatePositionEvent` is called on position change

## Future Enhancements

- [ ] LRC file format support
- [ ] Genius.com API integration
- [ ] Manual lyrics editing
- [ ] Crowd-sourced lyrics
- [ ] Lyrics search
- [ ] Multiple language display
- [ ] Lyrics translation

## Dependencies

- `flutter_bloc`: State management
- `dio`: HTTP client
- `hive_flutter`: Local caching
- `equatable`: Equality comparison
- `dartz`: Functional programming (Either)

## License

GPL-3.0 (Same as main project)
