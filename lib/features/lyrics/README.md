# 🎵 Lyrics Feature

Complete song lyrics display system for Mero Audio Player with support for:
- **Online lyrics fetching** from Lyrics.ovh API
- **Offline caching** using Hive database
- **Synced lyrics** with automatic scrolling based on playback position
- **Plain text lyrics** display with clean UI

## Architecture

Follows Clean Architecture principles with three layers:

### Domain Layer
- **Entities**: `Lyrics`, `LyricLine`
- **Repositories**: Abstract `LyricsRepository`
- **Usecases**: `FetchLyrics`

### Data Layer
- **Datasources**:
  - `LyricsLocalDatasource`: Hive-based local caching
  - `LyricsRemoteDatasource`: Lyrics.ovh API integration
- **Models**: `LyricsModel`, `LyricLineModel`
- **Repository**: `LyricsRepositoryImpl`

### Presentation Layer
- **BLoC**: `LyricsBloc` for state management
- **Events**: `FetchLyricsEvent`, `UpdatePositionEvent`, `ClearLyricsEvent`
- **States**: `LyricsLoading`, `LyricsLoaded`, `LyricsNotFound`, `LyricsError`
- **UI**: `LyricsPage`, `LyricsView`, `LyricsFABButton`

## Usage

### Fetch Lyrics
```dart
context.read<LyricsBloc>().add(
  FetchLyricsEvent(
    title: 'Song Title',
    artist: 'Artist Name',
    duration: Duration(minutes: 3),
  ),
);
```

### Update Position (for synced lyrics)
```dart
context.read<LyricsBloc>().add(
  UpdatePositionEvent(Duration(seconds: 30)),
);
```

### Open Lyrics Page
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LyricsPage(
      songTitle: 'Song Title',
      songArtist: 'Artist Name',
      songDuration: Duration(minutes: 3),
    ),
  ),
);
```

## Features

✅ **Smart Caching**: Lyrics are cached after first fetch
✅ **Fallback Strategy**: Local → Cache → Remote API
✅ **Synced Lyrics**: Smooth scrolling with playback position
✅ **Error Handling**: Graceful fallback UI states
✅ **Offline Support**: Works without internet after caching
✅ **Responsive Design**: Adapts to all screen sizes

## Future Enhancements

- [ ] Support for .LRC file format
- [ ] Genius API integration
- [ ] Lyrics editing and manual upload
- [ ] Lyrics search and suggestion
- [ ] Night mode optimizations
- [ ] Multiple language support
