import 'package:flutter/material.dart';
import 'package:temple/core/theme/color/colors.dart';

class WText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines; 
  final TextOverflow? overflow; 

  const WText({
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.maxLines,
    this.overflow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines ?? 1, // 👈 Default: 1 line
      overflow: overflow ?? TextOverflow.ellipsis, // 👈 Default: show "..."
      style: TextStyle(
        fontSize: (fontSize ?? 12),
        fontFamily: "NotoSansMalayalam",
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? primaryThemeColor,
        decoration: TextDecoration.none, // 👈 No unwanted underline
      ),
    );
  }
}
