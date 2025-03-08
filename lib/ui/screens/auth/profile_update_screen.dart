import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/data/repository/auth_repository.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../theme/backgroundBlueLinear.dart';
import '../../widget/form/CustomTextField.dart';

class ProfileUpdateScreen extends StatelessWidget {
  ProfileUpdateScreen({super.key});
  final TextEditingController firstNameController =
      TextEditingController(text: 'geogeo');
  final TextEditingController lastNameController =
      TextEditingController(text: 'la molossa');

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    dynamic user;
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      user = authState.user;
    }
    return BackgroundBlueLinear(
      context: context,
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
          if (state is AuthLoading) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            return Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text("Finaliser votre inscription",
                      style: TextStyle(
                          fontSize: 25,
                          fontFamily: GoogleFonts.titanOne().fontFamily)),
                ),
                CustomTextField(
                  controller: firstNameController,
                  labelText: 'Prénom',
                  hintText: 'Entrez votre prénom',
                ),
                CustomTextField(
                  controller: lastNameController,
                  labelText: 'Nom',
                  hintText: 'Entrez votre nom',
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: WidgetStateProperty.all(5),
                    ),
                    onPressed: () async {
                      AuthRepository().updateDisplayName(
                          authBloc: authBloc,
                          displayName:
                              '${firstNameController.text} ${lastNameController.text}');
                    },
                    child: Text("S'inscrire"),
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
