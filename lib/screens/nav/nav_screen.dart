import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';
import 'package:kingsfam/screens/nav/widgets/widgets.dart';

class NavScreen extends StatelessWidget {
  static const String routeName = '/nav';
  static Route route() {
    return PageRouteBuilder(
        settings: const RouteSettings(name: routeName),
        transitionDuration: const Duration(seconds: 0),
        pageBuilder: (_, __, ___) => NavScreen()); //buildcontext, animaitons ;
  }

  //navigator keys to maintain current satate across pages

  final Map<BottomNavItem, GlobalKey<NavigatorState>> navigatorKeys = {
    BottomNavItem.chats: GlobalKey<NavigatorState>(),
    BottomNavItem.search: GlobalKey<NavigatorState>(),
    BottomNavItem.notifications: GlobalKey<NavigatorState>(),
    BottomNavItem.profile: GlobalKey<NavigatorState>(),
  };

  final Map<BottomNavItem, Widget> items = const {
    BottomNavItem.chats: Icon(Icons.home, size: 20,),
    BottomNavItem.search: Icon(Icons.search, size: 20),
    BottomNavItem.notifications: Icon(Icons.favorite_border, size: 20),
    BottomNavItem.profile: Icon(Icons.account_circle, size: 20)
  };

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // sets the ability to pop this stack to false
      child: BlocBuilder<BottomnavbarCubit, BottomnavbarState>(
        builder: (context, state) { 
          return Scaffold(
            body: Stack( // the body is a stack the stack of the bottom sheet
              children: items // this is a map, bottomnavitem to icon data
                  .map((item, _) => MapEntry( // this mapping every 
                        item,
                        _buildOffStageNavigator(item, item == state.selectedItem,),
                      ))
                  .values
                  .toList(),
            ),
            bottomNavigationBar: context.read<BottomnavbarCubit>().state.showBottomNav ? BottomNavBar(
              
              onTap: (index) {
                final selectedItem = BottomNavItem.values[index];
                _selectBottomNavItem(context, selectedItem, selectedItem == state.selectedItem);
                //context.read<BottomnavbarCubit>().showBottomNav(true);
              },
              items: items,
              selectedItem: state.selectedItem,
            ) : SizedBox.shrink(),
          );
        },
      ),
    );
  }

  void _selectBottomNavItem(
      BuildContext context, BottomNavItem selectedItem, bool isSameItem) {
    if (isSameItem) {
      navigatorKeys[selectedItem]!
          .currentState!
          .popUntil((route) => route.isFirst);
    }
    context.read<BottomnavbarCubit>().updateSelectedItem(selectedItem);
  }

  Widget _buildOffStageNavigator(BottomNavItem currentItem, bool isSelected) {
    //only show item that is selected
    return Offstage(
      offstage: !isSelected,
      child: TabNavigator(
        navigatorKey: navigatorKeys[currentItem]!,
        item: currentItem,
      ),
    );
  }
}
