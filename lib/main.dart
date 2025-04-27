import 'package:flutter/material.dart';
import '../app_data.dart';
import '../pages/MyHomePage.dart';
import '../pages/ActivityPage.dart';
import '../pages/WorkoutPage.dart';
import '../pages/StatsPage.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart' as fft;
import 'package:timezone/data/latest_all.dart' as tz;
import 'services/VerificarAgendamento.dart';
import 'services/Notication.dart';
import 'services/background_task_handler.dart';
import './services/challenge_service.dart';
import 'package:provider/provider.dart';
import 'themeNotifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/reset_daily.dart';
import 'dart:async';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    tz.initializeTimeZones();

    final notificationService = NotificationService();
    await notificationService.init();

    await Verificaragendamento.verficarAgendamento();
    await AppData.carregarDados();
    await AppData.verificarSePrecisaSalvarHoje();

    await AppData.carregarDesafiosDoDia();
    await AppData.loadOwnedAvatars();
    await AppData.loadOwnedColors();

    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('currentTheme') ?? AppData.themes.first.name;
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



void startCallback() {
  fft.FlutterForegroundTask.setTaskHandler(MyTaskHandler());
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
      home: const MainPage(),
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
        }
      }
      ChallengeService.verificarDesafiosAutomaticos();
      _updateProgressBar();
      AppData.salvarDados();
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
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MyHomePage(),
              ActivityPage(lista: AppData.listaAtividades, progresso: AppData.progress, onComplete: _handleActivityCompletion),
              WorkoutPage(treinosDoDia: AppData.getExerciciosDoDia(), treino: AppData.getTreinosNome()),
              StatsPage(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).textTheme.bodyLarge?.color,
        unselectedItemColor: Theme.of(context).textTheme.bodyLarge?.color?.withValues(red: 0.4, blue: 0.4, green: 0.4),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: "Atividades"),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: "Treinos"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
        ],
      ),
    );
  }
}
