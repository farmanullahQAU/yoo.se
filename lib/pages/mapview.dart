import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:yoo_se/core/constants.dart';
import 'package:yoo_se/core/locator.dart';
import 'package:yoo_se/logic/dynamic_links.dart';
import 'package:yoo_se/logic/groups.dart';
import 'package:yoo_se/logic/locationServer.dart';
import 'package:yoo_se/logic/mapController.dart';
import 'package:yoo_se/widgets/fab.dart';
import 'package:yoo_se/widgets/followButton.dart';
import 'package:geolocator/geolocator.dart' as geoLoc;

class MapView extends StatefulWidget {
  MapView();

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with WidgetsBindingObserver {
  final textStyle = TextStyle(color: Colors.white);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  BitmapDescriptor img;
  LocationServer _locationServer = locator.get<LocationServer>();
  MapController _mapController = locator.get<MapController>();
  LinksService _linksService = locator.get<LinksService>();
  GroupService _groupService = locator.get<GroupService>();
  bool permission = false;

  static final CameraPosition stockholm = CameraPosition(
    target: LatLng(59.33, 18.06),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _linksService.checkForLink(context);
    if (Platform.isIOS) {
      WidgetsBinding.instance.addObserver(this);
    }
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (link) => this._linksService.runLink(link.link, context));
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 1000), () async {
        _linksService.checkForLink(context);
      });
    }
  }

  Widget build(BuildContext context) {
    double pixel_width = MediaQuery.of(context).devicePixelRatio *
        MediaQuery.of(context).size.width;
    _linksService.scaffoldKey = _scaffoldKey;
    Group group = Provider.of<Group>(context);
    BitmapDescriptor.fromAssetImage(createLocalImageConfiguration(context),
            pixel_width > 1000.0 ? 'images/2xicon.png' : 'images/icon.png')
        .then((value) {
      img = value;
    }).catchError((err) {
      print(err);
    });
    if (!permission) {
      Location().hasPermission().then((value) {
        setState(() {
          permission = value == PermissionStatus.GRANTED;
        });
      });
    }

    if (permission) {
      /*
      group?.locations?.values?.forEach((UserLocation user) {
        mapController
            ?.showMarkerInfoWindow(new MarkerId(user.uid));
      });
       */
      _locationServer.update();
      List<Marker> markers = [];
      group?.locations?.values?.forEach((UserLocation user) {
        markers.add(
          Marker(
              markerId: MarkerId(user.uid),
              position: user.position,
              onTap: () => _groupService.follow = false,
              infoWindow: InfoWindow(
                  onTap: () {
                    _groupService.follow = false;
                    return user.focus(mapController);
                  },
                  title: Platform.isIOS ? '' : '${user.name.toString()}',
                  snippet: Platform.isIOS
                      ? '${user.name.toString()}\n${timeago.format(user.lastSeen ?? DateTime.now(), locale: 'en_short')}'
                      : '${timeago.format(user.lastSeen ?? DateTime.now(), locale: 'en_short')}'),
              icon: img,
              anchor: Offset(0.5, 0.5)),
        );
      });

      return Scaffold(
          key: _scaffoldKey,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: Stack(
            children: <Widget>[
              Container(
                child: GoogleMap(
                  padding: EdgeInsets.fromLTRB(
                      0,
                      MediaQuery.of(context).padding.top + 30,
                      0,
                      MediaQuery.of(context).padding.bottom + 45),
                  mapType: MapType.normal,
                  initialCameraPosition: stockholm,
                  onMapCreated: (GoogleMapController controller) async {
                    mapController = controller;
                    _mapController.set = controller;
                    _groupService.follow = false;
                    final l = await geoLoc.Geolocator().getLastKnownPosition(
                        desiredAccuracy: geoLoc.LocationAccuracy.high);
                    if (l.longitude != null) {
                      mapController.animateCamera(CameraUpdate.newLatLngZoom(
                          LatLng(l.latitude, l.longitude), userFocusZoom));
                    }
                  },
                  myLocationEnabled: group == null,
                  myLocationButtonEnabled: false,
                  markers: Set.of(markers),
                ),
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                left: 0.0,
                child: BottomBar(),
              ),
              Positioned(
                right: 0.0,
                top: 0.0,
                left: 0.0,
                child: AppBar(
                  leading: FollowButton(),
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  title: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'YOO.SE',
                        textScaleFactor: 1.5,
                        style: textStyle.copyWith(color: mainColor),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.my_location,
                      ),
                      iconSize: 40,
                      color: mainColor,
                      onPressed: () async {
                        _groupService.follow = false;
                        final l = await geoLoc.Geolocator()
                            .getLastKnownPosition(
                                desiredAccuracy: geoLoc.LocationAccuracy.high);
                        if (l.longitude != null) {
                          mapController.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                  LatLng(l.latitude, l.longitude),
                                  userFocusZoom));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ));
    } else {
      Location().requestPermission();
      return Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'YOO.SE needs permission to your location, please change this in settings.'),
          ],
        )),
      );
    }
  }
}
