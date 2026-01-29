import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    try {
      return await auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) return false;

      final canCheckBiometrics = await auth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      return await auth.authenticate(
        localizedReason: 'Please authenticate to access HRMS',
      );
    } on PlatformException {
      return false;
    }
  }
}
