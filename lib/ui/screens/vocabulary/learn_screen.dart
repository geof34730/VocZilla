import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';
import 'package:flip_card/flip_card.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';


class LearnScreen extends StatelessWidget {
  LearnScreen();

  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  @override
  Widget build(BuildContext context) {
    var currentLocale = BlocProvider.of<LocalizationCubit>(context).state;
    return BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is VocabulairesLoaded) {
          final data = state.data["vocabulaireList"];
          print("data: $data");

          return SingleChildScrollView(
            child:  Center(child:FlipCard(
              key: cardKey,
              flipOnTouch: true,
              front: Container(
                width:400,
                height:400,
                color: Colors.red,
                child: ElevatedButton(
                  onPressed: () => cardKey.currentState!.toggleCard(),
                  child: Text('Toggle'),
                ),
              ),
              back: Container(
                width:400,
                height:400,
                color: Colors.green,
                child: ElevatedButton(
                  onPressed: () => cardKey.currentState!.toggleCard(),
                  child: Text('Toggle'),
                ),
              ),
            ))
            /*
            Column(
              children: (data as List?)?.map<Widget>((vocabulaire) {
                return Text("${vocabulaire['EN']} : ${vocabulaire['FR']}");
              }).toList() ?? [Text("No vocabulary items found")],
            ),*/
          );
        } else if (state is VocabulairesError) {
          return Center(child: Text("Erreur de chargement"));
        } else {
          return Center(child: Text("État inconnu")); // fallback
        }
      },
    );
  }
}
