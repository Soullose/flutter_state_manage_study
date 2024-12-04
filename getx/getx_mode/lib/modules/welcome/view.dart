import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'index.dart';
import 'package:getx_mode/style/index.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({Key? key}) : super(key: key);

  Widget _buildPageHeadTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 260),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          // color: AppColor.grayColor,
          fontWeight: FontWeight.bold,
          fontSize: 45.sp,
          fontFamily: 'NotoSansSC',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColor.primaryColor,
      body: SizedBox(
        width: 360.w,
        height: 780.h,
        child: _buildPageHeadTitle(controller.welcomeTitle),
      ),
    );
  }
}
