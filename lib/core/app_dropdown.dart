import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const AppDropdown({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      decoration: InputDecoration(
        filled: true,
        isDense: false,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: const Color.fromARGB(165, 158, 158, 158),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: const Color.fromARGB(165, 158, 158, 158),
          ),
        ),
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(5),
      ),
      style: TextStyle(
        fontFamily: "NotoSansMalayalam",
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
      ),
      isExpanded: true,
      value: value,
      hint: Text(
        hintText,
        style: const TextStyle(color: Color.fromARGB(165, 158, 158, 158)),
      ),
      items: items,
      onChanged: onChanged,
      dropdownStyleData: DropdownStyleData(
        width: 330,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(Icons.keyboard_arrow_down),
      ),
      selectedItemBuilder: (context){
        return items.map((item){
          return SizedBox(
            child: DefaultTextStyle(
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                overflow: TextOverflow.fade
              ), 
              child: item.child),
          );
        }).toList();
      },
    );
  }
}
