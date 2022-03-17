import 'package:flutter/material.dart';

import '../components/home_screen_navbar.dart';
import '../components/lists/explore_course_list.dart';
import '../components/lists/recent_course_list.dart';
import '../constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              const HomeScreenNavBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Recents", style: kLargeTitleStyle),
                    const SizedBox(height: 5.0),
                    Text("23 courses, more coming", style: kSubtitleStyle),
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
              ExploreCourseList(),
            ],
          ),
        ),
      ),
    );
  }
}
