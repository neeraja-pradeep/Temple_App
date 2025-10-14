import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/core/theme/color/colors.dart';
import 'package:temple_app/features/booking/data/booking_pooja_model.dart';
import 'package:temple_app/features/booking/providers/booking_page_providers.dart';
import 'package:temple_app/features/booking/providers/booking_provider.dart';
import 'package:temple_app/features/booking/providers/user_list_provider.dart';
import 'package:temple_app/features/booking/services/booking_service.dart';
import 'package:temple_app/features/booking/presentation/widgets/booking_info_card.dart';
import 'package:temple_app/features/booking/presentation/widgets/pooja_for_whom_section.dart';
import 'package:temple_app/features/booking/presentation/widgets/booking_calendar_card.dart';
import 'package:temple_app/features/booking/presentation/widgets/booking_bottom_button.dart';

class BookingPage extends ConsumerWidget {
  final int poojaId;
  final int userId;
  final String? source; // 'pooja' or 'special' to determine calendar visibility
  final String? malayalamDate; // Malayalam date passed from PoojaPage

  const BookingPage({
    super.key,
    required this.poojaId,
    required this.userId,
    this.source,
    this.malayalamDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingPoojaAsync = ref.watch(bookingPoojaProvider(poojaId));

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          BookingService.clearBookingState(ref, userId);
          return true;
        },
        child: Scaffold(
          backgroundColor: cWhite,
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context, ref),
          body: bookingPoojaAsync.when(
            data: (pooja) => _buildBookingContent(context, pooja),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _buildErrorWidget(error),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
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
            color: Color.fromRGBO(251, 239, 217, 1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: IconButton(
              icon: Image.asset(
                'assets/backIcon.png',
                width: 20.w,
                height: 20.h,
              ),
              onPressed: () {
                BookingService.clearBookingState(ref, userId);
                Navigator.pop(context);
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: primaryThemeColor),
          SizedBox(height: 16.h),
          Text(
            'Failed to load pooja details',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),
          Text(
            error.toString(),
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingContent(BuildContext context, BookingPooja pooja) {
    // Debug logging for pooja type
    print('🏛️ Pooja Details:');
    print('   ID: ${pooja.id}');
    print('   Name: ${pooja.name}');
    print('   Special Pooja: ${pooja.specialPooja}');
    print('   Special Pooja Dates Count: ${pooja.specialPoojaDates.length}');
    if (pooja.specialPoojaDates.isNotEmpty) {
      print('   First Special Date: ${pooja.specialPoojaDates.first.date}');
    }

    return Consumer(
      builder: (context, ref, _) {
        // Move state updates to post frame callback to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleAutoSelection(ref, pooja);
          _handleUserSelection(ref);
        });

        return Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.topCenter,
            ),
            // Content
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                75.h,
              ), // Increased bottom padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 64.h),
                  // Pooja Details Card
                  BookingInfoCard(
                    pooja: pooja,
                    source: source,
                    malayalamDate: malayalamDate,
                    selectedDate: ref.watch(selectedCalendarDateProvider),
                    onCalendarTap: () {
                      final show = ref.read(showCalendarProvider);
                      ref.read(showCalendarProvider.notifier).state = !show;
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Calendar Card
                  BookingCalendarCard(pooja: pooja),
                  SizedBox(height: 12.h),
                  // Pooja For Whom Section
                  _buildPoojaForWhomSection(ref),
                  SizedBox(height: 20.h),
                  // Total Price Section
                  _buildTotalPriceSection(ref, pooja),
                  // SizedBox(height: 20.h),
                ],
              ),
            ),
            // Fixed Book Now Button at bottom
            Consumer(
              builder: (context, ref, child) {
                final selectedUsers = ref.watch(selectedUsersProvider(userId));
                return BookingBottomButton(
                  pooja: pooja,
                  userId: userId,
                  isEnabled: selectedUsers.isNotEmpty,
                  onBookingPressed: () => _handleBooking(context, ref, pooja),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPoojaForWhomSection(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final userListsAsync = ref.watch(userListsProvider);
        return userListsAsync.when(
          data: (userLists) =>
              PoojaForWhomSection(userId: userId, userLists: userLists),
          loading: () => _buildLoadingCard(),
          error: (error, stack) => _buildErrorCard(error),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.selected),
      ),
    );
  }

  Widget _buildErrorCard(Object error) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Text(
        'Error loading users: $error',
        style: TextStyle(color: primaryThemeColor),
      ),
    );
  }

  Widget _buildTotalPriceSection(WidgetRef ref, BookingPooja pooja) {
    final selectedUsers = ref.watch(selectedUsersProvider(userId));
    final showCalendar = ref.watch(showCalendarProvider);

    // Don't show price when calendar is open
    if (showCalendar) return SizedBox.shrink();

    // Don't show price until at least one user is selected
    if (selectedUsers.isEmpty) return SizedBox.shrink();

    // Calculate price based on pooja type and selected date
    double basePrice = _calculateBasePrice(ref, pooja);
    final int userCount = selectedUsers.length;
    final double totalPrice = basePrice * userCount;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ആകെതുക: ₹${totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontFamily: 'NotoSansMalayalam',
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'നോസ്ത്രുഡ് എക്സെപ്റ്റെർ ഡ്യൂയിസ് മാഗ്നാ ക്വിസ് എനിം എനിം എസ്റ്റ് ഉല്ലാംകോ പ്രൊഇഡന്റ് ഉട്ട് നിസി ഉല്ലാംകോ മിനിം',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateBasePrice(WidgetRef ref, BookingPooja pooja) {
    double basePrice;
    if (pooja.specialPooja) {
      // For special pooja, use the price of the selected special date
      final selectedDate = ref.watch(selectedCalendarDateProvider);
      if (selectedDate != null) {
        try {
          final selectedSpecialDate = pooja.specialPoojaDates.firstWhere(
            (date) => date.date == selectedDate,
          );
          basePrice = double.tryParse(selectedSpecialDate.price) ?? 0.0;
        } catch (e) {
          // Fallback to first available special date price
          basePrice =
              double.tryParse(pooja.specialPoojaDates.first.price) ?? 0.0;
        }
      } else {
        // No date selected, use first available special date price
        basePrice = double.tryParse(pooja.specialPoojaDates.first.price) ?? 0.0;
      }
    } else {
      // For regular pooja, use the base price
      basePrice = double.tryParse(pooja.price) ?? 0.0;
    }
    return basePrice;
  }

  void _handleAutoSelection(WidgetRef ref, BookingPooja pooja) {
    // Auto-select a default date if none selected or invalid for current pooja
    List<String> enabledDates;
    if (pooja.specialPooja) {
      enabledDates = pooja.specialPoojaDates.map((d) => d.date).toList();
    } else {
      final now = DateTime.now();
      enabledDates = List.generate(30, (index) {
        final date = now.add(Duration(days: index + 1));
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      });
    }
    final currentSelectedDate = ref.watch(selectedCalendarDateProvider);
    final shouldSetDefaultDate =
        currentSelectedDate == null ||
        !enabledDates.contains(currentSelectedDate);
    if (enabledDates.isNotEmpty && shouldSetDefaultDate) {
      final defaultDate = pooja.specialPooja
          ? enabledDates
                .first // from API for special pooja
          : enabledDates.first; // next available for regular pooja
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedCalendarDateProvider.notifier).state = defaultDate;
      });
    }
  }

  void _handleUserSelection(WidgetRef ref) {
    // Ensure main user is always selected when entering booking page
    final currentSelectedUsers = ref.watch(selectedUsersProvider(userId));
    final currentVisibleUsers = ref.watch(visibleUsersProvider(userId));
    final userListsAsync = ref.watch(userListsProvider);

    // Check if we need to set the main user and user list is available
    userListsAsync.when(
      data: (users) {
        if (currentSelectedUsers.isEmpty || currentVisibleUsers.isEmpty) {
          try {
            final mainUser = users.firstWhere((u) => u.id == userId);
            // Set main user in both selected and visible lists
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(selectedUsersProvider(userId).notifier).state = [
                mainUser,
              ];
              ref.read(visibleUsersProvider(userId).notifier).state = [
                mainUser,
              ];
            });
          } catch (_) {
            // Main user not found, keep empty lists
          }
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  Future<void> _handleBooking(
    BuildContext context,
    WidgetRef ref,
    BookingPooja pooja,
  ) async {
    // Validate booking data
    final isValid = await BookingService.validateBookingData(
      pooja: pooja,
      userId: userId,
      ref: ref,
      context: context,
    );

    if (isValid) {
      // Process the booking
      await BookingService.processBooking(
        pooja: pooja,
        userId: userId,
        ref: ref,
        context: context,
      );
    }
  }
}
