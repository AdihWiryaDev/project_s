import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  final plugin = DeviceInfoPlugin();
  final android = await plugin.androidInfo;

  final storageStatus = android.version.sdkInt < 33
      ? await Permission.storage.request()
      : PermissionStatus.granted;

  if (storageStatus == PermissionStatus.granted) {
    return true;
  }
  if (storageStatus == PermissionStatus.permanentlyDenied) {
    openAppSettings();
  }
  return true;
}

Future<void> requestPermissions() async {
  if (await Permission.manageExternalStorage.isGranted ||
      await Permission.storage.isGranted) {
    return;
  }

  if (await Permission.manageExternalStorage.isDenied) {
    await Permission.manageExternalStorage.request();
  } else {
    await Permission.storage.request();
  }
}

Future<void> askPermissions() async {
  final permissions = [
    Permission.location,
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.nearbyWifiDevices,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
  ];

  for (var permission in permissions) {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  if (await Permission.location.isPermanentlyDenied) {
    await openAppSettings();
  }
}
