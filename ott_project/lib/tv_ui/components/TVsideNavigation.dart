import 'package:flutter/material.dart';

import '../FocusManager/focus_manager.dart';

/// TV Sidebar Navigation Bar
///
/// FIX: Converted from StatelessWidget to StatefulWidget so it can call
/// setState() when the D-pad focus moves between sidebar items.
/// Previously, because FocusManagerService stores state in static fields,
/// the sidebar never repainted after key events — the highlight appeared
/// stuck or missing entirely.
///
/// The parent (TVLayout / home screen) passes an [onSidebarSelected] callback
/// and calls its own setState() when a page-level selection changes; the
/// sidebar calls setState() for intra-sidebar highlight updates.
class TVSideNavigationBar extends StatefulWidget {
  final Function(int) onSidebarSelected;
  final int selectedIndex;

  const TVSideNavigationBar({
    Key? key,
    required this.onSidebarSelected,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  State<TVSideNavigationBar> createState() => _TVSideNavigationBarState();
}

class _TVSideNavigationBarState extends State<TVSideNavigationBar> {
  // White focus border — consistent with movie-page focus style
  static const Color _focusBorderColor = Colors.white;
  static const Color _activeColor = Color.fromARGB(255, 143, 228, 0);

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_filled, title: 'Home'),
    _NavItem(icon: Icons.movie, title: 'Movies'),
    _NavItem(icon: Icons.music_note_rounded, title: 'Music'),
    _NavItem(icon: Icons.favorite_outlined, title: 'LikedMusic'),
    _NavItem(icon: Icons.queue_music_sharp, title: 'Playlist'),
    _NavItem(icon: Icons.subscriptions_rounded, title: 'Watchlist'),
    _NavItem(icon: Icons.account_circle_outlined, title: 'Account'),
  ];

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    FocusManagerService.globalFocusNode.addListener(_refresh);
  }

  @override
  void dispose() {
    FocusManagerService.globalFocusNode.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width * 0.09,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _navItems.length,
          itemBuilder: (context, index) {
            final bool isFocused =
                FocusManagerService.focusedSidebarIndex == index &&
                    FocusManagerService.isSidebarFocused;
            final bool isSelected =
                FocusManagerService.selectedSidebarIndex == index;

            // Priority: focused > selected > default
            final Color itemColor = isFocused
                ? _activeColor
                : isSelected
                    ? _activeColor
                    : Colors.white;

            final double iconSize = isSelected ? 30 : 25;
            final double fontSize = isSelected ? 15 : 10;
            final FontWeight fontWeight =
                isSelected ? FontWeight.bold : FontWeight.normal;

            return GestureDetector(
              onTap: () {
                FocusManagerService.focusedSidebarIndex = index;
                setState(() {});
                widget.onSidebarSelected(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(
                    vertical: 3, horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isFocused
                      ? _activeColor.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  // FIX: White focus border — visible, consistent with movie-page style
                  border: isFocused
                      ? Border.all(
                          color: _focusBorderColor,
                          width: 2.0,
                        )
                      : Border.all(color: Colors.transparent, width: 2.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: isFocused ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _navItems[index].icon,
                        color: itemColor,
                        size: iconSize,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _navItems[index].title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: itemColor,
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String title;
  const _NavItem({required this.icon, required this.title});
}