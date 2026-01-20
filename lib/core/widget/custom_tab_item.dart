import 'package:flutter/material.dart';
import 'package:edara_hub_app_123/core/models/category_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:edara_hub_app_123/core/resources/values_manager.dart';
import 'package:edara_hub_app_123/core/resources/font_manager.dart';
import 'package:edara_hub_app_123/core/resources/styles_manager.dart';

class CustomTabItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final Color selectedBgColor;
  final Color unSelectedBgColor;
  final Color selectedFgColor;
  final Color unSelectedFgColor;

  const CustomTabItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.selectedBgColor,
    required this.unSelectedBgColor,
    required this.selectedFgColor,
    required this.unSelectedFgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w, vertical: AppPadding.p8.h),
      decoration: BoxDecoration(
        color: isSelected ? selectedBgColor : unSelectedBgColor,
        borderRadius: BorderRadius.circular(AppSize.s20.r),
        border: Border.all(color: isSelected ? selectedBgColor : unSelectedFgColor, width: AppSize.s1.w)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, color: isSelected ? selectedFgColor : unSelectedFgColor, size: AppSize.s20.sp,),
          SizedBox(width: AppSize.s8.w,),
          Text(category.name, style: getMediumStyle(color: isSelected ? selectedFgColor : unSelectedFgColor, fontSize: FontSize.s14.sp),),
        ],
      ),
    );
  }
}
