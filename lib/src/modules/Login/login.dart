
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voipmax/src/core/theme/dimensions.dart';
import 'package:voipmax/src/core/theme/text_theme.dart';
import 'package:voipmax/src/modules/Login/widgets.dart';

import '../../component/button.dart';
import '../../core/theme/color_theme.dart';
import '../../routes/routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      // top: true,
      child: Container(
          padding: EdgeInsets.only(
            top: Get.height * .03,
            left: Get.width * .06,
            right: Get.width * .06,
          ),
          height: Get.height,
          width: Get.width,
          color: backGroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              backBtn(),
              voipMaxLogo(),
              spY(Get.height * .03),
              loginTitle(),
              spY(Get.height * .03),
              userNameField(),
              spY(Get.height * .04),
              passwordField(),
              spY(Get.height * .02),
              forgotPass(),
              spY(Get.height * .02),
              Button(
                  btnWidth: Get.width,
                  btnBackGroundColor: primaryColor,
                  btnChild: Text(
                    "Login",
                    style: textMedium.copyWith(color: backGroundColor),
                  ),
                  btnOnPressed: () {
                    Get.toNamed(Routes.LOGIN);
                  }),
              spY(Get.height * .02),
              divider(),
              spY(Get.height * .02),
              loginOptions(),
              spY(Get.height * .02),
              register(),
              spY(Get.height * .01),
            ],
          )),
    ));
  }
}