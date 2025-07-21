import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mining_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../localization/app_localizations.dart'; // Add this import

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Timer? _miningTimer;
  String _remainingTime = '';
  final NotificationService _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    // Initialize notification service
    _notificationService.init();
    
    // Fetch data when the tab is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final miningProvider = context.read<MiningProvider>();
      
      // Check mining status first
      miningProvider.checkMiningStatus().then((_) {
        // Then fetch complete statistics
        miningProvider.fetchMiningStatistics();
        
        // Start timer if mining is active
        _checkAndStartTimer(miningProvider);
      });
      
      // Fetch market prices
      miningProvider.fetchMarketPrices();
    });
  }

  @override
  void dispose() {
    _miningTimer?.cancel();
    super.dispose();
  }

  // Check if mining is active and start timer
  void _checkAndStartTimer(MiningProvider provider) {
    if (provider.isMining) {
      final sessionEnd = provider.miningStatistics['mining_status']?['session_end'];
      if (sessionEnd != null) {
        _startRemainingTimeTimer(sessionEnd);
      }
    }
  }

  // Calculate and display remaining time for mining session
  void _startRemainingTimeTimer(String endTimeStr) {
    try {
      final endTime = DateTime.parse(endTimeStr);
      
      // Schedule notification reminder 1 hour before mining ends
      _notificationService.scheduleMiningReminderNotification(endTime);
      
      _miningTimer?.cancel();
      _miningTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        final remaining = endTime.difference(now);
        
        if (remaining.isNegative) {
          setState(() {
            _remainingTime = 'Session ended';
          });
          timer.cancel();
          
          // Refresh mining statistics
          context.read<MiningProvider>().fetchMiningStatistics();
        } else {
          final hours = remaining.inHours;
          final minutes = remaining.inMinutes % 60;
          final seconds = remaining.inSeconds % 60;
          
          setState(() {
            _remainingTime = '${hours}h ${minutes}m ${seconds}s';
          });
        }
      });
    } catch (e) {
      debugPrint('Error parsing end time: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme mode
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Get localization instance
    final localizations = AppLocalizations.of(context);

    // Define color schemes based on theme
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtextColor = isDarkMode ? Colors.white70 : Colors.grey[600]!;
    final cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final shadowColor = isDarkMode 
        ? Colors.black.withOpacity(0.3) 
        : Colors.grey.withOpacity(0.2);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final user = authProvider.user;
                return Text(
                  '${localizations.translate('hello')}, ${user?.name ?? localizations.translate('miner')}!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              localizations.translate('miningDashboard'),
              style: TextStyle(
                fontSize: 16,
                color: subtextColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // Mining button or status section
            Consumer<MiningProvider>(
              builder: (context, miningProvider, _) {
                final isActive = miningProvider.isMining;
                final isLoading = miningProvider.isLoading;
                final miningStatus = miningProvider.miningStatistics['mining_status'];
                final currentEarnings = miningStatus?['current_session_earnings'] ?? '0.00';
                
                return Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode 
                        ? [Colors.indigo, Colors.deepPurple]
                        : [Colors.indigo, Colors.deepPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode 
                          ? Colors.black.withOpacity(0.5) 
                          : Colors.indigo.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isActive ? localizations.translate('miningInProgress') : localizations.translate('startMining'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isLoading) ...[
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ] else if (isActive) ...[
                        // Show mining information when active
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '${localizations.translate('earning')}: $currentEarnings KOOK',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${localizations.translate('timeRemaining')}: $_remainingTime',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.translate('miningDuration'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ] else ...[
                        // Show start mining button when inactive
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.power_settings_new, color: Colors.white, size: 40),
                            onPressed: () {
                              miningProvider.startMining().then((_) {
                                // Check status after starting mining
                                if (miningProvider.isMining) {
                                  final sessionEnd = miningProvider.miningStatistics['mining_status']?['session_end'];
                                  if (sessionEnd != null) {
                                    _startRemainingTimeTimer(sessionEnd);
                                  }
                                }
                              });
                            },
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localizations.translate('tapToEarn'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Mining Statistics
            Text(
              localizations.translate('miningStatistics'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<MiningProvider>(
              builder: (context, miningProvider, _) {
                final stats = miningProvider.miningStatistics;
                
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          localizations.translate('balance'),
                          stats['balance'] ?? '0',
                          'KOOK',
                          Icons.account_balance_wallet,
                          Colors.indigo,
                          cardColor,
                          textColor,
                          subtextColor,
                          shadowColor,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          context,
                          localizations.translate('miningRate'),
                          stats['mining_rate'] ?? '0',
                          'KOOK/hr',
                          Icons.speed,
                          Colors.deepPurple,
                          cardColor,
                          textColor,
                          subtextColor,
                          shadowColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          localizations.translate('teamSize'),
                          stats['team_size'] ?? '0',
                          localizations.translate('miners'),
                          Icons.group,
                          Colors.blue,
                          cardColor,
                          textColor,
                          subtextColor,
                          shadowColor,
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          context,
                          localizations.translate('daysActive'),
                          stats['days_active'] ?? '0',
                          localizations.translate('days'),
                          Icons.calendar_today,
                          Colors.teal,
                          cardColor,
                          textColor,
                          subtextColor,
                          shadowColor,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Market Prices
            Text(
              localizations.translate('marketPrices'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<MiningProvider>(
              builder: (context, miningProvider, _) {
                final marketPrices = miningProvider.marketPrices;
                
                if (marketPrices.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                return Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: marketPrices.map((coin) => 
                      Column(
                        children: [
                          _buildMarketListTile(
                            coin['name'],
                            coin['symbol'],
                            coin['price'],
                            coin['change'],
                            coin['isPositive'] ?? true,
                            textColor,
                            subtextColor,
                          ),
                          if (coin != marketPrices.last) 
                            Divider(
                              height: 1, 
                              color: isDarkMode ? Colors.white24 : Colors.grey[300],
                            ),
                        ],
                      )
                    ).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String unit,
    IconData icon,
    Color iconColor,
    Color cardColor,
    Color textColor,
    Color subtextColor,
    Color shadowColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontSize: 14,
                      color: subtextColor,
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
  
  Widget _buildMarketListTile(
    String name,
    String symbol,
    String price,
    String change,
    bool isPositive,
    Color textColor,
    Color subtextColor,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Colors.indigo.withOpacity(0.1),
        child: Text(
          symbol[0],
          style: const TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        symbol,
        style: TextStyle(
          color: subtextColor,
          fontSize: 12,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$price',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
          Text(
            change,
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}