import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:edara_hub_app_123/core/resources/color_manager.dart';
import 'package:edara_hub_app_123/core/resources/values_manager.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';

class EventItem extends StatelessWidget {
  final EventEntity event;
  const EventItem({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppMargin.m16.w, vertical: AppMargin.m8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.s12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.image != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.s12.r)),
              child: Image.network(
                event.image!,
                height: 150.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150.h,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 50.r, color: Colors.grey),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(AppPadding.p12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title ?? "No Title",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSize.s4.h),
                Text(
                  event.description ?? "No Description",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorManager.darkGrey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSize.s8.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14.sp, color: ColorManager.primary),
                    SizedBox(width: AppSize.s4.w),
                    Text(
                      event.startDate ?? "",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
