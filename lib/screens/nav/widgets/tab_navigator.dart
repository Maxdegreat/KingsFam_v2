

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/blocs/search/search_bloc.dart';
import 'package:kingsfam/config/custum_router.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';

import 'package:kingsfam/enums/bottom_nav_items.dart';
import 'package:kingsfam/repositories/prayer_repo/prayer_repo.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/notification/bloc/noty_bloc.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';

import '../../screens.dart';

// this screen can controll how data is loaded on the open of the app by using the chain opperator.
// for many reasons we will try to not load what we do not nead initally

class TabNavigator extends StatelessWidget {
  static const String tabNavigatorRoot = '/';
  final GlobalKey<NavigatorState> navigatorKey;
  final BottomNavItem item;

  const TabNavigator({
    Key? key,
    required this.navigatorKey,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeBuilders = _routeBuilders();
    return Navigator(
      key: navigatorKey,
      initialRoute: tabNavigatorRoot,
      onGenerateInitialRoutes: (_, initialRoute) {
        return [
          MaterialPageRoute(
            settings: RouteSettings(name: tabNavigatorRoot),
            builder: (context) => routeBuilders[initialRoute]!(context),
          )
        ];
      },
      onGenerateRoute: CustomRoute.onGenerateRoute,
    );
  }

  Map<String, WidgetBuilder> _routeBuilders() {
    return {tabNavigatorRoot: (context) => _getScreen(context, item)};
  }

  Widget _getScreen(BuildContext ctx, BottomNavItem item) {
    switch (item) {
      case BottomNavItem.chats:
        return   ChatsScreen();
     

      // removed the chain operator that ads the init user
      case BottomNavItem.search:
        return SearchScreen();
        

      case BottomNavItem.notifications:
        return BlocProvider<NotyBloc>(
          create: (context) => NotyBloc(
            notificationRepository: context.read<NotificationRepository>(), 
            authBloc: context.read<AuthBloc>(),
          ),
          child: NotificationsScreen(),
        );

      case BottomNavItem.profile:
        return BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(
            prayerRepo: ctx.read<PrayerRepo>(),
            churchRepository: ctx.read<ChurchRepository>(),
            likedPostCubit: ctx.read<LikedPostCubit>(),
            userrRepository: ctx.read<UserrRepository>(),
            authBloc: ctx.read<AuthBloc>(),
            postRepository: ctx.read<PostsRepository>(),
            chatRepository: ctx.read<ChatRepository>()
          ),
          child: ProfileScreen(ownerId: ctx.read<AuthBloc>().state.user!.uid, initScreen: true,),
        );
      default:
        return Scaffold();
    }
  }
}
