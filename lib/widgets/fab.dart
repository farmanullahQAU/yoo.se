import 'dart:async';
import 'dart:io' show Platform;

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:yoo_se/core/constants.dart';
import 'package:yoo_se/core/locator.dart';
import 'package:yoo_se/logic/dynamic_links.dart';
import 'package:yoo_se/logic/groups.dart';
import 'package:yoo_se/widgets/infoOverlay.dart';
import 'package:yoo_se/widgets/trackingstarter.dart';

class BottomBar extends StatelessWidget {
  Widget build(BuildContext context) {
    Group _group = Provider.of<Group>(context);
    if (_group == null) {
      return SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              iconSize: 48,
              color: mainColor,
              onPressed: () => Navigator.push(context, TutorialOverlay()),
              icon: Icon(Icons.info),
            ),
            FlatButton(
              color: mainColor,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return BottomSheet(
                        onClosing: () {},
                        builder: (BuildContext context) => TrackingStarter());
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'START',
                  style: textStyle,
                  textScaleFactor: 1.0,
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            Container(
              width: 60,
            )
          ],
        ),
      );
    } else {
      return Tracking();
    }
  }
}

class Tracking extends StatefulWidget {
  @override
  _TrackingState createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  Timer callbackTimer;
  GroupService _groupService = locator.get<GroupService>();
  bool loading = false;

  @override
  void initState() {
    callbackTimer = Timer.periodic(Duration(seconds: 2), (timer) {
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
    Group _group = Provider.of<Group>(context);
    final durLeft = _group.deletion - currentTime;
    int totTime = durLeft;
    if (_group.created != null) {
      totTime = _group.deletion - _group.created.millisecondsSinceEpoch;
    }
    if (durLeft <= 0.0) {
      _groupService.deleteGroup();
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }

    return Column(
      children: <Widget>[
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                iconSize: 55,
                color: mainColor,
                onPressed: () async {
                  final res = await Navigator.push(context, TutorialOverlay());
                  if (res == 'stop') {
                    _groupService.deleteGroup();
                  }
                },
                icon: Icon(Icons.remove),
              ),
              IconButton(
                iconSize: 53,
                color: mainColor,
                onPressed: () async {
                  if (!loading) {
                    setState(() {
                      loading = true;
                    });
                    await shareButton(_group);
                    setState(() {
                      loading = false;
                    });
                  }
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> shareButton(Group group) async {
  Future<bool> _isIpad() async {
    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      return iosInfo.name.toLowerCase().contains('ipad');
    }
    return false;
  }

  LinksService _linksService = locator.get<LinksService>();
  String link = await _linksService
      .generateLink({'pass': group.password, 'gid': group.id});
  await Share.share(
      'If you have internet, click this link to view my location ' + link,
      sharePositionOrigin: await _isIpad()
          ? Rect.fromCenter(center: Offset(0, 0), width: 100, height: 100)
          : null);
}
