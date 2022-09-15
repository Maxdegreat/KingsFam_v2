import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kingsfam/helpers/vid_helper.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/kingscord.dart';
import 'package:kingsfam/screens/commuinity/screens/roles/roles_screen.dart';
import 'package:kingsfam/screens/commuinity/screens/roles/update_role.dart';
import 'package:kingsfam/screens/commuinity/screens/stories/storys.dart';

import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/screens/search/more_cm_screen.dart';
import 'package:kingsfam/screens/search/widgets/show_following.dart';

class CustomRoute {
  static Route onGenerateRoute(RouteSettings settings) {
    log('Route: ${settings.name}');
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/'),
          builder: (_) => Scaffold(),
        );

      case SplashScreen.routeName:
        return SplashScreen.route();

      case LoginScreen.routeName:
        return LoginScreen.route();

      case NavScreen.routeName:
        return NavScreen.route();

      case SignupFormScreen.routeName:
        return SignupFormScreen.route();

      case LoginFormScren.routeName:
        return LoginFormScren.route();

      default:
        return _errorRoute();
    }
  }

  static Route onGenerateNestedRoute(RouteSettings settings) {
    print('Nested Route: ${settings.name}');
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/'),
          builder: (_) => Scaffold(
            body: Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.purple,
            ),
          ),
        );

      case EditProfileScreen.routeName:
        return EditProfileScreen.route(
          args: settings.arguments as EditProfileScreenArgs,
        );

      case CreatePostScreen.routeName:
        return CreatePostScreen.route();

      case ProfileScreen.routeName:
        return ProfileScreen.route(
            args: settings.arguments as ProfileScreenArgs);

      case SearchScreen.routeName:
        return SearchScreen.route();

      // case PostView.routeName:
      //   return PostView.route(settings.arguments as PostViewAgrs);

      //case VideoCallScreen.routeName:
      //  return VideoCallScreen.route(args: settings.arguments as VideoCallScreenArgs);

      case ProfilePostView.routeName:
        return ProfilePostView.route(settings.arguments as ProfilePostViewArgs);

      case CreateChatScreen.routeName:
        return CreateChatScreen.route(settings.arguments as CreateChatArgs);

      case AddUsers.routeName:
        return AddUsers.route(settings.arguments as CreateNewGroupArgs);

      case ChatRoom.routeName:
        return ChatRoom.route(args: settings.arguments as ChatRoomArgs);

      case ChatRoomSettings.routeName:
        return ChatRoomSettings.route(
            args: settings.arguments as ChatRoomSettingsArgs);

      case BuildChurch.routeName:
        return BuildChurch.route(settings.arguments as BuildChurchArgs);

      case CreateComuinity.routeName:
        return CreateComuinity.route();

      case KingsCordScreen.routeName:
        return KingsCordScreen.route(settings.arguments as KingsCordArgs);

      case SoundsScreen.routeName:
        return SoundsScreen.route(args: settings.arguments as SoundsArgs);

      case StorysCommuinityScreen.routeName:
        return StorysCommuinityScreen.route(
            args: settings.arguments as StoryCommuinityArgs);

      case CommuinityFeedScreen.routeName:
        return CommuinityFeedScreen.route(
            args: settings.arguments as CommuinityFeedScreenArgs);

      case CallsHome.routeName:
        return CallsHome.route(args: settings.arguments as CallsHomeArgs);

      case BuildCallScreen.routeName:
        return BuildCallScreen.route(
            args: settings.arguments as BuildCallScreenArgs);

      case CommuinityScreen.routeName:
        return CommuinityScreen.route(
            args: settings.arguments as CommuinityScreenArgs);

      case FeedNewScreen.routeName:
        return FeedNewScreen.route(
            args: settings.arguments as FeedNewScreenArgs);

      case CommentScreen.routeName:
        return CommentScreen.route(
            args: settings.arguments as CommentScreenArgs);

      case UrlViewScreen.routeName:
        return UrlViewScreen.route(args: settings.arguments as UrlViewArgs);

      case RolesScreen.routeName:
        return RolesScreen.route(args: settings.arguments as RoleScreenArgs);

      case CommunityUpdateRoleScreen.routeName:
        return CommunityUpdateRoleScreen.route(
            args: settings.arguments as CommunityUpdateRoleArgsScreen);

      // case SnackTimeShopScreen.routeName:
        // return SnackTimeShopScreen.route(settings.arguments as SnackTimeArgs);

      case BuyPerkScreen.routeName:
        return BuyPerkScreen.route(settings.arguments as BuyPerkArgs);
      
      case UpdateCmThemePack.routeName:
        return UpdateCmThemePack.route(settings.arguments as UpdateCmThemePackArgs);
      
      case MoreCm.routeName:
        return MoreCm.route(settings.arguments as MoreCmArgs);
      
      case ShowFollowingList.routeName:
        return ShowFollowingList.route(settings.arguments as ShowFollowingListArgs);

      case PostContentScreen.routeName:
        return PostContentScreen.route(args: settings.arguments as PostContentArgs);
      
      case VideoEditor.routeName:
        return VideoEditor.route(settings.arguments as VideoEditorArgs);

      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: '/error'),
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Something went wrong!'),
        ),
      ),
    );
  }
}