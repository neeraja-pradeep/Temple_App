import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/booking/data/user_list_model.dart';
import 'package:temple_app/features/booking/providers/user_list_provider.dart';
import 'package:temple_app/features/booking/presentation/bottom_sheets/add_user_bottom_sheet.dart';
import 'package:temple_app/features/booking/presentation/bottom_sheets/all_users_bottom_sheet.dart';

class AddNewUserOption extends ConsumerWidget {
  final int userId;

  const AddNewUserOption({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: GestureDetector(
            onTap: () => _showAddNewUserBottomSheet(context, ref),
            child: Icon(Icons.add, size: 14.sp, color: AppColors.selected),
          ),
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
            _showAllUsersBottomSheet(context, ref);
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

  void _showAddNewUserBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddUserBottomSheet(userId: userId),
    );
  }

  void _showAllUsersBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AllUsersBottomSheet(userId: userId),
    );
  }
}

