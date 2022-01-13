import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoo_se/core/constants.dart';
import 'package:yoo_se/core/locator.dart';
import 'package:yoo_se/logic/auth.dart';
import 'package:yoo_se/logic/groups.dart';
import 'package:yoo_se/pages/mapview.dart';
import 'package:firebase_core/firebase_core.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MyApp());
  setupLocator();
  AuthService auth = locator.get<AuthService>();
  auth.regUser();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GroupService _groupService = locator.get<GroupService>();
  AuthService auth = locator.get<AuthService>();
  final firestore = FirebaseFirestore.instance;
  bool uploading = false;
  int lastMembers = 0;
  FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute: '/',
        routes: {
          '/map': (context) => MapView(),
        },
        theme: ThemeData(
          primaryColor: mainColor,
        ),
        home: StreamBuilder<User>(
            stream: auth.stream$,
            builder: (context, snapshot) {
              if (snapshot?.data != null) {
                return StreamProvider<Group>.value(
                  value: firestore
                      .collection('groups')
                      .where('members', arrayContains: snapshot.data.uid)
                      .limit(1)
                      .snapshots()
                      .map((QuerySnapshot event) {
                    Group _g;
                    if (event.docs.isNotEmpty) {
                      _g = new Group.fromMap(event.docs.first.data,
                          event.docs.first.id);
                      if (lastMembers != _g.members.length &&
                          _g.members.length > 1) {
                        _g.showAll();
                        lastMembers = _g.members.length;
                      }
                      // member of group
                      if (!uploading) {
                        _groupService.startUploadStream();
                        uploading = true;
                      }
                    } else {
                      _groupService.stopUploadStream();
                      lastMembers = 0;
                      uploading = false;
                      _groupService.follow = false;
                      _g = null;
                    }

                    _groupService.group = _g;
                    return _g;
                  }),
                  child: MapView(),
                );
              }
              return Scaffold(
                body: Center(
                  child: Text('Loading...'),
                ),
              );
            }));
  }
}
