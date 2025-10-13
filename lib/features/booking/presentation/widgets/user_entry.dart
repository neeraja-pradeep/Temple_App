import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import 'package:temple_app/features/booking/data/user_list_model.dart';
import 'package:temple_app/features/booking/providers/booking_page_providers.dart';
import 'package:temple_app/features/booking/presentation/bottom_sheets/edit_user_bottom_sheet.dart';
import 'package:temple_app/features/booking/providers/user_list_provider.dart';

class UserEntry extends ConsumerWidget {
  final int userId;
  final UserList user;
  final bool isSelected;

  const UserEntry({
    super.key,
    required this.userId,
    required this.user,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  backgroundColor: primaryThemeColor,
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
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) =>
                  EditUserBottomSheet(userId: userId, user: user),
            );
            // Trigger a provider refresh after sheet closes on next frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.invalidate(userListsProvider);
            });
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
}

