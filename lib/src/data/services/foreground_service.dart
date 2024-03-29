import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:voipmax/src/bloc/bloc.dart';
import 'package:voipmax/src/repo.dart';

class MyTellForeGroundService extends Bloc {
  final notificationChannelId = 'MyTellForeGroundChannel';
  final notificationId = 01;
  FlutterBackgroundService foreGroundService = FlutterBackgroundService();
  late ServiceInstance localService;
  // MyTelRepo repo = Get.find();

  Future<void> startForeGroundService() async {
    await initializeService().then((value) async {
      await MyTellForeGroundService().foreGroundService.startService();
    });
  }

  Future<void> stopService() async {
    FlutterBackgroundService().invoke("stop_service", null);
  }

  static Future<void> onStartForeGround(ServiceInstance service) async {
    service.on("stop_service").listen((event) {
      service.stopSelf();
    });
    DartPluginRegistrant.ensureInitialized();
    MyTellForeGroundService().localService = service;
  }

  Future<void> initializeService() async {
    MyTelRepo repo = Get.find();
    MyTellForeGroundService().foreGroundService = FlutterBackgroundService();

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId, // id
      'MyTell foreGround service', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await MyTellForeGroundService().foreGroundService.configure(
          androidConfiguration: AndroidConfiguration(
            onStart: onStartForeGround,
            autoStart: false,
            isForegroundMode: true,
            notificationChannelId: notificationChannelId,
            initialNotificationTitle: repo.remoteUserDetails["callee"] ?? "",
            initialNotificationContent: repo.remoteUserDetails["caller"] ?? "",
            foregroundServiceNotificationId: notificationId,
          ),
          iosConfiguration: IosConfiguration(autoStart: false),
        );
  }

  static final MyTellForeGroundService _instance =
      MyTellForeGroundService.internal();
  factory MyTellForeGroundService() => _instance;
  MyTellForeGroundService.internal();
}
