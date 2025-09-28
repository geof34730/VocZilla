import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:voczilla/core/utils/localization.dart';
import '../../global.dart';
import '../../logic/blocs/purchase/purchase_bloc.dart';
import '../../logic/blocs/purchase/purchase_event.dart';
import '../../logic/blocs/purchase/purchase_state.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with WidgetsBindingObserver {
  String? _purchasingProductId;
  StreamSubscription<List<PurchaseDetails>>? _purchaseStreamSub;
  bool _awaitingSheetClose = false;
  bool _isRestoring = false;
  Timer? _resumeSafetyTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<PurchaseBloc>().add(const LoadProducts());

    _purchaseStreamSub = InAppPurchase.instance.purchaseStream.listen(
          (purchases) {
        _awaitingSheetClose = false;
        for (final p in purchases) {
          switch (p.status) {
            case PurchaseStatus.canceled:
            case PurchaseStatus.error:
              if (mounted) setState(() => _purchasingProductId = null);
              break;
            case PurchaseStatus.purchased:
            case PurchaseStatus.restored:
              break;
            case PurchaseStatus.pending:
              break;
          }
        }
      },
      onError: (_) {
        if (mounted) setState(() => _purchasingProductId = null);
        _awaitingSheetClose = false;
      },
    );
  }

  @override
  void dispose() {
    _purchaseStreamSub?.cancel();
    _resumeSafetyTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingSheetClose) {
      _resumeSafetyTimer?.cancel();
      _resumeSafetyTimer = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _purchasingProductId = null;
          _awaitingSheetClose = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final endTrial = args != null && args['endTrial'] == true;

    return BlocListener<PurchaseBloc, PurchaseState>(
      listener: (context, state) {
        if (state is PurchaseCompleted) {
          setState(() => _purchasingProductId = null);
          Navigator.of(context).pop(true);
        } else if (state is PurchaseFailure) {
          setState(() => _purchasingProductId = null);
          final msg = state.error.isNotEmpty
              ? '${context.loc.erreur_chargement_produits}\n\n"${state.error}"'
              : context.loc.erreur_chargement_produits;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      child: SingleChildScrollView(
        key: const ValueKey('screenSubscription'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderSection(endTrial: endTrial),
            const SizedBox(height: 16),
            BlocBuilder<PurchaseBloc, PurchaseState>(
              builder: (context, state) {
                if (state is PurchaseLoading || state is PurchaseInitial) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is PurchaseFailure) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Text(
                            '${context.loc.erreur_chargement_produits}\n\n"${state.error}"',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              context.read<PurchaseBloc>().add(const LoadProducts());
                            },
                            child: Text(context.loc.reessayer),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ProductsLoaded) {
                  final products = List<ProductDetails>.from(state.products);
                  products.sort((a, b) {
                    final aAnnual = a.id == idSubscriptionAnnuel;
                    final bAnnual = b.id == idSubscriptionAnnuel;
                    if (aAnnual && !bAnnual) return -1;
                    if (!aAnnual && bAnnual) return 1;
                    return a.price.compareTo(b.price);
                  });

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // pleine largeur
                    children: products.map((product) {
                      final isMensuel = product.id == idSubscriptionMensuel;
                      final isAnnuel = product.id == idSubscriptionAnnuel;
                      final isPurchasing = _purchasingProductId == product.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PlanCard(
                          title: isMensuel
                              ? context.loc.abonnement_mensuel
                              : context.loc.abonnement_annuel,
                          priceLine:
                          '${product.price}/${isMensuel ? context.loc.mois : context.loc.annee}',
                          description: isMensuel
                              ? context.loc.abonnement_descriptif_mensuel
                              : context.loc.abonnement_descriptif_annuel,
                          badge: isAnnuel
                              ? context.loc.subscription_plan_badge_best_offer
                              : null,
                          highlighted: true, // même design pour les deux
                          trailing: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _purchasingProductId = product.id;
                                _awaitingSheetClose = true;
                              });
                              context.read<PurchaseBloc>().add(BuyProduct(product));
                            },
                            child: isPurchasing
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                                : Text(context.loc.button_sabonner),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            if (Platform.isIOS || Platform.isMacOS)
              Center(
                child: _isRestoring
                    ? const CircularProgressIndicator()
                    : TextButton.icon(
                  onPressed: () async {
                    setState(() => _isRestoring = true);
                    try {
                      await InAppPurchase.instance.restorePurchases();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.loc.restauration_terminee)),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.loc.restaurer_achats_error)),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isRestoring = false);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(context.loc.restaurer_achats),
                ),
              ),
            const SizedBox(height: 8),
            if (Platform.isIOS || Platform.isMacOS) const _LegalNote(),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final bool endTrial;
  const _HeaderSection({required this.endTrial});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.green, // couleur conservée
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.subscription_header_title,
            style: t.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.loc.subscription_header_subtitle,
            style: t.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          _BenefitRow(text: context.loc.subscription_benefit_full_access),
          _BenefitRow(text: context.loc.subscription_benefit_unlimited),
          _BenefitRow(text: context.loc.subscription_benefit_updates),
          _BenefitRow(text: context.loc.subscription_benefit_no_pub),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String priceLine;
  final String description;
  final String? badge;
  final bool highlighted;
  final Widget trailing;

  const _PlanCard({
    required this.title,
    required this.priceLine,
    required this.description,
    required this.trailing,
    this.badge,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final borderColor =
    highlighted ? t.colorScheme.primary : t.dividerColor.withOpacity(0.3);

    return SizedBox(
      width: double.infinity, // pleine largeur
      child: Card(
        margin: EdgeInsets.zero, // supprime la marge par défaut
        elevation: highlighted ? 6 : 2,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: highlighted ? 1.2 : 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (badge != null)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: t.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge!,
                      style: t.textTheme.labelMedium?.copyWith(
                        color: t.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                title,
                style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                priceLine,
                style: t.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                textAlign: TextAlign.center,
                style: t.textTheme.bodySmall?.copyWith(
                  color: t.textTheme.bodySmall?.color?.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 12),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalNote extends StatelessWidget {
  const _LegalNote();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Text(
      context.loc.subscription_legal_note,
      textAlign: TextAlign.center,
      style: t.textTheme.bodySmall?.copyWith(
        color: t.textTheme.bodySmall?.color?.withOpacity(0.7),
        height: 1.25,
      ),
    );
  }
}
