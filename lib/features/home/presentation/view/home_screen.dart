import 'package:flutter/material.dart';
import 'package:osox/features/home/presentation/view/widgets/home_header.dart';
import 'package:osox/features/home/presentation/view/widgets/stories_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      appBar: HomeHeader(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StoriesSection(),
            // Post feed will go here
          ],
        ),
      ),
    );
  }
}
