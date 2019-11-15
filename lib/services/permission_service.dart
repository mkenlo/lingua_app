import 'dart:async';
import 'dart:io' show Directory;
import 'package:permission_handler/permission_handler.dart';

import '../config.dart';

class PermissionService {
  final PermissionHandler _permissionHandler = PermissionHandler();
  final List<PermissionGroup> _requiredPermissions = [
    PermissionGroup.microphone,
    PermissionGroup.storage
  ];


  Future<bool> hasPermission(PermissionGroup permission) async {
    var permissionStatus =
    await _permissionHandler.checkPermissionStatus(permission);
    return permissionStatus == PermissionStatus.granted;
  }


  Future<bool> _requestPermission(List<PermissionGroup> permissions) async {
    var result = await _permissionHandler.requestPermissions(permissions);
    bool granted = true;
    result.forEach((permission, permissionStatus) {
      if (permissionStatus != PermissionStatus.granted)
        granted = granted && false;
    });
    if(granted){ // create app Directory files
      new Directory(recordStorage).createSync();
    }
    return granted;
  }

  Future<bool> requestAppPermission() async {
    return _requestPermission(_requiredPermissions);
  }

}


