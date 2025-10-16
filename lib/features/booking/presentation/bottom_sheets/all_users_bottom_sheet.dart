import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import 'package:temple_app/features/booking/data/user_list_model.dart';
import 'package:temple_app/features/booking/providers/user_list_provider.dart';
import 'package:temple_app/features/booking/presentation/bottom_sheets/add_user_bottom_sheet.dart';
import 'package:temple_app/features/booking/presentation/bottom_sheets/edit_user_bottom_sheet.dart';

class AllUsersBottomSheet extends ConsumerWidget {
  final int userId;

  const AllUsersBottomSheet({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Always fetch fresh users when opening the sheet
    ref.invalidate(userListsProvider);

    // Auto-select main user when opening the sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureMainUserIsSelected(ref);
    });

    return Container(
      height: 370.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          SizedBox(height: 20.h),
          _buildUsersList(),
          _buildAddNewUserButton(context),
          _buildContinueButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
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
                border: Border.all(color: AppColors.selected, width: 2.w),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(Icons.close, size: 16.sp, color: AppColors.selected),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return Expanded(
      child: Consumer(
        builder: (context, ref, child) {
          final selectedUsers = ref.watch(selectedUsersProvider(userId));
          final usersAsync = ref.watch(userListsProvider);

          return usersAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.selected),
            ),
            error: (e, _) => Center(child: Text('Failed to load users')),
            data: (liveUsers) {
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                itemCount: liveUsers.length,
                itemBuilder: (context, index) {
                  final user = liveUsers[index];
                  final isSelected = selectedUsers.any(
                    (selectedUser) => selectedUser.id == user.id,
                  );
                  final nakshatramName = user.attributes.isNotEmpty
                      ? user.attributes.first.nakshatramName
                      : 'Please select a nakshatram';

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
                          onTap: () => _handleUserSelection(
                            context,
                            ref,
                            user,
                            isSelected,
                          ),
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
                              if (nakshatramName.isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  nakshatramName,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: user.attributes.isNotEmpty
                                        ? Colors.grey[600]
                                        : Colors.red[700],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Edit button
                        TextButton(
                          onPressed: () => _showEditUser(context, ref, user),
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
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddNewUserButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Align(
        alignment: Alignment.center,
        child: TextButton.icon(
          onPressed: () => _showAddNewUser(context),
          icon: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.selected, width: 2.w),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Icon(Icons.add, size: 14.sp, color: AppColors.selected),
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
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Consumer(
        builder: (context, ref, child) {
          final selectedUsers = ref.watch(selectedUsersProvider(userId));

          return SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton(
              onPressed: () {
                if (selectedUsers.isNotEmpty) {
                  ref.read(selectedUsersProvider(userId).notifier).state =
                      selectedUsers;
                  ref.read(visibleUsersProvider(userId).notifier).state =
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
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleUserSelection(
    BuildContext context,
    WidgetRef ref,
    UserList user,
    bool isSelected,
  ) {
    // Prevent unselecting the main user
    if (user.id == userId && isSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('പ്രധാന ഉപയോക്താവിനെ നീക്കാൻ കഴിയില്ല'),
          backgroundColor: primaryThemeColor,
        ),
      );
      return;
    }

    final currentSelectedUsers = List<UserList>.from(
      ref.read(selectedUsersProvider(userId)),
    );
    final currentVisibleUsers = ref.read(visibleUsersProvider(userId));
    final updatedVisibleUsers = List<UserList>.from(currentVisibleUsers);

    if (isSelected) {
      currentSelectedUsers.removeWhere(
        (selectedUser) => selectedUser.id == user.id,
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

    ref.read(selectedUsersProvider(userId).notifier).state =
        currentSelectedUsers;
    ref.read(visibleUsersProvider(userId).notifier).state = updatedVisibleUsers;
  }

  void _showEditUser(BuildContext context, WidgetRef ref, UserList user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditUserBottomSheet(userId: userId, user: user),
    );
  }

  void _showAddNewUser(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddUserBottomSheet(userId: userId),
    );
  }

  void _ensureMainUserIsSelected(WidgetRef ref) {
    final usersAsync = ref.read(userListsProvider);
    final selectedUsers = ref.read(selectedUsersProvider(userId));
    print('selectedUsers: $selectedUsers');
    usersAsync.when(
      data: (users) {
        // Check if main user is already selected
        final isMainUserSelected = selectedUsers.any(
          (user) => user.id == userId,
        );

        if (!isMainUserSelected) {
          try {
            // Find the main user and add to selection
            final mainUser = users.firstWhere((user) => user.id == userId);
            final updatedSelectedUsers = List<UserList>.from(selectedUsers);
            updatedSelectedUsers.add(mainUser);

            // Update both selected and visible users
            ref.read(selectedUsersProvider(userId).notifier).state =
                updatedSelectedUsers;
            ref.read(visibleUsersProvider(userId).notifier).state =
                updatedSelectedUsers;
          } catch (e) {
            // Main user not found in the list, this shouldn't happen normally
            print('Main user not found in user list: $e');
          }
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }
}
