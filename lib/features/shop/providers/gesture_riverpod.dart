
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Store the currently selected index (-1 means none selected)
/// 
/// 
final selectedIndexCatProvider = StateProvider<int>((ref) => -1); // For Category
final selectedIndexProvider = StateProvider<int>((ref) => -1);  //For Prouct List


final onclickCheckoutButton = StateProvider<bool>((ref) => false,);