import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:yoo_se/core/constants.dart';
import 'package:yoo_se/core/locator.dart';
import 'package:yoo_se/logic/groups.dart';
import 'package:yoo_se/widgets/fab.dart';

Future<void> createGroup(
    int deletion, BuildContext context, int maxGroupSize, String name) async {
  final _gServ = locator.get<GroupService>();
  try {
    await _gServ.createGroup(deletion, maxGroupSize, name);
  } catch (error) {
    print(error);
  }

  _gServ.stream$
      .firstWhere((element) => element != null)
      .then((val) => shareButton(val));
  Navigator.pop(context);
}

class TrackingStarter extends StatefulWidget {
  @override
  _TrackingStarterState createState() => _TrackingStarterState();
}

class _TrackingStarterState extends State<TrackingStarter> {
  Duration selectedDur = Duration(minutes: 30);
  double max = 13.0;
  double now = 13.0;
  TextEditingController nameController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text(
                'SHARE YOUR LOCATION',
                textScaleFactor: 1.0,
                style: textStyle.copyWith(color: Colors.black),
              ),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Choose name',
                ),
                controller: nameController,
                keyboardType: TextInputType.text,
                autocorrect: false,
                autofocus: false,
                maxLength: 10,
              ),
            ),
            flex: 4,
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: Column(
                children: <Widget>[
                  Slider(
                    activeColor: mainColor,
                    onChanged: (v) {
                      print(v);
                      setState(() {
                        now = v;
                      });
                    },
                    value: now,
                    min: 1,
                    max: max,
                    divisions: max.toInt() - 1,
                  ),
                  Text(
                    '1 to ${now.toInt()} people for:',
                    textScaleFactor: 1.0,
                    style: textStyle.copyWith(
                        color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: CupertinoTimerPicker(
                initialTimerDuration: selectedDur,
                onTimerDurationChanged: (Duration duration) {
                  setState(() {
                    selectedDur = duration;
                  });
                },
                mode: CupertinoTimerPickerMode.hm,
                minuteInterval: 5,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30)),
                    color: mainColor,
                    onPressed: nameController.value.text == ''
                        ? null
                        : () {
                            createGroup(
                                DateTime.now().millisecondsSinceEpoch +
                                    selectedDur.inMilliseconds,
                                context,
                                now.toInt() + 1,
                                nameController.value.text);
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'START TRACKING',
                        textScaleFactor: 1.0,
                        style: textStyle,
                      ),
                    ),
                  ), /*
                  RaisedButton(
                    color: Colors.red,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ), */
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
