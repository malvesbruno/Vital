import 'package:flutter/material.dart';
import '../app_data.dart';
import '../pages/MyHomePage.dart';
import '../pages/ActivityPage.dart';
import '../pages/WorkoutPage.dart';
import '../pages/StatsPage.dart';

import './services/challenge_service.dart';
import 'package:provider/provider.dart';
import 'themeNotifier.dart';
import '../services/reset_daily.dart';
import 'dart:async';
import '../pages/SplashScreen.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import '../services/navigation_service.dart';
import '../app_data_service.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';



void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await MobileAds.instance.initialize();
    tz.initializeTimeZones();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final themeName = AppData.currentTheme;
    final initialTheme = AppData.themes.firstWhere((t) => t.name == themeName);

    
    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(initialTheme),
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    print('Erro no main: $error');
  });
}




class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ChallengeService.inicializarDesafios();
    DailyResetService.verificarEDefinirNovoDia();
    ChallengeService.verificarDesafiosAutomaticos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Vital',
      theme: ThemeData(
        scaffoldBackgroundColor: theme.backgroundColor,
        primaryColor: theme.primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: theme.accentColor,
        ),
        
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: theme.textColor),
          bodyMedium: TextStyle(color: theme.secondaryColor),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: theme.backgroundColor,
          foregroundColor: theme.textColor,
        ),
        
        // você pode adicionar mais aqui com base no AppTheme
      ),
      home: const SplashScreen(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  void _handleActivityCompletion(String title) {
    setState(() {
      for (var activity in AppData.listaAtividades) {
        if (activity.title == title) {
          activity.completed = true; // Remove visualmente o card
          AppData.completedActivities++;
           AppData.ativoHoje = true;
        }
      }
      ChallengeService.verificarDesafiosAutomaticos();
      _updateProgressBar();
      AppDataService.salvarTudo();
    });
  }

  void _updateProgressBar() {
    final atividadesHoje = AppData.listaAtividades.where((el) => isHojeNaLista(el.dias));
    if (atividadesHoje.isEmpty){
      AppData.progress = 0;
    }

    final concluidas = atividadesHoje.where((el) => el.completed).length;
    AppData.progress = concluidas / atividadesHoje.length;

  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool isHojeNaLista(List<int> diasDaSemana) {
  int weekday = DateTime.now().weekday;
  return diasDaSemana.contains(weekday);
}

  @override
  Widget build(BuildContext context) {
    return Stack(
  children: [
    Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Deixa o scaffold transparente!
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          MyHomePage(),
          ActivityPage(lista: AppData.listaAtividades, progresso: AppData.progress, onComplete: _handleActivityCompletion),
          WorkoutPage(treinosDoDia: AppData.getExerciciosDoDia(), treino: AppData.getTreinosNome()),
          StatsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7), // Pode deixar semi-transparente se quiser
        selectedItemColor: Theme.of(context).textTheme.bodyLarge?.color,
        unselectedItemColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.4),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: "Atividades"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Treinos"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
        ],
      ),
    ),
  ],
);
  }
}
