import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';

bool isTablet(BuildContext context) {
  // Material Design guidelines recommend 600dp as the breakpoint for tablets.
  final shortestSide = MediaQuery.of(context).size.shortestSide;
  return shortestSide >= 600;
}
