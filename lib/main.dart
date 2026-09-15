import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cinemax_app/core/app_theme.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/presentation/pages/main_wrapper_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'api.env');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CinemaxApp());
}

class CinemaxApp extends StatelessWidget {
  final MovieCubit? cubit;

  const CinemaxApp({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => cubit ?? MovieCubit(),
      child: MaterialApp(
        title: 'Cinemax',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const MainWrapperScreen(),
      ),
    );
  }
}
