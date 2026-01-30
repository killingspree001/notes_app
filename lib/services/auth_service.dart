import 'package:local_auth/local_auth.dart';
// If AuthenticationOptions is not found, it might be in a sub-package or the version is old.
// For now, I'll use the basic call which is most compatible.

class AuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticate() async {
    try {
      if (!await isBiometricAvailable()) return false;
      
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access your secure notes',
      );
    } catch (e) {
      return false;
    }
  }
}
