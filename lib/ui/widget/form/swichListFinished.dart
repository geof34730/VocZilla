import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/data/repository/vocabulaire_user_repository.dart';
import 'package:voczilla/ui/theme/appColors.dart';

import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart' hide VocabulaireUserUpdate;

class SwitchListFinished extends StatefulWidget {
  const SwitchListFinished({super.key});

  @override
  State<SwitchListFinished> createState() => _SwitchListFinishedState();
}

class _SwitchListFinishedState extends State<SwitchListFinished> {

  Future<bool> _checkListEndPresence() async {
    final bool isPresent = await VocabulaireUserRepository().isListEndPresent();
    return isPresent;
  }

  @override
  void initState() {
    super.initState();
    _checkListEndPresence();
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
      builder: (context, state) {
        if (state is VocabulaireUserLoaded) {
          // Ici, tu peux décider d'afficher ou non le switch selon les données de l'état
          // Par exemple, si tu veux l'afficher seulement s'il y a des listes terminées :
          // We need to handle this as a FutureBuilder since _checkListEndPresence is async
          return FutureBuilder<bool>(
            future: _checkListEndPresence(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              final bool isListEndPresent = snapshot.data ?? false;
              if (!isListEndPresent) return const SizedBox.shrink();
              return _SwitchControl(showFinished: state.data.allListView);
            },
          );

        }
        // Affiche un loader ou rien selon tes besoins
        if (state is VocabulaireUserLoading || state is VocabulaireUserUpdate) {
          return const Center(child: CircularProgressIndicator());
        }
        return SizedBox.shrink();
      },
    );
  }
}

class _SwitchControl extends StatefulWidget {
  final bool showFinished;
  const _SwitchControl({required this.showFinished});

  @override
  State<_SwitchControl> createState() => _SwitchControlState();
}

class _SwitchControlState extends State<_SwitchControl> {
  late bool _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.showFinished;
  }

  @override
  void didUpdateWidget(covariant _SwitchControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with BLoC state if it changes from an external source
    if (widget.showFinished != _currentValue) {
      setState(() {
        _currentValue = widget.showFinished;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            context.loc.hide_lists_finiched,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            activeTrackColor: AppColors.colorTextTitle,
            value: _currentValue,
            onChanged: (val) {
              setState(() {
                _currentValue = val;
              });
              final bloc = context.read<VocabulaireUserBloc>();
              final event = val ? FilterShowAllList(local: lang) : FilterHideListFinished(local: lang);
              bloc.add(event);
            },
          ),
        ),
      ],
    );
  }
}
