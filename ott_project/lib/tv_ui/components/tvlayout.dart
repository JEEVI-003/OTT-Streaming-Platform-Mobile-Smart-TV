import 'package:flutter/material.dart';

import 'package:ott_project/tv_ui/components/appbartv.dart';
import 'package:ott_project/tv_ui/components/TVsideNavigation.dart';

class TVLayout extends StatefulWidget {
  final Widget child;
  final Function(int) onSidebarSelected;
  final int selectedIndex;

  const TVLayout({
    Key? key,
    required this.child,
    required this.onSidebarSelected,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  _TVLayoutState createState() => _TVLayoutState();
}

class _TVLayoutState extends State<TVLayout> {
  @override
  Widget build(BuildContext context) {
    // FIX: TVAppBar must be a real Scaffold.appBar — NOT a Positioned widget.
    //
    // OLD (broken): Stack → Positioned → TVAppBar
    //   The AppBar had no height constraints from the Scaffold, so any widget
    //   inside it with flex (Expanded, Column with flex children, ListView,
    //   AppBar.bottom: PreferredSize) received UNBOUNDED height → caused the
    //   cascade of "RenderFlex unbounded height" + "Cannot hit test render box
    //   with no size" assertion failures on every frame.
    //
    // NEW (fixed): Scaffold.appBar = TVAppBar()
    //   The Scaffold correctly measures the AppBar's preferredSize, reserves
    //   that space, and offsets the body below it. extendBodyBehindAppBar:true
    //   keeps the gradient visible behind the transparent AppBar.
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TVAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF070708), // Dark grayish black at 0%
              Color(0xFF1D1B53), // Deep blue at 100%
            ],
          ),
        ),
        child: Row(
          children: [
            TVSideNavigationBar(
              onSidebarSelected: widget.onSidebarSelected,
              selectedIndex: widget.selectedIndex,
            ),
            Expanded(
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}