import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:temple/core/constants/sized.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/delivery/data/model/address_model.dart';
import 'package:temple/features/shop/delivery/providers/delivery_provider.dart';
import 'package:temple/features/shop/widget/text_formfield.dart';
import 'package:temple/widgets/mytext.dart';

class AddAddressSheet extends ConsumerStatefulWidget {
  final BuildContext parentContext;
  const AddAddressSheet({super.key, required this.parentContext});

  @override
  ConsumerState<AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends ConsumerState<AddAddressSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void showToast(String message, {Color? bgColor}) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor ?? primaryThemeColor.withOpacity(0.9),
      textColor: Colors.white,
      fontSize: 14.sp,
      timeInSecForIosWeb: 2,
    );
  }

  Future<void> saveAddress() async {
    if (nameController.text.isEmpty) {
      showToast("Please enter your name");
      return;
    }
    if (address1Controller.text.isEmpty) {
      showToast("Please enter address line 01");
      return;
    }
    if (address2Controller.text.isEmpty) {
      showToast("Please enter address line 02");
      return;
    }
    if (pincodeController.text.isEmpty ||
        !RegExp(r'^[0-9]{6}$').hasMatch(pincodeController.text)) {
      showToast("Please enter a valid 6-digit pincode");
      return;
    }
    if (phoneController.text.isEmpty ||
        !RegExp(r'^[0-9]{10}$').hasMatch(phoneController.text)) {
      showToast("Please enter a valid 10-digit phone number");
      return;
    }

    final newAddress = AddressModel(
      id: 0, // Backend will assign ID
      name: nameController.text.trim(),
      street: address1Controller.text.trim(),
      city: address2Controller.text.trim(), // adjust if needed
      state: "",
      country: "India",
      pincode: pincodeController.text.trim(),
      selection: true,
      phonenumber: phoneController.text.trim(),
    );

    try {
      await ref.read(addressListProvider.notifier).addAddress(newAddress);
      Navigator.pop(context);
      showToast("Address added successfully", bgColor: Colors.green);
    } catch (e) {
      showToast("Failed to add address", bgColor: Colors.red);
    }
  }

  void deleteAddress() {
    nameController.clear();
    address1Controller.clear();
    address2Controller.clear();
    pincodeController.clear();
    phoneController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Address deleted", style: TextStyle(fontSize: 14.sp)),
        backgroundColor: Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(15.w),
        height: 0.75.sh,
        decoration: BoxDecoration(
          color: cWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 15.h),
                decoration: BoxDecoration(
                  color: cGrey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),

            // Title and close button
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 30,
                  child: Center(
                    child: Text(
                      'Add new Address',
                      style: TextStyle(
                        color: primaryThemeColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/svg/closeicon.svg',
                      fit: BoxFit.contain,
                      height: 16.h,
                      width: 16.w,
                    ),
                  ),
                ),
              ],
            ),
            AppSizes.h20,

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormFiledWithoutColorEight(
                      controller: nameController,
                      hintText: "Person name",
                      title: 'Name',
                    ),
                    TextFormFiledWithoutColorEight(
                      controller: address1Controller,
                      hintText: "Address line 01",
                      title: 'Address line 01',
                    ),
                    TextFormFiledWithoutColorEight(
                      controller: address2Controller,
                      hintText: "Address line 02",
                      title: 'Address line 02',
                    ),
                    TextFormFiledWithoutColorEight(
                      controller: pincodeController,
                      hintText: "Pincode",
                      title: 'Pincode',
                      keyboardType: TextInputType.number,
                    ),
                    TextFormFiledWithoutColorEight(
                      controller: phoneController,
                      hintText: "Phone number",
                      title: 'Phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 20.h),

                    // Save Button
                    SizedBox(
                      width: 0.88.sw,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryThemeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                        onPressed: saveAddress,
                        child: WText(
                          text: 'Save',
                          color: cWhite,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Delete Button
                    SizedBox(
                      width: 0.88.sw,
                      child: Center(
                        child: GestureDetector(
                          onTap: deleteAddress,
                          child: WText(
                            text: 'Delete',
                            color: primaryThemeColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showAddAddressSheet(BuildContext parentContext) {
  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: AddAddressSheet(parentContext: parentContext),
        ),
      );
    },
  );
}
