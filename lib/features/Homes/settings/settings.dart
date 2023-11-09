import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muonroi/core/localization/settings.language.code.dart';
import 'package:muonroi/shared/settings/enums/theme/enum.code.color.theme.dart';
import 'package:muonroi/shared/settings/settings.fonts.dart';
import 'package:muonroi/shared/settings/settings.main.dart';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer(this.delay);

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }
}

class Throttle {
  final Duration delay;
  Timer? _timer;
  bool _canCall = true;

  Throttle(this.delay);

  void call(VoidCallback action) {
    if (_canCall) {
      _canCall = false;
      action();
      _timer = Timer(delay, () => _canCall = true);
    }
  }

  void cancel() {
    _timer?.cancel();
    _canCall = true;
  }
}

String formatValueNumber(double value) {
  final numberFormat = NumberFormat("#,###");

  return numberFormat.format(value);
}

void showTooltipNotification(BuildContext context) {
  final tooltip = Tooltip(
      message: L(context, LanguageCodes.recentlyStoryTextInfo.toString()),
      child: Text(
        L(context, LanguageCodes.recentlyStoryTextInfo.toString()),
        style: CustomFonts.h5(context),
        textAlign: TextAlign.center,
      ));

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: tooltip,
      duration: const Duration(seconds: 2),
      backgroundColor: themeMode(context, ColorCode.disableColor.name),
    ),
  );
}
