import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/logic/cubit/localization_cubit.dart';
import 'package:voczilla/services/admob_service.dart';

import '../../../core/utils/detailTypeVocabulaire.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/vocabulaire_repository.dart';
import '../../widget/ads/banner_ad_widget.dart';
import '../../widget/elements/PlaySoond.dart';

import '../../../core/utils/languageUtils.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../widget/form/RadioChoiceVocabularyLearnedOrNot.dart';

class ListScreen extends StatefulWidget {
  ListScreen({required String listName});
  @override
  _ListScreenState createState() => _ListScreenState();
}


class _ListScreenState extends State<ListScreen> {
  String searchQuery = '';
  bool sortAscending = true;
  late int sortColumnIndex;
  GlobalKey<PaginatedDataTableState> tableKey = GlobalKey();
  TextEditingController searchController = TextEditingController();
  final _vocabulaireRepository=VocabulaireRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // On déclenche le chargement des bannières pour cet écran
      AdMobService.instance.loadListScreenBanners(context);
    });
  }
  @override
  void dispose() {
    // Dispose banner ads to free up resources and prevent memory leaks.
    AdMobService.instance.disposeListScreenBanners();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is VocabulairesLoaded) {
          var data = (state.data.vocabulaireList)
              .map((item) => item as Map<String, dynamic>)
              .toList();
          if (searchQuery.isNotEmpty) {
            data = data.where((vocabulaire) {
              return vocabulaire['EN']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
                  vocabulaire[LanguageUtils.getSmallCodeLanguage(context: context)]
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
            }).toList();
          }
          final dataSource = data.isEmpty
              ? EmptyDataSource(context: context)
              : VocabularyDataSource(data: data, context: context);
          int rowsPerPage = data.isEmpty ? 1 : (data.length < 10 ? data.length : 10);
          bool isNotLearned = state.data.isVocabularyNotLearned;
          int _vocabulaireConnu = isNotLearned ? 0 : 1;
          return Column(
            key: ValueKey('screenList'),
            children: [
              const AdaptiveBannerAdWidget(
                placementId: 'list_top',
                padding: EdgeInsets.only(top: 8),
              ),
              RadioChoiceVocabularyLearnedOrNot(
                  state: state,
                  vocabulaireConnu: _vocabulaireConnu,
                  vocabulaireRepository: _vocabulaireRepository,
                  local: LanguageUtils.getSmallCodeLanguage(context: context)
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: context.loc.search,
                    border: OutlineInputBorder(),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.cancel,color: Colors.red,),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                  searchController.clear();
                                  tableKey = GlobalKey();
                                });
                              },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      // Change the key to force the table to rebuild
                      tableKey = GlobalKey();
                    });
                  },
                ),
              ),

              // Use a fixed height for the table or wrap it in a ListView
              if(!data.isEmpty)...[
                  Container(
                    // Set a fixed height
                    width: MediaQuery.of(context).size.width,
                    child: PaginatedDataTable(
                      key: tableKey,
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
                      rowsPerPage: rowsPerPage,  // Nombre de lignes par page
                      columnSpacing: 20,
                      horizontalMargin: 10,
                      // headingRowColor: WidgetStateProperty.all(AppColors.cardBackground),
                    ),
                  ),
              ],

              if(data.isEmpty)...[
                Container(
                  // Set a fixed height
                  width: MediaQuery.of(context).size.width,
                  child: PaginatedDataTable(
                    key: tableKey,
                    columns: [
                      DataColumn(
                          onSort: (columnIndex, ascending) {},
                          label: Text('')
                      ),
                    ],
                    source: dataSource,
                    rowsPerPage: rowsPerPage,  // Nombre de lignes par page
                    columnSpacing: 0,
                    horizontalMargin: 10,
                    // headingRowColor: WidgetStateProperty.all(AppColors.cardBackground),
                  ),
                ),
              ],
              const AdaptiveBannerAdWidget(
                placementId: 'list_bottom',
                padding: EdgeInsets.only(top: 8),
              ),
            ],
          );
        } else if (state is VocabulairesError) {
          return Center(child: Text(context.loc.error_loading));
        } else {
          return Center(child: Text(context.loc.unknown_error)); // fallback
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
                child:  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            vocabulaire['isLearned'] ? Icons.check: Icons.close,
                            color: vocabulaire['isLearned'] ? Colors.green : Colors.red,
                            size: 16.0,
                          ),
                          Text(vocabulaire['EN'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ]
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.only(left:16),
                          child:Text(
                          "(${getTypeDetaiVocabulaire(typeDetail:vocabulaire['TYPE_DETAIL'],context: context)})",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10
                          ),
                          )
                      )
                    ]
                )
            )
        ),
        DataCell(
          Center(
              child: Text(vocabulaire["TRAD"],
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
                guidVocabulaire: vocabulaire['GUID'],
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

class EmptyDataSource extends DataTableSource {
  final BuildContext context;
  EmptyDataSource({required this.context});

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(
      color: WidgetStateProperty.all(Colors.white),
      index: index,
        cells: [
          DataCell(
            Container(
                width: double.infinity , // Adjust width to span across columns
                alignment: Alignment.center, // Center the text
                child: Text(
                  context.loc.no_results,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          )
        ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => 1;

  @override
  int get selectedRowCount => 0;
}



