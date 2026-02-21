import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edara_hub_app_123/features/main_layout/home/presentation/widgets/multimedia_carousel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edara_hub_app_123/features/main_layout/home/presentation/manager/home_bloc.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';
import 'package:edara_hub_app_123/core/resources/color_manager.dart';
import 'package:edara_hub_app_123/core/resources/styles_manager.dart';
import 'package:edara_hub_app_123/core/resources/font_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.explore},
    {'name': 'Sport', 'icon': Icons.directions_bike},
    {'name': 'Birthday', 'icon': Icons.cake},
    {'name': 'Meeting', 'icon': Icons.groups},
    {'name': 'Clubbing', 'icon': Icons.music_note},
  ];

  @override
  void initState() {
    super.initState();
    print('HomeTab: initState called, userId: $_currentUserId');
    if (_currentUserId.isNotEmpty) {
      context.read<HomeBloc>().add(LoadEvents(_currentUserId));
      print('HomeTab: LoadEvents dispatched');
    } else {
      print('HomeTab: WARNING - currentUserId is empty!');
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
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HomeLoaded) {
                  if (state.events.isEmpty) {
                    return const Center(child: Text('No events found for you.'));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 10.h),
                    itemCount: state.events.length,
                    itemBuilder: (context, index) {
                      final event = state.events[index];
                      return EventCard(
                        event: event,
                        currentUserId: _currentUserId,
                      );
                    },
                  );
                } else if (state is HomeError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const Center(child: Text('Welcome!'));
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
          colors: [
            ColorManager.headerGradientStart,
            ColorManager.headerGradientEnd,
          ],
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
                    Text(
                      'Welcome Back ✨',
                      style: getLightStyle(color: Colors.white70, fontSize: FontSize.s16.sp),
                    ),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(_currentUserId).get(),
                      builder: (context, snapshot) {
                        String name = 'User';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          name = snapshot.data!.get('name') ?? 'User';
                        }
                        return Text(
                          name,
                          style: getBoldStyle(color: Colors.white, fontSize: 28.sp),
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.wb_sunny_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        'EN',
                        style: getBoldStyle(color: Colors.white, fontSize: FontSize.s14.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 18),
                SizedBox(width: 5.w),
                Text(
                  'Cairo, Egypt',
                  style: getRegularStyle(color: Colors.white, fontSize: FontSize.s14.sp),
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
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['name'];
                    });
                  },
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
                        Icon(
                          cat['icon'],
                          size: 20.r,
                          color: isSelected ? ColorManager.headerGradientEnd : ColorManager.white,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          cat['name'],
                          style: getBoldStyle(
                            color: isSelected ? ColorManager.headerGradientEnd : ColorManager.white,
                            fontSize: FontSize.s14.sp,
                          ),
                        ),
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

class EventCard extends StatelessWidget {
  final EventEntity event;
  final String currentUserId;

  const EventCard({
    super.key,
    required this.event,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isWishlisted = event.wishlist.contains(currentUserId);
    final TextEditingController commentController = TextEditingController();

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
          // Multimedia Carousel
          SizedBox(
            height: 200.h,
            width: double.infinity,
            child: MultimediaCarousel(urls: event.attachments),
          ),
          
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: getBoldStyle(color: ColorManager.appBarTitleColor, fontSize: FontSize.s20.sp),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        context.read<HomeBloc>().add(
                          ToggleWishlist(event.id, currentUserId, !isWishlisted),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  event.description,
                  style: getRegularStyle(color: Colors.blueGrey, fontSize: FontSize.s14.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(height: 32),
                Text(
                  'Comments',
                  style: getBoldStyle(color: Colors.black87, fontSize: FontSize.s16.sp),
                ),
                SizedBox(height: 8.h),
                if (event.comments.isEmpty)
                  Text('No comments yet.', style: getRegularStyle(color: Colors.grey, fontSize: FontSize.s12.sp)),
                ...event.comments.take(2).map((comment) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.comment_outlined, size: 14.r, color: Colors.grey),
                          SizedBox(width: 8.w),
                          Expanded(child: Text(comment, style: getRegularStyle(color: Colors.black87, fontSize: 13.sp))),
                        ],
                      ),
                    )),
                if (event.comments.length > 2)
                   Text('View all ${event.comments.length} comments', style: getRegularStyle(color: ColorManager.primary, fontSize: FontSize.s12.sp)),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        style: getRegularStyle(color: Colors.black87, fontSize: FontSize.s14.sp),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF4A49D1)),
                      onPressed: () {
                        if (commentController.text.isNotEmpty) {
                          context.read<HomeBloc>().add(
                                AddComment(event.id, commentController.text),
                              );
                          commentController.clear();
                        }
                      },
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
