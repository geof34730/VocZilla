import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

Future<String> generateShareLink(String guid) async {
  // 1. Créez un Branch Universal Object
  BranchUniversalObject buo = BranchUniversalObject(
    canonicalIdentifier: 'list/$guid',
    title: 'Voczilla',
    contentDescription: 'Découvre et apprends cette liste sur VocZilla.',
    contentMetadata: BranchContentMetaData()
      ..addCustomMetadata('guid', guid), // C'est ici qu'on ajoute le guid !
  );

  // 2. Définissez les propriétés du lien
  BranchLinkProperties lp = BranchLinkProperties(
    channel: 'app',
    feature: 'share',
    campaign: 'list_sharing',
  );

  // 3. Générez le lien court
  BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);

  if (response.success) {
    return response.result;
  } else {
    print('Erreur de génération de lien Branch: ${response.errorMessage}');
    return ''; // Ou gérez l'erreur comme vous le souhaitez
  }
}
