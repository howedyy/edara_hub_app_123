import 'package:edara_hub_app_123/core/models/category_model.dart';
import 'package:edara_hub_app_123/core/widget/custom_tab_item.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({super.key,
    required this.categories,
  required this.selectedBgColor,
  required this.unSelectedBgColor,
  required this.selectedFgColor,
  required this.unSelectedFgColor,
    this.onCategoryItemClicked
  });



  final List<CategoryModel> categories;
  final Color selectedBgColor;
  final Color unSelectedBgColor;
  final Color selectedFgColor;
  final Color unSelectedFgColor;
  final void Function(CategoryModel category)? onCategoryItemClicked;

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
      length: widget.categories.length,
      child: TabBar(
        isScrollable: true,
        dividerColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          tabAlignment: TabAlignment.start,
          onTap: (index){
            widget.onCategoryItemClicked?.call(widget.categories[index]);
            setState(() {
              selectedIndex = index;
            });
          },
          tabs:widget.categories.map((category)=> CustomTabItem(
            category: category,
            selectedBgColor: widget.selectedBgColor,
            selectedFgColor: widget.selectedFgColor,
            unSelectedBgColor: widget.unSelectedBgColor,
            unSelectedFgColor: widget.unSelectedFgColor,
            isSelected:
            selectedIndex ==
                widget.categories.indexOf(category),
          ),
          )
              .toList()
      ),
    );
  }
}
