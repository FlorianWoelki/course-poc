import 'package:course_poc/screens/sidebar_screen.dart';
import 'package:flutter/material.dart';

import '../components/home_screen_navbar.dart';
import '../components/lists/explore_course_list.dart';
import '../components/lists/recent_course_list.dart';
import '../constants.dart';
import 'continue_watching_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Animation<Offset> _sidebarAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _sidebarAnimationController;

  var _sidebarHidden = true;

  @override
  void initState() {
    super.initState();

    _sidebarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _sidebarAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _sidebarAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _sidebarAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _sidebarAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kBackgroundColor,
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HomeScreenNavBar(
                      triggerAnimation: () {
                        setState(() {
                          _sidebarHidden = !_sidebarHidden;
                        });
                        _sidebarAnimationController.forward();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("Recents", style: kLargeTitleStyle),
                          const SizedBox(height: 5.0),
                          Text("23 courses, more coming",
                              style: kSubtitleStyle),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const RecentCourseList(),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: 25.0,
                        bottom: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("Explore", style: kTitle1Style),
                        ],
                      ),
                    ),
                    const ExploreCourseList(),
                  ],
                ),
              ),
            ),
            const ContinueWatchingScreen(),
            IgnorePointer(
              ignoring: _sidebarHidden,
              child: Stack(
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: GestureDetector(
                      child: Container(
                        color: const Color.fromRGBO(36, 38, 41, 0.4),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      ),
                      onTap: () {
                        setState(() {
                          _sidebarHidden = !_sidebarHidden;
                        });
                        _sidebarAnimationController.reverse();
                      },
                    ),
                  ),
                  SlideTransition(
                    position: _sidebarAnimation,
                    child: const SafeArea(
                      child: SidebarScreen(),
                      bottom: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
