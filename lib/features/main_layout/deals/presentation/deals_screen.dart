import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/presentation/manager/deals_bloc.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/domain/entities/deal_entity.dart';
import 'package:edara_hub_app_123/core/resources/color_manager.dart';
import 'package:edara_hub_app_123/core/resources/styles_manager.dart';
import 'package:edara_hub_app_123/core/resources/font_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.local_offer},
    {'name': 'Electronics', 'icon': Icons.devices},
    {'name': 'Fashion', 'icon': Icons.checkroom},
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Travel', 'icon': Icons.flight},
  ];

  @override
  void initState() {
    super.initState();
    if (_currentUserId.isNotEmpty) {
      context.read<DealsBloc>().add(LoadDeals(_currentUserId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: BlocBuilder<DealsBloc, DealsState>(
              builder: (context, state) {
                if (state is DealsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DealsLoaded) {
                  if (state.deals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_offer_outlined, size: 80.r, color: Colors.grey[400]),
                          SizedBox(height: 16.h),
                          Text('No deals available', style: getBoldStyle(color: Colors.grey[600]!, fontSize: FontSize.s18.sp)),
                          SizedBox(height: 8.h),
                          Text('Check back later for amazing offers!', style: getRegularStyle(color: Colors.grey[500]!, fontSize: FontSize.s14.sp)),
                        ],
                      ),
                    );
                  }
                  final filteredDeals = _selectedCategory == 'All' ? state.deals : state.deals.where((deal) => deal.category == _selectedCategory).toList();
                  if (filteredDeals.isEmpty) {
                    return Center(child: Text('No deals in this category', style: getRegularStyle(color: Colors.grey[600]!, fontSize: FontSize.s16.sp)));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
                    itemCount: filteredDeals.length,
                    itemBuilder: (context, index) => DealCard(deal: filteredDeals[index], currentUserId: _currentUserId),
                  );
                }
                if (state is DealsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60.r, color: Colors.red[300]),
                        SizedBox(height: 16.h),
                        Text('Error loading deals', style: getBoldStyle(color: Colors.red[700]!, fontSize: FontSize.s16.sp)),
                        SizedBox(height: 8.h),
                        Text(state.message, style: getRegularStyle(color: Colors.grey[600]!, fontSize: FontSize.s14.sp), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }
                return Center(child: Text('Welcome to Deals!', style: getBoldStyle(color: Colors.grey[600]!, fontSize: FontSize.s18.sp)));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.h, bottom: 20.h),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ ColorManager.headerGradientStart,
            ColorManager.headerGradientEnd,],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hot Deals 🔥', style: getLightStyle(color: Colors.white70, fontSize: FontSize.s16.sp)),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(_currentUserId).get(),
                      builder: (context, snapshot) {
                        String name = 'User';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          name = snapshot.data!.get('name') ?? 'User';
                        }
                        return Text('Save Big, $name!', style: getBoldStyle(color: Colors.white, fontSize: 28.sp));
                      },
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Icon(Icons.local_offer, color: Colors.white, size: 28.r),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: _categories.map((cat) {
                bool isSelected = _selectedCategory == cat['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['name']),
                  child: Container(
                    margin: EdgeInsets.only(right: 12.w),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(30.r),
                      border: isSelected ? null : Border.all(color: Colors.white54),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat['icon'], size: 20.r, color: isSelected ? const Color(0xFFFF6B6B) : Colors.white),
                        SizedBox(width: 8.w),
                        Text(cat['name'], style: getBoldStyle(color: isSelected ? const Color(0xFFFF6B6B) : Colors.white, fontSize: FontSize.s14.sp)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class DealCard extends StatelessWidget {
  final DealEntity deal;
  final String currentUserId;

  const DealCard({super.key, required this.deal, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isWishlisted = deal.wishlist.contains(currentUserId);
    final daysLeft = deal.validUntil.difference(DateTime.now()).inDays;
    final isExpired = deal.isExpired;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              if (deal.imageUrl != null)
                Image.network(
                  deal.imageUrl!,
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200.h,
                    color: Colors.grey[200],
                    child: Icon(Icons.local_offer, size: 60.r, color: Colors.grey[400]),
                  ),
                )
              else
                Container(
                  height: 200.h,
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(Icons.local_offer, size: 60.r, color: Colors.grey[400]),
                  ),
                ),
              Positioned(
                top: 16.h,
                left: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ ColorManager.headerGradientStart,
                        ColorManager.headerGradientEnd,],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '${deal.discountPercentage}% OFF',
                    style: getBoldStyle(color: Colors.white, fontSize: FontSize.s16.sp),
                  ),
                ),
              ),
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => context.read<DealsBloc>().add(
                      ToggleDealWishlist(deal.id, currentUserId, !isWishlisted),
                    ),
                  ),
                ),
              ),
              if (isExpired)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Text(
                          'EXPIRED',
                          style: getBoldStyle(color: Colors.white, fontSize: FontSize.s18.sp),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color:  ColorManager.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        deal.category,
                        style: getBoldStyle(color: const Color(0xFFFF6B6B), fontSize: FontSize.s12.sp),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 16.r, color: daysLeft <= 3 ? Colors.red : Colors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      isExpired ? 'Expired' : '$daysLeft days left',
                      style: getBoldStyle(
                        color: isExpired ? Colors.red : (daysLeft <= 3 ? Colors.red : Colors.grey[600]!),
                        fontSize: FontSize.s12.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  deal.title,
                  style: getBoldStyle(color: Colors.black87, fontSize: FontSize.s20.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Text(
                  deal.description,
                  style: getRegularStyle(color: Colors.grey[600]!, fontSize: FontSize.s14.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${deal.discountedPrice.toStringAsFixed(2)}',
                      style: getBoldStyle(color: const Color(0xFFFF6B6B),
                          fontSize: 28.sp),
                    ),
                    SizedBox(width: 12.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text(
                        '\$${deal.originalPrice.toStringAsFixed(2)}',
                        style: getRegularStyle(
                          color: Colors.grey[500]!,
                          fontSize: FontSize.s16.sp,
                        ).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Save \$${(deal.originalPrice - deal.discountedPrice).toStringAsFixed(2)}',
                        style: getBoldStyle(color: Colors.green, fontSize: FontSize.s14.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isExpired
                            ? null
                            : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Deal claimed: ${deal.title}'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isExpired ? Colors.grey :  ColorManager.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isExpired ? Icons.block : Icons.local_offer, size: 20.r),
                            SizedBox(width: 8.w),
                            Text(
                              isExpired ? 'Deal Expired' : 'Claim Deal',
                              style: getBoldStyle(color: Colors.white, fontSize: FontSize.s16.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 14.r, color: Colors.grey[500]),
                    SizedBox(width: 6.w),
                    Text(
                      'Valid until ${DateFormat('MMM dd, yyyy').format(deal.validUntil)}',
                      style: getRegularStyle(color: Colors.grey[500]!, fontSize: FontSize.s12.sp),
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
