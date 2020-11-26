import 'dart:async';

import 'package:Amplessimus/colors.dart' as AmpColors;
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    try {
      ampInfo('ErrorScreen', 'Building Main Page');
      return ampMatApp(ErrorScreenPage());
    } catch (e) {
      ampErr('ErrorScreen', errorString(e));
      return ampText(errorString(e));
    }
  }
}

class ErrorScreenPage extends StatefulWidget {
  ErrorScreenPage({Key key}) : super(key: key);
  @override
  ErrorScreenPageState createState() => ErrorScreenPageState();
}

class ErrorScreenPageState extends State<ErrorScreenPage> {
  ErrorScreenPageState() {
    Timer.periodic(Duration(seconds: 2), (_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AmpColors.colorBackground,
        body: Column(children: [
          ampText(
            'Amplessimus did not initialize.\n'
            'Please contact ampless@chrissx.de with a screenshot/video of this page.',
            size: 20,
          ),
          ampLogWidget,
        ]),
      ),
    );
  }
}
