import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/core/constants/format.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import 'package:temple_app/features/booking/data/nakshatram_model.dart';
import 'package:temple_app/features/booking/data/user_list_model.dart';
import 'package:temple_app/features/booking/providers/booking_page_providers.dart';
import 'package:temple_app/features/booking/providers/user_list_provider.dart';

class EditUserBottomSheet extends ConsumerStatefulWidget {
  final int userId;
  final UserList user;

  const EditUserBottomSheet({
    super.key,
    required this.userId,
    required this.user,
  });

  @override
  ConsumerState<EditUserBottomSheet> createState() =>
      _EditUserBottomSheetState();
}

class _EditUserBottomSheetState extends ConsumerState<EditUserBottomSheet> {
  late final TextEditingController nameController;
  late final TextEditingController dobController;
  late final TextEditingController timeController;
  int? selectedNakshatram;
  String? selectedNakshatramName;
  bool didStartFetch = false;
  List<NakshatramOption> nakshatramOptions = [];
  bool nakshLoading = true;
  String? nakshError;

  // Store original values to detect changes
  late final String originalName;
  late final String originalDob;
  late final String originalTime;
  late final int originalNakshatram;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupOriginalValues();
  }

  void _initializeControllers() {
    nameController = TextEditingController(text: widget.user.name);
    dobController = TextEditingController(text: widget.user.dob);
    timeController = TextEditingController(text: widget.user.time);

    selectedNakshatram = widget.user.attributes.isNotEmpty
        ? widget.user.attributes.first.nakshatram
        : 1;
    selectedNakshatramName = widget.user.attributes.isNotEmpty
        ? widget.user.attributes.first.nakshatramName
        : null;
  }

  void _setupOriginalValues() {
    originalName = widget.user.name;
    originalDob = widget.user.dob;
    originalTime = widget.user.time;
    originalNakshatram = selectedNakshatram ?? 1;
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildFormFields(setState),
                _buildActionButtons(setState, hasChanges),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
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
                border: Border.all(color: AppColors.selected, width: 2.w),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(Icons.close, size: 16.sp, color: AppColors.selected),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(StateSetter setState) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameField(setState),
          SizedBox(height: 16.h),
          _buildNakshatramField(setState),
          SizedBox(height: 20.h),
          _buildDateTimeFields(setState),
        ],
      ),
    );
  }

  Widget _buildNameField(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            onChanged: (value) => setState(() {}),
            decoration: _buildInputDecoration('Person name filled'),
          ),
        ),
      ],
    );
  }

  Widget _buildNakshatramField(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  final options = await ref.read(nakshatramsProvider.future);
                  setState(() {
                    nakshatramOptions = options;
                    nakshLoading = false;
                    nakshError = null;
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
                initialValue: selectedNakshatram,
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
                            : (selectedNakshatramName ?? 'select any')),
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
                decoration: _buildInputDecoration('select any'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeFields(StateSetter setState) {
    return Row(
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
                  readOnly: true,
                  enableInteractiveSelection: false,
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(1900, 1, 1),
                      lastDate: DateTime(now.year, 12, 31),
                    );
                    if (picked != null) {
                      final String yyyy = picked.year.toString().padLeft(
                        4,
                        '0',
                      );
                      final String mm = picked.month.toString().padLeft(2, '0');
                      final String dd = picked.day.toString().padLeft(2, '0');
                      setState(() {
                        dobController.text = '$yyyy-$mm-$dd';
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'yyyy-mm-dd',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
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
                  readOnly: true,
                  enableInteractiveSelection: false,
                  onTap: () async {
                    final TimeOfDay initial = TimeOfDay.now();
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: initial,
                    );
                    if (picked != null) {
                      final String hh = picked.hour.toString().padLeft(2, '0');
                      final String mm = picked.minute.toString().padLeft(
                        2,
                        '0',
                      );
                      setState(() {
                        timeController.text = '$hh:$mm:00';
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: '00:00:00',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(StateSetter setState, bool hasChanges) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.w,
        bottom: 20.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          // Update button
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton(
              onPressed: hasChanges ? () => _handleUpdate(setState) : null,
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
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Delete button
          TextButton(
            onPressed: () => _handleDelete(),
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
    );
  }

  Future<void> _handleUpdate(StateSetter setState) async {
    try {
      if (selectedNakshatram == null) {
        _showSnackBar('⚠️ Please select a Nakshatram');
        return;
      }

      final dob = formatDate(dobController.text);
      final time = formatTime(timeController.text);

      final userData = {
        'name': nameController.text,
        'DOB': dob,
        'time': time,
        'attributes': [
          {'nakshatram': selectedNakshatram},
        ],
      };

      print('🌐 API Call - PATCH /api/user/user-lists/${widget.user.id}');
      print('📤 Request Payload: ${json.encode(userData)}');

      final updatedUser = await ref.read(
        updateUserProvider((userId: widget.user.id, userData: userData)).future,
      );

      print('✅ API Response - User updated successfully');
      print('📥 Response Data: ${json.encode(updatedUser.toJson())}');

      // Update the user in both lists
      final currentVisibleUsers = ref.read(visibleUsersProvider(widget.userId));
      final currentSelectedUsers = ref.read(
        selectedUsersProvider(widget.userId),
      );

      final updatedVisibleUsers = currentVisibleUsers
          .map((u) => u.id == widget.user.id ? updatedUser : u)
          .toList();
      final updatedSelectedUsers = currentSelectedUsers
          .map((u) => u.id == widget.user.id ? updatedUser : u)
          .toList();

      ref.read(visibleUsersProvider(widget.userId).notifier).state =
          updatedVisibleUsers;
      ref.read(selectedUsersProvider(widget.userId).notifier).state =
          updatedSelectedUsers;

      ref.invalidate(userListsProvider);
      Navigator.pop(context);
      _showSnackBar('✅ User updated successfully!');
    } catch (e) {
      print('❌ API Error - Failed to update user');
      print('🚨 Error Message: $e');
      _showSnackBar('❌ Failed to update user: ${e.toString()}');
    }
  }

  Future<void> _handleDelete() async {
    try {
      final repo = ref.read(userListRepositoryProvider);
      final ok = await repo.deleteUser(widget.user.id);
      if (ok) {
        // Remove from local state immediately
        final currentVisibleUsers = ref.read(
          visibleUsersProvider(widget.userId),
        );
        final currentSelectedUsers = ref.read(
          selectedUsersProvider(widget.userId),
        );

        ref.read(visibleUsersProvider(widget.userId).notifier).state =
            currentVisibleUsers.where((u) => u.id != widget.user.id).toList();
        ref.read(selectedUsersProvider(widget.userId).notifier).state =
            currentSelectedUsers.where((u) => u.id != widget.user.id).toList();

        ref.invalidate(userListsProvider);
        Navigator.pop(context);
        _showSnackBar('✅ User deleted');
      } else {
        _showSnackBar('❌ Failed to delete user');
      }
    } catch (e) {
      _showSnackBar('❌ Delete error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryThemeColor,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400]),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
    );
  }
}

