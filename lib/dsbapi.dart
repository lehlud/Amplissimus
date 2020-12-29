import 'dart:async';

import 'ui/first_login.dart';
import 'langs/language.dart';
import 'logging.dart';
// ignore: library_prefixes
import 'prefs.dart' as Prefs;
import 'subject.dart';
import 'ui/home_page.dart';
import 'uilib.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

Widget _renderPlans(List<Plan> plans) {
  ampInfo('DSB', 'Rendering plans: $plans');
  final widgets = <Widget>[];
  for (final plan in plans) {
    final dayWidgets = <Widget>[];
    if (plan.subs.isEmpty) {
      dayWidgets.add(ListTile(title: ampText(Language.current.noSubs)));
    }
    for (final sub in plan.subs) {
      dayWidgets.add(ampLessonTile(
        subject: Prefs.parseSubjects ? parseSubject(sub.subject) : sub.subject,
        orgTeacher: sub.orgTeacher,
        lesson: sub.lesson.toString(),
        subtitle: Language.current.dsbSubtoSubtitle(sub),
        affClass: (Prefs.classGrade.isEmpty ||
                Prefs.classLetter.isEmpty ||
                !Prefs.oneClassOnly)
            ? sub.affectedClass
            : '',
      ));
    }
    widgets.add(ListTile(
      title: ampRow([
        outdated(plan.date, DateTime.now())
            ? IconButton(
                icon: ampIcon(Icons.warning, Icons.warning_outlined),
                //TODO:
                onPressed: () {},
              )
            : ampNull,
        ampText(' ${Language.current.dayToString(plan.day)}', size: 24),
        IconButton(
          icon: ampIcon(Icons.info, Icons.info_outline),
          tooltip: plan.date.split(' ').first,
          onPressed: () =>
              scaffoldMessanger.showSnackBar(ampSnackBar(plan.date)),
          padding: EdgeInsets.fromLTRB(4, 4, 2, 4),
        ),
        IconButton(
          icon: ampIcon(Icons.open_in_new, Icons.open_in_new_outlined),
          tooltip: Language.current.openPlanInBrowser,
          onPressed: () => ampOpenUrl(plan.url),
          padding: EdgeInsets.fromLTRB(4, 4, 2, 4),
        ),
      ]),
    ));
    widgets.add(ampList(dayWidgets));
  }
  ampInfo('DSB', 'Done rendering plans.');
  return ampColumn(widgets);
}

List<Plan> plans;
Widget widget;

Future<Null> updateWidget([bool useJsonCache]) async {
  useJsonCache ??= Prefs.useJsonCache;
  try {
    var plans = useJsonCache && Prefs.dsbJsonCache != null
        ? Plan.plansFromJson(Prefs.dsbJsonCache)
        : await getAllSubs(
            Prefs.username, Prefs.password, cachedHttpGet, http.post,
            language: Prefs.dsbLanguage);
    Prefs.dsbJsonCache = Plan.plansToJson(plans);
    if (Prefs.oneClassOnly) {
      plans = searchClass(plans, Prefs.classGrade, Prefs.classLetter);
    }
    for (final plan in plans) {
      plan.subs.sort();
    }
    widget = _renderPlans(plans);
    plans = plans;
  } catch (e) {
    ampErr(['DSB', 'updateWidget'], errorString(e));
    widget = ampList([ampErrorText(e)]);
  }
}

bool outdated(String date, DateTime now) {
  try {
    final raw = date.split(' ').first.split('.');
    return now.isAfter(DateTime(
      int.parse(raw[2]),
      int.parse(raw[1]),
      int.parse(raw[0]),
    ).add(Duration(days: 3)));
  } catch (e) {
    return false;
  }
}

//this is a really bad place to put this, but we can fix that later
List<String> get grades => ['5', '6', '7', '8', '9', '10', '11', '12', '13'];
List<String> get letters => ['', 'a', 'b', 'c', 'd', 'e', 'f', 'g'];
