import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/booking/data/user_list_model.dart';
import 'package:temple_app/features/booking/providers/booking_page_providers.dart';
import 'package:temple_app/features/booking/providers/user_list_provider.dart';
import 'package:temple_app/features/booking/presentation/widgets/user_entry.dart';
import 'package:temple_app/features/booking/presentation/widgets/add_new_user_option.dart';
import 'package:temple_app/features/booking/presentation/widgets/additional_options.dart';

class PoojaForWhomSection extends ConsumerWidget {
  final int userId;
  final List<UserList> userLists;

  const PoojaForWhomSection({
    super.key,
    required this.userId,
    required this.userLists,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedUsers = ref.watch(selectedUsersProvider(userId));

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
            ...selectedUsers.map(
              (user) => Column(
                children: [
                  UserEntry(
                    userId: userId,
                    user: user,
                    isSelected: selectedUsers.any(
                      (selectedUser) => selectedUser.id == user.id,
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),

            // Add new user option
            AddNewUserOption(userId: userId),
            SizedBox(height: 12.h),
          ],

          // Additional Options
          AdditionalOptions(),
        ],
      ),
    );
  }
}

