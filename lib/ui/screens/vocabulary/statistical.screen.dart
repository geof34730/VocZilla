import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/logic/cubit/localization_cubit.dart';


class StatisticalScreen extends StatelessWidget {

  StatisticalScreen() ;

  @override
  Widget build(BuildContext context) {
    var currentLocale = BlocProvider.of<LocalizationCubit>(context).state;
    return Text("StatisticalScreen : ");
  }



}
