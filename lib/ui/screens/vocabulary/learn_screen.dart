import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/ui/theme/appColors.dart';
import '../../../core/utils/PlaySoond.dart';
import '../../../core/utils/enum.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/vocabulaires_repository.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import 'package:flip_card/flip_card.dart';

import '../../widget/elements/LevelChart.dart';
import '../../widget/form/RadioChoiceVocabularyLearnedOrNot.dart';


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
  late bool visibilityBack = true;
  late String directionAnimation = "next";




  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: durationAnimationFlipCardStock),
      vsync: this,
    );
    _controller.forward(from: 0).then((_) {});
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut) // reverseCurve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _vocabulairesRepository=VocabulairesRepository(context:context);
    screenWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is VocabulairesLoaded) {
          final List<dynamic> data = state.data["vocabulaireList"] as List<dynamic>;
          bool isNotLearned = state.data["isVocabularyNotLearned"] as bool? ?? true;
          int _vocabulaireConnu = isNotLearned ? 0 : 1;
          return SingleChildScrollView(
            child: Center(
                child: Column(
                    children: [
                      RadioChoiceVocabularyLearnedOrNot(
                          state: state,
                          vocabulaireConnu: _vocabulaireConnu,
                          vocabulairesRepository: _vocabulairesRepository
                      ),
                      if (data.isEmpty)...[
                        _vocabulaireConnu==0 ?
                            Column(
                                children: [
                                  Padding(
                                      padding:EdgeInsets.only(top: 40),
                                      child:Text("✅ Bravo !!!",
                                        style: TextStyle(
                                            color:Colors.green,
                                            fontSize: 35,
                                            fontWeight: FontWeight.bold
                                        ),
                                      )
                                  ),
                                  Text("vous avez terminé d'apprendre cette Liste",
                                    style: TextStyle(
                                      color:Colors.green,
                                      fontSize: 20,

                                    ),

                                  )
                                ]
                            )
                            : Center(child: Text(context.loc.no_vocabulary_items_found)
                        )
                      ],
                      if (data.isNotEmpty)...[
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
                                child: GestureDetector(
                                  onHorizontalDragEnd: (details) {
                                    if (details.primaryVelocity != null) {
                                      if (details.primaryVelocity! < 0) {
                                        numItemVocabulary + 1 <= data.length - 1 ? learnNext():null;
                                      } else if (details.primaryVelocity! > 0) {
                                        numItemVocabulary != 0 ? learnBack() : null;
                                      }
                                    }
                                  },
                                  child:FlipCard(
                                    directionAnimation:directionAnimation,
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
                                                "${data[numItemVocabulary][LanguageUtils().getSmallCodeLanguage(context: context)]}",
                                                style: TextStyle(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )

                                    ),
                                    back: Material(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        color: AppColors.cardBackground,
                                        elevation: 8.0,
                                        child: (visibilityBack ?
                                        Container(
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
                                                guidVocabulaire: data[numItemVocabulary]['GUID'],
                                                buttonColor: Colors.green,
                                                sizeButton: 70,
                                              ).buttonPlay(),
                                            ],
                                          ),
                                        )
                                            :
                                        Container(
                                            width: screenWidth * 0.8,
                                            height: screenWidth * 0.8,
                                            child:Text('')
                                        )
                                        )
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
                            Container(
                              width: screenWidth * 0.8,
                              height: screenWidth * 0.8,
                              child: Row(
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
                                        child: const Icon(
                                          Icons.navigate_before,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 12.0,
                                      left: (numItemVocabulary + 1 == 1 ? 55 : 0),
                                      right: (numItemVocabulary + 1 == data.length ? 55 : 0),
                                    ),child:
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.swipe,
                                        color: Colors.black87,
                                        size: 35,
                                      ),
                                      Text(
                                        '${numItemVocabulary + 1}/${data.length}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17.0
                                        ),
                                      ),
                                    ],
                                  ),
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
                                        child: const Icon(
                                          Icons.navigate_next,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ]
                ],
              ),
            ),
          );
        } else if (state is VocabulairesError) {
          return Center(child: Text(context.loc.error_loading));
        } else {
          return Center(child: Text(context.loc.unknown_error));// fallback
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
      updateDurationAnimation(newDuration: 0,animationType: animationType);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateDurationAnimation(newDuration: durationAnimationFlipCard,animationType: animationType);
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
          Future.delayed(Duration(milliseconds: durationChangeContentCard), (){visibilityBack = true;});
        });
      },
      );
    }
    else{
      updateDurationAnimation(newDuration: durationAnimationFlipCard,animationType: animationType);
      Future.delayed(
        Duration(milliseconds: durationChangeContentCard), () {
        setState(() {
          if(animationType == AnimationType.next){
            numItemVocabulary++;
          }
          if(animationType == AnimationType.back){
            numItemVocabulary--;
          }
          Future.delayed(Duration(milliseconds: durationChangeContentCard), (){visibilityBack = true;});
        });
      },
      );
    }
  }

  void updateDurationAnimation({required int newDuration,required AnimationType animationType})  {
    //print("je suis dans le updateDurationAnimation : $newDuration");
    setState(() {
      // print("e suis dans le setstate : $newDuration");
      visibilityBack=false;
      // directionAnimation="back";
      durationAnimationFlipCardStock = newDuration;
      directionAnimation=(animationType == AnimationType.next) ? "next" : "back";
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
