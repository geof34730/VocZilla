import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../logic/blocs/BlocStateTracker.dart';

class DebugWidget extends StatelessWidget {
  DebugWidget({super.key});
  final blocStates = BlocStateTracker().blocStates;
  @override
  Widget build(BuildContext context) {
     return Material(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 75,
              child: Container(
                height: 75.00,
                decoration: const BoxDecoration(
                  color: Colors.red,
                ),
                child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                      const Text(
                        'DEBUG TOOLS GEOFFREY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ]),
              ),
            ),


            SingleChildScrollView(
                child:Container(
                    color: Colors.yellow,
                    child:Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("CUBIT",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.amberAccent
                          ),
                        ),
                        Container(
                            width: double.infinity,
                            color: Colors.black,
                            padding: const EdgeInsets.all(5.00),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('localLangProvider => ',
                                  style: TextStyle(
                                      color: Colors.yellow
                                  ),
                                ),
                                Text('localOnlineDeviceProvider => ',
                                  style: TextStyle(
                                      color: Colors.yellow
                                  ),
                                ),

                              ],
                            )
                        ),
                        Text("BLOC",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.amberAccent
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          color: Colors.black,
                          padding: const EdgeInsets.all(5.00),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: blocStates.entries.map((entry) {
                              return Text(
                                '${entry.key} => ${entry.value}',
                                style: TextStyle(color: Colors.yellow),
                              );
                            }).toList(),
                          ),
                        ),
                        Text("SHARE PREFERENCE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _getAllSharedPreferences(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Erreur lors de la récupération des préférences',
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            } else {
                              final allPrefs = snapshot.data!;
                              return Container(
                                width: double.infinity,
                                color: Colors.black,
                                padding: const EdgeInsets.all(5.00),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: allPrefs.entries.map((entry) {
                                    return Text(
                                      '${entry.key} => ${entry.value}',
                                      style: TextStyle(color: Colors.yellow),
                                    );
                                  }).toList(),
                                ),
                              );
                            }
                          },
                        ),

                      ],
                    )
                )
            ),
          ],
        ));
  }

  Future<Map<String, dynamic>> _getAllSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, dynamic> allPrefs = {};
    for (String key in keys) {
      allPrefs[key] = prefs.get(key);
    }
    return allPrefs;
  }

}


