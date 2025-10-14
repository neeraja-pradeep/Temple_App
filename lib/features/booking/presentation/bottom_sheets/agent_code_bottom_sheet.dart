import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:temple_app/features/booking/providers/booking_page_providers.dart';

class AgentCodeBottomSheet extends ConsumerStatefulWidget {
  final String currentAgentCode;

  const AgentCodeBottomSheet({super.key, required this.currentAgentCode});

  @override
  ConsumerState<AgentCodeBottomSheet> createState() =>
      _AgentCodeBottomSheetState();
}

class _AgentCodeBottomSheetState extends ConsumerState<AgentCodeBottomSheet> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.currentAgentCode);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Uncheck agent code checkbox when dismissing with back button
        ref.read(isAgentCodeProvider.notifier).state = false;
        ref.read(agentCodeProvider.notifier).state = '';
        return true;
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom +
                16.h,
            top: 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              SizedBox(height: 16.h),
              _buildTextField(),
              SizedBox(height: 12.h),
              _buildDescription(),
              SizedBox(height: 16.h),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Center(
          child: Text(
            '                      ഏജന്റ് കോഡ്',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8C001A),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            // Uncheck agent code checkbox when closing without confirming
            ref.read(isAgentCodeProvider.notifier).state = false;
            ref.read(agentCodeProvider.notifier).state = '';
            Navigator.pop(context);
          },
          child: Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: const Icon(Icons.close, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Code XYZA',
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      'ഏജന്റ് കോഡ് ഉപയോഗിക്കുന്നതുപക്ഷത്തിൽ, തീർത്ഥാടന നടത്തിപ്പ് മുൻപ് കൗണ്ടറിൽ പണമടയ്ക്കണം. ഓൺലൈനായി പണമടയ്ക്കേണ്ടതില്ല.',
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 40.h,
      child: ElevatedButton(
        onPressed: () {
          ref.read(agentCodeProvider.notifier).state = controller.text;
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8C001A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'സ്ഥിരീകരിക്കുക',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
