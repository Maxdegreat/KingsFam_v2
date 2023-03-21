// copyrights @KingsFam
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/blocs/search/search_bloc.dart';
import 'package:kingsfam/blocs/simple_bloc_observer.dart';
import 'package:kingsfam/config/custum_router.dart';
import 'package:kingsfam/cubits/buid_cubit/buid_cubit.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/cubits/liked_says/liked_says_cubit.dart';
import 'package:kingsfam/helpers/user_preferences.dart';
import 'package:kingsfam/repositories/prayer_repo/prayer_repo.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/repositories/says/says_repository.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/cubit/kingscord_cubit.dart';
import 'package:kingsfam/screens/commuinity/screens/says_room/bloc/says_bloc.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/theme_club_house/theme_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/build_church/cubit/buildchurch_cubit.dart';
import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // lets keep the splash till app is one initializing
  if (!kIsWeb) {
    MobileAds.instance.initialize();
    Bloc.observer = SimpleBlocObserver();
  }
  EquatableConfig.stringify = kDebugMode;

  await Firebase.initializeApp(
      options: !kIsWeb
          ? null
          : FirebaseOptions(
              apiKey: "AIzaSyCXVic9bfTfwv77hjChsGvCTeg6rvVlMkE",
              appId: "1:628805532994:web:7a5aa12ebebdc26aca1cdb",
              messagingSenderId: "628805532994",
              projectId: "kingsfam-9b1f8",
              storageBucket: "kingsfam-9b1f8.appspot.com",
            ));

  await UserPreferences.init();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SaysRepository>(create: (_) => SaysRepository()),
        RepositoryProvider<ChurchRepository>(create: (_) => ChurchRepository()),
        RepositoryProvider<KingsCordRepository>(
            create: (_) => KingsCordRepository()),
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<PrayerRepo>(create: (_) => PrayerRepo()),
        RepositoryProvider<UserrRepository>(create: (_) => UserrRepository()),
        RepositoryProvider<StorageRepository>(
            create: (_) => StorageRepository()),
        RepositoryProvider<PostsRepository>(create: (_) => PostsRepository()),
        RepositoryProvider<NotificationRepository>(
          create: (_) => NotificationRepository(),
        ),
        //TODO ADD PERKSREPO
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<LikedPostCubit>(
            create: (context) => LikedPostCubit(
                postsRepository: context.read<PostsRepository>(),
                authBloc: context.read<AuthBloc>()),
          ),

          BlocProvider<ProfileBloc>(
              create: (context) => ProfileBloc(
                  prayerRepo: context.read<PrayerRepo>(),
                  userrRepository: context.read<UserrRepository>(),
                  authBloc: context.read<AuthBloc>(),
                  postRepository: context.read<PostsRepository>(),
                  likedPostCubit: context.read<LikedPostCubit>(),
                  churchRepository: context.read<ChurchRepository>())
                ..add(ProfileLoadUserOnly(
                    userId: context.read<AuthBloc>().state.user!.uid))),
           
          BlocProvider<ChatscreenBloc>(
            create: (context) => ChatscreenBloc(
                authBloc: context.read<AuthBloc>(),
                likedPostCubit: context.read<LikedPostCubit>(),
                postsRepository: context.read<PostsRepository>(),
                churchRepository: context.read<ChurchRepository>(),
                userrRepository: context.read<UserrRepository>()),
          ),
          BlocProvider<SearchBloc>(
              create: (context) => SearchBloc(
                  userrRepository: context.read<UserrRepository>(),
                  churchRepository: context.read<ChurchRepository>(),
                  authBloc: context.read<AuthBloc>())),
          BlocProvider<KingscordCubit>(
            create: (context) => KingscordCubit(
                storageRepository: context.read<StorageRepository>(),
                authBloc: context.read<AuthBloc>(),
                kingsCordRepository: context.read<KingsCordRepository>(),
                churchRepository:
                    context.read<ChurchRepository>() // may need to report
                ),
          ),
          BlocProvider<LikedSaysCubit>(
              create: (context) => LikedSaysCubit(
                  saysRepository: context.read<SaysRepository>(),
                  authBloc: context.read<AuthBloc>())),
          BlocProvider<SaysBloc>(
              create: (context) => SaysBloc(
                    saysRepository: context.read<SaysRepository>(),
                    authBloc: context.read<AuthBloc>(),
                    likedSaysCubit: context.read<LikedSaysCubit>(),
                  )),
          BlocProvider<BuildchurchCubit>(
              create: (context) => BuildchurchCubit(
                  churchRepository: context.read<ChurchRepository>(),
                  storageRepository: context.read<StorageRepository>(),
                  authBloc: context.read<AuthBloc>(),
                  userrRepository: context.read<UserrRepository>())),
          BlocProvider<BottomnavbarCubit>(
            create: (context) => BottomnavbarCubit(),
          ),
          BlocProvider<BuidCubit>(
            create: (context) => BuidCubit(),
          ),
          BlocProvider<FeedBloc>(
            create: (context) => FeedBloc(
                postsRepository: context.read<PostsRepository>(),
                authBloc: context.read<AuthBloc>(),
                likedPostCubit: context.read<LikedPostCubit>(),
                buidCubit: context.read<BuidCubit>()),
          ),
          BlocProvider<CommuinityBloc>(
              create: (context) => CommuinityBloc(
                  churchRepository: context.read<ChurchRepository>(),
                  storageRepository: context.read<StorageRepository>(),
                  authBloc: context.read<AuthBloc>(),
                  userrRepository: context.read<UserrRepository>())),
          
        ],
        child: MaterialApp(
          //THEME DATA
          themeMode: ThemeMode.system,
          // will make cubit to update theme -> updateThemeState() -> dark, light, or tiered customs
          theme: ThemeInfo().themeClubHouseLight(),
          darkTheme: ThemeInfo().themeClubHouseDark(),
          debugShowCheckedModeBanner: false,
          title: 'KingsFam',
          onGenerateRoute: CustomRoute.onGenerateRoute,
          initialRoute: SplashScreen.routeName,
        ),
      ),
    );
  }
}
