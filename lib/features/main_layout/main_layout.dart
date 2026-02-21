import 'package:edara_hub_app_123/core/resources/assets_manager.dart';
import 'package:edara_hub_app_123/core/resources/color_manager.dart';
import 'package:edara_hub_app_123/core/widget/home_screen_app_bar.dart';
import 'package:edara_hub_app_123/features/main_layout/categories/presentation/categories_tab.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/presentation/deals_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edara_hub_app_123/core/di/service_locator.dart';
import 'package:edara_hub_app_123/features/main_layout/home/presentation/manager/home_bloc.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/presentation/manager/deals_bloc.dart';
import 'home/presentation/home_tab.dart';
import 'profile_tab/presentation/profile_tab.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;
  List<Widget> tabs = [
    BlocProvider(
      create: (context) => serviceLocator<HomeBloc>(),
      child: const HomeTab(),
    ),
  // const CategoriesTab(),
   BlocProvider(
      create: (context) => serviceLocator<DealsBloc>(),
      child: const DealsScreen(),
    ),
   const ProfileTab(),
  ];
  
  @override
  void initState() {
    super.initState();
    print('MainLayout: initState called');
    print('MainLayout: Current tab index: $currentIndex');
  }
  
  @override
  Widget build(BuildContext context) {
    print('MainLayout: build called with currentIndex: $currentIndex');
    return Scaffold(
      //appBar: const HomeScreenAppBar(),
     // extendBody: false,
      body: tabs[currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (value) => changeSelectedIndex(value),
            backgroundColor: ColorManager.primary,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: ColorManager.primary,
            unselectedItemColor: ColorManager.white,
            showSelectedLabels: false, // Hide selected item labels
            showUnselectedLabels: false, // Hide unselected item labels
            items: [
              // Build BottomNavigationBarItem widgets for each tab
              CustomBottomNavBarItem(IconsAssets.icHome, "Home"),
              //CustomBottomNavBarItem(IconsAssets.icCategory, "Category"),
              CustomBottomNavBarItem(IconsAssets.icWithList, "Deals"),
              CustomBottomNavBarItem(IconsAssets.icProfile, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  changeSelectedIndex(int selectedIndex) {
    setState(() {
      currentIndex = selectedIndex;
    });
  }
}

class CustomBottomNavBarItem extends BottomNavigationBarItem {
  String iconPath;
  String title;
  CustomBottomNavBarItem(this.iconPath, this.title)
      : super(
          label: title,
          icon: ImageIcon(
            AssetImage(iconPath), // Inactive icon image
            color: ColorManager.white, // Inactive icon color
          ),
          activeIcon: CircleAvatar(
            backgroundColor: ColorManager.white, // Background of active icon
            child: ImageIcon(
              AssetImage(iconPath),
              color: ColorManager
                  .primary, // Active icon imagecolor: ColorManager.primary, // Active icon color
            ),
          ),
        );
}
