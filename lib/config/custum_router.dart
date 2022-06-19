import 'package:flutter/material.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/kingscorcd.dart';
import 'package:kingsfam/screens/commuinity/screens/stories/storys.dart';
import 'package:kingsfam/screens/screens.dart';

class CustomRoute {
  static Route onGenerateRoute(RouteSettings settings) {
    print('Route: ${settings.name}');
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          settings: const RouteSettings(name: '/'),
          builder: (_) => const Scaffold(),
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
          builder: (_) => const Scaffold(),
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
        return CommuinityFeedScreen.route(args: settings.arguments as CommuinityFeedScreenArgs);

      case CallsHome.routeName:
        return CallsHome.route(args: settings.arguments as CallsHomeArgs);

      case BuildCallScreen.routeName:
        return BuildCallScreen.route(
            args: settings.arguments as BuildCallScreenArgs);

      case CommuinityScreen.routeName:
        return CommuinityScreen.route(
            args: settings.arguments as CommuinityScreenArgs);
      
      case FeedNewScreen.routeName:
        return FeedNewScreen.route(args: settings.arguments as FeedNewScreenArgs);

      case CommentScreen.routeName:
        return CommentScreen.route(args: settings.arguments as CommentScreenArgs);

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
