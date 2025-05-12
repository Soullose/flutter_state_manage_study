import 'package:animations/animations.dart';
import 'package:bloc_mode/main_wrapper/main_wrapper_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MainWrapperView extends StatelessWidget {
  const MainWrapperView(
      {required this.navigationShell,
        // required this.children,
        Key? key})
      : super(key: key ?? const ValueKey<String>('MainWrapperView'));

  final StatefulNavigationShell navigationShell;
  // final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final indexPage = context.read<MainWrapperBloc>().state.indexPage;
    if (kDebugMode) {
      print('$indexPage');
    }
    final mainWrapperBloc = context.read<MainWrapperBloc>();
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 1500),
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
      // body: Stack(
      //   children: children.map((Widget navigator) {
      //     return PageTransitionSwitcher(transitionBuilder: (
      //       Widget child,
      //       Animation<double> animation,
      //       Animation<double> secondaryAnimation,
      //     ) {
      //       return FadeScaleTransition(
      //         key: navigator.key,
      //         animation: animation,
      //         child: navigator,
      //       );
      //     });
      //   }).toList(),
      // ),
      bottomNavigationBar:
          // GestureDetector(
          //   onTap: () {},
          //   onDoubleTap: () {},
          //   child:
          NavigationBar(
        animationDuration: const Duration(milliseconds: 500),
        onDestinationSelected: (int index) {
          mainWrapperBloc.add(ChangeIndexPage(index));
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
