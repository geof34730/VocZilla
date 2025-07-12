import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/data/repository/auth_repository.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_event.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../backgroundBlueLinear.dart';
import '../../widget/elements/Loading.dart';
import '../../widget/form/CustomTextField.dart';

class ProfileUpdateScreen extends StatelessWidget {
  ProfileUpdateScreen({super.key});
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController =  TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    dynamic user;
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      user = authState.user;
    }
    return BackgroundBlueLinear(
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated && state.user!.displayName != null) {
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/",
                (Route<dynamic> route) => false,
              );
            }
          }
        },
        builder: (context, state) {
           return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(context.loc.profil_update_title,
                      style: TextStyle(
                          fontSize: 25,
                          fontFamily: GoogleFonts.titanOne().fontFamily)),
                ),
                CustomTextField(
                  controller: firstNameController,
                  labelText: context.loc.login_prenom,
                  hintText: context.loc.login_entrer_prenom,
                ),
                CustomTextField(
                  controller: lastNameController,
                  labelText: context.loc.login_nom,
                  hintText: context.loc.login_entrer_nom,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: WidgetStateProperty.all(5),
                    ),
                    onPressed: () async {
                     context.read<AuthBloc>().add(UpdateDisplayNameEvent('${firstNameController.text} ${lastNameController.text}'));
                    },
                    child: Text(context.loc.login_sinscrire),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
