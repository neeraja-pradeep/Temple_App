import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:temple/core/app_colors.dart';
import '../providers/booking_provider.dart';
import '../providers/user_list_provider.dart';
import '../data/booking_pooja_model.dart';
import '../data/user_list_model.dart';

final isParticipatingPhysicallyProvider = StateProvider<bool>((ref) => false);
final isAgentCodeProvider = StateProvider<bool>((ref) => false);
final agentCodeProvider = StateProvider<String>((ref) => '');
final showCalendarProvider = StateProvider<bool>((ref) => false);
final selectedCalendarDateProvider = StateProvider<String?>((ref) => null);

class BookingPage extends ConsumerWidget {
  final int poojaId;
  final int userId;

  const BookingPage({super.key, required this.poojaId, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingPoojaAsync = ref.watch(bookingPoojaProvider(poojaId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64.w, // give extra space for left padding
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w), // shift container inward
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
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
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
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
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
    );
  }

  Widget _buildBookingContent(BuildContext context, BookingPooja pooja) {
    return Consumer(
      builder: (context, ref, _) {
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
                        // Malayalam Date
                        if (pooja.specialPoojaDates.isNotEmpty) ...[
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
                          // English Date
                          Text(
                            _formatDate(pooja.specialPoojaDates.first.date),
                            style: TextStyle(
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
                  // Show calendar card below the first card if toggled
                  Builder(
                    builder: (context) {
                      final showCalendar = ref.watch(showCalendarProvider);
                      if (!showCalendar) return SizedBox.shrink();
                      final enabledDates = pooja.specialPoojaDates
                          .map((d) => d.date)
                          .toList();
                      final selectedDate = ref.watch(
                        selectedCalendarDateProvider,
                      );
                      return Padding(
                        padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: CustomCalendarPicker(
                              enabledDates: enabledDates,
                              selectedDate: selectedDate,
                              onDateSelected: (date) {
                                ref
                                        .read(
                                          selectedCalendarDateProvider.notifier,
                                        )
                                        .state =
                                    date;
                                ref.read(showCalendarProvider.notifier).state =
                                    false;
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
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
                            onPressed: () {
                              // TODO: Implement actual booking logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Booking functionality coming soon!',
                                  ),
                                  backgroundColor: AppColors.selected,
                                ),
                              );
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
    final visibleUsers = ref.watch(visibleUsersProvider(userId));

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
            ...visibleUsers
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
                      SizedBox(height: 12.h),
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
            height: 20.h,
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
          height: 20.h,
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
          height: 20.h,
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
              value: isAgentCode ? true : isParticipatingPhysically,
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
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                    ),
                    builder: (context) {
                      String tempAgentCode = agentCode;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          left: 16.w,
                          right: 16.w,
                          top: 24.h,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ഏജന്റ് കോഡ്',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            TextField(
                              onChanged: (value) => tempAgentCode = value,
                              decoration: InputDecoration(hintText: 'Code'),
                              controller: TextEditingController(
                                text: agentCode,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Close'),
                                ),
                                SizedBox(width: 8.w),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(agentCodeProvider.notifier).state =
                                        tempAgentCode;
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Save'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
            SizedBox(width: 12.w),
            Text(
              'ഏജന്റ് കോഡ് നൽകുക (Optional)',
              style: TextStyle(fontSize: 12.sp, color: Colors.black),
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
            height: MediaQuery.of(context).size.height * 0.7,
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
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Title
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Text(
                    'Select Person for Pooja',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                // Users list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: userLists.length,
                    itemBuilder: (context, index) {
                      final user = userLists[index];
                      final isSelected = selectedUsers.any(
                        (selectedUser) => selectedUser.id == user.id,
                      );
                      final nakshatramName = user.attributes.isNotEmpty
                          ? user.attributes.first.nakshatramName
                          : '';

                      return GestureDetector(
                        onTap: () {
                          final currentSelectedUsers = List<UserList>.from(
                            selectedUsers,
                          );
                          final currentVisibleUsers = ref.read(
                            visibleUsersProvider(userId),
                          );
                          final updatedVisibleUsers = List<UserList>.from(
                            currentVisibleUsers,
                          );

                          if (isSelected) {
                            // Remove from selection
                            currentSelectedUsers.removeWhere(
                              (selectedUser) => selectedUser.id == user.id,
                            );
                            // Also remove from visible list
                            updatedVisibleUsers.removeWhere(
                              (visibleUser) => visibleUser.id == user.id,
                            );
                          } else {
                            // Add to selection
                            currentSelectedUsers.add(user);
                            // Also add to visible list if not already there
                            if (!updatedVisibleUsers.any(
                              (visibleUser) => visibleUser.id == user.id,
                            )) {
                              updatedVisibleUsers.add(user);
                            }
                          }

                          ref
                                  .read(selectedUsersProvider(userId).notifier)
                                  .state =
                              currentSelectedUsers;
                          ref
                                  .read(visibleUsersProvider(userId).notifier)
                                  .state =
                              updatedVisibleUsers;
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.selected
                                  : Colors.grey[300]!,
                              width: isSelected ? 2.w : 1.w,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            color: isSelected
                                ? AppColors.selected.withOpacity(0.1)
                                : Colors.white,
                          ),
                          child: Row(
                            children: [
                              // Checkbox
                              Container(
                                width: 20.w,
                                height: 20.h,
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
                              SizedBox(width: 16.w),

                              // User details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Save button
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // Save the selected users and update visible users
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
                        'Save',
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
    int? selectedNakshatram = 2;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

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
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.selected,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32.w,
                      height: 32.h,
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
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Person name filled',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: AppColors.selected),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Nakshatram field
                    Text(
                      'നക്ഷത്രം',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'selected Nakshatram',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: Colors.black),
                        ],
                      ),
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
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              TextField(
                                controller: dobController,
                                decoration: InputDecoration(
                                  hintText: 'ddmmyy/XX yrs',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
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
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              TextField(
                                controller: timeController,
                                decoration: InputDecoration(
                                  hintText: '00:00 AM',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.h),
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
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty) {
                          try {
                            final userData = {
                              'name': nameController.text,
                              'DOB': dobController.text,
                              'time': timeController.text,
                              'attributes': [
                                {'nakshatram': selectedNakshatram ?? 1},
                              ],
                            };

                            // Print API call details
                            print('🌐 API Call - POST /api/user/user-lists');
                            print(
                              '📤 Request Payload: ${json.encode(userData)}',
                            );

                            final newUser = await ref.read(
                              addNewUserProvider(userData).future,
                            );

                            // Print successful response
                            print('✅ API Response - User added successfully');
                            print(
                              '📥 Response Data: ${json.encode(newUser.toJson())}',
                            );

                            // Add to visible and selected users
                            final currentVisibleUsers = ref.read(
                              visibleUsersProvider(userId),
                            );
                            final currentSelectedUsers = ref.read(
                              selectedUsersProvider(userId),
                            );

                            final updatedVisibleUsers = List<UserList>.from(
                              currentVisibleUsers,
                            )..add(newUser);
                            final updatedSelectedUsers = List<UserList>.from(
                              currentSelectedUsers,
                            )..add(newUser);

                            ref
                                    .read(visibleUsersProvider(userId).notifier)
                                    .state =
                                updatedVisibleUsers;
                            ref
                                    .read(
                                      selectedUsersProvider(userId).notifier,
                                    )
                                    .state =
                                updatedSelectedUsers;

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
                            // Print error details
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
                          // Show validation error
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
                          fontSize: 16.sp,
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
            height: MediaQuery.of(context).size.height * 0.8,
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
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

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
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.selected,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32.w,
                          height: 32.h,
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
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: nameController,
                          onChanged: (value) {
                            setState(() {
                              // Trigger rebuild to check for changes
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Person name filled',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(color: AppColors.selected),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Nakshatram field
                        Text(
                          'നക്ഷത്രം',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () {
                            // TODO: Show nakshatram selection dialog
                            setState(() {
                              selectedNakshatram = selectedNakshatram == 1
                                  ? 2
                                  : 1;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8.r),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  user.attributes.isNotEmpty
                                      ? user.attributes.first.nakshatramName
                                      : 'selected Nakshatram',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
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
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextField(
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
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextField(
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
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40.h),
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
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: hasChanges
                              ? () async {
                                  try {
                                    final userData = {
                                      'name': nameController.text,
                                      'DOB': dobController.text,
                                      'time': timeController.text,
                                      'attributes': [
                                        {'nakshatram': selectedNakshatram ?? 1},
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
                              fontSize: 16.sp,
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

class CustomCalendarPicker extends StatefulWidget {
  final List<String> enabledDates;
  final String? selectedDate;
  final void Function(String) onDateSelected;

  const CustomCalendarPicker({
    Key? key,
    required this.enabledDates,
    required this.onDateSelected,
    this.selectedDate,
  }) : super(key: key);

  @override
  State<CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<CustomCalendarPicker> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    // Default to first enabled date's month, or today
    if (widget.enabledDates.isNotEmpty) {
      _displayedMonth = DateTime.parse(widget.enabledDates.first);
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month);
    } else {
      final now = DateTime.now();
      _displayedMonth = DateTime(now.year, now.month);
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabledDateSet = widget.enabledDates.toSet();
    final selected = widget.selectedDate;
    final daysInMonth = DateUtils.getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    final firstDayOfWeek =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday % 7;
    final days = List.generate(daysInMonth, (i) => i + 1);
    final monthName = _monthName(_displayedMonth.month);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: _goToPreviousMonth,
            ),
            Text(
              '$monthName ${_displayedMonth.year}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: _goToNextMonth,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4.h,
            crossAxisSpacing: 4.w,
            childAspectRatio: 1,
          ),
          itemCount: daysInMonth + firstDayOfWeek,
          itemBuilder: (context, i) {
            if (i < firstDayOfWeek) {
              return SizedBox.shrink();
            }
            final day = days[i - firstDayOfWeek];
            final date = DateTime(
              _displayedMonth.year,
              _displayedMonth.month,
              day,
            );
            final dateStr = date.toIso8601String().substring(0, 10);
            final isEnabled = enabledDateSet.contains(dateStr);
            final isSelected = selected == dateStr;
            return GestureDetector(
              onTap: isEnabled
                  ? () {
                      widget.onDateSelected(dateStr);
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.selected
                      : isEnabled
                      ? Colors.white
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(6.r),
                  border: isSelected
                      ? Border.all(color: AppColors.selected, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isEnabled
                          ? (isSelected ? Colors.white : Colors.black)
                          : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
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
    return months[month - 1];
  }
}
