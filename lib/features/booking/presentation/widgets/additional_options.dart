import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/core/app_colors.dart';
import 'package:temple_app/features/booking/providers/booking_page_providers.dart';
import 'package:temple_app/features/booking/presentation/bottom_sheets/agent_code_bottom_sheet.dart';

class AdditionalOptions extends ConsumerWidget {
  const AdditionalOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isParticipatingPhysically = ref.watch(
      isParticipatingPhysicallyProvider,
    );
    final isAgentCode = ref.watch(isAgentCodeProvider);
    final agentCode = ref.watch(agentCodeProvider);

    return Column(
      children: [
        // Participating physically
        Row(
          children: [
            _buildCustomCheckbox(
              value: isParticipatingPhysically,
              onTap: isAgentCode
                  ? null
                  : () {
                      ref
                              .read(isParticipatingPhysicallyProvider.notifier)
                              .state =
                          !isParticipatingPhysically;
                    },
              disabled: isAgentCode,
              color: isAgentCode ? Colors.grey : null,
            ),
            SizedBox(width: 12.w),
            Text(
              'ഭൗതികമായി പങ്കെടുക്കുന്നു',
              style: TextStyle(fontSize: 12.sp, color: Colors.black),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Agent code
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCustomCheckbox(
              value: isAgentCode,
              onTap: () async {
                final newValue = !isAgentCode;
                ref.read(isAgentCodeProvider.notifier).state = newValue;
                if (newValue) {
                  // Auto-check and disable the first checkbox
                  ref.read(isParticipatingPhysicallyProvider.notifier).state =
                      true;
                  // Show bottom sheet for agent code input
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        AgentCodeBottomSheet(currentAgentCode: agentCode),
                  );
                } else {
                  // Clear agent code when unchecked
                  ref.read(agentCodeProvider.notifier).state = '';
                }
              },
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ഏജന്റ് കോഡ് നൽകുക (Optional)',
                    style: TextStyle(fontSize: 12.sp, color: Colors.black),
                  ),
                  // Show entered agent code if available
                  if (agentCode.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      agentCode,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomCheckbox({
    required bool value,
    required VoidCallback? onTap,
    bool disabled = false,
    Color? color,
  }) {
    final borderColor = color ?? (value ? AppColors.selected : Colors.grey);
    final iconColor = color ?? (value ? AppColors.selected : Colors.grey);
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2.w),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: value ? Icon(Icons.check, size: 14.sp, color: iconColor) : null,
      ),
    );
  }
}

