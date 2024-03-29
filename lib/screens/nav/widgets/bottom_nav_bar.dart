import 'package:flutter/material.dart';

import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/extensions/hexcolor.dart';

class BottomNavBar extends StatelessWidget {
  final Map<BottomNavItem, Widget> items;
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
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.secondary, // Color.fromARGB(255, 27, 49, 67),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.inversePrimary,
      currentIndex: BottomNavItem.values.indexOf(selectedItem),
      onTap: onTap,
      items: items
          .map((item, icon) => MapEntry(
              item.toString(),
              BottomNavigationBarItem(
                label: '',
                icon: Container(child: icon),
              )))
          .values
          .toList(),
    );
  }
}
