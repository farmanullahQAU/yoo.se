import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoo_se/core/constants.dart';
import 'package:yoo_se/core/locator.dart';
import 'package:yoo_se/logic/groups.dart';

class CountDown extends StatefulWidget {
  @override
  _CountDownState createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  Timer callbackTimer;
  GroupService _groupService = locator.get<GroupService>();
  bool loading = false;

  @override
  void initState() {
    callbackTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      callbackTimer = timer;
      setState(() {
        currentTime = DateTime.now().millisecondsSinceEpoch;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    callbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Group _group = _groupService.current;
    final durLeft = _group.deletion - currentTime;
    int totTime = durLeft;
    if (_group.created != null) {
      totTime = _group.deletion - _group.created.millisecondsSinceEpoch;
    }
    if (durLeft <= 0.0) {
      _groupService.deleteGroup();
    }
    return FlatButton(
      shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
      disabledColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      onPressed: () => null,
      color: Colors.white,
      child: Container(
        width: 120,
        child: Center(
          child: Text(
            '${_printDuration(Duration(milliseconds: durLeft))}',
            style: textStyle.copyWith(color: Colors.red),
            textScaleFactor: 1.0,
          ),
        ),
      ),
    );
  }
}

String _printDuration(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}
