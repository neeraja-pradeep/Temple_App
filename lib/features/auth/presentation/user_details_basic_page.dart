import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import 'package:temple_app/features/auth/providers/nakshatra_service.dart';

import '../../../core/services/user_profile_api_service.dart';
import '../providers/auth_providers.dart';
import '../../home/providers/home_providers.dart';
import '../../../core/services/token_storage_service.dart';

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
      // Ensure nakshatram is selected (mandatory)
      if ((nakshatra == null) || nakshatra.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select your Nakshatram')),
          );
        }
        return;
      }

      // Get nakshatram ID from the API list
      final nakshatraListAsync = ref.read(userNakshatraListProvider);
      final nakshatraList = nakshatraListAsync.when(
        data: (list) => list,
        loading: () => <Map<String, dynamic>>[],
        error: (_, __) => <Map<String, dynamic>>[],
      );

      Map<String, dynamic> selectedNakshatra;
      try {
        selectedNakshatra = nakshatraList.firstWhere(
          (Map<String, dynamic> item) => item['name'] == nakshatra,
        );
      } catch (e) {
        selectedNakshatra = {'id': 0, 'name': ''};
      }
      final nakshatramId = selectedNakshatra['id'] as int;

      // Console logs for cross-checking nakshatram payload
      debugPrint('🧭 Selected Nakshatram name: $nakshatra');
      debugPrint('🧭 Resolved Nakshatram ID from API: $nakshatramId');
      final previewBody = {
        if (nameController.text.trim().isNotEmpty)
          'name': nameController.text.trim(),
        'email': '',
        'DOB': dobController.text.trim().isNotEmpty
            ? dobController.text.trim()
            : null,
        'time': '10:00:00',
        'nakshatram': nakshatramId > 0 ? nakshatramId : null,
      };
      debugPrint('🧾 Profile update preview body: ' + previewBody.toString());

      // Call profile update API
      await UserProfileApiService.updateProfile(
        name: nameController.text.trim().isNotEmpty
            ? nameController.text.trim()
            : null,
        phone: TokenStorageService.getPhoneNumber(),
        dob: dobController.text.trim().isNotEmpty
            ? dobController.text.trim()
            : null,
        time: "10:00:00", // Default time as per requirement
        // Always pass resolved ID; guard above ensures selection exists
        nakshatram: nakshatramId,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();

        // Invalidate cached profile so Home drawer shows fresh data
        ref.invalidate(profileProvider);

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
    // Autofill phone from saved token storage (already set earlier)
    // Ensure it has a value before building
    phoneController.text =
        TokenStorageService.getPhoneNumber() ?? phoneController.text;
    // final nakshatra = ref.watch(userBasicNakshatraProvider);

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
                            // Phone input removed entirely as requested
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
                                                    nakshatraList.any(
                                                      (item) =>
                                                          item['name'] ==
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
                                                        value:
                                                            e['name'] as String,
                                                        child: Text(
                                                          e['name'] as String,
                                                        ),
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
                      // Removed Skip; all fields are mandatory for new users
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
