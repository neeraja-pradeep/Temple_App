import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:temple/core/constants/sized.dart';
import 'package:temple/core/theme/color/colors.dart';
import 'package:temple/features/shop/delivery/presentation/add_address.dart';
import 'package:temple/features/shop/delivery/presentation/edit_address.dart';
import 'package:temple/features/shop/delivery/providers/delivery_provider.dart';
import 'package:temple/widgets/mytext.dart';

class ShowSavedAddressSheet extends ConsumerWidget {
  const ShowSavedAddressSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressListProvider);

    return Container(
      padding: EdgeInsets.all(15.w),
      height: 0.46.sh,
      decoration: BoxDecoration(
        color: cWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Drag handle
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

          /// Title + Close
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 30,
                child: Center(
                  child: Text(
                    'Saved Address',
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

          /// Address List
          Expanded(
            child: addressState.when(
              data: (addresses) {
                if (addresses.isEmpty) {
                  return const Center(child: Text("No saved addresses."));
                }

                // ✅ Sort so that selected address always comes first
                final sortedAddresses = [...addresses]
                  ..sort(
                    (a, b) => b.selection.toString().compareTo(
                      a.selection.toString(),
                    ),
                  );

                return ListView.separated(
                  itemCount: sortedAddresses.length,
                  separatorBuilder: (_, __) => AppSizes.h10,
                  itemBuilder: (context, index) {
                    final address = sortedAddresses[index];
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      leading: Checkbox(
                        value: address.selection,
                        onChanged: (_) {
                          ref
                              .read(addressListProvider.notifier)
                              .selectAddress(address.id);
                        },
                      ),
                      title: WText(
                        text: "${address.name} – ${address.city}",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: cBlack,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WText(
                            text: "${address.street}, ${address.state}",
                            fontSize: 10.sp,
                            color: cGrey,
                          ),
                          WText(
                            text: "Pincode: ${address.pincode}",
                            fontSize: 10.sp,
                            color: cGrey,
                          ),
                        ],
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          showAddressSheet(context, address: address);
                        },
                        child: Text(
                          "Edit",
                          style: TextStyle(
                            color: primaryThemeColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },

              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),

          AppSizes.h10,

          /// Add New Address
          GestureDetector(
            onTap: () {
              showAddAddressSheet(context);
            },
            child: SizedBox(
              height: 35.h,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svg/addicon.svg',
                    fit: BoxFit.contain,
                    height: 16.h,
                    width: 16.w,
                  ),
                  AppSizes.w10,
                  WText(
                    text: 'മറ്റൊരു വിലാസം ചേർക്കുക',
                    color: primaryThemeColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ),
          ),

          /// Select Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryThemeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 10.h),
              ),
              onPressed: () {
                Navigator.pop(context); // close sheet
              },
              child: WText(
                text: 'Select Address',
                color: cWhite,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showSavedAddressSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: const ShowSavedAddressSheet(),
        ),
      );
    },
  );
}
