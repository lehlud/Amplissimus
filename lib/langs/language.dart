import 'dart:collection';

import 'package:dsbuntis/dsbuntis.dart';
import 'english.dart';
import 'german.dart';
// ignore: library_prefixes
import '../prefs.dart' as Prefs;

abstract class Language {
  String get code;
  String get name;

  //
  //these are all of the translations hardcoded into the language classes
  //
  String get darkMode;
  String get useSystemTheme;
  String get alternativeAppearance;
  String get changeLanguage;
  String get parseSubjects;
  String get changeLogin;
  String get changeLoginPopup;
  String get username;
  String get password;
  String get save;
  String get cancel;
  String get selectClass;
  String get settingsAppInfo;
  String get appInfo;
  String get start;
  String get settings;
  String get noLogin;
  String get allClasses;
  String get empty;
  String get widgetValidatorInvalid;
  String get done;
  String get timetable;
  String get setupTimetable;
  String get setupTimetableTitle;
  String get noSubs;
  String get subject;
  String get notes;
  String get editHour;
  String get teacher;
  String get freeLesson;
  String get filterTimetables;
  String get edit;
  String get substitution;
  String get changedAppearance;
  String get show;
  String get useForDsb;
  String get dismiss;
  String get open;
  String get update;
  String get plsUpdate;
  String get wpemailDomain;
  String get openPlanInBrowser;
  String dsbSubtoSubtitle(Substitution sub);
  String dayToString(Day day);
  String dsbError(String e);
  LinkedHashMap<String, String> get subjectLut;

  //why tf doesnt this break?!
  static Language _current = fromCode(Prefs.savedLangCode);
  static Language get current => _current;
  static set current(Language l) {
    Prefs.savedLangCode = l.code;
    _current = l;
  }

  static final List<Language> _langs = [English(), German()];
  static List<Language> get all => _langs;

  static Language fromCode(String code) {
    if (code == null) return _langs[0];
    for (final lang in _langs) {
      if (strcontain(code, lang.code)) return lang;
    }
    return _langs[0];
  }

  @override
  String toString() => name;
}
