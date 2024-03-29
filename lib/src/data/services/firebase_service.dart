import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:voipmax/firebase_options.dart';
import 'package:voipmax/src/bloc/bloc.dart';
import 'package:voipmax/src/bloc/call_bloc.dart';
import 'package:voipmax/src/bloc/login_bloc.dart';
import 'package:voipmax/src/bloc/sip_bloc.dart';
import 'package:voipmax/src/repo.dart';

class MyTelFirebaseServices extends Bloc {
  LoginBloc loginController = Get.find();
  MyTelRepo repo = MyTelRepo();
  late AndroidNotificationChannel channel;
  bool isFlutterLocalNotificationsInitialized = false;
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  RxInt remainingDays = 0.obs;
  CallBloc callController = Get.find();
  SIPBloc sipController = Get.put(SIPBloc(), permanent: true);

  // Future<void> _handleMessage(RemoteMessage message) async {
  //   await Firebase.initializeApp(
  //       options: DefaultFirebaseOptions.currentPlatform);
  // }

  Future<void> showFlutterNotification(RemoteMessage message) async {
    if (message.data.containsKey("callee")) {
      if (callController.callStateController != null) {
        if (callController.callStateController?.state !=
            CallStateEnum.CALL_INITIATION) return;
      }

      await loginController.login(isPush: true);
      sipController.register();
      callController.showIncomeCall(
          caller: message.data["caller"], callee: message.data["callee"]);
    }
    await setupFlutterNotifications();
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'ArpaVpn notification',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future init() async {
    final String? pushNotifToken;
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // FirebaseMessaging.onBackgroundMessage(showFlutterNotification);
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    if (defaultTargetPlatform == TargetPlatform.android) {
      pushNotifToken = await FirebaseMessaging.instance.getToken();
    } else {
      pushNotifToken = await FirebaseMessaging.instance.getAPNSToken();
    }
    repo.fcmToken = pushNotifToken;
    print("fcmToken : $pushNotifToken");

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  static final MyTelFirebaseServices _instance =
      MyTelFirebaseServices.internal();
  factory MyTelFirebaseServices() => _instance;
  MyTelFirebaseServices.internal();
}
