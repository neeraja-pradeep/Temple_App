import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/drawer/pooja_orders/order_model.dart';
import 'package:temple_app/features/drawer/pooja_orders/presentation/detailed_view.dart';

class OrderCard extends StatefulWidget {
  final Booking booking;

  const OrderCard({super.key, required this.booking});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final orderLine = widget.booking.orderLines.first;

    // collapsed info
    final poojaName = orderLine.poojaDetails?.name ?? "Unknown Pooja";
    final date = orderLine.specialPoojaDateDetails?.date ?? '';
    final persons = widget.booking.orderLines.length;
    final categoryName = orderLine.poojaDetails!.categoryName;

    return GestureDetector(
      onTap: (){
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
            Text(
                  date,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
            isExpanded
            ? SizedBox(height: 6.h)
            : SizedBox(),
            isExpanded
            ? Text(
              categoryName!,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16.sp, 
                color: AppColors.selected,
                fontWeight: FontWeight.w700,
      
                ),
            )
            : Text(""),
            Text(
              poojaName,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16.sp, 
                color: AppColors.selected,
                fontWeight: FontWeight.w700,
      
                ),
            ),
            !isExpanded
              ? Text("$persons Persons" )
              : Text(""),
      
            // expanded content
            if (isExpanded) ...[
              Column(
                children: widget.booking.orderLines.map((line) {
                  final userName = line.userListDetails?.name ?? "Unknown";
                  final nakshatra =
                      line.userAttributeDetails?.nakshatramName ?? "";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "$userName - $nakshatra",
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => DetailedView(booking: widget.booking) )
                    );
                  },
                  child: const Text("View Details",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: AppColors.selected
                  ),),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
