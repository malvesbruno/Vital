import 'package:flutter/material.dart';
import '../app_data.dart';
import '../pages/MyHomePage.dart';
import '../pages/ActivityPage.dart';
import '../pages/WorkoutPage.dart';
import '../pages/StatsPage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart' as fft;
import 'package:timezone/data/latest_all.dart' as tz;
import 'services/VerificarAgendamento.dart';
import 'services/Notication.dart';
import 'services/background_task_handler.dart';
import './services/challenge_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa os dados de fuso horário
  tz.initializeTimeZones();

  // Inicializa o plugin de notificações locais
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Inicializa o serviço de notificações e agendamento
  Future.delayed(Duration.zero, () async {
    final notificationService = NotificationService();
    await notificationService.init();
    
    await Verificaragendamento.verficarAgendamento();  // Corrigido o nome da função para "verificar"
  });

  // Carrega os dados do AppData antes de rodar o app
  await AppData.carregarDados();
  await AppData.verificarSePrecisaSalvarHoje();
  
  // Inicia o serviço de tarefas em segundo plano após a inicialização do App
  fft.FlutterForegroundTask.init(
    androidNotificationOptions: fft.AndroidNotificationOptions(
      channelId: 'vital_foreground',
      channelName: 'Vital Background',
      channelDescription: 'Executa tarefas periódicas em segundo plano.',
      channelImportance: fft.NotificationChannelImportance.MIN,
      priority: fft.NotificationPriority.MIN,
      iconData: const fft.NotificationIconData(
        resType: fft.ResourceType.mipmap,
        resPrefix: fft.ResourcePrefix.ic,
        name: 'launcher',
      ), 
      visibility: fft.NotificationVisibility.VISIBILITY_SECRET,
    ),
    iosNotificationOptions: const fft.IOSNotificationOptions(),
    foregroundTaskOptions: const fft.ForegroundTaskOptions(
      interval: 600000,
      isOnceEvent: false,
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
  await _startForegroundTask();
  await AppData.carregarDesafiosDoDia();

  // Executa o app
  runApp(const MyApp());
}

Future<void> _startForegroundTask() async {
  await fft.FlutterForegroundTask.startService(
    notificationTitle: 'Vital está rodando em segundo plano',
    notificationText: 'Monitorando suas atividades e treinos!',
    callback: startCallback,
  );
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
    ChallengeService.verificarDesafiosAutomaticos();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vital',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(13, 16, 16, 1),
        splashColor: const Color.fromARGB(255, 31, 31, 31),
        highlightColor: const Color.fromARGB(255, 86, 86, 86),
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
      _updateProgressBar();
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
        backgroundColor: const Color.fromRGBO(13, 16, 16, 1),
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: const Color.fromARGB(255, 120, 120, 120),
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
