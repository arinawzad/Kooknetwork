import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/loading_widget.dart';
import '../localization/app_localizations.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import '../tabs/home_tab.dart';
import '../tabs/task_tab.dart';
import '../tabs/community_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/notification_permission_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  
  // Animation controllers
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late List<Animation<double>> _tabAnimations;
  
  // Only allow swiping between these tab indices
  final List<int> _swipeableTabs = [0, 1, 2]; // Home, Tasks, Community
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Create animations for each tab
    _tabAnimations = List.generate(
      4, // Number of tabs
      (index) => Tween<double>(
        begin: index == 0 ? 1.0 : 0.7,
        end: index == 0 ? 1.0 : 0.7,
      ).animate(CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      )),
    );
    
    _fadeController.forward();
    _scaleController.forward();
    
    // Request notification permissions
    _requestNotificationPermissions();
  }
  
  // Request notification permissions when the home screen loads
  Future<void> _requestNotificationPermissions() async {
    // Check if we've already asked for permission
    final prefs = await SharedPreferences.getInstance();
    final hasAskedBefore = prefs.getBool('notification_permission_asked') ?? false;
    
    if (hasAskedBefore) {
      // We've asked before, no need to show dialog again
      return;
    }
    
    // Wait a moment for the home screen to fully build
    Future.delayed(const Duration(seconds: 1), () {
      // Show our custom permission dialog
      showDialog(
        context: context,
        builder: (ctx) => NotificationPermissionDialog(
          onPermissionResult: (bool granted) async {
            // Save that we've asked
            await prefs.setBool('notification_permission_asked', true);
            
            // Could handle the result here if needed
            if (granted) {
              // User granted permission, could show a thank you toast or do something
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).translate('notificationPermissionGranted') ?? 
                    'Notifications enabled successfully!',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      );
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  void _onItemTapped(int index) {
    // Navigate to profile screen directly
    if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
      return;
    }
    
    // Update animations
    for (int i = 0; i < _tabAnimations.length; i++) {
      _tabAnimations[i] = Tween<double>(
        begin: _tabAnimations[i].value,
        end: i == index ? 1.0 : 0.7,
      ).animate(CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      ));
    }
    
    // Play animations
    _fadeController.reset();
    _scaleController.reset();
    _fadeController.forward();
    _scaleController.forward();
    
    setState(() {
      _selectedIndex = index;
      // Animate to the selected page
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int page) {
    // Only update if this is a swipeable tab
    if (_swipeableTabs.contains(page)) {
      setState(() {
        _selectedIndex = page;
        
        // Update animations
        for (int i = 0; i < _tabAnimations.length; i++) {
          _tabAnimations[i] = Tween<double>(
            begin: _tabAnimations[i].value,
            end: i == page ? 1.0 : 0.7,
          ).animate(CurvedAnimation(
            parent: _scaleController,
            curve: Curves.easeOutBack,
          ));
        }
        
        // Play animations
        _fadeController.reset();
        _scaleController.reset();
        _fadeController.forward();
        _scaleController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    // Get localization instance
    final localizations = AppLocalizations.of(context);
    
    // Handle RTL for Arabic
    final isRtl = localizations.locale.languageCode == 'ar' || localizations.locale.languageCode == 'fa';

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        
        if (user == null) {
          return Directionality(
            // Add Directionality widget to properly handle RTL
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
        return Directionality(
          // Add Directionality widget to properly handle RTL
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: Scaffold(
              appBar: _buildAnimatedAppBar(user.name, localizations),
              body: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                // Only include the first 3 tabs in PageView (excluding Profile)
                children: const [
                  HomeTabWrapper(),
                  TaskTabWrapper(),
                  CommunityTabWrapper(),
                ],
              ),
              bottomNavigationBar: _buildAnimatedBottomNavBar(isDarkMode, localizations),
            ),
          ),
        );
      },
    );
  }
  
  PreferredSizeWidget _buildAnimatedAppBar(String userName, AppLocalizations localizations) {
    // Get theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // App bar titles based on selected tab
    final List<String> titles = [
      localizations.translate('appName'),
      localizations.translate('tasks'),
      localizations.translate('community'),
      localizations.translate('profile')
    ];
    
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode 
              ? [Colors.indigo, Colors.deepPurple]
              : [Colors.indigo, Colors.deepPurple],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Animated title
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    titles[_selectedIndex],
                    key: ValueKey<String>(titles[_selectedIndex]),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Profile avatar
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'profileAvatar',
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white, 
                          width: 1.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAnimatedBottomNavBar(bool isDarkMode, AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.3) 
              : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAnimatedNavItem(0, Icons.home_outlined, Icons.home, localizations.translate('home'), isDarkMode),
              _buildAnimatedNavItem(1, Icons.assignment_outlined, Icons.assignment, localizations.translate('tasks'), isDarkMode),
              _buildAnimatedNavItem(2, Icons.people_outline, Icons.people, localizations.translate('community'), isDarkMode),
              _buildAnimatedNavItem(3, Icons.person_outline, Icons.person, localizations.translate('profile'), isDarkMode),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAnimatedNavItem(
    int index, 
    IconData icon, 
    IconData activeIcon, 
    String label, 
    bool isDarkMode
  ) {
    final isSelected = _selectedIndex == index;
    
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _tabAnimations[index].value,
          child: InkWell(
            onTap: () => _onItemTapped(index),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                  ? (isDarkMode 
                      ? Colors.indigo.withOpacity(0.2) 
                      : Colors.indigo.withOpacity(0.1)) 
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected 
                      ? (isDarkMode ? Colors.white : Colors.indigo) 
                      : (isDarkMode ? Colors.grey[400] : Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected 
                        ? (isDarkMode ? Colors.white : Colors.indigo) 
                        : (isDarkMode ? Colors.grey[400] : Colors.grey),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 3,
                    width: isSelected ? 20 : 0,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white : Colors.indigo,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Wrapper classes remain the same as in the previous implementation
class HomeTabWrapper extends StatefulWidget {
  const HomeTabWrapper({super.key});

  @override
  State<HomeTabWrapper> createState() => _HomeTabWrapperState();
}

class _HomeTabWrapperState extends State<HomeTabWrapper> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const HomeTab();
  }
}

class TaskTabWrapper extends StatefulWidget {
  const TaskTabWrapper({super.key});

  @override
  State<TaskTabWrapper> createState() => _TaskTabWrapperState();
}

class _TaskTabWrapperState extends State<TaskTabWrapper> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const TaskTab();
  }
}

class CommunityTabWrapper extends StatefulWidget {
  const CommunityTabWrapper({super.key});

  @override
  State<CommunityTabWrapper> createState() => _CommunityTabWrapperState();
}

class _CommunityTabWrapperState extends State<CommunityTabWrapper> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const CommunityTab();
  }
}