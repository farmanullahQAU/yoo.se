import 'package:flutter/material.dart';
import 'package:yoo_se/logic/groups.dart';
import 'package:yoo_se/core/constants.dart';
import 'package:yoo_se/core/locator.dart';
import 'package:yoo_se/logic/mapController.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class FollowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MapController mapController = locator.get<MapController>();
    Group group = Provider.of<Group>(context);
    GroupService groupService = locator.get<GroupService>();
    return IconButton(
        color: mainColor,
        iconSize: 40,
        icon: new Icon(Icons.people),
        onPressed: () async {
          if (group != null && group.members.length > 1) {
            group.showAll();
            groupService.follow = true;
            Timer.periodic(Duration(seconds: 3), (timer) {
              if (groupService.follow) {
                Group group = Provider.of<Group>(context);
                group.showAll();
              } else {
                timer.cancel();
              }
            });
          } else {
            // final PhoneContact contact =
            // await FlutterContactPicker.pickPhoneContact().catchError((error)=>print(error));


            mapController.current.animateCamera(CameraUpdate.zoomTo(3));
          }
        });
  }
}
