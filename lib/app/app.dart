import 'package:e_learning/app/router/app_router.dart';
import 'package:e_learning/app/theme/app_theme.dart';
import 'package:e_learning/app/theme/theme_cubit.dart';
import 'package:e_learning/core/di/service_locator.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ELearningApp extends StatefulWidget {
  const ELearningApp({super.key});

  @override
  State<ELearningApp> createState() => _ELearningAppState();
}

class _ELearningAppState extends State<ELearningApp> {
  late final AuthCubit _authCubit;
  late final ThemeCubit _themeCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>()..bootstrap();
    _themeCubit = sl<ThemeCubit>();
    _appRouter = AppRouter(_authCubit);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Nova',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            //  darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: const Locale('en'),
            supportedLocales: const [Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              );
            },
            routerConfig: _appRouter.router,
          );
        },
      ),
    );
  }
}
