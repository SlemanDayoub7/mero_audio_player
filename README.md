# Mero Audio Player
<img width="824" height="300" alt="cover" src="https://github.com/user-attachments/assets/cdb420a9-24d6-4d38-9c69-cb7cd58a4dbb" />

Your ultimate offline music companion — designed for speed, simplicity, and full control of your listening experience.

https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
https://img.shields.io/badge/State%2520Management-BLoC-5FB0C8?style=for-the-badge

A showcase of advanced Flutter development, clean architecture, and native Android integration.

</div>
📱 Screenshots

Player Screen	Playlists	Equalizer	Themes
![Screenshot_٢٠٢٥-١٠-٠٣-٢٢-١٠-٥٢-٤٢٥_com example mero_audio_player](https://github.com/user-attachments/assets/524d16f6-177a-47d6-bccc-75839dab427b)
![Screenshot_٢٠٢٥-١٠-٠٣-٢٢-٠٣-٤٩-٠٠٢_com example mero_audio_player](https://github.com/user-attachments/assets/37e60bf9-ec28-40bc-a492-c04e4df95b25)

🚀 Features
🎵 Core Experience
Offline-First Music Library: Instantly play all your local audio files — no internet required.

Smart Organization: Browse your music by songs, artists, albums, or folders.

Advanced Playback: Create smart playlists and mark your favorite songs for quick access.

Background Playback: Seamless listening with full notification controls and song artwork on the lock screen.

🛠️ Powerful Tools
Built-in Equalizer: Fine-tune your music with a powerful multi-band equalizer.

Audio Trimmer & Ringtone Set: Cut any part of a song and set it as your phone's ringtone directly from the app.

Global Search & Sort: Find music quickly with search and sort by title, artist, album, duration, size, or date added.

🎨 Customization
Visual Appeal: Beautiful, adaptive themes and custom wallpapers to personalize the player's look and feel.

Internationalization: Support for 40+ languages, providing a native experience for users worldwide.

🏗️ Technical Architecture
This project is built to demonstrate professional, scalable Flutter development practices.

Clean Architecture & State Management
🔄 BLoC Pattern: The app uses flutter_bloc for predictable, testable, and manageable state management. All events and states are built with equatable for efficient comparison.

🧩 Clean Architecture: The codebase is structured into distinct layers (Presentation, Domain, Data) to ensure separation of concerns, testability, and maintainability.

💉 Dependency Injection: get_it is used for managing dependencies in a clean and decoupled manner.

Persistence & Data
🗄️ Local Database: Hive is used for fast, lightweight local storage (e.g., favorites, playlists, app settings).

📁 File & Path Handling: path_provider and media_store_plus are used for robust access to the device's file system and media library.

Audio Engine
🎧 Core Playback: Powered by just_audio and audio_service for robust, background-capable audio playback that integrates with the system.

🔊 Advanced Audio Features:

equalizer_flutter for system-level equalizer controls.

just_audio_background for configuring the Android notification.

on_audio_query to efficiently fetch metadata from the device's media store.

🎼 Audio Manipulation: Custom Method Channels are implemented to access native Android code for audio trimming and interacting with system settings.

UI/UX
📐 Responsive Design: flutter_screenutil is used to create a consistent UI across different screen sizes and densities.

🎭 Rich Animations: lottie for smooth, beautiful animations.

🖼️ Vector Graphics: flutter_svg for crisp, scalable icons and graphics.

📜 Scrolling Text: marquee for long song titles that scroll automatically.

📱 Native Feel: cupertino_icons and Material Design are used to provide a familiar experience.

Other Key Plugins
permission_handler: Manages runtime permissions gracefully.

share_plus: Allows sharing songs and app content.

ringtone_set_plus: Handles the system-level process of setting a ringtone.

easy_localization: Manages the 40+ language supports efficiently.

url_launcher: For opening links (e.g., privacy policy).

📁 Project Structure (Clean Architecture)
text
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── usecases/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── audio_player/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── music_library/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── equalizer/
│   ├── ringtone_cutter/
│   └── settings/
└── injection_container.dart
🔧 Installation & Setup
Prerequisites
Flutter SDK (version 3.0 or higher)

Android Studio / VS Code

An Android device/emulator with SDK 21+

Steps
Clone the repository

bash
git clone https://github.com/your-username/mero_audio_player.git
cd mero_audio_player
Get dependencies

bash
flutter pub get
Generate necessary files
(Run these commands if you have code generation set up for Hive or flutter_gen)

bash
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter gen-l10n # If you're using ARB files for localization
Run the app

bash
flutter run
🛠️ Building for Release
To build an APK for distribution:

bash
flutter build apk --release
🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

📄 License
This project is licensed under the MIT License.

👨‍💻 Developer
Sleman Dayoub

GitHub: @your-username

LinkedIn: Your LinkedIn Profile
![Screenshot_٢٠٢٥-١٠-٠٤-١٤-٠٥-٣٥-٦٢١_com example mero_audio_player](https://github.com/user-attachments/assets/fa2a986f-a960-40a6-8866-d1edf7de44ff)

Portfolio: Your Portfolio Website![Screenshot_٢٠٢٥-١٠-٠٣-٢٢-١٨-٢٧-٩٤٤_com example mero_audio_player](https://github.com/user-attachments/assets/2f8300ad-04e1-4104-acc6-ab5d245e9b56)


<div align="center">![Screenshot_٢٠٢٥-١٠-٠٣-٢٢-١٦-٠٢-٤٥٩_com example mero_audio_player](https://github.com/user-attachments/assets/f5879ae1-6db5-46a0-9af8-fc22913fb1ff)

⭐ If you found this project helpful or impressive, don't forget to give it a star!
</div>

