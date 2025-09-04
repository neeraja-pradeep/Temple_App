import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:temple/core/app_colors.dart';
import 'package:temple/features/booking/presentation/pooja_summary_page.dart';
import 'package:temple/widgets/custom_calendar_picker.dart';
import '../providers/booking_provider.dart';
import '../providers/user_list_provider.dart';
import '../data/booking_pooja_model.dart';
import '../data/user_list_model.dart';
import '../providers/booking_page_providers.dart';
import '../data/nakshatram_model.dart';

// Import providers from separate file to avoid circular imports

class BookingPage extends ConsumerWidget {
  final int poojaId;
  final int userId;

  const BookingPage({super.key, required this.poojaId, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingPoojaAsync = ref.watch(bookingPoojaProvider(poojaId));

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          _clearBookingState(ref);
          return true;
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 60.h,
            leadingWidth: 64.w,
            // give extra space for left padding
            leading: Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                top: 16.h,
              ), // shift container inward
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(251, 239, 217, 1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: IconButton(
                    icon: Image.asset(
                      'assets/backIcon.png',
                      width: 20.w,
                      height: 20.h,
                    ),
                    onPressed: () {
                      _clearBookingState(ref);
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 40.w,
                      minHeight: 40.h,
                    ),
                  ),
                ),
              ),
            ),
          ),

          body: bookingPoojaAsync.when(
            data: (pooja) => _buildBookingContent(context, pooja),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load pooja details',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    error.toString(),
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearBookingState(WidgetRef ref) {
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

  Future<void> _showCenteredErrorDialog(
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

  Widget _buildBookingContent(BuildContext context, BookingPooja pooja) {
    // Debug logging for pooja type
    print('🏛️ Pooja Details:');
    print('   ID: ${pooja.id}');
    print('   Name: ${pooja.name}');
    print('   Special Pooja: ${pooja.specialPooja}');
    print('   Special Pooja Dates Count: ${pooja.specialPoojaDates.length}');
    if (pooja.specialPoojaDates.isNotEmpty) {
      print('   First Special Date: ${pooja.specialPoojaDates.first.date}');
    }

    return Consumer(
      builder: (context, ref, _) {
        // Auto-select a default date if none selected or invalid for current pooja
        List<String> enabledDates;
        if (pooja.specialPooja) {
          enabledDates = pooja.specialPoojaDates.map((d) => d.date).toList();
        } else {
          final now = DateTime.now();
          enabledDates = List.generate(30, (index) {
            final date = now.add(Duration(days: index + 1));
            return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          });
        }
        final currentSelectedDate = ref.watch(selectedCalendarDateProvider);
        final shouldSetDefaultDate =
            currentSelectedDate == null ||
            !enabledDates.contains(currentSelectedDate);
        if (enabledDates.isNotEmpty && shouldSetDefaultDate) {
          final defaultDate = pooja.specialPooja
              ? enabledDates
                    .first // from API for special pooja
              : enabledDates.first; // next available for regular pooja
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedCalendarDateProvider.notifier).state = defaultDate;
          });
        }

        // Ensure main user is always selected when entering booking page
        final currentSelectedUsers = ref.watch(selectedUsersProvider(userId));
        final currentVisibleUsers = ref.watch(visibleUsersProvider(userId));
        final userListsAsync = ref.watch(userListsProvider);

        // Check if we need to set the main user and user list is available
        userListsAsync.when(
          data: (users) {
            if (currentSelectedUsers.isEmpty || currentVisibleUsers.isEmpty) {
              try {
                final mainUser = users.firstWhere((u) => u.id == userId);
                // Set main user in both selected and visible lists
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(selectedUsersProvider(userId).notifier).state = [
                    mainUser,
                  ];
                  ref.read(visibleUsersProvider(userId).notifier).state = [
                    mainUser,
                  ];
                });
              } catch (_) {
                // Main user not found, keep empty lists
              }
            }
          },
          loading: () {},
          error: (_, __) {},
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.topCenter,
            ),
            // Content
            SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 64.h),
                  // Banner Image
                  // Pooja Details Card
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pooja Name with Calendar Icon
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                pooja.name,
                                style: TextStyle(
                                  fontFamily: 'NotoSansMalayalam',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.selected,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                final show = ref.read(showCalendarProvider);
                                ref.read(showCalendarProvider.notifier).state =
                                    !show;
                              },
                              child: Image.asset(
                                'assets/calendar.png',
                                width: 20.w,
                                height: 20.h,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        // Date Information
                        if (pooja.specialPooja &&
                            pooja.specialPoojaDates.isNotEmpty) ...[
                          // Special Pooja - Show first available date
                          Text(
                            pooja.specialPoojaDates.first.malayalamDate,
                            style: TextStyle(
                              fontFamily: 'NotoSansMalayalam',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _formatDate(pooja.specialPoojaDates.first.date),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ] else if (!pooja.specialPooja) ...[
                          // Regular Pooja - Show instruction to select date
                          Text(
                            'തീയതി തിരഞ്ഞെടുക്കാൻ കലണ്ടർ ക്ലിക്ക് ചെയ്യുക',
                            style: TextStyle(
                              fontFamily: 'NotoSansMalayalam',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Show calendar card below the first card if toggled
                  Builder(
                    builder: (context) {
                      final showCalendar = ref.watch(showCalendarProvider);
                      if (!showCalendar) return SizedBox.shrink();

                      List<String> enabledDates;
                      if (pooja.specialPooja) {
                        // For special pooja, use the predefined dates
                        enabledDates = pooja.specialPoojaDates
                            .map((d) => d.date)
                            .toList();
                        print(
                          '🎯 Special Pooja - Available dates: $enabledDates',
                        );
                      } else {
                        // For regular pooja, generate dates for the next 30 days
                        final now = DateTime.now();
                        enabledDates = List.generate(30, (index) {
                          final date = now.add(Duration(days: index + 1));
                          return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        });
                        print(
                          '📅 Regular Pooja - Generated dates: ${enabledDates.take(5)}... (${enabledDates.length} total)',
                        );
                      }

                      final selectedDate = ref.watch(
                        selectedCalendarDateProvider,
                      );

                      // If previously stored date is invalid for this pooja, clear it
                      if (selectedDate != null &&
                          !enabledDates.contains(selectedDate)) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref
                                  .read(selectedCalendarDateProvider.notifier)
                                  .state =
                              null;
                        });
                      }

                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: CustomCalendarPicker(
                          enabledDates: enabledDates,
                          selectedDate: selectedDate,
                          onDateSelected: (date) {
                            ref
                                    .read(selectedCalendarDateProvider.notifier)
                                    .state =
                                date;
                            ref.read(showCalendarProvider.notifier).state =
                                false;
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Pooja For Whom Section
                  Consumer(
                    builder: (context, ref, child) {
                      final userListsAsync = ref.watch(userListsProvider);
                      return userListsAsync.when(
                        data: (userLists) =>
                            _buildPoojaForWhomSection(context, ref, userLists),
                        loading: () => Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.selected,
                            ),
                          ),
                        ),
                        error: (error, stack) => Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Text(
                            'Error loading users: $error',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 100.h), // Add extra space for bottom button
                ],
              ),
            ),
            // Fixed Book Now Button at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Consumer(
                builder: (context, ref, child) {
                  final showCalendar = ref.watch(showCalendarProvider);
                  final selectedUsers = ref.watch(
                    selectedUsersProvider(userId),
                  );
                  // Ensure price is numeric
                  print(pooja.price);
                  final double basePrice = double.tryParse(pooja.price) ?? 0.0;
                  final int userCount = selectedUsers.isNotEmpty
                      ? selectedUsers.length
                      : 1;
                  final double totalPrice = basePrice * userCount;
                  print(totalPrice);
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      boxShadow: [
                        // BoxShadow(
                        //   color: Colors.black.withOpacity(0.1),
                        //   blurRadius: 16.r,
                        //   offset: Offset(0, 0.h),
                        //   spreadRadius: 1.r,
                        // ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!showCalendar) ...[
                          Text(
                            'ആകെതുക: ₹${totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily: 'NotoSansMalayalam',
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'നോസ്ത്രുഡ് എക്സെപ്റ്റെർ ഡ്യൂയിസ് മാഗ്നാ ക്വിസ് എനിം എനിം എസ്റ്റ് ഉല്ലാംകോ പ്രൊഇഡന്റ് ഉട്ട് നിസി ഉല്ലാംകോ മിനിം',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 12.h),
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 40.h,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Check if this is a special pooja
                              final isSpecialPooja = pooja.specialPooja;
                              String? selectedDate;
                              int? specialPoojaDateId;

                              if (isSpecialPooja) {
                                // For special pooja, we need to get the selected special pooja date ID
                                final selectedDateStr = ref.read(
                                  selectedCalendarDateProvider,
                                );
                                if (selectedDateStr == null) {
                                  final errorMsg =
                                      'Please select a date for the special pooja';
                                  print('❌ Validation Error: $errorMsg');
                                  await _showCenteredErrorDialog(
                                    context,
                                    "Please select a date for the special pooja",
                                  );
                                  return;
                                }

                                // Find the corresponding special pooja date ID
                                try {
                                  final selectedSpecialDate = pooja
                                      .specialPoojaDates
                                      .firstWhere(
                                        (date) => date.date == selectedDateStr,
                                        orElse: () => throw Exception(
                                          'Selected date not found in special pooja dates',
                                        ),
                                      );
                                  specialPoojaDateId = selectedSpecialDate.id;
                                  print(
                                    '🎯 Special Pooja - Date: $selectedDateStr, ID: $specialPoojaDateId',
                                  );
                                } catch (e) {
                                  final errorMsg =
                                      'Failed to find special pooja date';
                                  print('❌ Special Pooja Date Error: $e');
                                  await _showCenteredErrorDialog(
                                    context,
                                    'please select a date for the special pooja',
                                  );
                                  return;
                                }
                              } else {
                                // For regular pooja, we need a selected date
                                selectedDate = ref.read(
                                  selectedCalendarDateProvider,
                                );
                                if (selectedDate == null) {
                                  final errorMsg =
                                      'Please select a date for the pooja';
                                  print('❌ Validation Error: $errorMsg');
                                  await _showCenteredErrorDialog(
                                    context,
                                    'Please select a date for the pooja',
                                  );
                                  return;
                                }
                                print(
                                  '📅 Regular Pooja - Selected Date: $selectedDate',
                                );
                              }

                              // Get selected users
                              final selectedUsers = ref.read(
                                selectedUsersProvider(userId),
                              );
                              if (selectedUsers.isEmpty) {
                                final errorMsg =
                                    'Please select at least one person for the pooja';
                                print('❌ Validation Error: $errorMsg');
                                print(
                                  '   Available users: ${ref.read(userListsProvider).value?.length ?? 0}',
                                );
                                print(
                                  '   Selected users count: ${selectedUsers.length}',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMsg),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              // Get agent code and participation status
                              final agentCode = ref.read(agentCodeProvider);
                              final isParticipatingPhysically = ref.read(
                                isParticipatingPhysicallyProvider,
                              );

                              try {
                                // Show loading indicator
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                // Log API call parameters
                                print('🚀 Making API call with parameters:');
                                print('   Pooja ID: ${pooja.id}');
                                print('   Pooja Name: ${pooja.name}');
                                print('   Is Special Pooja: $isSpecialPooja');
                                print('   Selected Date: $selectedDate');
                                print(
                                  '   Special Pooja Date ID: $specialPoojaDateId',
                                );
                                print(
                                  '   User List IDs: ${selectedUsers.map((user) => user.id).toList()}',
                                );
                                print(
                                  '   Status (Physical Participation): $isParticipatingPhysically',
                                );
                                print(
                                  '   Agent Code: ${agentCode.isNotEmpty ? agentCode : "Not provided"}',
                                );

                                // Make API call using simple provider
                                final Map<String, dynamic> apiParams = {
                                  'poojaId': pooja.id.toString(),
                                  'selectedDate': isSpecialPooja
                                      ? null
                                      : selectedDate,
                                  'specialPoojaDateId': isSpecialPooja
                                      ? specialPoojaDateId
                                      : null,
                                  'userListIds': selectedUsers
                                      .map((user) => user.id)
                                      .toList(),
                                  'status': isParticipatingPhysically,
                                  'agentCode': agentCode.isNotEmpty
                                      ? agentCode
                                      : null,
                                };

                                // Print raw request body
                                print('📤 Raw Request Body:');
                                print(apiParams);

                                final response = await ref.read(
                                  simpleBookPoojaProvider(apiParams).future,
                                );

                                // Hide loading indicator
                                Navigator.pop(context);

                                // Check if booking was successful (either by success field or status code)
                                final isSuccessful =
                                    response.success ||
                                    response.statusCode >= 200 &&
                                        response.statusCode < 300;

                                print('🔍 Response Analysis:');
                                print(
                                  '   HTTP Status Code: ${response.statusCode}',
                                );
                                print(
                                  '   Response Success Field: ${response.success}',
                                );
                                print('   Calculated Success: $isSuccessful');
                                print(
                                  '   Response Message: ${response.message}',
                                );
                                print('   Response Data: ${response.data}');

                                if (isSuccessful) {
                                  print('✅ Booking successful!');
                                  print(
                                    '   Status Code: ${response.statusCode}',
                                  );
                                  print('   Message: ${response.message}');
                                  print('   Data: ${response.data}');

                                  // Navigate to pooja summary page
                                  // For special pooja, use the selected date string; for regular pooja, use selectedDate
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PoojaSummaryPage(),
                                    ),
                                  );
                                } else {
                                  // Show error message
                                  final errorMsg =
                                      'Booking failed: ${response.message}';
                                  print('❌ API Response Error: $errorMsg');
                                  print(
                                    '   Status Code: ${response.statusCode}',
                                  );
                                  print(
                                    '   Success Field: ${response.success}',
                                  );
                                  print('   Message: ${response.message}');
                                  print('   Data: ${response.data}');

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMsg),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                // Hide loading indicator
                                Navigator.pop(context);

                                // Show error message
                                final errorMsg =
                                    'Booking failed: ${e.toString()}';
                                print('❌ Exception Error: $errorMsg');
                                print('   Error type: ${e.runtimeType}');
                                print('   Error details: $e');
                                if (e is Exception) {
                                  print(
                                    '   Exception message: ${e.toString()}',
                                  );
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMsg),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.selected,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'പൂജ ബുക്ക് ചെയ്യുക',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPoojaForWhomSection(
    BuildContext context,
    WidgetRef ref,
    List<UserList> userLists,
  ) {
    final selectedUsers = ref.watch(selectedUsersProvider(userId));
    // Only show users that are currently selected

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Pooja For Whom',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20.h),

          // User List
          if (userLists.isNotEmpty) ...[
            // Display visible users with their selection state
            ...selectedUsers
                .map(
                  (user) => Column(
                    children: [
                      _buildUserEntry(
                        context,
                        ref,
                        user,
                        selectedUsers.any(
                          (selectedUser) => selectedUser.id == user.id,
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                )
                .toList(),

            // Add new user option
            _buildAddNewUserOption(context, ref, userLists),
            SizedBox(height: 12.h),
          ],

          // Additional Options
          _buildAdditionalOptions(context, ref),
        ],
      ),
    );
  }

  Widget _buildUserEntry(
    BuildContext context,
    WidgetRef ref,
    UserList user,
    bool isSelected,
  ) {
    final nakshatramName = user.attributes.isNotEmpty
        ? user.attributes.first.nakshatramName
        : '';

    return Row(
      children: [
        // Interactive Checkbox
        GestureDetector(
          onTap: () {
            // Prevent unselecting the main user
            if (user.id == userId && isSelected) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('പ്രധാന ഉപയോക്താവിനെ നീക്കാൻ കഴിയില്ല'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            final selectedUsers = ref.read(selectedUsersProvider(userId));
            final currentSelectedUsers = List<UserList>.from(selectedUsers);

            if (isSelected) {
              // Remove user from selection but keep in UI (uncheck)
              currentSelectedUsers.removeWhere(
                (selectedUser) => selectedUser.id == user.id,
              );
            } else {
              // Add user to selection (check)
              currentSelectedUsers.add(user);
            }

            ref.read(selectedUsersProvider(userId).notifier).state =
                currentSelectedUsers;
          },
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.selected : Colors.grey,
                width: 2.w,
              ),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: isSelected
                ? Icon(Icons.check, size: 14.sp, color: AppColors.selected)
                : null,
          ),
        ),
        SizedBox(width: 12.w),

        // User details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (nakshatramName.isNotEmpty)
                Text(
                  nakshatramName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),

        // Edit button
        TextButton(
          onPressed: () {
            _showEditUserBottomSheet(context, ref, user);
          },
          child: Text(
            'എഡിറ്റ്',
            style: TextStyle(
              color: AppColors.selected,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddNewUserOption(
    BuildContext context,
    WidgetRef ref,
    List<UserList> userLists,
  ) {
    return Row(
      children: [
        // Plus icon container
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.selected, width: 2.w),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Icon(Icons.add, size: 14.sp, color: AppColors.selected),
        ),
        SizedBox(width: 12.w),

        // Add new name text
        Expanded(
          child: GestureDetector(
            onTap: () {
              _showAddNewUserBottomSheet(context, ref);
            },
            child: Text(
              'മറ്റൊരു പേര് ചേർക്കുക',
              style: TextStyle(color: AppColors.selected, fontSize: 12.sp),
            ),
          ),
        ),

        // View all button
        TextButton(
          onPressed: () {
            _showAllUsersBottomSheet(context, ref, userLists);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'വ്യൂ ഓൾ',
                style: TextStyle(color: AppColors.selected, fontSize: 12.sp),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16.sp,
                color: AppColors.selected,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalOptions(BuildContext context, WidgetRef ref) {
    final isParticipatingPhysically = ref.watch(
      isParticipatingPhysicallyProvider,
    );
    final isAgentCode = ref.watch(isAgentCodeProvider);
    final agentCode = ref.watch(agentCodeProvider);

    Widget customCheckbox({
      required bool value,
      required VoidCallback? onTap,
      bool disabled = false,
      Color? color,
    }) {
      final borderColor = color ?? (value ? AppColors.selected : Colors.grey);
      final iconColor = color ?? (value ? AppColors.selected : Colors.grey);
      return GestureDetector(
        onTap: disabled ? null : onTap,
        child: Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2.w),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: value
              ? Icon(Icons.check, size: 14.sp, color: iconColor)
              : null,
        ),
      );
    }

    return Column(
      children: [
        // Participating physically
        Row(
          children: [
            customCheckbox(
              value: isParticipatingPhysically,
              onTap: isAgentCode
                  ? null
                  : () {
                      ref
                              .read(isParticipatingPhysicallyProvider.notifier)
                              .state =
                          !isParticipatingPhysically;
                    },
              disabled: isAgentCode,
              color: isAgentCode ? Colors.grey : null,
            ),
            SizedBox(width: 12.w),
            Text(
              'ഭൗതികമായി പങ്കെടുക്കുന്നു',
              style: TextStyle(fontSize: 12.sp, color: Colors.black),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Agent code
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            customCheckbox(
              value: isAgentCode,
              onTap: () async {
                final newValue = !isAgentCode;
                ref.read(isAgentCodeProvider.notifier).state = newValue;
                if (newValue) {
                  // Auto-check and disable the first checkbox
                  ref.read(isParticipatingPhysicallyProvider.notifier).state =
                      true;
                  // Show bottom sheet for agent code input
                  _showAgentCodeSheet(context, ref, agentCode);
                } else {
                  // Clear agent code when unchecked
                  ref.read(agentCodeProvider.notifier).state = '';
                  // Keep physical participation as user had it before
                  // Don't change isParticipatingPhysically here
                }
              },
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ഏജന്റ് കോഡ് നൽകുക (Optional)',
                    style: TextStyle(fontSize: 12.sp, color: Colors.black),
                  ),
                  // Show entered agent code if available
                  if (agentCode.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      '$agentCode',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAllUsersBottomSheet(
    BuildContext context,
    WidgetRef ref,
    List<UserList> userLists,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final selectedUsers = ref.watch(selectedUsersProvider(userId));

          return Container(
            height: 370.h,
            // height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                // Handle bar

                // Header with title and close button
                Padding(
                  padding: EdgeInsets.only(top: 20.w, left: 32.w, right: 32.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'വ്യക്തിവിവരം',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.selected,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.selected,
                              width: 2.w,
                            ),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: AppColors.selected,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // Users list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 0.w),
                    itemCount: userLists.length,
                    itemBuilder: (context, index) {
                      final user = userLists[index];
                      final isSelected = selectedUsers.any(
                        (selectedUser) => selectedUser.id == user.id,
                      );
                      final nakshatramName = user.attributes.isNotEmpty
                          ? user.attributes.first.nakshatramName
                          : '';

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: 12.h,
                          left: 32.w,
                          right: 20.w,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Checkbox
                            GestureDetector(
                              onTap: () {
                                // Prevent unselecting the main user
                                if (user.id == userId && isSelected) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'പ്രധാന ഉപയോക്താവിനെ നീക്കാൻ കഴിയില്ല',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                final currentSelectedUsers =
                                    List<UserList>.from(selectedUsers);
                                final currentVisibleUsers = ref.read(
                                  visibleUsersProvider(userId),
                                );
                                final updatedVisibleUsers = List<UserList>.from(
                                  currentVisibleUsers,
                                );

                                if (isSelected) {
                                  currentSelectedUsers.removeWhere(
                                    (selectedUser) =>
                                        selectedUser.id == user.id,
                                  );
                                  updatedVisibleUsers.removeWhere(
                                    (visibleUser) => visibleUser.id == user.id,
                                  );
                                } else {
                                  currentSelectedUsers.add(user);
                                  if (!updatedVisibleUsers.any(
                                    (visibleUser) => visibleUser.id == user.id,
                                  )) {
                                    updatedVisibleUsers.add(user);
                                  }
                                }

                                ref
                                        .read(
                                          selectedUsersProvider(
                                            userId,
                                          ).notifier,
                                        )
                                        .state =
                                    currentSelectedUsers;
                                ref
                                        .read(
                                          visibleUsersProvider(userId).notifier,
                                        )
                                        .state =
                                    updatedVisibleUsers;
                              },
                              child: Container(
                                width: 20.w,
                                height: 20.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.selected
                                        : Colors.grey,
                                    width: 2.w,
                                  ),
                                  color: isSelected
                                      ? AppColors.selected
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 14.sp,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(width: 16.w),

                            // User details (no outer container styling)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (nakshatramName.isNotEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      nakshatramName,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Edit button
                            TextButton(
                              onPressed: () {
                                _showEditUserBottomSheet(context, ref, user);
                              },
                              child: Text(
                                'എഡിറ്റ്',
                                style: TextStyle(
                                  color: AppColors.selected,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Add new row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () => _showAddNewUserBottomSheet(context, ref),
                      icon: Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.selected,
                            width: 2.w,
                          ),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 14.sp,
                          color: AppColors.selected,
                        ),
                      ),
                      label: Text(
                        'മറ്റൊരു പേര് ചേർക്കുക',
                        style: TextStyle(
                          color: AppColors.selected,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Continue button
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedUsers.isNotEmpty) {
                          ref
                                  .read(selectedUsersProvider(userId).notifier)
                                  .state =
                              selectedUsers;
                          ref
                                  .read(visibleUsersProvider(userId).notifier)
                                  .state =
                              selectedUsers;
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.selected,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'തുടരുക',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddNewUserBottomSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final dobController = TextEditingController();
    final timeController = TextEditingController();
    int? selectedNakshatram;
    String? selectedNakshatramName;
    bool didStartFetch = false;
    List<NakshatramOption> nakshatramOptions = [];
    bool nakshLoading = true;
    String? nakshError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                // Header with title and close button
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'വ്യക്തിവിവരം',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.selected,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.selected,
                              width: 2.w,
                            ),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: AppColors.selected,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        Text(
                          'പേര്',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 40.h,
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'Person name filled',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.selected,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Nakshatram field
                        Text(
                          'നക്ഷത്രം',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Builder(
                          builder: (ctx) {
                            if (!didStartFetch) {
                              didStartFetch = true;
                              Future(() async {
                                try {
                                  final options = await ref.read(
                                    nakshatramsProvider.future,
                                  );
                                  setState(() {
                                    nakshatramOptions = options;
                                    nakshLoading = false;
                                    nakshError = null;
                                    if (options.isNotEmpty) {
                                      final initial = options.first;
                                      selectedNakshatram ??= initial.id;
                                      selectedNakshatramName ??= initial.name;
                                    }
                                  });
                                } catch (e) {
                                  setState(() {
                                    nakshLoading = false;
                                    nakshError = e.toString();
                                  });
                                }
                              });
                            }

                            return SizedBox(
                              height: 40.h,
                              child: DropdownButtonFormField<int>(
                                value: selectedNakshatram,
                                isExpanded: true,
                                items: nakshatramOptions
                                    .map(
                                      (o) => DropdownMenuItem<int>(
                                        value: o.id,
                                        child: Text(o.name),
                                      ),
                                    )
                                    .toList(),
                                hint: Text(
                                  nakshLoading
                                      ? 'Loading...'
                                      : (nakshError != null
                                            ? 'Failed to load'
                                            : 'select any'),
                                ),
                                onChanged: nakshLoading || nakshError != null
                                    ? null
                                    : (val) {
                                        if (val == null) return;
                                        final name = nakshatramOptions
                                            .firstWhere((o) => o.id == val)
                                            .name;
                                        setState(() {
                                          selectedNakshatram = val;
                                          selectedNakshatramName = name;
                                        });
                                      },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(
                                      color: AppColors.selected,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20.h),

                        // Date of birth and Time row
                        Row(
                          children: [
                            // Date of birth field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date of birth/Age',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  SizedBox(
                                    height: 40.h,
                                    child: TextField(
                                      controller: dobController,
                                      decoration: InputDecoration(
                                        hintText: 'ddmmyy/XX yrs',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 10.h,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.selected,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16.w),
                            // Time field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Time',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  SizedBox(
                                    height: 40.h,
                                    child: TextField(
                                      controller: timeController,
                                      decoration: InputDecoration(
                                        hintText: '00:00 AM',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 10.h,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.selected,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 40.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.isNotEmpty) {
                              try {
                                if (selectedNakshatram == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '⚠️ Please select a Nakshatram',
                                      ),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                String dob = dobController.text.trim();
                                if (dob.isNotEmpty) {
                                  dob = dob.replaceAll('/', '-');
                                  final parts = dob.split('-');
                                  if (parts.length == 3 &&
                                      parts[0].length == 2 &&
                                      parts[1].length == 2 &&
                                      parts[2].length == 4) {
                                    dob = '${parts[2]}-${parts[1]}-${parts[0]}';
                                  }
                                }

                                String time = timeController.text.trim();
                                if (RegExp(
                                  r'^\d{1,2}:\d{2} $',
                                ).hasMatch(time)) {
                                  time = '$time:00';
                                } else if (RegExp(
                                  r'^\d{1,2}:\d{2}$',
                                ).hasMatch(time)) {
                                  time = '$time:00';
                                }

                                final userData = {
                                  'name': nameController.text,
                                  'DOB': dob,
                                  'time': time,
                                  'attributes': [
                                    {'nakshatram': selectedNakshatram},
                                  ],
                                };

                                print(
                                  '🌐 API Call - POST /api/user/user-lists',
                                );
                                print(
                                  '📤 Request Payload: ${json.encode(userData)}',
                                );

                                final newUser = await ref.read(
                                  addNewUserProvider(userData).future,
                                );

                                print(
                                  '✅ API Response - User added successfully',
                                );
                                print(
                                  '📥 Response Data: ${json.encode(newUser.toJson())}',
                                );

                                // Refresh the complete user list so the new
                                // user appears in the "View All" list, but do
                                // not auto-add to visible/selected users.
                                final _ = ref.refresh(userListsProvider);

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('✅ User added successfully!'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 3),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                print('❌ API Error - Failed to add user');
                                print('🚨 Error Message: $e');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '❌ Failed to add user: ${e.toString()}',
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 4),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    action: SnackBarAction(
                                      label: 'Dismiss',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentSnackBar();
                                      },
                                    ),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('⚠️ Please enter a name'),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.selected,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'സേവ്',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Cancel button
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'റദ്ദാക്കുക',
                          style: TextStyle(
                            color: AppColors.selected,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditUserBottomSheet(
    BuildContext context,
    WidgetRef ref,
    UserList user,
  ) {
    final nameController = TextEditingController(text: user.name);
    final dobController = TextEditingController(text: user.dob);
    final timeController = TextEditingController(text: user.time);
    int? selectedNakshatram = user.attributes.isNotEmpty
        ? user.attributes.first.nakshatram
        : 1;
    String? selectedNakshatramName = user.attributes.isNotEmpty
        ? user.attributes.first.nakshatramName
        : null;
    bool didStartFetch = false;
    List<NakshatramOption> nakshatramOptions = [];
    bool nakshLoading = true;
    String? nakshError;

    // Store original values to detect changes
    final originalName = user.name;
    final originalDob = user.dob;
    final originalTime = user.time;
    final originalNakshatram = selectedNakshatram;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Check if any field has changed
          bool hasChanges =
              nameController.text != originalName ||
              dobController.text != originalDob ||
              timeController.text != originalTime ||
              selectedNakshatram != originalNakshatram;

          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                // Handle bar

                // Header with title and close button
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'വ്യക്തിവിവരം',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.selected,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.selected,
                              width: 2.w,
                            ),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: AppColors.selected,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        Text(
                          'പേര്',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 40.h,
                          child: TextField(
                            controller: nameController,
                            onChanged: (value) {
                              setState(() {
                                // Trigger rebuild to check for changes
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Person name filled',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: AppColors.selected,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Nakshatram field
                        Text(
                          'നക്ഷത്രം',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Builder(
                          builder: (ctx) {
                            if (!didStartFetch) {
                              didStartFetch = true;
                              Future(() async {
                                try {
                                  final options = await ref.read(
                                    nakshatramsProvider.future,
                                  );
                                  setState(() {
                                    nakshatramOptions = options;
                                    nakshLoading = false;
                                    nakshError = null;
                                    // Keep current selection by default
                                  });
                                } catch (e) {
                                  setState(() {
                                    nakshLoading = false;
                                    nakshError = e.toString();
                                  });
                                }
                              });
                            }

                            return SizedBox(
                              height: 40.h,
                              child: DropdownButtonFormField<int>(
                                value: selectedNakshatram,
                                isExpanded: true,
                                items: nakshatramOptions
                                    .map(
                                      (o) => DropdownMenuItem<int>(
                                        value: o.id,
                                        child: Text(o.name),
                                      ),
                                    )
                                    .toList(),
                                hint: Text(
                                  nakshLoading
                                      ? 'Loading...'
                                      : (nakshError != null
                                            ? 'Failed to load'
                                            : (selectedNakshatramName ??
                                                  'select any')),
                                ),
                                onChanged: nakshLoading || nakshError != null
                                    ? null
                                    : (val) {
                                        if (val == null) return;
                                        final name = nakshatramOptions
                                            .firstWhere((o) => o.id == val)
                                            .name;
                                        setState(() {
                                          selectedNakshatram = val;
                                          selectedNakshatramName = name;
                                        });
                                      },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                    borderSide: BorderSide(
                                      color: AppColors.selected,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20.h),

                        // Date of birth and Time row
                        Row(
                          children: [
                            // Date of birth field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date of birth/Age',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  SizedBox(
                                    height: 40.h,
                                    child: TextField(
                                      controller: dobController,
                                      onChanged: (value) {
                                        setState(() {
                                          // Trigger rebuild to check for changes
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'ddmmyy/XX yrs',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 10.h,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.selected,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16.w),
                            // Time field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Time',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  SizedBox(
                                    height: 40.h,
                                    child: TextField(
                                      controller: timeController,
                                      onChanged: (value) {
                                        setState(() {
                                          // Trigger rebuild to check for changes
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: '00:00 AM',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 10.h,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.selected,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      // Update button
                      SizedBox(
                        width: double.infinity,
                        height: 40.h,
                        child: ElevatedButton(
                          onPressed: hasChanges
                              ? () async {
                                  try {
                                    if (selectedNakshatram == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '⚠️ Please select a Nakshatram',
                                          ),
                                          backgroundColor: Colors.orange,
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    String dob = dobController.text.trim();
                                    if (dob.isNotEmpty) {
                                      dob = dob.replaceAll('/', '-');
                                      final parts = dob.split('-');
                                      if (parts.length == 3 &&
                                          parts[0].length == 2 &&
                                          parts[1].length == 2 &&
                                          parts[2].length == 4) {
                                        dob =
                                            '${parts[2]}-${parts[1]}-${parts[0]}';
                                      }
                                    }

                                    String time = timeController.text.trim();
                                    if (RegExp(
                                      r'^\d{1,2}:\d{2}$',
                                    ).hasMatch(time)) {
                                      time = '$time:00';
                                    }

                                    final userData = {
                                      'name': nameController.text,
                                      'DOB': dob,
                                      'time': time,
                                      'attributes': [
                                        {'nakshatram': selectedNakshatram},
                                      ],
                                    };

                                    // Print API call details
                                    print(
                                      '🌐 API Call - PATCH /api/user/user-lists/${user.id}',
                                    );
                                    print(
                                      '📤 Request Payload: ${json.encode(userData)}',
                                    );

                                    final updatedUser = await ref.read(
                                      updateUserProvider((
                                        userId: user.id,
                                        userData: userData,
                                      )).future,
                                    );

                                    // Print successful response
                                    print(
                                      '✅ API Response - User updated successfully',
                                    );
                                    print(
                                      '📥 Response Data: ${json.encode(updatedUser.toJson())}',
                                    );

                                    // Update the user in both lists
                                    final currentVisibleUsers = ref.read(
                                      visibleUsersProvider(userId),
                                    );
                                    final currentSelectedUsers = ref.read(
                                      selectedUsersProvider(userId),
                                    );

                                    final updatedVisibleUsers =
                                        currentVisibleUsers
                                            .map(
                                              (u) => u.id == user.id
                                                  ? updatedUser
                                                  : u,
                                            )
                                            .toList();
                                    final updatedSelectedUsers =
                                        currentSelectedUsers
                                            .map(
                                              (u) => u.id == user.id
                                                  ? updatedUser
                                                  : u,
                                            )
                                            .toList();

                                    ref
                                            .read(
                                              visibleUsersProvider(
                                                userId,
                                              ).notifier,
                                            )
                                            .state =
                                        updatedVisibleUsers;
                                    ref
                                            .read(
                                              selectedUsersProvider(
                                                userId,
                                              ).notifier,
                                            )
                                            .state =
                                        updatedSelectedUsers;

                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '✅ User updated successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 3),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    // Print error details
                                    print(
                                      '❌ API Error - Failed to update user',
                                    );
                                    print('🚨 Error Message: $e');

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '❌ Failed to update user: ${e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 4),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        action: SnackBarAction(
                                          label: 'Dismiss',
                                          textColor: Colors.white,
                                          onPressed: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).hideCurrentSnackBar();
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasChanges
                                ? AppColors.selected
                                : Colors.grey[400],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'അപ്ഡേറ്റ്',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Delete button
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'ഡിലീറ്റ്',
                          style: TextStyle(
                            color: AppColors.selected,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAgentCodeSheet(
    BuildContext context,
    WidgetRef ref,
    String currentAgentCode,
  ) {
    final TextEditingController controller = TextEditingController(
      text: currentAgentCode,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async {
            // Uncheck agent code checkbox when dismissing with back button
            ref.read(isAgentCodeProvider.notifier).state = false;
            ref.read(agentCodeProvider.notifier).state = '';
            return true;
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom:
                  MediaQuery.of(ctx).viewInsets.bottom +
                  MediaQuery.of(ctx).padding.bottom +
                  16.h,
              top: 16.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ഏജന്റ് കോഡ്',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Uncheck agent code checkbox when closing without confirming
                        ref.read(isAgentCodeProvider.notifier).state = false;
                        ref.read(agentCodeProvider.notifier).state = '';
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Code XYZA',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'ഏജന്റ് കോഡ് ഉപയോഗിക്കുന്നതുപക്ഷത്തിൽ, തീർത്ഥാടന നടത്തിപ്പ് മുൻപ് കൗണ്ടറിൽ പണമടയ്ക്കണം. ഓൺലൈനായി പണമടയ്ക്കേണ്ടതില്ല.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(agentCodeProvider.notifier).state =
                          controller.text;
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8C001A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'സ്ഥിരീകരിക്കുക',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _formatDate(String dateString) {
  try {
    final DateTime date = DateTime.parse(dateString);
    final List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final String month = months[date.month - 1];
    final int day = date.day;
    final int year = date.year;

    return '$month $day, $year';
  } catch (e) {
    // Return original string if parsing fails
    return dateString;
  }
}

// CustomCalendarPicker moved to its own file: lib/widgets/custom_calendar_picker.dart
