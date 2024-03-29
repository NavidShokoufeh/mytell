// import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:voipmax/src/bloc/bloc.dart';
import 'package:voipmax/src/bloc/sip_bloc.dart';
import 'package:voipmax/src/repo.dart';

class DialPadBloc extends Bloc {
  final SIPBloc sipController = Get.find();
  MyTelRepo repo = MyTelRepo();

  Future makeCall([bool voiceOnly = false, String? dest]) async {
    sipController.makeCall(voiceOnly, dest);
  }

  @override
  void onInit() {
    super.onInit();
  }
}
