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

class AddressSheet extends ConsumerStatefulWidget {
  final BuildContext parentContext;
  final AddressModel? address; // null => Add, not null => Edit

  const AddressSheet({super.key, required this.parentContext, this.address});

  @override
  ConsumerState<AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends ConsumerState<AddressSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      // Prefill fields for edit
      nameController.text = widget.address!.name;
      address1Controller.text = widget.address!.street;
      address2Controller.text = widget.address!.city;
      pincodeController.text = widget.address!.pincode;
      phoneController.text = widget.address!.phonenumber;
    }
  }

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

    final AddressModel newAddress = AddressModel(
      id: widget.address?.id ?? 0, // Keep ID for edit
      name: nameController.text.trim(),
      street: address1Controller.text.trim(),
      city: address2Controller.text.trim(),
      state: widget.address?.state ?? "",
      country: widget.address?.country ?? "India",
      pincode: pincodeController.text.trim(),
      selection: widget.address?.selection ?? true,
      phonenumber: phoneController.text.trim(),
    );

    try {
      if (widget.address == null) {
        // Add
        await ref.read(addressListProvider.notifier).addAddress(newAddress);
        showToast("Address added successfully", bgColor: Colors.green);
      } else {
        // Edit
        await ref.read(addressListProvider.notifier).updateAddress(newAddress);
        showToast("Address updated successfully", bgColor: Colors.green);
      }
      Navigator.pop(context);
    } catch (e) {
      showToast(
        widget.address == null
            ? "Failed to add address"
            : "Failed to update address",
        bgColor: Colors.red,
      );
    }
  }

  void deleteAddress() async {
    // Clear form fields
    nameController.clear();
    address1Controller.clear();
    address2Controller.clear();
    pincodeController.clear();
    phoneController.clear();

    try {
      await ref
          .read(addressListProvider.notifier)
          .deleteAddress(widget.address!.id);

      if (!mounted) return;
      showToast("Address deleted successfully", bgColor: Colors.green);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      // Show error dialog with specific error message
      String errorMessage =
          "Please try again later or contact support if the problem persists.";
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      showErrorDialog("Unable to delete address", errorMessage);
    }
  }

  void showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: cWhite,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 30.sp,
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    color: cBlack,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Message
                Text(
                  message,
                  style: TextStyle(color: cGrey, fontSize: 14.sp, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25.h),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryThemeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: cWhite,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(15.w),
        height: 0.80.sh,
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
                      widget.address == null
                          ? 'Add new Address'
                          : 'Edit Address',
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

void showAddressSheet(BuildContext context, {AddressModel? address}) {
  showModalBottomSheet(
    context: context,
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
          child: AddressSheet(parentContext: context, address: address),
        ),
      );
    },
  );
}
