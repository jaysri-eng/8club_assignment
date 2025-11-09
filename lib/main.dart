import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/experience_selection_screen.dart';
import 'blocs/experience/experience_bloc.dart';
import 'blocs/onboarding/onboarding_bloc.dart';
import 'repositories/experience_repository.dart';

Future<void> main() async{
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => ExperienceRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ExperienceBloc(
              repository: context.read<ExperienceRepository>(),
            )..add(LoadExperiences()),
          ),
          BlocProvider(
            create: (context) => OnboardingBloc(),
          ),
        ],
        child: MaterialApp(
          title: '8Club',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF0A0A0A),
            textTheme: GoogleFonts.spaceGroteskTextTheme(),
          ),
          home: const ExperienceSelectionScreen(),
        ),
      ),
    );
  }
}