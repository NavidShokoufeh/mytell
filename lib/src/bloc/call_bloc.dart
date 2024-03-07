// ignore_for_file: unnecessary_nullable_for_final_variable_declarations, unused_field
import 'dart:async';

import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:uuid/uuid.dart';
import 'package:voipmax/src/bloc/bloc.dart';

class CallBloc extends Bloc with GetSingleTickerProviderStateMixin {
  late RTCVideoRenderer? localRenderer = RTCVideoRenderer();
  late RTCVideoRenderer? remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RxString callStatus = "".obs;
  late Call? callStateController;
  RxBool isOnlyVoice = false.obs;
  late Timer _timer;
  RxString timeLabel = '00:00'.obs;
  RxBool audioMuted = false.obs;
  RxBool videoMuted = false.obs;
  RxBool speakerOn = false.obs;
  RxBool hold = false.obs;

  Future<void> initRenderers() async {
    if (localRenderer != null) {
      await localRenderer!.initialize();
    }
    if (remoteRenderer != null) {
      await remoteRenderer!.initialize();
    }
  }

  void callOnStreams(CallState event) async {
    MediaStream? stream = event.stream;
    _startTimer();
    if (event.originator == 'local') {
      if (localRenderer != null) {
        localRenderer!.srcObject = stream;
      }

      _localStream = stream;
    }
    if (event.originator == 'remote') {
      if (remoteRenderer != null) {
        remoteRenderer!.srcObject = stream;
      }
      _remoteStream = stream;
    }

    update();
  }

  onHangUp() {
    // callStateController.hangup({'status_code': 603});
    _timer.cancel();
    timeLabel.value = '00:00';
    _cleanUp();
    Get.back();
  }

  void _cleanUp() {
    if (_localStream == null) return;
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    _localStream!.dispose();
    _localStream = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      Duration duration = Duration(seconds: timer.tick);
      // if (mounted) {
      // setState(() {
      timeLabel.value = [duration.inMinutes, duration.inSeconds]
          .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
          .join(':');
      // });
      // } else {
      //   _timer.cancel();
      // }
    });
  }

  void switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks()[0]);
      // setState(() {
      //   _mirror = !_mirror;
      // });
    }
  }

  void muteAudio() {
    if (audioMuted.value) {
      audioMuted.value = false;
      callStateController!.unmute(true, false);
    } else {
      audioMuted.value = true;
      callStateController!.mute(true, false);
    }
  }

  void muteVideo() {
    if (videoMuted.value) {
      callStateController!.unmute(false, true);
    } else {
      callStateController!.mute(false, true);
    }
  }

  void handleHold() {
    if (hold.value) {
      hold.value = false;
      callStateController!.unhold();
    } else {
      hold.value = true;
      callStateController!.hold();
    }
  }

  void showIncomeCall({required String caller, required String callee}) async {
    CallKitParams callKitParams = CallKitParams(
      id: const Uuid().v4(),
      nameCaller: callee,
      appName: 'My tel',
      // avatar: callee[0],
      handle: caller,
      type: 0,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Missed call',
        // callbackText: 'Call back',
      ),
      duration: 30000,
      android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          actionColor: '#4CAF50',
          textColor: '#ffffff',
          incomingCallNotificationChannelName: "My tel Incoming Call",
          missedCallNotificationChannelName: "My tel Missed Call",
          isShowCallID: true),
      ios: const IOSParams(
        iconName: 'My tel',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    localRenderer!.dispose();
    remoteRenderer!.dispose();
  }
}