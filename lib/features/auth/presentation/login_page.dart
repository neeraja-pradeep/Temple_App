import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import '../providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  void initState() {
    super.initState();
    // Reset auth state when login page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).resetAllAuthState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formKey = ref.watch(loginFormKeyProvider);
    final phoneController = ref.watch(loginPhoneControllerProvider);
    final otpController = ref.watch(loginOtpControllerProvider);
    final isLoading = ref.watch(authLoadingProvider);
    final otpSent = ref.watch(otpSentProvider);

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
                        'ലോഗിൻ',
                        style: TextStyle(
                          color: AppColors.selected,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      otpSent
                          ? "Enter the OTP sent to \nyour phone number"
                          : "Welcome back you've \nbeen missed!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 60.h),
                    _LabeledTextField(
                      controller: phoneController,
                      hintText: 'Phone number',
                      keyboardType: TextInputType.phone,
                      prefixText: '+91 ',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter phone number';
                        }
                        // Remove +91 prefix and spaces for validation
                        String cleanNumber = v
                            .replaceAll('+91', '')
                            .replaceAll(' ', '')
                            .trim();
                        if (cleanNumber.length != 10) {
                          return 'Enter valid 10-digit phone number';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(cleanNumber)) {
                          return 'Phone number should contain only digits';
                        }
                        return null;
                      },
                    ),
                    if (otpSent) ...[
                      SizedBox(height: 30.h),
                      _LabeledTextField(
                        controller: otpController,
                        hintText: 'OTP',
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter OTP'
                            : null,
                      ),
                      SizedBox(height: 10.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ref
                                .read(authControllerProvider.notifier)
                                .resetOTPState();
                          },
                          child: Text(
                            'Change Number',
                            style: TextStyle(
                              color: AppColors.selected,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (!otpSent)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot your password?',
                            style: TextStyle(
                              color: AppColors.selected,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
                              : () {
                                  // Validate form before proceeding
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    if (otpSent) {
                                      // Verify OTP
                                      ref
                                          .read(authControllerProvider.notifier)
                                          .login(context);
                                    } else {
                                      // Send OTP - format phone number with +91 country code
                                      String cleanPhoneNumber = phoneController
                                          .text
                                          .replaceAll('+91', '')
                                          .replaceAll(' ', '')
                                          .trim();
                                      // Add +91 prefix for Firebase
                                      String formattedPhoneNumber =
                                          '+91$cleanPhoneNumber';
                                      ref
                                          .read(authControllerProvider.notifier)
                                          .sendOTP(
                                            context,
                                            formattedPhoneNumber,
                                          );
                                    }
                                  }
                                },
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
                                  otpSent ? 'Verify OTP' : 'Send OTP',
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
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/register',
                        ),
                        child: Text(
                          'Create new account',
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
  final String? prefixText;
  const _LabeledTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.validator,
    this.prefixText,
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
            prefixText: prefixText,
            prefixStyle: TextStyle(
              color: Colors.black87,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: primaryThemeColor, width: 1.2.w),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: primaryThemeColor, width: 1.2.w),
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
