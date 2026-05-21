# Integration Summary: Lyrics FAB in Main Screen

## What Was Changed

### Updated Files

#### 1. `lib/main_screen.dart`

**Added imports:**
```dart
import 'package:mero_audio_player/features/audio_player/presentation/bloc/audio_player/audio_player_bloc.dart';
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_bloc.dart';
import 'package:mero_audio_player/features/lyrics/presentation/bloc/lyrics_event.dart';
import 'package:mero_audio_player/features/lyrics/presentation/pages/lyrics_page.dart';
import 'package:mero_audio_player/features/lyrics/presentation/widgets/lyrics_fab_button.dart';
```

**Added method:**
```dart
/// Show lyrics for the currently playing song
void _showLyrics() {
  final audioPlayerBloc = context.read<AudioPlayerBloc>();
  final currentSong = audioPlayerBloc.state.current;

  if (currentSong == null) {
    // Show snackbar if no song is playing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No song is currently playing'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // Fetch lyrics for the current song
  context.read<LyricsBloc>().add(
    FetchLyricsEvent(
      title: currentSong.title,
      artist: currentSong.artistOrUnknown,
      duration: Duration(milliseconds: currentSong.duration ?? 0),
    ),
  );

  // Navigate to lyrics page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LyricsPage(
        songTitle: currentSong.title,
        songArtist: currentSong.artistOrUnknown,
        songDuration: Duration(milliseconds: currentSong.duration ?? 0),
      ),
    ),
  );
}
```

**Added FAB widget:**
```dart
// In Scaffold build
floatingActionButton: LyricsFABButton(
  onPressed: _showLyrics,
  isLoading: false,
),
floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
```

## Key Features

✅ **Smart Detection**: Checks if a song is playing before showing lyrics
✅ **Error Handling**: Shows snackbar if no song is playing
✅ **Data Binding**: Gets current song info from AudioPlayerBloc
✅ **BLoC Integration**: Triggers LyricsBloc to fetch and manage lyrics
✅ **Navigation**: Seamless transition to full-screen lyrics page
✅ **Responsive**: Works with all screen sizes via FloatingActionButton

## User Flow

```
1. User sees main screen with music library
   ↓
2. User clicks lyrics FAB button (music note icon)
   ↓
3. App checks if a song is currently playing
   ├─ No song: Shows "No song is currently playing" message
   └─ Song playing:
      ↓
      Fetches lyrics via LyricsBloc
      ↓
      Opens full-screen lyrics page
      ↓
      User can read/scroll through lyrics
      ↓
      User taps close to return to main screen
```

## Technical Details

### BLoC Interaction

The implementation properly integrates with your existing BLoCs:

1. **AudioPlayerBloc**: Gets current song information
   - Song title
   - Artist name
   - Duration

2. **LyricsBloc**: Manages lyrics fetching and state
   - Triggers `FetchLyricsEvent` with song details
   - Handles loading, success, and error states

### Error Handling

Three error scenarios are handled:

1. **No song playing**
   - Displays user-friendly snackbar
   - Prevents unnecessary API calls

2. **Lyrics not found**
   - `LyricsNotFound` state in BLoC
   - Shows appropriate UI message in `LyricsPage`

3. **Network/API errors**
   - `LyricsError` state in BLoC
   - Shows error message with retry option

## Testing

To test the integration:

1. **No song playing**
   - Open the app
   - Click the lyrics FAB
   - Should see "No song is currently playing" snackbar

2. **With song playing**
   - Play a popular song (e.g., "Bohemian Rhapsody" by "Queen")
   - Click the lyrics FAB
   - Should fetch and display lyrics

3. **Unknown song**
   - Play a very obscure song
   - Click the lyrics FAB
   - Should show "No lyrics found" message

## Position Syncing (Optional Enhancement)

To sync lyrics with playback position, add this listener to the player widget:

```dart
StreamBuilder<Duration>(
  stream: player.positionStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      // Update lyrics position
      context.read<LyricsBloc>().add(
        UpdatePositionEvent(snapshot.data!),
      );
    }
    return SizedBox();
  },
)
```

## Next Steps

1. ✅ **Integration Complete** - FAB button is now in main screen
2. 📱 **Test with Real Songs** - Try different songs to test lyrics fetching
3. 🎨 **Customize Styling** - Adjust FAB appearance to match your theme
4. 📍 **Add Position Syncing** - Implement position listener for synced lyrics
5. 🔄 **Handle Edge Cases** - Test with various song types and unavailable lyrics

## Files Modified

- `lib/main_screen.dart` - Added lyrics FAB button and integration

## Commits

Branch: `feature/song-lyrics`
Commit: Integrates LyricsFAB into main player screen
