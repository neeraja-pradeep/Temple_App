import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/shop/delivery/data/model/address_model.dart';
import 'package:temple_app/features/shop/delivery/presentation/edit_address.dart';
import 'package:temple_app/features/shop/delivery/providers/delivery_provider.dart';

class SavedAddress extends ConsumerWidget {
  const SavedAddress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Saved Address",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: 343.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r)
              ),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Add/Edit information",
                    style: TextStyle(
                      color: Colors.grey
                    ),),
                    SizedBox(height: 30.h,),
                
                    GestureDetector(
                      onTap: (){
                        showAddressSheet(context); 
                      },
                      child: Text("+ Add address",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.selected,
                        fontWeight: FontWeight.w700
                      ),),
                    ),
                    SizedBox(height: 20.h,),
                
                    addressState.when(
                      data: (addresses) {
                        if (addresses.isEmpty) {
                          return const Center(child: Text("No addresses saved"));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            final AddressModel address = addresses[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(address.name,
                                              style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.sp,
                                              )),
                                          SizedBox(height: 4.h),
                                          Text(
                                            "${address.street}, ${address.city}",
                                            style: TextStyle(
                                               overflow: TextOverflow.ellipsis,
                                                fontSize: 12.sp,),
                                          ),
                                          Text(
                                            "${address.state} - ${address.pincode}",
                                            style: TextStyle(
                                               overflow: TextOverflow.ellipsis,
                                                fontSize: 12.sp,),
                                          ),
                                          Text(
                                            address.country,
                                            style: TextStyle(
                                               overflow: TextOverflow.ellipsis,
                                                fontSize: 12.sp,),
                                          ),
                                          Text(
                                            "Phone : ${address.phonenumber}",
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Image.asset("assets/icons/edit.png",height: 20.h,width: 20.w,),
                                          onPressed: () {
                                            showAddressSheet(context,
                                                address: address);
                                          },
                                        ),
                                        IconButton(
                                         icon: Image.asset("assets/icons/delete.png",height: 20.h,width: 20.w,),
                                          onPressed: () {
                                            _confirmDelete(context, ref, address.id);
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppColors.selected),
                      ),
                      error: (e, _) => Center(child: Text("Error: $e")),
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

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Confirm"),
        content: const Text("Do you want to delete this address?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel",
            style: TextStyle(
              color: Colors.grey
            ),),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(addressListProvider.notifier).deleteAddress(id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Address deleted")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed: $e")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
