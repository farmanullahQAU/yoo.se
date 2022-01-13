import 'package:geolocator/geolocator.dart' as geoLoc;
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class LocationServer {
  Location _loc = Location();

  BehaviorSubject<LocationData> _location = BehaviorSubject();
  Observable<LocationData> get stream$ => _location.stream;
  LocationData get current {
    update();
    return _location.value;
  }

  set last(LocationData loc) => _location.add(loc);

  LocationServer() {
    update();
  }
  Future<LocationData> update() async {
    bool permission = await _loc.hasPermission() == PermissionStatus.GRANTED;
    if (permission) {
      // The usage of two location packages is not ideal but implemented since there seems to be an issue with the getLocation method in the "location" package
      final l = await geoLoc.Geolocator()
          .getCurrentPosition(desiredAccuracy: geoLoc.LocationAccuracy.high);
      return last = LocationData.fromMap(
          {'latitude': l.latitude, 'longitude': l.longitude});
    } else {
      permission = await _loc.requestPermission() == PermissionStatus.GRANTED;
      update();
    }
  }
}
