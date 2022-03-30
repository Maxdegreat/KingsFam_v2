import 'package:flutter/material.dart';

import 'package:kingsfam/enums/enums.dart';

class BottomNavBar extends StatelessWidget {
  final Map<BottomNavItem, IconData> items;
  final BottomNavItem selectedItem;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.red[400],
      unselectedItemColor: Colors.red[100],
      currentIndex: BottomNavItem.values.indexOf(selectedItem),
      onTap: onTap,
      items: items.map((item, icon) => MapEntry(
        item.toString(), 
        BottomNavigationBarItem(
          label: '',
          icon:  Icon(icon, size:30.0),
        ))).values.toList(),
    );
  }
}
