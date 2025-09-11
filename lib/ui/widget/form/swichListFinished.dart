import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/data/repository/vocabulaire_user_repository.dart';
import 'package:voczilla/logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';

import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';

class SwitchListFinished extends StatefulWidget {
  const SwitchListFinished({super.key});

  @override
  State<SwitchListFinished> createState() => _SwitchListFinishedState();
}

class _SwitchListFinishedState extends State<SwitchListFinished> {
  // Default to true, will be updated from the repository.
  bool _showFinished = true;
  bool _isListEndPresent = false;

  @override
  void initState() {
    super.initState();
    _loadInitialFilterState();
    _checkListEndPresence();
  }

  void _loadInitialFilterState() async {
    if (context.read<VocabulaireUserBloc>().state is VocabulaireUserLoaded) {
      final bool showFinished = await VocabulaireUserRepository().isFilterAllList() ?? true;
      if (mounted) {
        setState(() {
          _showFinished = showFinished;
        });
      }
    }
  }

  void _checkListEndPresence() async {
    final bool isPresent = await VocabulaireUserRepository().isListEndPresent();
    if (mounted) {
      setState(() {
        _isListEndPresent = isPresent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String lang = Localizations.localeOf(context).languageCode;

    return _isListEndPresent ? Column(
      mainAxisSize: MainAxisSize.min, // ✅ taille naturelle, pas d'espace forcé
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
             "Afficher les listes terminées",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Transform.scale(
              scale: 0.75, // ajuste la taille du switch
              child: Switch(
                activeTrackColor: Colors.green,
                value: _showFinished,
                onChanged: (val) {
                  setState(() {
                    _showFinished = val;
                  });
                  final bloc = BlocProvider.of<VocabulaireUserBloc>(context);
                  val ? bloc.add(FilterShowAllList(local: lang)) : bloc.add(FilterHideListFinished(local: lang));
                },
              ),
            ),
          ],
        ),
      ],
    ) : Container();
  }
}
