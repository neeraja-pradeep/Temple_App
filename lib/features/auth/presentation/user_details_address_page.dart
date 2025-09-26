import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/core/app_colors.dart';
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
          Image.asset('assets/loginUI.jpg', fit: BoxFit.cover),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'വിലാസം',
                        style: TextStyle(
                          color: AppColors.selected,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Please provide your address and other supporting details for pooja booking.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                    ),
                    SizedBox(height: 24.h),
                    _LabeledTextField(
                      controller: nameController,
                      hintText: 'Name',
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(height: 14.h),
                    _LabeledTextField(
                      controller: line1Controller,
                      hintText: 'Address line 01',
                    ),
                    SizedBox(height: 14.h),
                    _LabeledTextField(
                      controller: line2Controller,
                      hintText: 'Address line 02',
                    ),
                    SizedBox(height: 14.h),
                    _LabeledTextField(
                      controller: cityStateController,
                      hintText: 'City, State',
                    ),
                    SizedBox(height: 14.h),
                    _LabeledTextField(
                      controller: pinController,
                      hintText: 'PIN Code',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20.h),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/main'),
                      child: Container(
                        height: 44.h,
                        width: double.infinity,
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
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/main'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.selected,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF9F0E6),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.selected, width: 1.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.selected, width: 1.2.w),
        ),
      ),
    );
  }
}
