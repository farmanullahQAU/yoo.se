import 'package:location/location.dart';
import 'dart:convert';
import 'dart:math';

Map<String, dynamic> locationDataToMap(LocationData loc) {
  return Map.from({
    'latitude': loc.latitude,
    'longitude': loc.longitude,
    'accuracy': loc.accuracy,
    'altitude': loc.altitude,
    'speed': loc.speed,
    'speed_accuracy': loc.speedAccuracy,
    'heading': loc.heading,
    'time': loc.time
  });
}

String createCryptoRandomString([int length = 32]) {
  final Random _random = Random.secure();
  var values = List<int>.generate(length, (i) => _random.nextInt(256));
  return base64Url.encode(values);
}
