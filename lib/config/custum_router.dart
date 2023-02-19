import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kingsfam/camera/bloc/camera_screen.dart';
import 'package:kingsfam/helpers/vid_helper.dart';
import 'package:kingsfam/screens/commuinity/community_home/home.dart';

import 'package:kingsfam/screens/commuinity/screens/kings%20cord/kingscord.dart';
import 'package:kingsfam/screens/commuinity/screens/roles/roles_screen.dart';
import 'package:kingsfam/screens/commuinity/screens/roles/update_role.dart';
import 'package:kingsfam/screens/commuinity/screens/says_room/says_view.dart';
import 'package:kingsfam/screens/commuinity/screens/says_room/screens/create_says.dart';
import 'package:kingsfam/screens/profile/widgets/show_follows.dart';

import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/screens/search/more_cm_screen.dart';


class CustomRoute {
  static Route onGenerateRoute(RouteSettings settings) {
    log('Route: ${settings.name}');

    if (settings.name == '/') {
      return MaterialPageRoute(
          settings: const RouteSettings(name: '/'),
          builder: (_) => Scaffold(),
        );
    } else if (settings.name == SplashScreen.routeName) {
       return SplashScreen.route();
    } else if (settings.name == LoginScreen.routeName) {
       return LoginScreen.route();
    } else if (settings.name == NavScreen.routeName) {
      return NavScreen.route();
    } else if (settings.name == SignupFormScreen.routeName) {
      return SignupFormScreen.route();
    } else if (settings.name == LoginFormScren.routeName) {
      return LoginFormScren.route();
    } else {
      return onGenerateNestedRoute(settings);
    }

    }

    
  }

  Route onGenerateNestedRoute(RouteSettings settings) {
    log('Nested Route: ${settings.name}');
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

      case KingsCordScreen.routeName:
        return KingsCordScreen.route(settings.arguments as KingsCordArgs);

      case CommuinityFeedScreen.routeName:
        return CommuinityFeedScreen.route(
            args: settings.arguments as CommuinityFeedScreenArgs);

      //  case CommuinityScreen.routeName:
      //    return CommuinityScreen.route(
      //        args: settings.arguments as CommuinityScreenArgs);

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

      case ShowFollowsScreen.routeName:
        return ShowFollowsScreen.route(args:
            settings.arguments as ShowFollowsArgs);

      case PostContentScreen.routeName:
        return PostContentScreen.route(
            args: settings.arguments as PostContentArgs);

      case CreateRoom.routeName:
        return CreateRoom.route(args: settings.arguments as CreateRoomArgs);


      case SaysView.routeName:
        return SaysView.route(args: settings.arguments as SaysViewArgs);

       case VideoEditor.routeName:
         return VideoEditor.route(settings.arguments as VideoEditorArgs);

      case ShowBanedUsers.routeName:
        return ShowBanedUsers.route(settings.arguments as ShowBanedUsersArgs);

      case CreateSays.routeName:
        return CreateSays.route(args: settings.arguments as CreateSaysArgs);

      case UpdatePrivacyCm.routeName:
        return UpdatePrivacyCm.route(
            args: settings.arguments as UpdatePrivacyCmArgs);

      case ReviewPendingRequest.routeName:
        return ReviewPendingRequest.route(
            args: settings.arguments as ReviewPendingRequestArgs);

      case ParticipantsView.routeName:
        return ParticipantsView.route(
            args: settings.arguments as ParticipantsViewArgs);


      case KingsCordRoomSettings.routeName:
        return KingsCordRoomSettings.route(a: settings.arguments as KingsCordRoomSettingsArgs);

      case Participant_deep_view.routeName:
        return Participant_deep_view.route(
            args: settings.arguments as ParticipantDeepViewArgs);

      case CommunityHome.routeName:
        return CommunityHome.route(
          args: settings.arguments as CommunityHomeArgs
        );

    case CameraScreen.routeName:
      return CameraScreen.route(
        args: settings.arguments as CameraScreenArgs
      );
    
    case VcScreen.routeName:
      return VcScreen.route(
        args: settings.arguments as VcScreenArgs
    );

    case ReportContentScreen.routeName:
      return ReportContentScreen.route(args: settings.arguments as RepoetContentScreenArgs);

      default:
        return _errorRoute();
    }

  }

  Route _errorRoute() {
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

