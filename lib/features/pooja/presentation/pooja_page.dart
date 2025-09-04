import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:temple/core/app_buttonStyles.dart';
import 'package:temple/core/app_calender.dart';
import 'package:temple/core/app_colors.dart';
import 'package:temple/core/app_dropdown.dart';
import 'package:temple/features/pooja/data/models/pooja_category_model.dart';
import 'package:temple/features/pooja/providers/pooja_providers.dart';
import 'package:temple/widgets/pooja_page_skeleton.dart';
import 'package:temple/features/booking/presentation/booking_page.dart';
import 'package:temple/features/booking/providers/booking_page_providers.dart';

class PoojaPage extends ConsumerStatefulWidget {
  const PoojaPage({super.key});

  @override
  ConsumerState<PoojaPage> createState() => _PoojaPageState();
}

class _PoojaPageState extends ConsumerState<PoojaPage> {
  int? selectedCategoryId;
  int? selectedPoojaId;

  // Provider for tracking selected date from calendar
  late final StateProvider<String?> selectedDateProvider;

  // Store the current Malayalam date
  String? currentMalayalamDate;

  @override
  void initState() {
    super.initState();
    // Initialize with tomorrow's date
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    selectedDateProvider = StateProvider<String?>(
      (ref) => tomorrow.toIso8601String().split('T')[0],
    );
  }

  Future<void> _refreshData(WidgetRef ref) async {
    ref.invalidate(poojaCategoriesProvider);
    if (selectedCategoryId != null) {
      ref.invalidate(poojasByCategoryProvider(selectedCategoryId!));
    }
  }

  Future<void> _testApiCall(int categoryId) async {
    try {
      print('🧪 Testing direct API call for category $categoryId');
      final repo = ref.read(repositoryProvider);
      final poojas = await repo.fetchPoojasByCategory(categoryId);
      print('🧪 Direct API call successful: ${poojas.length} poojas');
      for (var pooja in poojas) {
        print('🧪   - ${pooja.name} (₹${pooja.price})');
      }
    } catch (e) {
      print('🧪 Direct API call failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(poojaCategoriesProvider);
    final poojasAsync = selectedCategoryId != null
        ? ref.watch(poojasByCategoryProvider(selectedCategoryId!))
        : null;

    // Watch Malayalam date provider to get the current Malayalam date
    final malayalamDateAsync = ref.watch(malayalamDateProvider);
    malayalamDateAsync.whenData((malayalamDate) {
      currentMalayalamDate = malayalamDate.malayalamDate;
    });

    return Stack(
      children: [
        RefreshIndicator(
          backgroundColor: AppColors.navBarBackground,
          color: AppColors.selected,
          onRefresh: () => _refreshData(ref),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50.h),
                Padding(
                  padding: const EdgeInsets.only(left: 18, bottom: 4),
                  child: Text(
                    "Select God",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                categoriesAsync.when(
                  data: (gods) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: SizedBox(
                        height: 152.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: gods.length,
                          itemBuilder: (context, index) {
                            final god = gods[index];
                            return Padding(
                              padding: const EdgeInsets.all(2),
                              child: _CategoryCard(
                                category: god,
                                isSelected: selectedCategoryId == god.id,
                                onTap: () {
                                  print(
                                    '🎯 Category selected: ${god.id} - ${god.name}',
                                  );
                                  setState(() {
                                    selectedCategoryId = god.id;
                                    selectedPoojaId = null;
                                  });

                                  // Test the API call directly
                                  _testApiCall(god.id);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  error: (err, _) => Center(child: Text(err.toString())),
                  loading: () => const PoojaPageSkeleton(),
                ),
                SizedBox(height: 15.h),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    "പൂജ തിരഞ്ഞെടുക്കുക",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: "NotoSansMalayalam",
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 14, right: 10),
                  child: SizedBox(
                    height: 40.h,
                    width: 342.w,
                    child: AppDropdown(
                      value: selectedPoojaId,
                      hintText: "Value",
                      items: selectedCategoryId == null
                          ? [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text(
                                  "Please select a god first",
                                  style: TextStyle(
                                    color: Color.fromARGB(165, 158, 158, 158),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ]
                          : poojasAsync!.when(
                              data: (poojas) {
                                print(
                                  '🔍 Poojas loaded for category $selectedCategoryId:',
                                );
                                print('   Number of poojas: ${poojas.length}');
                                for (var pooja in poojas) {
                                  print(
                                    '   - ID: ${pooja.id}, Name: ${pooja.name}, Price: ${pooja.price}',
                                  );
                                }
                                return poojas
                                    .map(
                                      (pooja) => DropdownMenuItem<int>(
                                        value: pooja.id,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                pooja.name,
                                                overflow: TextOverflow.fade,
                                                maxLines: 1,
                                              ),
                                            ),
                                            SizedBox(width: 6.w),
                                            Text("₹${pooja.price}"),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList();
                              },
                              error: (err, _) {
                                print(
                                  '❌ Error loading poojas for category $selectedCategoryId: $err',
                                );
                                return [
                                  DropdownMenuItem<int>(
                                    value: null,
                                    child: Text(
                                      "Unable to load poojas",
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          165,
                                          158,
                                          158,
                                          158,
                                        ),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ];
                              },
                              loading: () {
                                print(
                                  '⏳ Loading poojas for category $selectedCategoryId...',
                                );
                                return [
                                  DropdownMenuItem<int>(
                                    value: null,
                                    child: Text(
                                      "Loading Poojas...",
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          165,
                                          158,
                                          158,
                                          158,
                                        ),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ];
                              },
                            ),
                      onChanged: (value) {
                        setState(() {
                          selectedPoojaId = value;
                        });
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 18, top: 18),
                  child: Text(
                    "Date തിരഞ്ഞെടുക്കുക",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: "NotoSansMalayalam",
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: MalayalamCalendar(
                    onDateSelected: (date) {
                      ref.read(selectedDateProvider.notifier).state = date;
                    },
                  ),
                ),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
        // book button
        Positioned(
          left: 14.w,
          bottom: 10.h,
          child: ElevatedButton(
            onPressed: () {
              // Check if both category and pooja are selected
              if (selectedCategoryId == null || selectedPoojaId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a god and pooja first'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Get the selected date from calendar
              final selectedDate = ref.read(selectedDateProvider);
              if (selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a date first'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Set the selected date in the booking page provider
              ref.read(selectedCalendarDateProvider.notifier).state =
                  selectedDate;

              // Navigate to booking page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingPage(
                    poojaId: selectedPoojaId!,
                    userId: 2, // Use same user ID as SpecialPage
                    source: 'pooja', // Indicate this is from PoojaPage
                    malayalamDate:
                        currentMalayalamDate, // Pass the Malayalam date
                  ),
                ),
              );
            },
            style: AppButtonStyles.submitButtom,
            child: Text("ബുക്ക്"),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final PoojaCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          side: widget.isSelected
              ? BorderSide(width: 1.2, color: AppColors.selected)
              : BorderSide.none,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: SizedBox(
          width: 142.w,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  child: Image.network(
                    widget.category.mediaUrl,
                    height: 102.h,
                    width: 131.w,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 102.h,
                          width: 131.w,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 102.h,
                          width: 131.w,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.category.name,
                style: TextStyle(
                  fontFamily: "NotoSansMalayalam",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
