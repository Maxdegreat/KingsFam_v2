//   <meta-data
// android:name="com.google.android.gms.ads.APPLICATION_ID"
// android:value="ca-app-pub-3940256099942544~3347511713"/>

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
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/commuinity/screens/commuinity_calls/cubit/calls_home_cubit.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';

import 'screens/build_church/cubit/buildchurch_cubit.dart';
import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();

  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ChurchRepository>(create: (_) => ChurchRepository()),
        RepositoryProvider<KingsCordRepository>(create: (_) => KingsCordRepository()),
        RepositoryProvider<ChatRepository>(create: (_) => ChatRepository()),
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<UserrRepository>(create: (_) => UserrRepository()),
        RepositoryProvider<StorageRepository>(create: (_) => StorageRepository()),
        RepositoryProvider<PostsRepository>(create: (_) => PostsRepository()),
        RepositoryProvider<CallRepository>(create: (_) => CallRepository()),
        RepositoryProvider<NotificationRepository>(create: (_) => NotificationRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<SearchBloc>(
              create: (context) => SearchBloc(
                  userrRepository: context.read<UserrRepository>(),
                  churchRepository: context.read<ChurchRepository>(),
                  authBloc: context.read<AuthBloc>())
                ),
          BlocProvider<LikedPostCubit>(
            create: (context) => LikedPostCubit(
                postsRepository: context.read<PostsRepository>(),
                authBloc: context.read<AuthBloc>()),
          ),
          BlocProvider<CallshomeCubit>(
              create: (context) => CallshomeCubit(
                    callRepository: context.read<CallRepository>(),
                    userrRepository: context.read<UserrRepository>(),
                    authBloc: context.read<AuthBloc>(),
                  )),
          BlocProvider<BuildchurchCubit>(
              create: (context) => BuildchurchCubit(
                  callRepository: context.read<CallRepository>(),
                  churchRepository: context.read<ChurchRepository>(),
                  storageRepository: context.read<StorageRepository>(),
                  authBloc: context.read<AuthBloc>(),
                  userrRepository: context.read<UserrRepository>())),
          BlocProvider<FeedBloc>(
            create: (context) => FeedBloc(
                postsRepository: context.read<PostsRepository>(),
                authBloc: context.read<AuthBloc>(),
                likedPostCubit: context.read<LikedPostCubit>()),
          ),
          BlocProvider<CommuinityBloc>(
              create: (context) => CommuinityBloc(
                  callRepository: context.read<CallRepository>(),
                  churchRepository: context.read<ChurchRepository>(),
                  storageRepository: context.read<StorageRepository>(),
                  authBloc: context.read<AuthBloc>(),
                  userrRepository: context.read<UserrRepository>())),
           BlocProvider<ProfileBloc>(
             create: (context) => ProfileBloc(
                 userrRepository: context.read<UserrRepository>(),
                 authBloc: context.read<AuthBloc>(),
                 postRepository: context.read<PostsRepository>(),
                 likedPostCubit: context.read<LikedPostCubit>(),
                 churchRepository: context.read<ChurchRepository>()),
           ),
          // BlocProvider<CommentBloc>(
          //   create: (context) => CommentBloc(
          //     postsRepository: context.read<PostsRepository>(),
          //     authBloc:context.read<AuthBloc>()
          //   )),
          // BlocProvider<RingerBloc>(
          // create: (context) => RingerBloc(
          // authBloc: context.read<AuthBloc>())
          // )
        ],
        child: MaterialApp(
          //THEME DATA
          theme: ThemeData(
              brightness: Brightness.dark,
              appBarTheme: AppBarTheme(color: Colors.black),
              scaffoldBackgroundColor: Colors.black,
              primaryColorDark: Colors.red[300],
              textTheme: TextTheme(
                  bodyText1: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  bodyText2: TextStyle(fontSize: 15, color: Colors.grey[400]),
                  headline1: TextStyle(
                      fontSize: 25.0,
                      color: Colors.red[400],
                      fontWeight: FontWeight.bold),
                  headline2: TextStyle(
                      fontSize: 23.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              accentColor: Colors.white),
          debugShowCheckedModeBanner: false,
          title: 'KingsFam',
          onGenerateRoute: CustomRoute.onGenerateRoute,
          initialRoute: SplashScreen.routeName,
        ),
      ),
    );
  }
}
