import 'package:rxdart/rxdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController {
  BehaviorSubject<GoogleMapController> _controller = BehaviorSubject();
  Observable<GoogleMapController> get stream$ => _controller.stream;
  GoogleMapController get current => _controller.value;
  set set(value) => _controller.add(value);
}
