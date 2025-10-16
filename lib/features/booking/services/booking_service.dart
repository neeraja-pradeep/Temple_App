import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import 'package:temple_app/features/booking/data/booking_pooja_model.dart';
import 'package:temple_app/features/booking/data/user_list_model.dart';
import 'package:temple_app/features/booking/presentation/pooja_summary_page.dart';
import 'package:temple_app/features/booking/providers/booking_provider.dart';
import 'package:temple_app/features/booking/providers/booking_page_providers.dart';
import 'package:temple_app/features/booking/providers/user_list_provider.dart';

class BookingService {
  static Future<void> showCenteredErrorDialog(
    BuildContext context,
    String message,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          contentPadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'NotoSansMalayalam',
            ),
          ),
          actionsPadding: EdgeInsets.only(right: 12.w, bottom: 8.h),
          actions: [
            SizedBox(
              height: 36.h,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.selected,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> validateBookingData({
    required BookingPooja pooja,
    required int userId,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    // Check if this is a special pooja
    final isSpecialPooja = pooja.specialPooja;
    String? selectedDate;
    int? specialPoojaDateId;

    if (isSpecialPooja) {
      // For special pooja, we need to get the selected special pooja date ID
      final selectedDateStr = ref.read(selectedCalendarDateProvider);
      if (selectedDateStr == null) {
        final errorMsg = 'Please select a date for the special pooja';
        print('❌ Validation Error: $errorMsg');
        await showCenteredErrorDialog(
          context,
          "Please select a date for the special pooja",
        );
        return false;
      }

      // Find the corresponding special pooja date ID
      try {
        final selectedSpecialDate = pooja.specialPoojaDates.firstWhere(
          (date) => date.date == selectedDateStr,
          orElse: () =>
              throw Exception('Selected date not found in special pooja dates'),
        );
        specialPoojaDateId = selectedSpecialDate.id;
        print(
          '🎯 Special Pooja - Date: $selectedDateStr, ID: $specialPoojaDateId',
        );
      } catch (e) {
        print('❌ Special Pooja Date Error: $e');
        await showCenteredErrorDialog(
          context,
          'please select a date for the special pooja',
        );
        return false;
      }
    } else {
      // For regular pooja, we need a selected date
      selectedDate = ref.read(selectedCalendarDateProvider);
      if (selectedDate == null) {
        final errorMsg = 'Please select a date for the pooja';
        print('❌ Validation Error: $errorMsg');
        await showCenteredErrorDialog(
          context,
          'Please select a date for the pooja',
        );
        return false;
      }
      print('📅 Regular Pooja - Selected Date: $selectedDate');
    }

    // Get selected users
    final selectedUsers = ref.read(selectedUsersProvider(userId));
    if (selectedUsers.isEmpty) {
      final errorMsg = 'Please select at least one person for the pooja';
      print('❌ Validation Error: $errorMsg');
      print(
        '   Available users: ${ref.read(userListsProvider).value?.length ?? 0}',
      );
      print('   Selected users count: ${selectedUsers.length}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: primaryThemeColor),
      );
      return false;
    }

    return true;
  }

  static Future<Map<String, dynamic>> prepareBookingData({
    required BookingPooja pooja,
    required int userId,
    required WidgetRef ref,
  }) async {
    final isSpecialPooja = pooja.specialPooja;
    String? selectedDate;
    int? specialPoojaDateId;

    if (isSpecialPooja) {
      final selectedDateStr = ref.read(selectedCalendarDateProvider);
      final selectedSpecialDate = pooja.specialPoojaDates.firstWhere(
        (date) => date.date == selectedDateStr,
      );
      specialPoojaDateId = selectedSpecialDate.id;
    } else {
      selectedDate = ref.read(selectedCalendarDateProvider);
    }

    final selectedUsers = ref.read(selectedUsersProvider(userId));
    final agentCode = ref.read(agentCodeProvider);
    final isParticipatingPhysically = ref.read(
      isParticipatingPhysicallyProvider,
    );

    return {
      'poojaId': pooja.id.toString(),
      'selectedDate': isSpecialPooja ? null : selectedDate,
      'specialPoojaDateId': isSpecialPooja ? specialPoojaDateId : null,
      'userListIds': selectedUsers.map((user) => user.id).toList(),
      'status': isParticipatingPhysically,
      'agentCode': agentCode.isNotEmpty ? agentCode : null,
    };
  }

  static Future<void> processBooking({
    required BookingPooja pooja,
    required int userId,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Prepare API parameters
      final apiParams = await prepareBookingData(
        pooja: pooja,
        userId: userId,
        ref: ref,
      );

      // Log API call parameters
      print('🚀 Making API call with parameters:');
      print('   Pooja ID: ${pooja.id}');
      print('   Pooja Name: ${pooja.name}');
      print('   Is Special Pooja: ${pooja.specialPooja}');
      print('   Selected Date: ${apiParams['selectedDate']}');
      print('   Special Pooja Date ID: ${apiParams['specialPoojaDateId']}');
      print('   User List IDs: ${apiParams['userListIds']}');
      print('   Status (Physical Participation): ${apiParams['status']}');
      print('   Agent Code: ${apiParams['agentCode'] ?? "Not provided"}');

      // Print raw request body
      print('📤 Raw Request Body:');
      print(apiParams);

      final response = await ref.read(
        simpleBookPoojaProvider(apiParams).future,
      );

      // Hide loading indicator
      Navigator.pop(context);

      // Check if booking was successful
      final isSuccessful =
          response.success ||
          (response.statusCode >= 200 && response.statusCode < 300);

      print('🔍 Response Analysis:');
      print('   HTTP Status Code: ${response.statusCode}');
      print('   Response Success Field: ${response.success}');
      print('   Calculated Success: $isSuccessful');
      print('   Response Message: ${response.message}');
      print('   Response Data: ${response.data}');

      if (isSuccessful) {
        print('✅ Booking successful!');
        print('   Status Code: ${response.statusCode}');
        print('   Message: ${response.message}');
        print('   Data: ${response.data}');

        // Navigate to pooja summary page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PoojaSummaryPage(
              userId: userId,),
          ),
        );
      } else {
        // Show error message
        String errorMsg = 'Booking failed: ${response.message}';

        // Check if it's an agent code error and show a cleaner message
        if (response.message.toLowerCase().contains(
              'invalid or inactive agent code',
            ) ||
            response.message.toLowerCase().contains('agent code')) {
          errorMsg =
              'Invalid or inactive agent code. Please check your agent code and try again.';
        }

        print('❌ API Response Error: $errorMsg');
        print('   Status Code: ${response.statusCode}');
        print('   Success Field: ${response.success}');
        print('   Message: ${response.message}');
        print('   Data: ${response.data}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: primaryThemeColor),
        );
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);

      // Show error message
      String errorMsg = 'Booking failed: ${e.toString()}';

      // Check if it's an agent code error and show a cleaner message
      if (e.toString().toLowerCase().contains(
            'invalid or inactive agent code',
          ) ||
          e.toString().toLowerCase().contains('agent code')) {
        errorMsg =
            'Invalid or inactive agent code. Please check your agent code and try again.';
      }

      print('❌ Exception Error: $errorMsg');
      print('   Error type: ${e.runtimeType}');
      print('   Error details: $e');
      if (e is Exception) {
        print('   Exception message: ${e.toString()}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: primaryThemeColor),
      );
    }
  }

  static void clearBookingState(WidgetRef ref, int userId) {
    // Attempt to preserve the main user in selection/visibility
    UserList? mainUser;
    try {
      final asyncUsers = ref.read(userListsProvider);
      asyncUsers.maybeWhen(
        data: (users) {
          try {
            mainUser = users.firstWhere((u) => u.id == userId);
          } catch (_) {
            mainUser = null;
          }
        },
        orElse: () {},
      );
    } catch (_) {}

    // Reset selected and visible users
    try {
      ref.read(selectedUsersProvider(userId).notifier).state = mainUser != null
          ? [mainUser!]
          : [];
    } catch (_) {}
    try {
      ref.read(visibleUsersProvider(userId).notifier).state = mainUser != null
          ? [mainUser!]
          : [];
    } catch (_) {}

    // Clear calendar-related state
    try {
      ref.read(selectedCalendarDateProvider.notifier).state = null;
    } catch (_) {}
    try {
      ref.read(showCalendarProvider.notifier).state = false;
    } catch (_) {}

    // Reset participation and agent code state
    try {
      ref.read(isParticipatingPhysicallyProvider.notifier).state = false;
    } catch (_) {}
    try {
      ref.read(isAgentCodeProvider.notifier).state = false;
    } catch (_) {}
    try {
      ref.read(agentCodeProvider.notifier).state = '';
    } catch (_) {}
  }
}
