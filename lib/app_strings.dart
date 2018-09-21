import 'package:flutter/material.dart';

class AppStrings {

  AppStrings(this.locale);

  final Locale locale;

  get addFabTooltip => _localizedValues[locale.languageCode]['addFabTooltip'];
  get analysisTooltip => _localizedValues[locale.languageCode]['analysisTooltip'];
  get title => _localizedValues[locale.languageCode]['title'];
  get loadingMessage => _localizedValues[locale.languageCode]['loadingMessage'];
  get generalErrorMessage => _localizedValues[locale.languageCode]['generalErrorMessage'];

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Blood Pressure Log',
      'analysisTooltip': 'Analysis',
      'addFabTooltip': 'Add blood pressure reading',
      'loadingMessage': 'loading...',
      'generalErrorMessage': 'Something went wrong.',
    },
  };

}