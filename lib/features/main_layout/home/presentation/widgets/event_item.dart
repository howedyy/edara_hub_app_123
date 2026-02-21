import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:edara_hub_app_123/core/resources/color_manager.dart';
import 'package:edara_hub_app_123/core/resources/values_manager.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';
import 'package:edara_hub_app_123/features/main_layout/home/presentation/manager/home_bloc.dart';
import 'package:edara_hub_app_123/features/main_layout/home/presentation/widgets/event_details_bottom_sheet.dart';

class EventItem extends StatelessWidget {
  final EventEntity event;
  const EventItem({super.key, required this.event});

  void _showEventDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<HomeBloc>(context),
        child: EventDetailsBottomSheet(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppMargin.m16.w, vertical: AppMargin.m8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.s12.r)),
      child: InkWell(
        onTap: () => _showEventDetails(context),
        borderRadius: BorderRadius.circular(AppSize.s12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with Wishlist Button
            Stack(
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
                
                // Wishlist Button
                Positioned(
                  top: AppSize.s8.h,
                  right: AppSize.s8.w,
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            event.isInWishlist ?? false
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: event.isInWishlist ?? false
                                ? Colors.red
                                : ColorManager.darkGrey,
                          ),
                          onPressed: () {
                            context.read<HomeBloc>().add(
                              ToggleWishlistEvent(
                                eventId: event.id!,
                                isRemoving: event.isInWishlist ?? false,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
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
                  
                  // Date and Comments Row
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14.sp, color: ColorManager.primary),
                      SizedBox(width: AppSize.s4.w),
                      Expanded(
                        child: Text(
                          event.startDate ?? "",
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // Comments Count
                      Icon(Icons.comment, size: 14.sp, color: ColorManager.primary),
                      SizedBox(width: AppSize.s4.w),
                      Text(
                        '${event.commentsCount ?? 0}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: AppSize.s8.h),
                  
                  // View Details Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showEventDetails(context),
                      icon: Icon(Icons.visibility, size: AppSize.s16.sp),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorManager.primary,
                        side: BorderSide(color: ColorManager.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

