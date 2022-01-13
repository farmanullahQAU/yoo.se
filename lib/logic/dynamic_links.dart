import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:yoo_se/core/constants.dart';
import 'package:yoo_se/core/locator.dart';
import 'package:yoo_se/logic/locationServer.dart';
import 'dart:io' show Platform;

class LinksService {
  final url = 'https://yoose.page.link';
  final fdl = FirebaseDynamicLinks.instance;
  final functions = FirebaseFunctions.instance;
  String lastLink;
  LocationServer _locationServer = locator.get<LocationServer>();
  var scaffoldKey;

  Future<String> generateLink(Map<String, String> data) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: url,
      link: Uri.https('yoo.se', 'location', data),
      androidParameters: AndroidParameters(
        packageName: packageName,
      ),
      iosParameters: IosParameters(bundleId: bundleID, appStoreId: appStoreID),
      navigationInfoParameters:
          NavigationInfoParameters(forcedRedirectEnabled: true),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: 'YOO.SE my real-time location',
          imageUrl: Uri.parse(
              'https://firebasestorage.googleapis.com/v0/b/yoose-70566.appspot.com/o/y.jpg?alt=media&token=8fb2869e-a2c8-44bc-8587-7962d0d3098f'),
          description: 'Click link to watch my current location live'),
    );
    ShortDynamicLink link = await parameters.buildShortLink();
    print(link.warnings);
    return link.shortUrl.toString();
  }

  Future<HttpsCallableResult> joinGroup(Uri link, String name) async {
    final HttpsCallable joinGroup = functions.httpsCallable("joinGroup"

    );

    if (_locationServer.current == null) {
      await _locationServer.update();
    }
    Map data = link.queryParameters;
    return joinGroup.call({
      'requested': data['gid'],
      'password': data['pass'],
      'lon': _locationServer.current.longitude,
      'lat': _locationServer.current.latitude,
      'name': name
    });
  }

  Future<void> runLink(Uri link, BuildContext context) async {
    if (link != null &&
        link.path == '/location' &&
        this.lastLink != link.toString()) {
      bool permission =
          await Location().hasPermission() == PermissionStatus.GRANTED;
      if (!permission) {
        permission =
            await Location().requestPermission() == PermissionStatus.GRANTED;
        if (!permission) {
          // TODO: add handler here
          return null;
        }
      }
      String name = await showDialog<String>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            void submit(String name) {
              Navigator.pop(context, name);
            }

            final nameController = TextEditingController();
            return SimpleDialog(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Choose name',
                  ),
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  maxLength: 10,
                  autocorrect: false,
                  autofocus: true,
                  onFieldSubmitted: (text) => submit(text),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: RaisedButton(
                    child: Text(
                      'Join',
                      style: TextStyle(color: mainColor),
                      textScaleFactor: 1.2,
                    ),
                    onPressed: () => submit(nameController.value.text),
                    color: Colors.white,
                  ),
                ),
              ],
              contentPadding: EdgeInsets.all(10),
            );
          });
      if (Platform.isIOS) {
        this.lastLink = link.toString();
      }
      if (name == '') {
        return null;
      }
      return joinGroup(link, name).then(
        (res) {
          return scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text(
                  res.data != null ? 'Successfully joined' : 'Failed to join'),
            ),
          );
        },
      );
    }
  }

  Future<void> checkForLink(BuildContext context) async {
    final PendingDynamicLinkData linkd =
        await FirebaseDynamicLinks.instance.getInitialLink();
    this.runLink(linkd?.link, context);
  }
}
