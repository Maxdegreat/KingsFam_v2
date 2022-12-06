import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kingsfam/screens/commuinity/community_home/home.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/kingscord.dart';
import 'package:kingsfam/screens/commuinity/screens/roles/roles_screen.dart';
import 'package:kingsfam/screens/commuinity/screens/roles/update_role.dart';
import 'package:kingsfam/screens/commuinity/screens/says_room/screens/create_says.dart';
import 'package:kingsfam/screens/commuinity/wrapers/create_new_role.dart';
import 'package:kingsfam/screens/commuinity/wrapers/role_permissions.dart';

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
        return BuildChurch.route();

      case CreateComuinity.routeName:
        return CreateComuinity.route();

      case KingsCordScreen.routeName:
        return KingsCordScreen.route(settings.arguments as KingsCordArgs);

      case CommuinityFeedScreen.routeName:
        return CommuinityFeedScreen.route(
            args: settings.arguments as CommuinityFeedScreenArgs);

      // case CommuinityScreen.routeName:
      //   return CommuinityScreen.route(
      //       args: settings.arguments as CommuinityScreenArgs);

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

      case SnackTimeShopScreen.routeName:
        return SnackTimeShopScreen.route(settings.arguments as SnackTimeArgs);

      case BuyPerkScreen.routeName:
        return BuyPerkScreen.route(settings.arguments as BuyPerkArgs);

      case UpdateCmThemePack.routeName:
        return UpdateCmThemePack.route(
            settings.arguments as UpdateCmThemePackArgs);

      case MoreCm.routeName:
        return MoreCm.route(settings.arguments as MoreCmArgs);

      case ShowFollowingList.routeName:
        return ShowFollowingList.route(
            settings.arguments as ShowFollowingListArgs);

      case PostContentScreen.routeName:
        return PostContentScreen.route(
            args: settings.arguments as PostContentArgs);

      case CreateRoom.routeName:
        return CreateRoom.route(args: settings.arguments as CreateRoomArgs);

      case SaysRoom.routeName:
        return SaysRoom.route(args: settings.arguments as SaysRoomArgs);

      case SaysPopUp.routeName:
        return SaysPopUp.route(args: settings.arguments as SaysPopUpArgs);

      // case VideoEditor.routeName:
      //   return VideoEditor.route(settings.arguments as VideoEditorArgs);

      case ShowBanedUsers.routeName:
        return ShowBanedUsers.route(settings.arguments as ShowBanedUsersArgs);

      case CreateSays.routeName:
        return CreateSays.route(args: settings.arguments as CreateSaysArgs);

      case EventView.routeName:
        return EventView.route(args: settings.arguments as EventViewArgs);

      case UpdatePrivacyCm.routeName:
        return UpdatePrivacyCm.route(
            args: settings.arguments as UpdatePrivacyCmArgs);

      case ReviewPendingRequest.routeName:
        return ReviewPendingRequest.route(
            args: settings.arguments as ReviewPendingRequestArgs);

      case ParticipantsView.routeName:
        return ParticipantsView.route(
            args: settings.arguments as ParticipantsViewArgs);

      case RolePermissions.routeName:
        return RolePermissions.route(
            args: settings.arguments as RolePermissionsArgs);

      case CreateRole.routeName:
        return CreateRole.route(args: settings.arguments as CreateRoleArgs);

      case KingsCordSettings.routeName:
        return KingsCordSettings.route(
            args: settings.arguments as KingsCordSettingsArgs);

      case Participant_deep_view.routeName:
        return Participant_deep_view.route(
            args: settings.arguments as ParticipantDeepViewArgs);

      case CommunityHome.routeName:
        return CommunityHome.route(
          args: settings.arguments as CommunityHomeArgs
        );

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
