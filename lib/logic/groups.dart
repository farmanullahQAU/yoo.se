import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yoo_se/core/locator.dart';
import 'package:yoo_se/logic/auth.dart';
import 'package:yoo_se/logic/locationServer.dart';
import 'package:yoo_se/logic/mapController.dart';
import 'package:yoo_se/logic/utility_functions.dart';

final userFocusZoom = 17.0;

class UserLocation {
  String name;
  DateTime lastSeen;
  LatLng position;
  String uid;
  bool self;
  bool admin;

  UserLocation({this.name, this.lastSeen, LocationData position, this.uid}) {
    this.position = LatLng(position.latitude, position.longitude);
  }

  UserLocation.fromMap(map) {
    this.position = LatLng(map['lat'].toDouble(), map['lon'].toDouble());
    this.lastSeen = map['lastSeen']?.toDate();
    this.uid = map['uid'];
    this.name = map['name'];
  }

  Map<String, dynamic> toMap() {
    return Map<String, dynamic>.from({
      'name': this.name,
      'lastSeen': FieldValue.serverTimestamp(),
      'lat': this.position.latitude,
      'lon': this.position.longitude,
      'uid': this.uid,
    });
  }

  focus(GoogleMapController controller) {
    controller.animateCamera(
        CameraUpdate.newLatLngZoom(this.position, userFocusZoom));
  }
}

class Group {
  String password;
  List<String> members;
  Map<String, UserLocation> locations;
  int deletion;
  String id;
  DateTime created;
  int maxMembers;

  Group();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> nMap = Map();
    this.locations.forEach((key, value) => nMap[key] = value.toMap());
    return Map<String, dynamic>.from({
      'password': this.password,
      'members': this.members,
      'locations': nMap,
      'deletion': this.deletion,
      'created': FieldValue.serverTimestamp(),
      'maxMembers': this.maxMembers
    });
  }

  Group.fromMap(map, this.id) {
    locations = new Map();

    map['locations'].forEach((key, value) {
      return locations[key] = UserLocation.fromMap(value);
    });

    this.password = map['password'];
    this.members = List<String>.from(map['members']);
    this.locations = locations;
    this.deletion = map['deletion'];
    this.created = map['created']?.toDate();
    this.maxMembers = map['maxMembers'];
  }
  LatLngBounds calcBound() {
    double lowestLat;
    double lowestLon;
    double highestLat;
    double highestLon;
    this.locations.values.toList().forEach((UserLocation uLoc) {
      double lat = uLoc.position.latitude;
      double lon = uLoc.position.longitude;
      if (lowestLat == null || lat < lowestLat) {
        lowestLat = lat;
      }
      if (lowestLon == null || lon < lowestLon) {
        lowestLon = lon;
      }

      if (highestLat == null || lat > highestLat) {
        highestLat = lat;
      }
      if (highestLon == null || lon > highestLon) {
        highestLon = lon;
      }
    });
    return LatLngBounds(
        southwest: LatLng(lowestLat, lowestLon),
        northeast: LatLng(highestLat, highestLon));
  }

  showAll() {
    MapController _mapController = locator.get<MapController>();
    GoogleMapController controller = _mapController.current;
    final bounds = calcBound();
    controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 20.0));
  }
}

class GroupService {
  LocationServer locServer = locator.get<LocationServer>();
  AuthService _authService = locator.get<AuthService>();
  FirebaseFunctions functions = FirebaseFunctions.instance;
  Location loc = new Location();
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription locationSub;
  int lastUpdate = DateTime.now().millisecondsSinceEpoch;

  BehaviorSubject<Group> _currentGroup = BehaviorSubject();
  Observable<Group> get stream$ => _currentGroup.stream;
  Group get current => _currentGroup.value;
  set group(Group value) => _currentGroup.add(value);

  bool follow = false;

  GroupService() {
    // These setting affect both battery consumption and the amount of firestore reads / writes.
    loc.changeSettings(
        accuracy: LocationAccuracy.HIGH, interval: 1000, distanceFilter: 5);
  }

  Future<void> createGroup(int deletion, int maxMembers, String name) async {
    Group nGroup = new Group();
    nGroup.deletion = deletion;
    nGroup.members = [_authService.current.uid];
    nGroup.password = createCryptoRandomString(15);
    nGroup.maxMembers = maxMembers;
    nGroup.locations = {
      _authService.current.uid: UserLocation(
          position: locServer.current,
          name: name,
          uid: _authService.current.uid)
    };
    DocumentReference ref =
        await _firestore.collection('groups').add(nGroup.toMap());
  }

  leaveGroup() {}

  deleteGroup() {
    _firestore.collection('groups').doc(current.id).delete();
  }

  startUploadStream() async {
    bool permission = await loc.hasPermission() == PermissionStatus.GRANTED;
    if (!permission) {
      permission = await loc.requestPermission() == PermissionStatus.GRANTED;
      if (!permission) {
        // TODO: add handler here
        return null;
      }
    }
    if (locationSub != null) {
      if (locationSub.isPaused) {
        locationSub.resume();
      }
    } else {
      locationSub = loc.onLocationChanged().listen((LocationData location) {
        // callback declaration
        locServer.last = location;
        uploadLocation(location);
      });
    }
  }

  stopUploadStream() {
    locationSub?.pause();
  }

  void uploadLocation(LocationData loc) {
    // This if statements caps the min upload interval to minInterval
    int minInterval = 1000 * 2;
    int now = DateTime.now().millisecondsSinceEpoch;
    if (lastUpdate + minInterval <= now) {
      final uid = _authService.current.uid;
      _firestore.collection('groups').doc(current.id).update({
        'locations.$uid.lat': loc.latitude,
        'locations.$uid.lon': loc.longitude,
        'locations.$uid.lastSeen': FieldValue.serverTimestamp()
      });
      lastUpdate = now;
    }
  }
}
