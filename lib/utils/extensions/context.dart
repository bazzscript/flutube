import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutube/utils/utils.dart';
import 'package:lucide_icons/lucide_icons.dart';

extension ContextExtensions on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ThemeData get theme => Theme.of(this);
  Brightness get brightness => Theme.of(this).brightness;
  bool get isDark => Theme.of(this).brightness.isDark;
  back([VoidCallback? after]) {
    if (after != null) after();
    Navigator.of(this).pop();
  }

  pushPage(Widget page) => Navigator.of(this).push(MaterialPageRoute(builder: (ctx) => page));

  Widget backLeading([VoidCallback? onBack]) => IconButton(
        icon: Icon(LucideIcons.chevronLeft, color: textTheme.bodyText1!.color),
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onPressed: onBack ?? back,
      );

  Color get getBackgroundColor => brightness.getBackgroundColor;
  Color get getAltBackgroundColor => brightness.getAltBackgroundColor;
  Color get getAlt2BackgroundColor => brightness.getAlt2BackgroundColor;

  bool get isMobile => (Platform.isAndroid && !isLandscape) || width < mobileWidth;

  MediaQueryData get queryData => MediaQuery.of(this);
  get isLandscape => queryData.orientation == Orientation.landscape;
  get width => queryData.size.width;
  get height => queryData.size.height;
}
