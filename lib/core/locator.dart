import 'package:get_it/get_it.dart';
import 'package:yoo_se/logic/dynamic_links.dart';
import 'package:yoo_se/logic/auth.dart';
import 'package:yoo_se/logic/locationServer.dart';
import 'package:yoo_se/logic/groups.dart';
import 'package:yoo_se/logic/mapController.dart';

GetIt locator = new GetIt();

void setupLocator() {
  locator.registerSingleton<AuthService>(AuthService());
  locator.registerSingleton<LocationServer>(LocationServer());
  locator.registerLazySingleton<GroupService>(() => GroupService());
  locator.registerLazySingleton<MapController>(() => MapController());
  locator.registerSingleton<LinksService>(LinksService());
}
