# ==== FFmpegKit Rules ====

# Keep FFmpegKit classes
-keep class com.antonkarpenko.** { *; }
-keep class com.arthenica.ffmpegkit.** { *; }

# Keep all enums
-keepclassmembers enum * { *; }

# Keep annotation types
-keep @interface * { *; }

# Preserve classes with native methods (important for JNI_OnLoad)
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep public FFmpegKit API
-keep public class com.antonkarpenko.ffmpegkit.FFmpegKitConfig { *; }
-keep public class com.antonkarpenko.ffmpegkit.FFmpegKit { *; }

# Optional: keep your main app classes intact
-keep class com.example.mero_audio_player.** { *; }
