import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import 'package:temple_app/features/auth/providers/nakshatra_service.dart';

import '../../../core/services/user_profile_api_service.dart';
import '../providers/auth_providers.dart';

class UserDetailsBasicPage extends ConsumerWidget {
  const UserDetailsBasicPage({super.key});

  /// Handle continue button press - save basic details and navigate to address page
  Future<void> _handleContinue(BuildContext context, WidgetRef ref) async {
    final formKey = ref.read(userBasicFormKeyProvider);
    final nameController = ref.read(userBasicNameControllerProvider);
    final dobController = ref.read(userBasicDobControllerProvider);
    final nakshatra = ref.read(userBasicNakshatraProvider);

    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Get nakshatram index from the list
      final nakshatraList = ref.read(userBasicNakshatraListProvider);
      final nakshatramIndex = nakshatraList.indexOf(nakshatra ?? '') + 1;

      // Call profile update API
      await UserProfileApiService.updateProfile(
        name: nameController.text.trim().isNotEmpty
            ? nameController.text.trim()
            : null,
        dob: dobController.text.trim().isNotEmpty
            ? dobController.text.trim()
            : null,
        time: "10:00:00", // Default time as per requirement
        nakshatram: nakshatramIndex > 0 ? nakshatramIndex : null,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Basic details saved successfully'),
            backgroundColor: primaryThemeColor,
          ),
        );

        // Navigate to address page
        Navigator.pushReplacementNamed(context, '/user/address');
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save details: $e'),
            backgroundColor: primaryThemeColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = ref.watch(userBasicFormKeyProvider);
    final nameController = ref.watch(userBasicNameControllerProvider);
    final phoneController = ref.watch(userBasicPhoneControllerProvider);
    final dobController = ref.watch(userBasicDobControllerProvider);
    final nakshatra = ref.watch(userBasicNakshatraProvider);

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
                                'വിശദാംശങ്ങൾ',
                                style: TextStyle(
                                  color: AppColors.selected,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              'Please provide your name and other supporting details for pooja booking.',
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
                              validator: (v) =>
                                  (v == null || v.trim().length < 10)
                                  ? 'Enter valid phone'
                                  : null,
                            ),
                            _LabeledTextField(
                              controller: dobController,
                              hintText: 'Date of Birth',
                              keyboardType: TextInputType.datetime,
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  dobController.text =
                                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                }
                              },
                              readOnly: true,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 357.w,
                                height: 45.h,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFieldColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Consumer(
                                    builder: (context, ref, _) {
                                      final nakshatraAsync = ref.watch(
                                        userNakshatraListProvider,
                                      );

                                      return nakshatraAsync.when(
                                        data: (nakshatraList) {
                                          return Align(
                                            alignment: Alignment.center,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value:
                                                    nakshatraList.contains(
                                                      ref.watch(
                                                        userBasicNakshatraProvider,
                                                      ),
                                                    )
                                                    ? ref.watch(
                                                        userBasicNakshatraProvider,
                                                      )
                                                    : null,
                                                hint: const Text('Nakshatram'),
                                                isExpanded: true,
                                                icon: const Icon(
                                                  Icons.keyboard_arrow_down,
                                                ),
                                                items: nakshatraList
                                                    .map(
                                                      (e) => DropdownMenuItem(
                                                        value: e,
                                                        child: Text(e),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (value) {
                                                  ref
                                                          .read(
                                                            userBasicNakshatraProvider
                                                                .notifier,
                                                          )
                                                          .state =
                                                      value;
                                                  print(
                                                    'Selected Nakshatra: $value',
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        loading: () =>
                                            const CircularProgressIndicator(),
                                        error: (e, _) => Text(
                                          'Failed to load Nakshatras: $e',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
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
                              '/user/address',
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
                            onPressed: () => _handleContinue(context, ref),
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
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  const _LabeledTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.validator,
    this.onTap,
    this.readOnly = false,
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
          onTap: onTap,
          readOnly: readOnly,
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
