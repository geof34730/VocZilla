import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';


class ListScreen extends StatelessWidget {
  final String id;

  ListScreen({required this.id}) ;

  @override
  Widget build(BuildContext context) {
    var currentLocale = BlocProvider.of<LocalizationCubit>(context).state;
    return Text("List :$id");
  }



}
