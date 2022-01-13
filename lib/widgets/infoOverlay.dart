import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yoo_se/core/constants.dart';
import 'package:yoo_se/core/locator.dart';
import 'package:yoo_se/logic/groups.dart';
import 'package:yoo_se/widgets/countdown.dart';

class TutorialOverlay extends ModalRoute<dynamic> {
  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.4);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: _buildOverlayContent(context),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    GroupService _groupService = locator.get<GroupService>();
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(),
          _groupService.current == null
              ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'People location\nReal-time location\n',
                              textScaleFactor: 1.10,
                              style: TextStyle(fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Easy, fast and most private way to see where everyone is in real time for a limited time.\nShare your real-time location and find each other.',
                              textScaleFactor: 1.05,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'No account needed. Just share link\n',
                              textScaleFactor: 1.05,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Share your real-time location data with 1-13 people. Each team can consist of at most 13 people who are able to see each other’s location in real time.\n\n'
                              'View each other\'s real-time location on the map in the app. Your location data is live for a limited time. When the time is up, all your real-time location information is deleted - we keep nothing.',
                              textScaleFactor: 1.07,
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          'images/qr-code.png',
                          scale: 2,
                        ),
                        Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                '© 2020 Joachim von Rost- ITS A WRAP AB\n'
                                'All rights reserved',
                                textScaleFactor: 0.9,
                                textAlign: TextAlign.center,
                              ),
                              InkWell(
                                child: Text(
                                  "www.yoo.se",
                                  style: TextStyle(
                                      color: Colors.blueAccent,
                                      decoration: TextDecoration.underline),
                                  textScaleFactor: 1.0,
                                ),
                                onTap: () async {
                                  if (await canLaunch("https://yoo.se/")) {
                                    await launch("https://yoo.se/");
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          Builder(
              builder: (context) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: (_groupService.current == null)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  color: mainColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                              ),
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: FlatButton(
                                  child: Text(
                                    'STOP',
                                    style: textStyle,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  onPressed: () =>
                                      Navigator.pop(context, 'stop'),
                                  color: mainColor,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Card(
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                        color: mainColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                      ),
                                    ),
                                    onTap: () => Navigator.pop(context),
                                  ),
                                  CountDown(),
                                  Container(
                                    width: 60,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ))),
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}

class InfoText extends StatelessWidget {
  final String text;
  InfoText(this.text);
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: Card(
        color: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
          child: Text(
            text,
            textScaleFactor: 1.2,
            style: TextStyle(color: mainColor),
          ),
        ),
      ),
    );
  }
}
