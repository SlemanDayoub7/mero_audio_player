import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(Locale initialLocale) : super(initialLocale);

  void changeLocale(Locale locale) {
    emit(locale);
  }

  Locale get currentLocale => state;
}
