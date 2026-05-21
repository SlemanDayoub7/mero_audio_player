# 🎵 Synced Lyrics with Playback - Implementation Guide

## Overview

This guide explains how to implement **real-time lyrics synchronization** with music playback in your Mero Audio Player.

## What is Synced Lyrics?

Synced lyrics automatically scroll and highlight the current lyric line based on the song's playback position. As the song plays, the lyrics stay in sync.

```
📊 Without Syncing:      📊 With Syncing:
- Static lyrics           - Lyrics scroll automatically
- Manual scrolling        - Current line highlighted
- Not interactive         - Interactive & engaging
```

---

## Architecture

### Position Flow

```
AudioPlayer (just_audio)
    ↓
positionStream (Duration)
    ↓
StreamBuilder in LyricsPage
    ↓
UpdatePositionEvent
    ↓
LyricsBloc
    ↓
LyricsLoaded State (currentLyricIndex updated)
    ↓
LyricsView (Auto-scroll to current line)
```

### Component Responsibilities

| Component | Responsibility |
|-----------|----------------|
| `AudioPlayer` | Emits position stream |
| `StreamBuilder` | Listens to position changes |
| `LyricsBloc` | Updates current lyric index |
| `LyricsView` | Scrolls to highlight lyric |
| `SyncedLyricsPage` | Coordinates everything |

---

## Implementation

### Step 1: Use SyncedLyricsPage

Replace regular `LyricsPage` with `SyncedLyricsPage` in your player:

```dart
// OLD (No syncing)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LyricsPage(...),
  ),
);

// NEW (With syncing)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SyncedLyricsPage(...),
  ),
);
```

### Step 2: Update Main Screen

Update `lib/main_screen.dart` to use synced lyrics:

```dart
void _showLyrics() {
  // ... get current song ...
  
  // OLD
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => LyricsPage(...),
  ));
  
  // NEW
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => SyncedLyricsPage(...),
  ));
}
```

### Step 3: Add Lyrics Button to Full Player (Optional)

Add lyrics button to your full player page:

```dart
import 'package:mero_audio_player/features/lyrics/presentation/pages/lyrics_player_integration.dart';

// In full player build:
LyricsPlayerButton(
  onPressed: () {
    // Fetch and show synced lyrics
    context.read<LyricsBloc>().add(
      FetchLyricsEvent(
        title: currentSong.title,
        artist: currentSong.artist,
        duration: currentSong.duration,
      ),
    );
    
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SyncedLyricsPage(...),
    ));
  },
)
```

---

## How Syncing Works

### 1. Position Stream Listener

```dart
// In SyncedLyricsPage
StreamBuilder<Duration>(
  stream: player.positionStream,  // Emits every 200ms
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      // Tell LyricsBloc about new position
      context.read<LyricsBloc>().add(
        UpdatePositionEvent(snapshot.data!),
      );
    }
    return SizedBox.shrink();
  },
)
```

### 2. LyricsBloc Updates Index

```dart
// In LyricsBloc
on<UpdatePositionEvent>((event, emit) async {
  if (state is LyricsLoaded) {
    final loadedState = state as LyricsLoaded;
    
    // Find which lyric line matches current position
    final newIndex = loadedState.lyrics
        .getCurrentLyricIndex(event.position);
    
    // Emit new state with updated index
    if (newIndex != loadedState.currentLyricIndex) {
      emit(loadedState.copyWith(currentLyricIndex: newIndex));
    }
  }
});
```

### 3. LyricsView Auto-Scrolls

```dart
// In LyricsView
void _updateScroll() {
  if (widget.lyrics.isSynced && widget.currentLyricIndex != null) {
    final targetIndex = widget.currentLyricIndex!;
    final scrollOffset = (targetIndex * 60) - 200;  // Center lyric
    
    _scrollController.animateTo(
      scrollOffset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
```

---

## Features

✅ **Real-time Sync** - Updates every 200ms
✅ **Smooth Scrolling** - Animated scroll to current line
✅ **Highlight Current** - Bold/white text for current lyric
✅ **Offline Support** - Works with cached lyrics
✅ **Error Handling** - Graceful fallback states
✅ **Responsive** - Works on all screen sizes

---

## Lyrics with Timestamps

For synced lyrics to work best, you need lyrics with **timestamps** (LRC format):

```
[00:12.00] First line of lyrics
[00:17.20] Second line of lyrics
[00:22.15] Third line of lyrics
```

The API (`lyrics.ovh`) returns plain text lyrics without timestamps, but you can:

1. **Extend the API** to use Genius API (has synced lyrics)
2. **Manual upload** LRC files with timestamps
3. **Generate timestamps** from timing analysis

---

## API Comparison

| API | Synced | Speed | Auth | Coverage |
|-----|--------|-------|------|----------|
| Lyrics.ovh | ❌ | Fast | None | Good |
| Genius | ✅ | Slow | Yes | Excellent |
| MusixMatch | ✅ | Good | Yes | Excellent |
| LRC | ✅ | Fast | No | Depends |

---

## Troubleshooting

### Lyrics not syncing

**Problem**: Lyrics display but don't scroll

**Solutions**:
1. Check if lyrics have timestamps (`isSynced == true`)
2. Verify `UpdatePositionEvent` is being sent
3. Check `getCurrentLyricIndex()` logic
4. Test with a synced lyrics source (Genius API)

### Scrolling too fast/slow

**Problem**: Scroll animation feels choppy or slow

**Solutions**:
1. Adjust scroll offset calculation
2. Change animation duration (currently 500ms)
3. Modify item height estimate (currently 60px)

### Position not updating

**Problem**: `UpdatePositionEvent` not being sent

**Solutions**:
1. Verify `positionStream` is active
2. Check `StreamBuilder` is in widget tree
3. Ensure player is actually playing
4. Check for stream subscription issues

---

## Performance Tips

1. **Throttle Updates**: Don't update on every position change
   ```dart
   // Only update every 200ms
   final shouldUpdate = snapshot.data!.inMilliseconds % 200 == 0;
   ```

2. **Lazy Load Lyrics**: Fetch only when user opens lyrics page

3. **Cache Aggressively**: Reuse cached lyrics when possible

4. **Optimize Scroll**: Use `shrinkWrap: true` in ListView for better performance

---

## File Structure

```
lib/features/lyrics/presentation/pages/
├── lyrics_page.dart                           # Basic lyrics (no sync)
├── synced_lyrics_page.dart                    # Synced lyrics ⭐ NEW
├── lyrics_player_integration.dart            # Helper widgets/mixins
└── main_screen_with_synced_lyrics.dart       # Reference implementation
```

---

## Next Steps

1. ✅ Replace `LyricsPage` with `SyncedLyricsPage` in your app
2. 🧪 Test with popular songs
3. 🎨 Customize styling (highlight colors, fonts)
4. 📊 Add synced lyrics API (Genius, MusixMatch)
5. 💾 Store user preferences (auto-sync on/off)

---

## Example Usage

```dart
// In your player page
void _openLyrics() {
  final audioBloc = context.read<AudioPlayerBloc>();
  final song = audioBloc.state.current;
  
  context.read<LyricsBloc>().add(
    FetchLyricsEvent(
      title: song.title,
      artist: song.artist,
      duration: Duration(milliseconds: song.duration ?? 0),
    ),
  );
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SyncedLyricsPage(
        songTitle: song.title,
        songArtist: song.artist,
        songDuration: Duration(milliseconds: song.duration ?? 0),
      ),
    ),
  );
}
```

---

## Branch Info

**Branch**: `feature/song-lyrics`
**New Files**: 
- `synced_lyrics_page.dart` - Synced lyrics implementation
- `lyrics_player_integration.dart` - Helper components
- `main_screen_with_synced_lyrics.dart` - Reference implementation

