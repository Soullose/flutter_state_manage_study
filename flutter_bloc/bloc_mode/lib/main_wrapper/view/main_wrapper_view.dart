import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainWrapperView extends StatelessWidget {
  const MainWrapperView({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        // duration: const Duration(milliseconds: 300),
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            fillColor: Colors.transparent,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: navigationShell,
      ),
      // body: navigationShell,
      bottomNavigationBar:
          // GestureDetector(
          //   onTap: () {},
          //   onDoubleTap: () {},
          //   child:
          NavigationBar(
        onDestinationSelected: (int index) {
          navigationShell.goBranch(index);
        },
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.looks_one),
            icon: Icon(Icons.looks_one_outlined),
            label: 'One',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.looks_two),
            icon: Icon(Icons.looks_two_outlined),
            label: 'Two',
          ),
        ],
      ),
      //     BottomNavigationBar(
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Semantics(
      //         label: 'Navigate to screen one',
      //         child: const Icon(Icons.looks_one),
      //       ),
      //       label: 'One',
      //     ),
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.looks_two),
      //       label: 'Two',
      //     ),
      //   ],
      //   currentIndex: navigationShell.currentIndex,
      //   onTap: (int index) => navigationShell.goBranch(index),
      //   elevation: 10,
      //   selectedItemColor: Colors.blue,
      //   unselectedItemColor: Colors.grey,
      //   backgroundColor: Colors.white,
      // ),
      // ),
    );
  }
}
