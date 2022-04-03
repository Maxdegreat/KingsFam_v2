import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/blocs/search/search_bloc.dart';
import 'package:kingsfam/config/custum_router.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';

import 'package:kingsfam/enums/bottom_nav_items.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/notification/bloc/noty_bloc.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';

import '../../screens.dart';

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
      onGenerateRoute: CustomRoute.onGenerateNestedRoute,
    );
  }

  Map<String, WidgetBuilder> _routeBuilders() {
    return {tabNavigatorRoot: (context) => _getScreen(context, item)};
  }

  Widget _getScreen(BuildContext ctx, BottomNavItem item) {
    switch (item) {
      case BottomNavItem.chats:
        return BlocProvider(
          create: (_) => ChatscreenBloc(
              authBloc: ctx.read<AuthBloc>(),
              chatRepository: ctx.read<ChatRepository>())
            ..add(LoadChats(chatId: ctx.read<AuthBloc>().state.user!.uid)),
          child: ChatsScreen(),
        );

      case BottomNavItem.search:
        return BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(
            authBloc: context.read<AuthBloc>(),
            churchRepository: context.read<ChurchRepository>(),
            userrRepository: context.read<UserrRepository>(),
          )..add(InitializeUser(
              currentUserrId: ctx.read<AuthBloc>().state.user!.uid)),
          child: SearchScreen(),
        );

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
            likedPostCubit: ctx.read<LikedPostCubit>(),
            userrRepository: ctx.read<UserrRepository>(),
            authBloc: ctx.read<AuthBloc>(),
            postRepository: ctx.read<PostsRepository>(),
          )..add(
              ProfileLoadUserr(userId: ctx.read<AuthBloc>().state.user!.uid)),
          child: ProfileScreen(),
        );
      default:
        return Scaffold();
    }
  }
}