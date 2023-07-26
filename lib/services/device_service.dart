import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solarisdemo/models/device_binding.dart';
import 'package:solarisdemo/models/device_consent.dart';

import '../models/device_activity.dart';
import 'api_service.dart';

const String _defaultKeyType = 'ecdsa-p256';
const String _defaultChallengeType = 'sms';
const DeviceBindingKeyPurposeType _defaultKeyPurposeType =
    DeviceBindingKeyPurposeType.unrestricted;
SmsChallenge _defaultSmsChallenge = SmsChallenge(appSignature: 'e2e-e2e-e2e');
const DeviceBindingLanguageType _defaultLanguageType =
    DeviceBindingLanguageType.en;

MethodChannel _platform =
    const MethodChannel('com.thinslices.solarisdemo/native');

class DeviceUtilService {
  static Future<String?> getDeviceFingerprint(String consentId) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _getAndroidDeviceFingerprint(consentId);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _getIosDeviceFingerprint(consentId);
    }
    return '';
  }

  static Future<Map<Object?, Object?>> getECDSAP256KeyPair() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _getAndroidECDSAP256KeyPair();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _getIosECDSAP256KeyPair();
    }
    return {};
  }

  static Future<String?> signMessage(String message, String privateKey) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _signMessageOnAndroid(message, privateKey);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _signMessageOnIos(message, privateKey);
    }
    return '';
  }

  static Future<String?> getDeviceConsentId() async {
    return await _getDeviceConsentId();
  }

  static Future<void> saveDeviceConsentId(String consentId) async {
    await _setDeviceConsentId(consentId);
  }

  static Future<String?> getPublicKeyFromCache() async {
    return await _getPublicKeyFromCache();
  }

  static Future<String?> getPrivateKeyFromCache() async {
    return await _getPrivateKeyFromCache();
  }

  static Future<void> saveKeyPairIntoCache(
      Map<Object?, Object?> keyPair) async {
    await _setKeyPairIntoCache(keyPair);
  }

  static Future<String?> getDeviceIdFromCache() async {
    return await _getDeviceIdFromCache();
  }

  static Future<void> saveDeviceIdIntoCache(String deviceId) async {
    await _setDeviceIdIntoCache(deviceId);
  }

  static Future<CacheCredentials?> getCredentialsFromCache() async {
    return await _getCredentialsFromCache();
  }

  static Future<void> saveCredentialsInCache(
      String email, String password) async {
    await _setCredentialsInCache(email, password);
  }
}

Future<void> _setDeviceIdIntoCache(String deviceId) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('device_id', deviceId);
}

Future<String?> _getDeviceIdFromCache() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString('device_id');
  return deviceId ?? '';
}

Future<void> _setCredentialsInCache(String email, String password) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('email', email);
  prefs.setString('password', password);
}

Future<CacheCredentials?> _getCredentialsFromCache() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.clear();
  String? email = prefs.getString('email');
  String? password = prefs.getString('password');
  String? deviceId = await _getDeviceIdFromCache();

  return CacheCredentials(
    email: email,
    password: password,
    deviceId: deviceId,
  );
}

class CacheCredentials {
  String? email;
  String? password;
  String? deviceId;

  CacheCredentials({
    required this.email,
    required this.password,
    required this.deviceId,
  });
}

Future<String> _getPublicKeyFromCache() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? publicKey = prefs.getString('publicKey');
  return publicKey ?? '';
}

Future<String> _getPrivateKeyFromCache() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? privateKey = prefs.getString('privateKey');
  return privateKey ?? '';
}

Future<void> _setKeyPairIntoCache(Map<Object?, Object?> keyPair) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('publicKey', keyPair['publicKey'] as String);
  prefs.setString('privateKey', keyPair['privateKey'] as String);
}

Future<String>? _getAndroidDeviceFingerprint(String deviceConsentId) async {
  try {
    final result = await _platform.invokeMethod(
      'getDeviceFingerprint',
      {'consentId': deviceConsentId},
    );
    return result;
  } on PlatformException catch (e) {
    throw Exception(e.message);
  }
}

Future<String>? _getIosDeviceFingerprint(String deviceConsentId) async {
  try {
    final result = await _platform.invokeMethod(
      'getIosDeviceFingerprint',
      {'consentId': deviceConsentId},
    );
    return result;
  } on PlatformException catch (e) {
    throw Exception(e.message);
  }
}

Future<Map<Object?, Object?>> _getAndroidECDSAP256KeyPair() async {
  try {
    final result = await _platform.invokeMethod(
      'generateECDSAP256KeyPair',
    );
    return result;
  } on PlatformException catch (e) {
    throw Exception(e.message);
  }
}

Future<Map<Object?, Object?>> _getIosECDSAP256KeyPair() async {
  try {
    final result = await _platform.invokeMethod(
      'generateIosECDSAP256KeyPair',
    );
    return result;
  } on PlatformException catch (e) {
    throw Exception(e.message);
  }
}

Future<String?> _signMessageOnAndroid(String message, String privateKey) async {
  try {
    final signature = await _platform.invokeMethod<String>(
      'signMessage',
      {'message': message, 'privateKey': privateKey},
    );
    return signature;
  } on PlatformException catch (e) {
    throw Exception(e.message);
  }
}

Future<String?> _signMessageOnIos(String message, String privateKey) async {
  try {
    final signature = await _platform.invokeMethod<String>(
      'signMessage',
      {'message': message, 'privateKeyHex': privateKey},
    );
    return signature;
  } on PlatformException catch (e) {
    throw Exception(e.message);
  }
}

Future<String> _getDeviceConsentId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? deviceConsentId = prefs.getString('device_consent_id');
  return deviceConsentId ?? '';
}

Future<void> _setDeviceConsentId(String deviceConsentId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('device_consent_id', deviceConsentId);
}

class DeviceService extends ApiService {
  DeviceService({required super.user});

  Future<CreateDeviceConsentResponse>? createDeviceConsent() async {
    try {
      String path = 'person/device/consent';

      CreateDeviceConsentRequest reqBody = CreateDeviceConsentRequest(
        confirmedAt: DateTime.now().toUtc(),
        eventType: DeviceConsentEventType.APPROVED,
      );

      Map<String, dynamic> req = reqBody.toJson();

      var data = await post(
        path,
        body: req,
      );
      return CreateDeviceConsentResponse.fromJson(data);
    } catch (e) {
      throw Exception("Failed to load device consent");
    }
  }

  Future<dynamic> createDeviceActivity(DeviceActivityType activityType) async {
    try {
      String path = 'person/device/activity';

      String? consentId = await _getDeviceConsentId();
      if (consentId.isEmpty) {
        throw Exception('Consent Id not found');
      }

      String? deviceFingerprint =
          await DeviceUtilService.getDeviceFingerprint(consentId);
      if (deviceFingerprint == null || deviceFingerprint.isEmpty) {
        throw Exception('Device Fingerprint not found');
      }

      await post(
        path,
        body: CreateDeviceActivityRequest(
          activityType: activityType,
          deviceData: deviceFingerprint,
        ).toJson(),
      );
      return;
    } catch (e) {
      throw Exception("Failed to load device activity");
    }
  }

  Future<CreateDeviceBindingResponse> createDeviceBinding(
      String personId) async {
    try {
      String path = 'person/device/binding';

      String? consentId = await _getDeviceConsentId();
      if (consentId.isEmpty) {
        throw Exception('Consent Id not found');
      }

      var keyPair = await DeviceUtilService.getECDSAP256KeyPair();
      if (keyPair.isEmpty) {
        throw Exception('Key Pair not found');
      }

      await DeviceUtilService.saveKeyPairIntoCache(keyPair);

      String publicKey = keyPair['publicKey'] as String;

      String? deviceData =
          await DeviceUtilService.getDeviceFingerprint(consentId);
      if (deviceData == null || deviceData.isEmpty) {
        throw Exception('Device Fingerprint not found');
      }

      var data = await post(
        path,
        body: CreateDeviceBindingRequest(
                personId: personId,
                keyType: _defaultKeyType,
                challengeType: _defaultChallengeType,
                key: publicKey,
                keyPurpose: _defaultKeyPurposeType,
                name: 'Test Device',
                smsChallenge: _defaultSmsChallenge,
                language: _defaultLanguageType,
                deviceData: deviceData)
            .toJson(),
      );
      var response = CreateDeviceBindingResponse.fromJson(data);
      await DeviceUtilService.saveDeviceIdIntoCache(response.id);
      return response;
    } catch (e) {
      throw Exception('Failed to create device binding - $e');
    }
  }

  Future<void> verifyDeviceBindingSignature(String tan) async {
    try {
      String? deviceId = await DeviceUtilService.getDeviceIdFromCache();
      if (deviceId == null) {
        throw Exception('Device Id not found');
      }

      String? consentId = await DeviceUtilService.getDeviceConsentId();
      if (consentId == null) {
        throw Exception('Consent Id not found');
      }

      String? privateKey = await DeviceUtilService.getPrivateKeyFromCache();
      if (privateKey == null) {
        throw Exception('Private key not found');
      }

      String? signature = await DeviceUtilService.signMessage(tan, privateKey);
      if (signature == null) {
        throw Exception('Signature not found');
      }

      String path = 'person/device/verify_signature/$deviceId';

      String? deviceFingerPrint =
          await DeviceUtilService.getDeviceFingerprint(consentId);
      if (deviceFingerPrint == null || deviceFingerPrint.isEmpty) {
        throw Exception('Device Fingerprint not found');
      }

      await post(
        path,
        body: VerifyDeviceSignatureChallengeRequest(
          deviceData: deviceFingerPrint,
          signature: signature,
        ).toJson(),
      );
    } catch (e) {
      throw Exception('Failed to verify device signature - $e');
    }
  }
}
