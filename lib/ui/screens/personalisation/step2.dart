import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/localization.dart';

import '../../../core/utils/detailTypeVocabulaire.dart';
import '../../../core/utils/languageUtils.dart';
import '../../../core/utils/logger.dart';
import '../../../data/repository/vocabulaire_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_event.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';
import '../../widget/elements/Error.dart';
import '../../widget/form/RadioChoiceVocabularyLearnedOrNot.dart';

class PersonnalisationStep2Screen extends StatefulWidget {
  final String guidListPerso;

  PersonnalisationStep2Screen({super.key, required this.guidListPerso});

  @override
  _PersonnalisationStep2ScreenState createState() => _PersonnalisationStep2ScreenState();
}

class _PersonnalisationStep2ScreenState extends State<PersonnalisationStep2Screen> {
  String searchQuery = '';
  bool sortAscending = true;
  late int sortColumnIndex;
  GlobalKey<PaginatedDataTableState> tableKey = GlobalKey();
  TextEditingController searchController = TextEditingController();
  final _vocabulaireRepository = VocabulaireRepository();
  final Set<String> _processingGuids = {};
  VocabulairesLoaded? _lastLoadedState;

  void _toggleVocabulary(Map<String, dynamic> vocabulaire, bool dataToLearn) {
    final String guid = vocabulaire['GUID'];
    if (_processingGuids.contains(guid)) {
      return; // Avoid multiple clicks if already processing
    }

    setState(() {
      _processingGuids.add(guid);
    });

    final bool isSelected = vocabulaire['isSelectedInListPerso'];
    final String local = LanguageUtils.getSmallCodeLanguage(context: context);
    if (isSelected) {
      Logger.Green.log("DELETE: ${guid}");
      BlocProvider.of<VocabulaireUserBloc>(context).add(DeleteVocabulaireListPerso(guidListPerso: widget.guidListPerso, guidVocabulaire: guid, local: local));
    } else {
      Logger.Green.log("ADD: ${guid}");
      BlocProvider.of<VocabulaireUserBloc>(context).add(AddVocabulaireListPerso(guidListPerso: widget.guidListPerso, guidVocabulaire: guid, local: local));
    }
    // We wrap this in a Future to ensure that the setState from above has time to update the UI
    // and show the loader before the list starts refreshing. This prevents a race condition.
    Future(() => BlocProvider.of<VocabulairesBloc>(context).add(getAllVocabulaire(isVocabularyNotLearned: dataToLearn, guid: widget.guidListPerso, local: local)));

  }

  @override
  Widget build(BuildContext context) {
    String guidListPerso = widget.guidListPerso;
    final langCode = LanguageUtils.getSmallCodeLanguage(context: context);

    return BlocListener<VocabulairesBloc, VocabulairesState>(
      listener: (context, state) {
        if (state is VocabulairesLoaded) {
          _lastLoadedState = state;
          if (_processingGuids.isNotEmpty) {
            setState(() {
              _processingGuids.clear();
            });
          }
        } else if (state is VocabulairesError) {
          // When an error occurs (e.g., during a refresh), clear the processing indicators
          // so the user can try again, and show an error message.
          if (_processingGuids.isNotEmpty) {
            setState(() {
              _processingGuids.clear();
            });
          }
          ErrorMessage(context: context, message: context.loc.error_loading);
        }
      },
      child: BlocBuilder<VocabulairesBloc, VocabulairesState>(
        builder: (context, state) {
          if (state is VocabulairesLoading && _lastLoadedState == null) {
            return Center(child: CircularProgressIndicator());
          }

          final dataState = state is VocabulairesLoaded ? state : _lastLoadedState;

          if (dataState == null) {
            if (state is VocabulairesError) {
              return Center(child: Text(context.loc.error_loading));
            }
            return Center(child: Text(context.loc.unknown_error)); // fallback
          }

          var data = (dataState.data.vocabulaireList)
              .map((item) => item as Map<String, dynamic>)
              .toList();
          if (searchQuery.isNotEmpty) {
            data = data.where((vocabulaire) {
              return vocabulaire['EN']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
                  vocabulaire["TRAD"]
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
            }).toList();
          }
          final dataSource = data.isEmpty
              ? EmptyDataSource(context: context)
              : VocabularyDataSource(
                  data: data,
                  context: context,
                  guidListPerso: guidListPerso,
                  dataToLearn: dataState.data.isVocabularyNotLearned,
                  langCode: langCode,
                  processingGuids: _processingGuids,
                  onToggle: _toggleVocabulary,
                );
          int rowsPerPage = data.isEmpty ? 1 : (data.length < 10 ? data.length : 10);
          bool isNotLearned = dataState.data.isVocabularyNotLearned;
          int _vocabulaireConnu = isNotLearned ? 0 : 1;
          return Column(
            key: ValueKey('perso_list_step2'),
            children: [
              RadioChoiceVocabularyLearnedOrNot(
                state: dataState,
                vocabulaireConnu: _vocabulaireConnu,
                vocabulaireRepository: _vocabulaireRepository,
                guidListPerso: guidListPerso,
                local: langCode,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: context.loc.search,
                    border: OutlineInputBorder(),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
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
              if (!data.isEmpty)
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: PaginatedDataTable(
                    key: tableKey,
                    columns: [
                      DataColumn(
                          onSort: (columnIndex, ascending) {},
                          label: Flexible(
                              child: Center(
                                  child: Text(
                            context.loc.language_anglais,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                            textAlign: TextAlign.center,
                          )))),
                      DataColumn(
                          onSort: (columnIndex, ascending) {},
                          label: Flexible(
                              child: Center(
                                  child: Text(
                            context.loc.language_locale,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                            textAlign: TextAlign.center,
                          )))),
                      DataColumn(
                          label: Flexible(
                              child: Center(
                                  child: Text(
                        "",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      )))),
                    ],
                    source: dataSource,
                    rowsPerPage: rowsPerPage,
                    columnSpacing: 20,
                    horizontalMargin: 10,
                  ),
                )
              else
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: PaginatedDataTable(
                    key: tableKey,
                    columns: [
                      DataColumn(onSort: (columnIndex, ascending) {}, label: Text('')),
                    ],
                    source: dataSource,
                    rowsPerPage: rowsPerPage,
                    columnSpacing: 0,
                    horizontalMargin: 10,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class VocabularyDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;
  final BuildContext context;
  final String guidListPerso;
  final bool dataToLearn;
  final String langCode;

  final Set<String> processingGuids;
  final Function(Map<String, dynamic>, bool) onToggle;

  VocabularyDataSource(
      {required this.data,
      required this.context,
      required this.guidListPerso,
      required this.dataToLearn,
      required this.langCode,
      required this.processingGuids,
      required this.onToggle});
  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= data.length) {
      throw Exception('Index out of range: $index');
    }

    final vocabulaire = data[index];
    Color colorRow = index.isEven ? Colors.white : Color.fromRGBO(192, 192, 192, 1.0);
    final bool isLoading = processingGuids.contains(vocabulaire['GUID']);
    return DataRow.byIndex(
      index: index,
      color: WidgetStateProperty.all(colorRow),
      cells: [
        DataCell(
            Center(
                child: Column(
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
                child: Text(vocabulaire['TRAD'],
                  style: TextStyle(
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                )
            )
        ),
        DataCell(
             Padding(
                padding: EdgeInsets.only(top:5, bottom:5),
                 child:Center(
                    child:CircleAvatar(
                      radius: 30,
                      backgroundColor:  vocabulaire['isSelectedInListPerso'] ? Colors.red : Colors.green,
                      child: IconButton(
                        key: ValueKey('button_add_voc_$index'),
                        icon: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : Icon(
                                vocabulaire['isSelectedInListPerso']
                                    ? Icons.delete
                                    : Icons.add,
                                color: Colors.white,
                              ),
                        onPressed: isLoading ? null : () => onToggle(vocabulaire, dataToLearn),
                      ),
                    ),
                 )
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
            width: double.infinity, // Adjust width to span across columns
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
