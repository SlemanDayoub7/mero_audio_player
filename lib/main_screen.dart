import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/audios/audios_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/pages/audios/search_page.dart';
import 'package:mero_audio_player/features/audio_player/presentation/widgets/current_audio_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static final List<Widget> _pages = [
    const AudiosPage(),
    const SearchPage(),
    const SizedBox.shrink(),
  ];

  static final List<_NavItem> _navItems = [
    _NavItem(Icons.music_note, 'Audios'),
    _NavItem(Icons.book, 'Books'),
    _NavItem(Icons.podcasts, 'Podcasts'),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).primaryColor;
    final unselectedColor = Theme.of(context).disabledColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(_navItems[_currentIndex].label),
        centerTitle: true,
        actions: const [],
      ),
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _pages),
          const Align(
            alignment: Alignment.bottomCenter,
            child: CurrentAudioWidget(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items:
            _navItems
                .map(
                  (navItem) => BottomNavigationBarItem(
                    icon: Icon(navItem.icon, size: 24.sp),
                    label: navItem.label,
                  ),
                )
                .toList(),
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        onTap: _onTabTapped,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 11.sp),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}
