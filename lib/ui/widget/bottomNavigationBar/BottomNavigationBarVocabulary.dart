import 'package:flutter/material.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/ui/theme/appColors.dart';

class BottomNavigationBarVocabulary extends StatelessWidget implements PreferredSizeWidget {
  final int itemSelected;
  final String id;

  const BottomNavigationBarVocabulary({super.key,  required this.itemSelected,required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
          color: Colors.black54,
          blurRadius: 5.0,
          offset: Offset(0.0, 0.75)
        )
      ],
    ),
    child:BottomNavigationBar(
          backgroundColor: AppColors.cardBackground,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          iconSize: 40,
          type: BottomNavigationBarType.fixed, // Change to fixed for better control
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Colors.black54),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          items: <BottomNavigationBarItem>[
            _buildBottomNavigationBarItem(Icons.school_rounded, context.loc.apprendre_title, 0),
            _buildBottomNavigationBarItem(Icons.quiz_rounded, context.loc.tester_title, 1),
            _buildBottomNavigationBarItem(Icons.visibility, context.loc.liste_title, 2),
            _buildBottomNavigationBarItem(Icons.playlist_play_outlined, context.loc.dictation_title, 3),
            _buildBottomNavigationBarItem(Icons.bar_chart, context.loc.statistiques_title, 4),
          ],
          currentIndex: itemSelected, // Set the initial selected index
          onTap: (value) {
            switch (value) {
              case 0:
                Navigator.pushReplacementNamed(context, '/vocabulary/learn/$id');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/vocabulary/quizz/$id');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/vocabulary/list/$id');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/vocabulary/voicedictation/$id');
                break;
              case 4:
                Navigator.pushReplacementNamed(context, '/vocabulary/statistical/$id');
                break;
            }
          },
        )
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          color: index == itemSelected ? Colors.green : Colors.white, // Change index to currentIndex
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(4.0), // Add padding for the background
        child: Icon(icon),
      ),
      label: label,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);


}
