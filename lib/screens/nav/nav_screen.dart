import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/config/global_keys.dart';
import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';
import 'package:kingsfam/screens/nav/widgets/widgets.dart';
import 'package:kingsfam/widgets/mainDrawer/main_drawer.dart';

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
    // BottomNavItem.notifications: GlobalKey<NavigatorState>(),
    BottomNavItem.profile: GlobalKey<NavigatorState>(),
  };

  final Map<BottomNavItem, Widget> items = {
    BottomNavItem.chats: Icon(
      Icons.question_answer,
      size: 20,
    ),
    BottomNavItem.search: Icon(Icons.search, size: 20),
    // BottomNavItem.notifications: Icon(Icons.favorite_border, size: 20),
    BottomNavItem.profile: Icon(Icons.account_circle, size: 20)
  };

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          false, // sets the ability to pop this stack to false
      child: BlocBuilder<BottomnavbarCubit, BottomnavbarState>(
        builder: (context, state) {
          return Scaffold(
            //  appBar: AppBar(),
            key: scaffoldKey,
            
            body: Stack(
              // the body is a stack the stack of the bottom sheet
              children: items // this is a map, bottomnavitem to icon data
                  .map((item, _) => MapEntry(
                        // this mapping every
                        item,
                        _buildOffStageNavigator(
                          item,
                          item == state.selectedItem,
                          item == BottomNavItem.profile ? context : null,
                        ),
                      ))
                  .values
                  .toList(),
            ),

            floatingActionButton: kIsWeb ? Container(
              height: 300, width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.secondary,
              ),

              child: NavigationRail(
                unselectedIconTheme: Theme.of(context).iconTheme,        
                backgroundColor: Colors.transparent,
                        destinations: items.entries
                            .map(
                              (entry) => NavigationRailDestination(
                                icon: entry.value,
                                label: SizedBox.shrink(),
                              ),
                            )
                            .toList(),
                        selectedIndex: BottomNavItem.values.indexOf(state.selectedItem),
                        onDestinationSelected: (index) {
                           final selectedItem = BottomNavItem.values[index];
                            if (index == 0 ||
                                BottomNavItem.values[index] ==
                                    BottomNavItem.chats) {
                              if (!kIsWeb) scaffoldKey.currentState!.openDrawer();
                              _selectBottomNavItem(context, selectedItem,
                                  selectedItem == state.selectedItem);
                            } else
                              _selectBottomNavItem(context, selectedItem,
                                  selectedItem == state.selectedItem);
                            //context.read<BottomnavbarCubit>().showBottomNav(true);
                        },  
                      ),
            ) : null,

            bottomNavigationBar: !kIsWeb
                ? context.read<BottomnavbarCubit>().state.showBottomNav
                    ? BottomNavBar(
                        onTap: (index) {
                          final selectedItem = BottomNavItem.values[index];
                          if (index == 0 ||
                              BottomNavItem.values[index] ==
                                  BottomNavItem.chats) {
                            if (!kIsWeb) {
                              scaffoldKey.currentState!.openDrawer();
                              context.read<BottomnavbarCubit>().showBottomNav(true);
                            }
                            _selectBottomNavItem(context, selectedItem,
                                selectedItem == state.selectedItem);
                          } else
                            _selectBottomNavItem(context, selectedItem,
                                selectedItem == state.selectedItem);
                          //context.read<BottomnavbarCubit>().showBottomNav(true);
                        },
                        items: items,
                        selectedItem: state.selectedItem,
                      )
                    : SizedBox.shrink()
                : null,
                extendBody: false,
                drawer: MainDrawer(),
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

  Widget _buildOffStageNavigator(BottomNavItem currentItem, bool isSelected, BuildContext? context) {
    //only show item that is selected
    return Offstage(
      offstage: !isSelected,
      child: TabNavigator(
        navigatorKey: navigatorKeys[currentItem]!,
        item: currentItem,
        context: currentItem == BottomNavItem.profile ? context : null,
      ),
    );
  }
}
