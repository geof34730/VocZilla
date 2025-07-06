import 'package:flutter/material.dart';
import 'package:vobzilla/ui/theme/appColors.dart';
import 'package:google_fonts/google_fonts.dart';
class FeatureGraphic extends StatelessWidget {
  const FeatureGraphic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width:1024,
      height:500,
      color: const Color(0xFF7DECF7),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Logo and title
          Row(
            children: [
              Image.asset(
                'assets/brand/logo.png', // Mets ici ton logo
                width: 200,
              ),
            ],
          ),
          // Headline
          Text(
            'Améliorez votre vocabulaire anglais',
              style: TextStyle(
                fontFamily: GoogleFonts.titanOne().fontFamily,
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
          ),

          // Features
         /* FeatureItem(
            icon: Icons.check_circle,
            text: '5,600 words',
          ),
          const SizedBox(height: 12),
          FeatureItem(
            icon: Icons.quiz,
            text: 'Quizzes & audio tests',
          ),
          const SizedBox(height: 12),
          FeatureItem(
            icon: Icons.show_chart,
            text: 'Progress tracking',
          ),
          const SizedBox(height: 12),
          FeatureItem(
            icon: Icons.list_alt,
            text: 'Shared & custom lists',
          ),*/
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
