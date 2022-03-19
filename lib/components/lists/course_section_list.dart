import 'package:course_poc/components/cards/course_section_card.dart';
import 'package:course_poc/constants.dart';
import 'package:course_poc/model/course.dart';
import 'package:flutter/material.dart';

class CourseSectionList extends StatelessWidget {
  const CourseSectionList({Key? key}) : super(key: key);

  List<Widget> courseSectionsWidgets() {
    List<Widget> cards = [];

    for (var course in courseSections) {
      cards.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: CourseSectionCard(course: course),
        ),
      );
    }

    cards.add(
      Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Text(
          "No more Sections to view, look\nfor more in our courses",
          style: kCaptionLabelStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: courseSectionsWidgets(),
      ),
    );
  }
}
