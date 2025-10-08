import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/booking/data/nakshatram_model.dart';
import 'package:temple_app/features/booking/providers/user_list_provider.dart';
import 'package:temple_app/features/drawer/saved_members/data/member_model.dart';
import 'package:temple_app/features/drawer/saved_members/data/member_service.dart';

class SavedMembers extends ConsumerWidget {
  const SavedMembers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60.h,
        leadingWidth: 64.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w, top: 16.h),
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.selectedBackground,
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
      body: Padding(
        padding: EdgeInsets.all(18.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saved Members",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins"),
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add/Edit information",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 25.h),
                    GestureDetector(
                      onTap: (){
                        _showAddOrEditUserBottomSheet(context, ref);
                      },
                      child: Text(
                        "+ Add person",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.selected,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    memberAsync.when(
                      data: (members) {
                        if (members.isEmpty) {
                          return const Text("No members saved");
                        }
                        return Column(
                          children: members.map((member) {
                            final attributes = member.attributes ?? [];
                            final nakshatra = attributes.isNotEmpty
                                ? attributes.first.nakshatramName ?? "N/A"
                                : "N/A";
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.name ?? "Unknown",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "Nakshatra: $nakshatra",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Image.asset(
                                          "assets/icons/edit.png",
                                          height: 22.h,
                                          width: 22.w,
                                        ),
                                        onPressed: () {
                                          _showAddOrEditUserBottomSheet(context, ref,member: member);
                                        },
                                      ),
                                      IconButton(
                                        icon: Image.asset(
                                          "assets/icons/delete.png",
                                          height: 22.h,
                                          width: 22.w,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context, 
                                            builder: (ctx) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title:const Text("സ്ഥിരീകരിക്കുക"),
                                              content: const Text("ഈ അംഗത്തെ മായ്ക്കണോ?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: (){
                                                    Navigator.of(ctx).pop();
                                                  }, 
                                                  child: const Text("റദ്ദാക്കുക",
                                                  style: TextStyle(color: Colors.grey),),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(ctx).pop();
                                                    try{
                                                      await ref.read(deleteMemberProvider(member.id!).future);
                                                      ref.invalidate(memberProvider);

                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("അംഗം വിജയകരമായി മായ്ച്ചു")));
                                                    }
                                                    catch(e){
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("മായ്ക്കൽ പരാജയപ്പെട്ടു: $e")));
                                                    }
                                                  }, 
                                                  child: Text("മായ്ക്കുക", style: TextStyle(color: Colors.red),)
                                                )
                                              ],
                                            )
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.selected,
                        ),
                      ),
                      error: (e, _) => Center(child: Text("Error: $e")),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddOrEditUserBottomSheet(
  BuildContext context,
  WidgetRef ref, {
  MemberModel? member, // if null -> add, if not null -> edit
}) {
  final nameController = TextEditingController(text: member?.name ?? '');
  final dobController = TextEditingController(text: member?.dob ?? '');
  final timeController = TextEditingController(text: member?.time ?? '');
  int? selectedNakshatram = member?.attributes.isNotEmpty == true
      ? member!.attributes.first.nakshatram
      : null;
  String? selectedNakshatramName = member?.attributes.isNotEmpty == true
      ? member!.attributes.first.nakshatramName
      : null;

  bool didStartFetch = false;
  List<NakshatramOption> nakshatramOptions = [];
  bool nakshLoading = true;
  String? nakshError;
  String? dobError;
  String? timeError;

  // DOB formatting listener
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

  // Time formatting listener
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

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
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
                // Header
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "വ്യക്തിവിവരം",
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

                // Form
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        'പേര്',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        height: 40.h,
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Person name filled',
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
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Nakshatram
                      Text(
                        'നക്ഷത്രം',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: 8.h),
                      Builder(builder: (ctx) {
                        if (!didStartFetch) {
                          didStartFetch = true;
                          Future(() async {
                            try {
                              final options = await ref.read(nakshatramsProvider.future);
                              setState(() {
                                nakshatramOptions = options;
                                nakshLoading = false;
                                nakshError = null;
                                if (options.isNotEmpty && selectedNakshatram == null) {
                                  selectedNakshatram = options.first.id;
                                  selectedNakshatramName = options.first.name;
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
                            items: nakshatramOptions
                                .map((o) => DropdownMenuItem(value: o.id, child: Text(o.name)))
                                .toList(),
                            hint: Text(nakshLoading
                                ? 'Loading...'
                                : (nakshError != null ? 'Failed to load' : 'select any')),
                            onChanged: nakshLoading || nakshError != null
                                ? null
                                : (val) {
                                    if (val == null) return;
                                    final name =
                                        nakshatramOptions.firstWhere((o) => o.id == val).name;
                                    setState(() {
                                      selectedNakshatram = val;
                                      selectedNakshatramName = name;
                                    });
                                  },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
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
                        );
                      }),
                      SizedBox(height: 20.h),

                      // DOB & Time
                      Row(
                        children: [
                          // DOB
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date of birth/Age', style: TextStyle(fontSize: 14.sp)),
                                SizedBox(height: 8.h),
                                SizedBox(
                                  height: 60.h,
                                  child: TextField(
                                    controller: dobController,
                                    readOnly: true,
                                    onTap: () async {
                                      final DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(DateTime.now().year, 12, 31),
                                      );
                                      if (picked != null) {
                                        dobController.text =
                                            '${picked.year.toString().padLeft(4,'0')}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}';
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'yyyy-mm-dd',
                                      errorText: dobError,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          // Time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Time', style: TextStyle(fontSize: 14.sp)),
                                SizedBox(height: 8.h),
                                SizedBox(
                                  height: 60.h,
                                  child: TextField(
                                    controller: timeController,
                                    readOnly: true,
                                    onTap: () async {
                                      final TimeOfDay? picked =
                                          await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                      if (picked != null) {
                                        timeController.text =
                                            '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}:00';
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'hh:mm:ss',
                                      errorText: timeError,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
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

                // Action Buttons
                Padding(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    top: 20.w,
                    bottom: 20.h + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 40.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('⚠️ Please enter a name')),
                              );
                              return;
                            }

                            if (selectedNakshatram == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('⚠️ Please select a Nakshatram')),
                              );
                              return;
                            }

                            final userData = {
                              'name': nameController.text,
                              'DOB': dobController.text,
                              'time': timeController.text,
                              'attributes': [
                                {'nakshatram': selectedNakshatram},
                              ],
                            };

                            try {
                              MemberModel newUser;
                              if (member == null) {
                                // Add
                                newUser = await ref.read(addMemberProvider(userData).future);
                                ref.invalidate(memberProvider);
                              } else {
                                // Edit
                                userData['id'] = member.id;
                                newUser = await ref.read(editMemberProvider(userData).future);
                              }

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('✅ User saved successfully!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('❌ Failed: $e')),
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
                            'അപ്ഡേറ്റ്',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('ഡിലീറ്റ്', style: TextStyle(color: AppColors.selected)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}




}
