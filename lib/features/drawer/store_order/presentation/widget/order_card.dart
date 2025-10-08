import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/drawer/store_order/data/order_model.dart';
import 'package:temple_app/features/drawer/store_order/presentation/order_detailed_view.dart';

class OrderCard extends StatefulWidget {
  final StoreOrder order;

  const OrderCard({super.key, required this.order});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final createdAt = widget.order.createdAt.split("T").first;
    final total = widget.order.total;
    final orderId = widget.order.id;
    final itemCount = widget.order.lines.length;

    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
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
            // --- Collapsed Section ---
            Text(
              createdAt,
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
                  "Order #$orderId",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    color: AppColors.selected,
                  ),
                ),

            Text(
              "$itemCount item${itemCount > 1 ? "s" : ""}",
              style: const TextStyle(color: Colors.black54),
            ),

            // --- Expanded Section ---
            if (isExpanded) ...[
              const SizedBox(height: 10),
              Column(
                children: widget.order.lines.map((line) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            line.productVariant.name,
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 14),
                          ),
                        ),
                        Text(
                          "- ${line.quantity}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: Text(
              //     "Total: ₹$total",
              //     style: TextStyle(
              //       fontFamily: "Poppins",
              //       fontWeight: FontWeight.bold,
              //       fontSize: 15.sp,
              //       color: AppColors.selected,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailedView(order: widget.order),
                      ),
                    );
                  },
                  child: const Text(
                    "View Details",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      color: AppColors.selected,
                    ),
                  ),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
