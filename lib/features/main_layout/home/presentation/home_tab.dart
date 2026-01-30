import 'package:edara_hub_app_123/features/main_layout/home/presentation/manager/home_bloc.dart';
import 'package:edara_hub_app_123/features/main_layout/home/presentation/widgets/event_item.dart';
import 'package:edara_hub_app_123/core/di/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:edara_hub_app_123/core/resources/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:edara_hub_app_123/core/models/category_model.dart';
import 'package:edara_hub_app_123/core/widget/custom_tab_bar.dart';
import 'package:edara_hub_app_123/core/resources/values_manager.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  CategoryModel? selectedCategory;
  late HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = serviceLocator<HomeBloc>()..add(GetEventsEvent());
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    selectedCategory ??= CategoryModel.getCategoriesWithAll(context)[0];
    return BlocProvider.value(
      value: _homeBloc,
      child: Column(
        children: [
          Container(
            padding: REdgeInsets.symmetric(horizontal: AppPadding.p8, vertical: AppPadding.p8),
            width: double.infinity,
            decoration: BoxDecoration(
                color: ColorManager.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppSize.s16.r))
            ),
            child: SafeArea(
              left: false,
              right: false,
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome Back ✨",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: ColorManager.white),
                          ),
                          Text("User Name", // Placeholder for UserModel.currentUser!.name
                            style:Theme.of(context).textTheme.headlineLarge?.copyWith(color: ColorManager.white),
                          ),


                        ],
                      ),
                      Spacer(),
                      IconButton(onPressed: (){
                        // configProvider.changeAppTheme(...)
                      },
                          icon: Icon(Icons.notifications,
                            color: ColorManager.white,
                          )
                      ),
                      SizedBox(width: AppSize.s10.w,),
                      InkWell(
                        onTap: (){
                          // configProvider.changeAppLanguage(...)
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppPadding.p8),
                            child: Text(
                              "En", // Placeholder
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: AppSize.s12.h,),
                  // CustomTabBar placeholder
                 CustomTabBar(
                   onCategoryItemClicked: (category){
                     selectedCategory = category;
                     setState(() {

                     });
                   },
                   categories: CategoryModel.getCategoriesWithAll(context),
                     selectedBgColor: ColorManager.white,
                     unSelectedBgColor: Colors.transparent,
                     selectedFgColor: ColorManager.primary,
                     unSelectedFgColor: ColorManager.white,
                 ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HomeFailure) {
                  return Center(child: Text(state.message));
                } else if (state is HomeSuccess) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: state.events.length,
                    itemBuilder: (context, index) {
                      return EventItem(event: state.events[index]);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
