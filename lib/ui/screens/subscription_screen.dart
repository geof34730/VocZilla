import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';
import '../../core/utils/getFontForLanguage.dart';
import '../../core/utils/logger.dart';
import '../../data/repository/user_repository.dart';
import '../../global.dart';
import '../../logic/blocs/purchase/purchase_bloc.dart';
import '../../logic/blocs/purchase/purchase_state.dart';
import '../../logic/blocs/purchase/purchase_event.dart';
import '../../logic/blocs/user/user_bloc.dart';
import '../../logic/blocs/user/user_state.dart';

class SubscriptionScreen extends StatelessWidget {
  SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<PurchaseBloc>().add(LoadProducts());
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserFreeTrialPeriodEndAndNotSubscribed) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 0),
                      child: Text(
                        context.loc.freetrial_info1.replaceAll("\$daysFreeTrial", "$daysFreeTrial"),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                // Retournez un SizedBox vide pour les autres états
                return SizedBox();
            }
          ),
          Center(child:Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 0),
            child: Text(
              context.loc.freetrial_info2,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          )),
          BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, state) {
              if (state is ProductsLoaded) {
                final sortedProducts = List.from(state.products)
                  ..sort((a, b) => a.price.compareTo(b.price));
                return SingleChildScrollView(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 15),
                    shrinkWrap: true,
                    // Add this to make ListView take only the necessary space
                    physics: NeverScrollableScrollPhysics(),
                    // Disable scrolling for inner ListView
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = sortedProducts[index];
                      return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0),
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ListTile(
                                  leading: SizedBox(
                                      width: 80, // Définir une largeur fixe
                                      child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center,
                                          children: [
                                            Text("${product.price}",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    height: 1)),
                                            Text(
                                                (product.id ==
                                                    idSubscriptionMensuel
                                                    ? '/${context.loc.mois}'
                                                    : '/${context.loc.annee}'),
                                                style: getFontForLanguage(
                                                    codelang: Localizations.localeOf(context).languageCode,
                                                    fontSize: 15,
                                                  ).copyWith(
                                                    height: 1,
                                                  ),
                                                ),
                                          ])),
                                  title: Text(
                                    (product.id == idSubscriptionMensuel
                                        ? context.loc.abonnement_mensuel
                                        : context.loc.abonnement_annuel),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    (product.id == idSubscriptionMensuel
                                        ? context.loc.abonnement_descriptif_mensuel
                                        : context.loc.abonnement_descriptif_annuel),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(padding: EdgeInsets.only(
                                        bottom: 10),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            context
                                                .read<PurchaseBloc>()
                                                .add(BuyProduct(product));
                                          },
                                          child: Text(context.loc.button_sabonner),
                                        )
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ],
                            ),
                          )
                      );
                    },
                  ),
                  // Add other widgets here
                );
              } else if (state is PurchaseFailure) {
                return Center(child: Text('Error: ${state.error}'));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          )
        ]
    );
  }
}

