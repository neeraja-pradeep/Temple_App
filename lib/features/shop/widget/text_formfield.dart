import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import 'package:temple_app/widgets/mytext.dart';

// ignore: must_be_immutable
class TextFormFiledWithoutColorEight extends StatelessWidget {
  TextEditingController? controller = TextEditingController();
  final String title;
  final String hintText;
  final Widget? widget;
  final double? width;
  final bool? readOnly;
  Function(String)? onChanged;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  Function()? onTap;
  final TextInputType? keyboardType;

  TextFormFiledWithoutColorEight({
    this.width,
    this.widget,
    required this.hintText,
    required this.title,
    this.readOnly,
    this.keyboardType,
    this.controller,
    this.autofillHints,
    this.onChanged,
    this.validator,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h, // increased height a bit for bigger text
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title Text (outside field)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WText(
                text: title,
                fontSize: 14.sp, // ⬆ increased label font size
                // fontWeight: FontWeight.w600,
                color: cBlack,
              ),
              widget == null ? const SizedBox() : widget!,
            ],
          ),
          const SizedBox(height: 6),
          
          /// Input Field
          Container(
            width: width,
            color: cWhite,
            child: Center(
              child: TextFormField(
                style: TextStyle(
                  fontSize: 13.sp, // ⬆ input text size
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                readOnly: readOnly ?? false,
                onChanged: onChanged,
                autofillHints: autofillHints,
                onTap: onTap,
                validator: validator,
                keyboardType: keyboardType,
                controller: controller,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: cWhite,
                  focusColor: cGrey,
                  contentPadding:  EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 10.w,
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      style: BorderStyle.solid,
                      color: Colors.red,
                    ),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      style: BorderStyle.solid,
                      color: Colors.red,
                    ),
                  ),
                  enabledBorder:  OutlineInputBorder(
                     borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      width: 0.5,
                      color: Colors.grey,
                    ),
                  ),
                  hintStyle: TextStyle(
                    fontSize: 14.sp, // ⬆ hint text size
                    color: Colors.grey,
                  ),
                  hintText: hintText,
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: primaryThemeColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
