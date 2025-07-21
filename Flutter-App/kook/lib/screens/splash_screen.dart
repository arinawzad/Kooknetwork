import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/auth_provider.dart';
import '../providers/version_provider.dart';
import '../services/app_version_service.dart';
import '../localization/app_localizations.dart';
import 'dart:math' as math;
import 'home_screen.dart';
import 'login_screen.dart';
import '../config/api_config.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _mainController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late AnimationController _waveController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  // Particle positions
  final List<Particle> _particles = [];
  final _random = math.Random();
  
  // Version check state
  bool _isVersionCheckComplete = false;
  bool _isAuthCheckComplete = false;
  
  // Internet connectivity status
  bool _isConnected = true;
  bool _isCheckingConnectivity = true;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  @override
  void initState() {
    super.initState();
    
    // Generate random particles for sparkle effect
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        position: Offset(
          _random.nextDouble() * 2 - 1, 
          _random.nextDouble() * 2 - 1
        ),
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
        size: _random.nextDouble() * 10 + 2,
        speed: _random.nextDouble() * 0.5 + 0.5,
      ));
    }
    
    // Main animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    // Rotation controller
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    
    // Pulsating effect controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Sparkle effect controller
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    // Wave animation for loading
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    // Setup animations
    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2).chain(
          CurveTween(curve: Curves.easeOutBack)
        ),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut)
        ),
        weight: 40,
      ),
    ]).animate(_mainController);
    
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOutCubic,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(_pulseController);
    
    // Start animations in sequence
    _rotateController.forward();
    _mainController.forward();
    
    // First check for internet connectivity
    _checkConnectivity();
    
    // Subscribe to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    _waveController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // Check for internet connectivity
  Future<void> _checkConnectivity() async {
    try {
      final ConnectivityResult result = await Connectivity().checkConnectivity();
      if (!mounted) return;
      
      await _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      setState(() {
        _isCheckingConnectivity = false;
        _isConnected = false;
      });
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final bool isConnected = result != ConnectivityResult.none;
    
    if (!mounted) return;
    
    setState(() {
      _isConnected = isConnected;
      _isCheckingConnectivity = false;
    });
    
    // Only proceed with version check if connected
    if (isConnected) {
      _checkAppVersion();
    }
  }

  // Check for app updates 
  Future<void> _checkAppVersion() async {
    try {
      await AppVersionService.initAppVersion(context);
    } catch (e) {
      debugPrint('Error checking app version: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isVersionCheckComplete = true;
        });
      }
      _checkAuth();
    }
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = await authProvider.checkAuth();
    
    if (!mounted) return;

    setState(() {
      _isAuthCheckComplete = true;
    });
    
    _navigateToNextScreen();
  }
  
  void _navigateToNextScreen() {
    // Only navigate when both checks are complete and we're connected
    if (_isVersionCheckComplete && _isAuthCheckComplete && _isConnected && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final versionProvider = Provider.of<VersionProvider>(context, listen: false);
      
      // Don't navigate if a forced update is needed
      if (versionProvider.forceUpdate) {
        return;
      }
      
      // Navigate to the appropriate screen based on authentication status
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => authProvider.isAuthenticated 
              ? const HomeScreen() 
              : const LoginScreen(),
        ),
      );
    }
  }

  // Try again when connection is restored
  void _retryConnection() async {
    setState(() {
      _isCheckingConnectivity = true;
    });
    await _checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    
    // Calculate sizes based on screen dimensions
    final logoSize = shortestSide * 0.25; // Logo takes 25% of shortest side
    final titleSize = shortestSide * 0.07; // Title font size
    final taglineSize = shortestSide * 0.035; // Tagline font size
    
    // Get localization instance
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3949AB), // Indigo
              const Color(0xFF5E35B1), // Deep Purple
              // Add a subtle animated shimmer effect with AnimatedBuilder
              Color.lerp(
                const Color(0xFF5E35B1),
                const Color(0xFF7B1FA2),
                _pulseController.value
              )!,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Particle effects in the background
            ...buildSparkles(size),
            
            // Main content column
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated App Logo/Icon with glowing effect
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow effect
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: logoSize * 1.5 * _pulseController.value,
                            height: logoSize * 1.5 * _pulseController.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      // Main icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: RotationTransition(
                          turns: _rotateAnimation,
                          child: Icon(
                            Icons.monetization_on,
                            size: logoSize,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: shortestSide * 0.06),
                  
                  // Animated App Name with slide effect
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        localizations.translate('appName'),
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 4,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: shortestSide * 0.02),
                  
                  // Animated Tagline with fade effect
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value - 1.0) * 0.1,
                          child: Text(
                            localizations.translate('appTagline'),
                            style: TextStyle(
                              fontSize: taglineSize,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: shortestSide * 0.06),
                  
                  // Version text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'v${ApiConfig.appVersion}',
                      style: TextStyle(
                        fontSize: taglineSize * 0.8,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  SizedBox(height: shortestSide * 0.06),
                  
                  // Internet connectivity status or wave loading
                  if (_isCheckingConnectivity)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                    )
                  else if (!_isConnected)
                    _buildNoConnectionMessage(context, shortestSide, localizations)
                  else
                    // Amazing wave loading animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: WaveLoadingIndicator(
                        size: Size(shortestSide * 0.4, shortestSide * 0.08),
                        controller: _waveController,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build no internet connection message and retry button
  Widget _buildNoConnectionMessage(
    BuildContext context, 
    double shortestSide, 
    AppLocalizations localizations
  ) {
    return Container(
      width: shortestSide * 0.8,
      padding: EdgeInsets.all(shortestSide * 0.05),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.signal_wifi_off,
            color: Colors.white,
            size: shortestSide * 0.1,
          ),
          SizedBox(height: shortestSide * 0.02),
          Text(
            localizations.translate('noInternetConnection'),
            style: TextStyle(
              color: Colors.white,
              fontSize: shortestSide * 0.05,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: shortestSide * 0.02),
          Text(
            localizations.translate('pleaseConnectInternet'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: shortestSide * 0.035,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: shortestSide * 0.04),
          ElevatedButton(
            onPressed: _retryConnection,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3949AB),
              padding: EdgeInsets.symmetric(
                horizontal: shortestSide * 0.1,
                vertical: shortestSide * 0.02,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child: Text(
              localizations.translate('retry'),
              style: TextStyle(
                fontSize: shortestSide * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build sparkle particles in the background
  List<Widget> buildSparkles(Size size) {
    return _particles.map((particle) {
      return AnimatedBuilder(
        animation: _sparkleController,
        builder: (context, child) {
          // Calculate current position with animation
          final progress = (_sparkleController.value + particle.speed) % 1.0;
          final scale = math.sin(progress * math.pi);
          
          // Get position based on the center of the screen
          final dx = particle.position.dx * size.width * 0.5;
          final dy = particle.position.dy * size.height * 0.5;
          
          return Positioned(
            left: size.width * 0.5 + dx - particle.size / 2,
            top: size.height * 0.5 + dy - particle.size / 2,
            child: Opacity(
              opacity: scale,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: particle.size,
                  height: particle.size,
                  decoration: BoxDecoration(
                    color: particle.color.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: particle.color.withOpacity(0.5),
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

// Particle class for sparkle effect
class Particle {
  final Offset position;
  final Color color;
  final double size;
  final double speed;
  
  Particle({
    required this.position,
    required this.color,
    required this.size,
    required this.speed,
  });
}

// Amazing wave loading animation
class WaveLoadingIndicator extends StatelessWidget {
  final Size size;
  final AnimationController controller;
  
  const WaveLoadingIndicator({
    super.key,
    required this.size,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size.height / 2),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(
                waveProgress: controller.value,
                waveColor: Colors.white.withOpacity(0.8),
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
              size: size,
            );
          },
        ),
      ),
    );
  }
}

// Wave painter for the loading animation
class WavePainter extends CustomPainter {
  final double waveProgress;
  final Color waveColor;
  final Color backgroundColor;
  
  WavePainter({
    required this.waveProgress,
    required this.waveColor,
    required this.backgroundColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );
    
    // Draw wave
    final wavePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Start at bottom left
    path.moveTo(0, size.height);
    
    // Define wave pattern
    for (var i = 0.0; i <= size.width; i++) {
      final waveHeight = size.height * 0.2;
      final dx = i;
      final dy = size.height - 
                (size.height * waveProgress) + 
                math.sin((i / size.width * 4 * math.pi) + (waveProgress * 10)) * waveHeight;
      path.lineTo(dx, dy);
    }
    
    // Complete the path
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, wavePaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}