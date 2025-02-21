import 'package:flutter/material.dart';


class HomeLogoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      body:Center(
        child:Column(
          children: [
            Text("Booste ton anglais avec VocZilla !"),
            Text("Tu veux enrichir ton vocabulaire anglais facilement et efficacement ? 📚💡 Avec VocZilla, accède à 5 600 mots essentiels, triés par fréquence d'utilisation pour apprendre les mots qui comptent vraiment. 🚀"),
            Text("📈 Méthode rapide et efficace"),
            Text("🎯 Apprends les mots les plus utiles en priorité"),
            Text("🧠 Mémorisation optimisée pour progresser vite"),
            Text("Prêt à dominer la langue de Shakespeare ? Inscris-toi maintenant et commence ton aventure linguistique ! 🔥👇"),
            ElevatedButton(
                onPressed: (){

                },
                child: Text("Get Started")
            )
          ]
        )
      ),
    );
  }
}
