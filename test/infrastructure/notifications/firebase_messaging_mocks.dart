// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

typedef Callback = Function(MethodCall call);

final MockFirebaseMessaging mockMessagingPlatform = MockFirebaseMessaging();

Future<T> neverEndingFuture<T>() async {
  while (true) {
    await Future.delayed(const Duration(minutes: 5));
  }
}

void setupFirebaseMessagingMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocks();

  // Mock Platform Interface Methods
  when(mockMessagingPlatform.delegateFor(app: anyNamed('app'))).thenReturn(mockMessagingPlatform);
  when(mockMessagingPlatform.setInitialValues(
    isAutoInitEnabled: anyNamed('isAutoInitEnabled'),
  )).thenReturn(mockMessagingPlatform);
}

class MockFirebaseMessaging extends Mock with MockPlatformInterfaceMixin implements FirebaseMessagingPlatform {
  MockFirebaseMessaging() {
    TestFirebaseMessagingPlatform();
  }

  @override
  bool get isAutoInitEnabled {
    return super
        .noSuchMethod(Invocation.getter(#isAutoInitEnabled), returnValue: true, returnValueForMissingStub: true);
  }

  @override
  FirebaseMessagingPlatform delegateFor({FirebaseApp? app}) {
    return super.noSuchMethod(
      Invocation.method(#delegateFor, [], {#app: app}),
      returnValue: TestFirebaseMessagingPlatform(),
      returnValueForMissingStub: TestFirebaseMessagingPlatform(),
    );
  }

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) {
    return super.noSuchMethod(
      Invocation.method(#setInitialValues, [], {#isAutoInitEnabled: isAutoInitEnabled}),
      returnValue: TestFirebaseMessagingPlatform(),
      returnValueForMissingStub: TestFirebaseMessagingPlatform(),
    );
  }

  @override
  Future<RemoteMessage?> getInitialMessage() {
    return super.noSuchMethod(
      Invocation.method(#getInitialMessage, []),
      returnValue: Future.value(null),
      returnValueForMissingStub: Future.value(null),
    );
  }

  @override
  Future<void> deleteToken() {
    return super.noSuchMethod(Invocation.method(#deleteToken, []),
        returnValue: Future<void>.value(), returnValueForMissingStub: Future<void>.value());
  }

  @override
  Future<String?> getAPNSToken() {
    return super.noSuchMethod(Invocation.method(#getAPNSToken, []),
        returnValue: Future<String>.value(''), returnValueForMissingStub: Future<String>.value(''));
  }

  @override
  Future<String> getToken({String? vapidKey}) {
    return super.noSuchMethod(Invocation.method(#getToken, [], {#vapidKey: vapidKey}),
        returnValue: Future<String>.value(''), returnValueForMissingStub: Future<String>.value(''));
  }

  @override
  Future<void> setAutoInitEnabled(bool? enabled) {
    return super.noSuchMethod(Invocation.method(#setAutoInitEnabled, [enabled]),
        returnValue: Future<void>.value(), returnValueForMissingStub: Future<void>.value());
  }

  @override
  Stream<String> get onTokenRefresh {
    return super.noSuchMethod(
      Invocation.getter(#onTokenRefresh),
      returnValue: const Stream<String>.empty(),
      returnValueForMissingStub: const Stream<String>.empty(),
    );
  }

  @override
  Future<NotificationSettings> requestPermission({
    bool? alert = true,
    bool? announcement = false,
    bool? badge = true,
    bool? carPlay = false,
    bool? criticalAlert = false,
    bool? provisional = false,
    bool? sound = true,
  }) {
    return super.noSuchMethod(
      Invocation.method(#requestPermission, [], {
        #alert: alert,
        #announcement: announcement,
        #badge: badge,
        #carPlay: carPlay,
        #criticalAlert: criticalAlert,
        #provisional: provisional,
        #sound: sound
      }),
      returnValue: Future.value(deniedNotificationSettings),
    );
  }

  @override
  Future<void> subscribeToTopic(String? topic) {
    return super.noSuchMethod(Invocation.method(#subscribeToTopic, [topic]),
        returnValue: Future<void>.value(), returnValueForMissingStub: Future<void>.value());
  }

  @override
  Future<void> unsubscribeFromTopic(String? topic) {
    return super.noSuchMethod(Invocation.method(#unsubscribeFromTopic, [topic]),
        returnValue: Future<void>.value(), returnValueForMissingStub: Future<void>.value());
  }

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    bool? alert = true,
    bool? badge = true,
    bool? sound = true,
  }) {
    return super.noSuchMethod(
        Invocation.method(#setForegroundNotificationPresentationOptions, [], {
          #alert: alert,
          #badge: badge,
          #sound: sound,
        }),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value());
  }
}

class TestFirebaseMessagingPlatform extends FirebaseMessagingPlatform {
  TestFirebaseMessagingPlatform() : super();
}

const NotificationSettings deniedNotificationSettings = NotificationSettings(
  authorizationStatus: AuthorizationStatus.denied,
  alert: AppleNotificationSetting.notSupported,
  announcement: AppleNotificationSetting.notSupported,
  badge: AppleNotificationSetting.notSupported,
  carPlay: AppleNotificationSetting.notSupported,
  lockScreen: AppleNotificationSetting.notSupported,
  notificationCenter: AppleNotificationSetting.notSupported,
  showPreviews: AppleShowPreviewSetting.notSupported,
  sound: AppleNotificationSetting.notSupported,
  timeSensitive: AppleNotificationSetting.notSupported,
  criticalAlert: AppleNotificationSetting.notSupported,
);

const NotificationSettings authorizedNotificationSettings = NotificationSettings(
  authorizationStatus: AuthorizationStatus.authorized,
  alert: AppleNotificationSetting.enabled,
  announcement: AppleNotificationSetting.enabled,
  badge: AppleNotificationSetting.enabled,
  carPlay: AppleNotificationSetting.enabled,
  lockScreen: AppleNotificationSetting.enabled,
  notificationCenter: AppleNotificationSetting.enabled,
  showPreviews: AppleShowPreviewSetting.always,
  sound: AppleNotificationSetting.enabled,
  timeSensitive: AppleNotificationSetting.enabled,
  criticalAlert: AppleNotificationSetting.enabled,
);
