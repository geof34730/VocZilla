import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/device.dart';
import 'package:vobzilla/core/utils/localization.dart';

import '../../../core/utils/languageUtils.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/ui.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../../logic/cubit/localization_cubit.dart';
import 'CardClassementGamer.dart';
import 'CardClassementUser.dart';
import 'CardHome.dart';
import 'TitleWidget.dart';


class HomeClassement extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
        builder: (context, state) {
          if (state is VocabulaireUserLoading) {
            return Center(child: CircularProgressIndicator());
          } else if( state is VocabulaireUserUpdate){
            return Center(child: CircularProgressIndicator());
          } else if (state is VocabulaireUserLoaded  ) {
            final VocabulaireUser data = state.data;
            //final bool listePerso = data.listTheme.length>0;
            return Column(
              children: [
                LayoutBuilder(builder: (context, constraints) {
                      final double spacing = 8.0;
                      final int crossAxisCount = isTablet(context) ? 2 : 1;
                      final double cardWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
                      final List<Widget> gamerCards = List.generate(4, (index) {
                        return SizedBox(
                          width: cardWidth,
                          child: index != 3 ? CardClassementGamer(position: index + 1) : CardClassementUser(),
                        );
                      });
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: gamerCards,
                      );
                    }
                  )
              ],
            );
          } else if (state is VocabulaireUserError) {
            return Center(child: Text(context.loc.error_loading));
          } else {
            return Center(child: Text(context.loc.unknown_error)); // fallback
          }
        }
    );
  }



}
