import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view_model/virtual_try_on_provider.dart';
import '../utils/theme.dart';

class ClothesTypeDropdown extends StatelessWidget {
  const ClothesTypeDropdown({super.key});

  static const Map<String, String> _clothesTypes = {
    'upper_body': 'Upper Body',
    'lower_body': 'Lower Body',
    'full_body':  'Full Body',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VirtualTryOnProvider>();

    return Container(
      margin: EdgeInsets.only(left: 30.w),
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFFF48FB1), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF48FB1).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.black87,
          value: provider.clothesType,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFFF48FB1), size: 70.sp),
          style: TextStyle(
            color: Colors.white,
            fontSize: 40.sp,
            fontFamily: 'medium',
          ),
          borderRadius: BorderRadius.circular(30.r),
          isExpanded: true,
          onChanged: (String? newValue) {
            if (newValue != null) {
              context.read<VirtualTryOnProvider>().setClothesType(newValue);
            }
          },
          items: _clothesTypes.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,         // "upper_body"  → sent to API
              child: Text(entry.value), // "Upper Body"  → shown in UI
            );
          }).toList(),
        ),
      ),
    );
  }
}