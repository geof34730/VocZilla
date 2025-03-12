import 'package:flutter/material.dart';



enum IconSize {
  bigIcon,
  smallIcon,
}

class ElevatedButtonCardHome extends StatelessWidget {
  final Color colorIcon;
  final VoidCallback onClickButton;
  final IconData iconContent;
  final BuildContext context;
  final IconSize iconSize;
  final bool disabledButton;
  final bool visibilityButton;

  ElevatedButtonCardHome({
    required this.colorIcon,
    required this.onClickButton,
    required this.iconContent,
    required this.context,
    this.iconSize = IconSize.smallIcon,
    this.disabledButton = true,
    this.visibilityButton = true,
    // Valeur par défaut
  });

  @override
  Widget build(BuildContext context) {
    double sizeIconDouble = (iconSize == IconSize.bigIcon) ? 40.0 : 25.0;
    double sizeButton = (iconSize == IconSize.bigIcon) ? 50.0 : 30.0;
    double sizeBorderRadius = (iconSize == IconSize.bigIcon) ? 10.0 : 5.0;
    return Visibility(
        visible: visibilityButton,
        child: Padding(
            padding: EdgeInsets.all(5.0), // Ajouter un padding
            child: PhysicalModel(
                color: Colors.blue,
                elevation: 5.0,
                borderRadius: BorderRadius.circular(sizeBorderRadius),
                shadowColor: Colors.black,
                child: Container(
                    width: sizeButton,
                    height: sizeButton,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(sizeBorderRadius),
                      color: Colors.white,
                    ),
                      child: IconButton(
                      key: UniqueKey(),
                      padding: const EdgeInsets.all(0.0),
                      color: colorIcon,
                      alignment: Alignment.center,
                      iconSize: sizeIconDouble,
                      icon: Icon(iconContent),
                      onPressed: (disabledButton
                          ? () {
                              onClickButton();
                            }
                          : null),
                    )
                )
            )
        )
    );
  }
}
