import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'providers/app_provider.dart';
import 'providers/tts_provider.dart';
import 'providers/sound_provider.dart';
import 'providers/auth_provider.dart';
import 'services/supabase_config.dart';
import 'services/connectivity_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Keep screen awake while app is in use
  WakelockPlus.enable();

  await initSupabase();
  runApp(const PhysicsGCSEApp());
}

class PhysicsGCSEApp extends StatelessWidget {
  const PhysicsGCSEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => TTSProvider()),
        ChangeNotifierProvider(create: (_) => SoundProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: MaterialApp(
        title: 'Physics GCSE',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const _ConnectivityGate(),
      ),
    );
  }
}

/// Blocks the entire app when there is no internet connection.
class _ConnectivityGate extends StatelessWidget {
  const _ConnectivityGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        if (!connectivity.isOnline) {
          return const _NoInternetScreen();
        }
        return const _AppEntry();
      },
    );
  }
}

/// Full-screen overlay shown when there is no internet.
class _NoInternetScreen extends StatelessWidget {
  const _NoInternetScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 80,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'No Internet Connection',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Physics GCSE requires an internet connection to work. Please check your connection and try again.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // ConnectivityService automatically detects reconnection,
                  // so this button is just for user reassurance.
                  // Force a rebuild by reading the provider.
                  context.read<ConnectivityService>();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _checkedFirstLaunch = false;
  bool _showLogin = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('has_launched') ?? false;

    if (!hasLaunched) {
      await prefs.setBool('has_launched', true);
      _showLogin = true;
    }

    if (!mounted) return;

    if (!_showLogin) {
      // Returning user — if logged in, trigger background sync
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) {
        context.read<AppProvider>().syncNow();
      }
    }

    setState(() => _checkedFirstLaunch = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedFirstLaunch) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _showLogin ? const LoginScreen() : const HomeScreen();
  }
}
