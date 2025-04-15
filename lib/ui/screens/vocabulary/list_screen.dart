import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';

import '../../../core/utils/PlaySoond.dart';

import '../../../core/utils/languageUtils.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}


class _ListScreenState extends State<ListScreen> {
  String searchQuery = '';
  bool sortAscending = true;
  late int sortColumnIndex;
  @override
  Widget build(BuildContext context) {
    var currentLocale = BlocProvider.of<LocalizationCubit>(context).state;
    return BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is VocabulairesLoaded) {
          var data = (state.data["vocabulaireList"] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
          if (searchQuery.isNotEmpty) {
            data = data.where((vocabulaire) {
              return vocabulaire['EN']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
                  vocabulaire[LanguageUtils().getSmallCodeLanguage(context: context)]
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
            }).toList();
          }
          final dataSource = VocabularyDataSource(data:data,context: context);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: context.loc.search,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              // Use a fixed height for the table or wrap it in a ListView
              Container(
                // Set a fixed height
                width: MediaQuery.of(context).size.width,
                child: PaginatedDataTable(
                  columns: [
                    DataColumn(
                        onSort: (columnIndex, ascending) {},
                        label: Flexible(child: Center(child:Text(context.loc.language_anglais,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        )))
                    ),
                    DataColumn(
                        onSort: (columnIndex, ascending) {},
                        label:  Flexible(child: Center(child:Text(context.loc.language_locale,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        )))
                    ),
                    DataColumn(
                        label: Flexible(child: Center(child:Text(context.loc.audios,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        )))
                    ),
                  ],
                  source: dataSource,
                  rowsPerPage: 10, // Nombre de lignes par page
                  columnSpacing: 20,
                  horizontalMargin: 10,
                  // headingRowColor: WidgetStateProperty.all(AppColors.cardBackground),
                ),
              ),
            ],
          );
        } else if (state is VocabulairesError) {
          return Center(child: Text("Erreur de chargement"));
        } else {
          return Center(child: Text("État inconnu")); // fallback
        }
      },
    );
  }
}

class VocabularyDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final BuildContext context;
  VocabularyDataSource({required this.data,required this.context});

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= data.length) {
      throw Exception('Index out of range: $index');
    }

    final vocabulaire = data[index];
    Color colorRow = index.isEven ? Colors.white : Color.fromRGBO(192, 192, 192, 1.0);
    return DataRow.byIndex(
      index: index,
      color: WidgetStateProperty.all(colorRow),
      cells: [
        DataCell(
            Center(
              child:Text(vocabulaire['EN'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                textAlign: TextAlign.center,
              )
            )
        ),
        DataCell(
          Center(
              child: Text(vocabulaire[LanguageUtils().getSmallCodeLanguage(context: context) ?? ''],
              style: TextStyle(
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            )
          )
        ),
        DataCell(
          Center(
            child:Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              child: PlaySoond(
                stringVocabulaire: vocabulaire['GUID'],
                buttonColor: Colors.green,
              ).buttonPlay(),
            ),
          )
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
