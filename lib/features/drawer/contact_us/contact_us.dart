import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                color:AppColors.selectedBackground,
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
          padding:EdgeInsets.all(15.w),
          child: Card(
            elevation: 8,
            child: Container(
              height: 260.h,
              width: 343.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.white
              ),
              child: Padding(
                padding: EdgeInsets.all(15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Contact Us",
                    style: TextStyle(
                      color: AppColors.selected,
                      fontWeight: FontWeight.w700,
                      fontFamily: "NotoSansMalayalam",
                      fontSize: 16.sp
                    ),),
                    SizedBox(height: 10.h,),
                    Text("Address",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp
                    ),
                    ),
                    Text("Address line 01",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp
                    ),
                    ),
                    Text("Address line 02",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp
                    ),
                    ),
                    Text("Address line 03 + pincode",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp
                    ),
                    ),
                    SizedBox(height: 10.h,),
                    Text("Phone",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp
                    ),
                    ),
                    Text("9142 3458 36",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp
                    ),
                    ),
                    Text("9142 3458 36",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp
                    ),
                    ),
                    SizedBox(height: 10.h,),
                    Text("Temple Office timings",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp
                    ),
                    ),
                    Text("Mon-Fri 9AM - 6PM",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp
                    ),
                    ),
                    Text("Sat-Sun 9AM - 6PM",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp
                    ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}