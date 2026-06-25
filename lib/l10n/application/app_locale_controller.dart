import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLocaleControllerProvider =
    NotifierProvider<AppLocaleController, Locale>(
  AppLocaleController.new,
);

class AppLocaleController extends Notifier<Locale> {
  static const Locale english = Locale('en');
  static const Locale arabic = Locale('ar');

  @override
  Locale build() => english;

  void setLocale(Locale locale) {
    state = locale;
  }
}
