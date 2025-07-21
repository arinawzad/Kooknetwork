import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
// Import app_links instead of uni_links
import 'package:app_links/app_links.dart';

import 'providers/auth_provider.dart';
import 'providers/mining_provider.dart';
import 'providers/task_provider.dart';
import 'providers/community_provider.dart';
import 'providers/team_provider.dart';
import 'providers/project_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/version_provider.dart';
import 'localization/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/Forgot_Screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations - this locks the orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // Comment out or remove these lines to completely disable landscape mode
    // DeviceOrientation.landscapeLeft,
    // DeviceOrientation.landscapeRight,
  ]);
  
  // Initialize theme and language providers
  final themeProvider = ThemeProvider();
  await themeProvider.loadThemeMode();
  
  final languageProvider = LanguageProvider();
  await languageProvider.loadLocale();

  runApp(MyApp(
    themeProvider: themeProvider,
    languageProvider: languageProvider,
  ));
}

class MyApp extends StatefulWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;
  
  const MyApp({
    super.key,
    required this.themeProvider,
    required this.languageProvider,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // No need to reinitialize as app_links maintains subscription
    }
  }

  // Initialize deep linking
  Future<void> _initDeepLinking() async {
    _appLinks = AppLinks();

    // Get the initial link that opened the app
    try {
      final appLink = await _appLinks.getInitialAppLink();
      if (appLink != null) {
        _handleDeepLink(appLink.toString());
      }
    } catch (e) {
      debugPrint('Error getting initial app link: $e');
    }

    // Listen for link changes while the app is open
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri.toString());
    }, onError: (error) {
      debugPrint('Error handling app link: $error');
    });
  }

  // Handle deep link logic
  void _handleDeepLink(String link) {
    // Password reset deep link format: kook://password-reset?email=user@example.com&token=xyz123
    if (link.startsWith('kook://password-reset')) {
      // Parse the URI to extract parameters
      final uri = Uri.parse(link);
      final email = uri.queryParameters['email'];
      final token = uri.queryParameters['token'];
      
      if (email != null && token != null && _navigatorKey.currentState != null) {
        // Navigate to password reset screen with parameters
        _navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => ForgotPasswordScreen(
              initialEmail: email,
              resetToken: token,
            ),
          ),
        );
      }
    }
    // You could also handle notification deep links here if needed
    else if (link.startsWith('kook://mining-reminder')) {
      // Handle navigation to mining screen when notification is tapped
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide theme and language providers
        ChangeNotifierProvider.value(value: widget.themeProvider),
        ChangeNotifierProvider.value(value: widget.languageProvider),
        
        // Add version provider
        ChangeNotifierProvider(create: (_) => VersionProvider()),
        
        // Original providers
        ChangeNotifierProvider(create: (context) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MiningProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          // Get current locale
          final currentLocale = languageProvider.locale;
          
          return MaterialApp(
            title: 'Kook',
            debugShowCheckedModeBanner: false,
            
            // Add navigator key for deep linking navigation
            navigatorKey: _navigatorKey,
            
            // Set the theme mode based on user preference
            themeMode: themeProvider.themeMode,
            
            // Define light theme
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            // Define dark theme
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepOrange,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[900],
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              cardColor: Colors.grey[1],
              scaffoldBackgroundColor: Colors.black,
            ),
            
            // Set the locale based on user preference
            locale: currentLocale,
            
            // Define supported locales
            supportedLocales: AppLocalizations.supportedLocales,
            
            // Set up localization delegates
            localizationsDelegates: const [
              AppLocalizations.delegate, // Our custom delegate for app-specific translations
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}