import 'package:flutter/material.dart';

class PermDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          'Please give YOO.SE access to your location for the app to function properly.'),
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
