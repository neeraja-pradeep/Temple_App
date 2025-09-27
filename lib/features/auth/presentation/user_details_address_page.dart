import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import '../providers/auth_providers.dart';

class UserDetailsAddressPage extends ConsumerWidget {
  const UserDetailsAddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = ref.watch(userAddressFormKeyProvider);
    final nameController = ref.watch(userAddressNameControllerProvider);
    final line1Controller = ref.watch(userAddressLine1ControllerProvider);
    final line2Controller = ref.watch(userAddressLine2ControllerProvider);
    final cityStateController = ref.watch(
      userAddressCityStateControllerProvider,
    );
    final pinController = ref.watch(userAddressPinControllerProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/loginUi.jpg', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.h),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'വിലാസം',
                                style: TextStyle(
                                  color: AppColors.selected,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              'Please provide your address and other supporting details for pooja booking.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 35.h),
                            _LabeledTextField(
                              controller: nameController,
                              hintText: 'Name',
                              keyboardType: TextInputType.name,
                            ),
                            _LabeledTextField(
                              controller: line1Controller,
                              hintText: 'Address line 01',
                            ),
                            _LabeledTextField(
                              controller: line2Controller,
                              hintText: 'Address line 02',
                            ),
                            _LabeledTextField(
                              controller: cityStateController,
                              hintText: 'City, State',
                            ),
                            _LabeledTextField(
                              controller: pinController,
                              hintText: 'PIN Code',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Buttons at the bottom
                  Column(
                    children: [
                      SizedBox(height: 20.h),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 357.w,
                          height: 35.h,
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              '/main',
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Container(
                              height: 35.h,
                              width: 357.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2E7DA),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 357.w,
                          height: 45.h,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              '/main',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.selected,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              shadowColor: const Color.fromRGBO(
                                140,
                                0,
                                26,
                                0.25,
                              ),
                            ),
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  const _LabeledTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 357.w,
        height: 60.h,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.inputFieldColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.selected, width: 1.2.w),
            ),
          ),
        ),
      ),
    );
  }
}
