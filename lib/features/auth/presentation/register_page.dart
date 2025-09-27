import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import '../providers/auth_providers.dart';

class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = ref.watch(registerFormKeyProvider);
    final nameController = ref.watch(registerNameControllerProvider);
    final phoneController = ref.watch(registerPhoneControllerProvider);
    final otpController = ref.watch(registerOtpControllerProvider);
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/loginUi.jpg', fit: BoxFit.cover),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'പുതിയ അക്കൗണ്ട്',
                        style: TextStyle(
                          color: AppColors.selected,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      "Create an account so you can explore all the existing jobs",
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
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your name'
                          : null,
                    ),
                    _LabeledTextField(
                      controller: phoneController,
                      hintText: 'Phone',
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().length < 10)
                          ? 'Enter valid phone'
                          : null,
                    ),
                    _LabeledTextField(
                      controller: otpController,
                      hintText: 'OTP',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter OTP' : null,
                    ),
                    SizedBox(height: 20.h),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 357.w,
                        height: 45.h,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pushReplacementNamed(
                                  context,
                                  '/user/basic',
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.selected,
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            shadowColor: const Color.fromRGBO(140, 0, 26, 0.25),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: Text(
                          'Already have an account',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Center(
                      child: Text(
                        'Or continue with',
                        style: TextStyle(
                          color: AppColors.selected,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialButton(imagePath: 'assets/icons/google.png'),
                        SizedBox(width: 12.w),
                        _SocialButton(imagePath: 'assets/icons/facebook.png'),
                      ],
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
  final String? Function(String?)? validator;
  const _LabeledTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.validator,
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
          validator: validator,
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

class _SocialButton extends StatelessWidget {
  final String imagePath;
  const _SocialButton({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: AppColors.socialButtonBackground,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Image.asset(imagePath),
    );
  }
}
