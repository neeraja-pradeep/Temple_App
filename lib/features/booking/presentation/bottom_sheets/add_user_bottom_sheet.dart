import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/core/constants/format.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import 'package:temple_app/features/booking/data/nakshatram_model.dart';
import 'package:temple_app/features/booking/providers/booking_page_providers.dart';
import 'package:temple_app/features/booking/providers/user_list_provider.dart';

class AddUserBottomSheet extends ConsumerStatefulWidget {
  final int userId;

  const AddUserBottomSheet({super.key, required this.userId});

  @override
  ConsumerState<AddUserBottomSheet> createState() => _AddUserBottomSheetState();
}

class _AddUserBottomSheetState extends ConsumerState<AddUserBottomSheet> {
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final timeController = TextEditingController();
  int? selectedNakshatram;
  String? selectedNakshatramName;
  bool didStartFetch = false;
  List<NakshatramOption> nakshatramOptions = [];
  bool nakshLoading = true;
  String? nakshError;
  String? dobError;
  String? timeError;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    dobController.addListener(() {
      final digits = dobController.text.replaceAll(RegExp(r'[^0-9]'), '');
      String formatted = '';
      for (int i = 0; i < digits.length && i < 8; i++) {
        formatted += digits[i];
        if (i == 3 || i == 5) formatted += '-';
      }
      if (formatted != dobController.text) {
        dobController.value = dobController.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });

    timeController.addListener(() {
      final digits = timeController.text.replaceAll(RegExp(r'[^0-9]'), '');
      String formatted = '';
      for (int i = 0; i < digits.length && i < 6; i++) {
        formatted += digits[i];
        if (i == 1 || i == 3) formatted += ':';
      }
      if (formatted != timeController.text) {
        timeController.value = timeController.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
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
        return SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                _buildHeader(),
                _buildFormFields(setState),
                _buildActionButtons(setState),
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
          _buildNameField(),
          SizedBox(height: 16.h),
          _buildNakshatramField(setState),
          SizedBox(height: 20.h),
          _buildDateTimeFields(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
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
                      : (nakshError != null ? 'Failed to load' : 'select any'),
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

  Widget _buildDateTimeFields() {
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
                height: 60.h,
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
                      dobController.text = '$yyyy-$mm-$dd';
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'yyyy-mm-dd',
                    errorText: dobError,
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
                height: 60.h,
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
                      timeController.text = '$hh:$mm:00';
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'hh:mm:ss',
                    errorText: timeError,
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

  Widget _buildActionButtons(StateSetter setState) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.w,
        bottom: 20.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          // Save button
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton(
              onPressed: () => _handleSave(setState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.selected,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'സേവ്',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
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
    );
  }

  Future<void> _handleSave(StateSetter setState) async {
    if (nameController.text.isNotEmpty) {
      try {
        if (selectedNakshatram == null) {
          _showSnackBar('⚠️ Please select a Nakshatram');
          return;
        }

        final dob = formatDate(dobController.text);
        final time = formatTime(timeController.text);

        setState(() {
          dobError = dob.isEmpty ? 'Invalid date format (yyyy-mm-dd)' : null;
          timeError = time == '00:00:00'
              ? 'Invalid time format (HH:MM:SS)'
              : null;
        });

        if (dobError != null || timeError != null) return;

        final userData = {
          'name': nameController.text,
          'DOB': dob,
          'time': time,
          'attributes': [
            {'nakshatram': selectedNakshatram},
          ],
        };

        print('🌐 API Call - POST /api/user/user-lists');
        print('📤 Request Payload: ${json.encode(userData)}');

        final newUser = await ref.read(addNewUserProvider(userData).future);

        print('✅ API Response - User added successfully');
        print('📥 Response Data: ${json.encode(newUser.toJson())}');

        // Refresh the complete user list immediately
        final repository = ref.read(userListRepositoryProvider);
        final updatedUsers = await repository.getUserLists();
        ref.read(visibleUsersProvider(widget.userId).notifier).state =
            updatedUsers;
        ref.invalidate(userListsProvider);

        Navigator.pop(context);
        _showSnackBar('✅ User added successfully!');
      } catch (e) {
        print('❌ API Error - Failed to add user');
        print('🚨 Error Message: $e');
        _showSnackBar('❌ Failed to add user: ${e.toString()}');
      }
    } else {
      _showSnackBar('⚠️ Please enter a name');
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

