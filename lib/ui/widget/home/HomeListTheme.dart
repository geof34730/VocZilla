import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/app_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voczilla/core/utils/localization.dart';

import '../../../core/utils/languageUtils.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/ui.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../../logic/cubit/localization_cubit.dart';
import 'CarHomeListThemes.dart';
import 'CardHome.dart';


class HomelistThemes extends StatelessWidget {
  final String view;
  final bool allListView;

  const HomelistThemes({
    super.key,
    this.view = "home",
    this.allListView = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
        builder: (context, state) {
          if (state is VocabulaireUserLoading) {
            return Center(child: CircularProgressIndicator());
          } else if( state is VocabulaireUserUpdate){
            return Center(child: CircularProgressIndicator());
          } else if (state is VocabulaireUserLoaded  ) {


             return HorizontalScrollViewCardHome(
               itemWidth: itemWidthListPerso(context: context, nbList: 3),
               children: getListThemes(
                 withCarhome: 340,
                 context: context,
                 data: state.data,
                 view: view,
                 allListView: allListView,
               ),
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
