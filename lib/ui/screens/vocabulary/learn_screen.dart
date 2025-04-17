import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';
import 'package:flip_card/flip_card.dart';
import 'package:vobzilla/ui/theme/appColors.dart';
import '../../../core/utils/PlaySoond.dart';
import '../../../core/utils/enum.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';

class LearnScreen extends StatefulWidget {
  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  late double screenWidth;
  int numItemVocabulary = 0;
  late AnimationController _controller;
  late int durationAnimationFlipCard = 500;
  late int durationAnimationFlipCardStock = durationAnimationFlipCard;
  late int durationChangeContentCard=250;


  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    // _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);

    _controller.forward(from: 0).then((_) {

    });
    _scaleAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is VocabulairesLoaded) {
          final List<dynamic> data = state.data["vocabulaireList"] as List<dynamic>;
          if (data.isEmpty) {
            return Center(child: Text("Aucun élément de vocabulaire trouvé"));
          }
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 5),
                    child: Text(
                      context.loc.learn_view_carte,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                        //..rotateY(_animation.value)
                          ..scale(_scaleAnimation.value),
                        child: FlipCard(
                          speed: durationAnimationFlipCardStock,
                          key: cardKey,
                          flipOnTouch: true,
                          front: Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: AppColors.cardBackground,
                            elevation: 8.0,
                            child: Container(
                              width: screenWidth * 0.8,
                              height: screenWidth * 0.8,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${data[numItemVocabulary][LanguageUtils()
                                        .getSmallCodeLanguage(
                                        context: context)]}",
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          back: Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: AppColors.cardBackground,
                            elevation: 8.0,
                            child: Container(
                              width: screenWidth * 0.8,
                              height: screenWidth * 0.8,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${data[numItemVocabulary]['EN']}",
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  PlaySoond(
                                    stringVocabulaire: data[numItemVocabulary]['GUID'],
                                    buttonColor: Colors.green,
                                    sizeButton: 70,
                                  ).buttonPlay(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Visibility(
                              visible: numItemVocabulary != 0,
                              child: FloatingActionButton(
                                heroTag: UniqueKey(),
                                onPressed: () async {
                                  learnBack();
                                },
                                child: const Icon(Icons.navigate_before),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 25.0,
                              left: (numItemVocabulary + 1 == 1 ? 55 : 0),
                              right: (numItemVocabulary + 1 == data.length
                                  ? 55
                                  : 0),
                            ),
                            child: Text(
                                '${numItemVocabulary + 1}/${data.length}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Visibility(
                              visible: numItemVocabulary + 1 <= data.length - 1,
                              child: FloatingActionButton(
                                heroTag: UniqueKey(),
                                onPressed: () {
                                  learnNext();
                                },
                                child: const Icon(Icons.navigate_next),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else if (state is VocabulairesError) {
          return Center(child: Text("Erreur de chargement"));
        } else {
          return Center(child: Text("État inconnu")); // fallback
        }
      },
    );
  }





  learnNext()  {
    animationNextBack(animationType: AnimationType.next);
  }

  void learnBack() {
    animationNextBack(animationType: AnimationType.back);
  }

  animationNextBack({required AnimationType animationType}) {
    if (cardKey.currentState!.isFront) {
      updateDurationAnimation(newDuration: 0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateDurationAnimation(newDuration: durationAnimationFlipCard);
      });
      Future.delayed(
        Duration(milliseconds: durationChangeContentCard), () {
        setState(() {
          if(animationType == AnimationType.next){
            numItemVocabulary++;
          }
          if(animationType == AnimationType.back){
            numItemVocabulary--;
          }
        });
      },
      );
    }
    else{
      updateDurationAnimation(newDuration: durationAnimationFlipCard);
      Future.delayed(
        Duration(milliseconds: durationChangeContentCard), () {
        setState(() {
          if(animationType == AnimationType.next){
            numItemVocabulary++;
          }
          if(animationType == AnimationType.back){
            numItemVocabulary--;
          }
        });
      },
      );
    }
  }

  void updateDurationAnimation({required int newDuration})  {
    //print("je suis dans le updateDurationAnimation : $newDuration");
    setState(() {
      // print("e suis dans le setstate : $newDuration");
      durationAnimationFlipCardStock = newDuration;
      _controller.duration = Duration(milliseconds: durationAnimationFlipCardStock);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // print("je suis dans le callback : $durationAnimationFlipCardStock new duration : $newDuration");
        cardKey.currentState!.toggleCard();
        _controller.forward(from: 0).then((_) {
        });
      });
    });
  }

}
