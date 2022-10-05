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
    HexColor hc = HexColor();
    return BottomNavigationBar(
      elevation: 0,
      backgroundColor: Color(hc.hexcolorCode('#141829')), //Color.fromARGB(255, 27, 49, 67),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      selectedItemColor:  Colors.amber[600],
      unselectedItemColor: Colors.white,
      currentIndex: BottomNavItem.values.indexOf(selectedItem),
      onTap: onTap,
      items: items.map((item, icon) => MapEntry(
        item.toString(), 
        BottomNavigationBarItem(
          label: '',
          icon:  Container(child: icon),
        ))).values.toList(),
    );
  }
}
