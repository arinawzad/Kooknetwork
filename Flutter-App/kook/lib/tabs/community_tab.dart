// lib/tabs/community_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/community_provider.dart';
import '../models/community_post.dart';
import '../tabs/team_tab.dart'; // Import the team tab
import '../localization/app_localizations.dart'; // Add this import

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadCommunityData();
  }
  
  Future<void> _loadCommunityData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
      await communityProvider.fetchTeamStats();
      await communityProvider.fetchGlobalStats();
      await communityProvider.fetchCommunityPosts();
      await communityProvider.fetchCommunityChannels();
    } catch (error) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.translate('errorLoadingCommunityData')}: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _openChannel(CommunityChannel channel) async {
    final localizations = AppLocalizations.of(context);
    
    try {
      final url = Uri.parse(channel.url);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${localizations.translate('couldNotOpen')} ${channel.title}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.translate('errorOpeningLink')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigate to the team tab
  void _navigateToTeamTab() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TeamTab()),
    );
  }

  void _inviteFriends() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);
    
    try {
      final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
      final inviteCode = await communityProvider.generateInviteCode();
      
      if (mounted) {
        // Show share dialog with the invite code
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localizations.translate('inviteFriends')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizations.translate('shareCodeToJoin'),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.indigo.withOpacity(0.3) 
                        : Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          inviteCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.indigo),
                        onPressed: () {
                          // Copy to clipboard functionality
                          Clipboard.setData(ClipboardData(text: inviteCode));
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localizations.translate('inviteCodeCopied')),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        tooltip: localizations.translate('copyToClipboard'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12, 
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[800]
                          ),
                          children: [
                            const TextSpan(
                              text: '• ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: localizations.translate('eachReferralGives'),
                            ),
                            TextSpan(
                              text: localizations.translate('miningBonusPercent'),
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12, 
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[800]
                          ),
                          children: [
                            const TextSpan(
                              text: '• ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: localizations.translate('inactiveMembersCause'),
                            ),
                            TextSpan(
                              text: localizations.translate('penaltyPercent'),
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: localizations.translate('each'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12, 
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[800]
                          ),
                          children: [
                            const TextSpan(
                              text: '• ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: '${localizations.translate('teamLimit')}: ',
                            ),
                            TextSpan(
                              text: localizations.translate('thousandMembers'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.translate('close')),
              ),
              ElevatedButton(
                onPressed: () {
                  // Share functionality (here we just simulate it)
                  Clipboard.setData(ClipboardData(text: 
                    inviteCode
                  ));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.translate('inviteMessageCopied')),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                ),
                child: Text(localizations.translate('share')),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.translate('errorGeneratingInviteCode')}: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Get localization instance
    final localizations = AppLocalizations.of(context);
    
    // Define text colors based on theme
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.grey[700];
    
    return RefreshIndicator(
      onRefresh: _loadCommunityData,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading 
              ? _buildLoadingState(isDarkMode, localizations) 
              : Consumer<CommunityProvider>(
                  builder: (context, communityProvider, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('miningCommunity'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${localizations.translate('team')}: ${communityProvider.teamStats['name']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Mining team stats - Now clickable to navigate to Team tab
                      GestureDetector(
                        onTap: _navigateToTeamTab, // Navigate when tapped
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.people,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    localizations.translate('yourMiningTeam'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildTeamStat(localizations.translate('members'), communityProvider.teamStats['members']?.toString() ?? '0', localizations),
                                  _buildTeamStat(localizations.translate('active'), communityProvider.teamStats['active']?.toString() ?? '0', localizations),
                                  _buildTeamStat(localizations.translate('inactive'), communityProvider.teamStats['inactive']?.toString() ?? '0', localizations),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Mining bonus and penalty section
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade800,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${localizations.translate('referralBonus')}:',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${communityProvider.teamStats['rate']}',
                                          style: TextStyle(
                                            color: Colors.green[200],
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${localizations.translate('inactivePenalty')}:',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          communityProvider.teamStats['penalty'] == "null" 
                                              ? localizations.translate('none') 
                                              : '${communityProvider.teamStats['penalty']}',
                                          style: TextStyle(
                                            color: communityProvider.teamStats['penalty'] == "null" 
                                                ? Colors.grey[400] 
                                                : Colors.red[200],
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(color: Colors.white24, height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${localizations.translate('netMiningBonus')}:',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          communityProvider.teamStats['rate'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${communityProvider.teamStats['available']} ${localizations.translate('slotsAvailable')}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _inviteFriends,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.indigo,
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Text(localizations.translate('inviteFriends')),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Global mining stats
                      Text(
                        localizations.translate('globalNetworkStats'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[850] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode 
                                  ? Colors.black.withOpacity(0.2) 
                                  : Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildGlobalStat(
                              localizations.translate('activeMiners'),
                              communityProvider.globalStats['activeMiners']?.toString() ?? '0',
                              Icons.group,
                              communityProvider.globalStats['activeMinersDelta'] ?? '+0',
                              isDarkMode,
                            ),
                            Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                            _buildGlobalStat(
                              localizations.translate('networkHashrate'),
                              communityProvider.globalStats['hashrate'] ?? '0 H/s',
                              Icons.speed,
                              communityProvider.globalStats['hashrateDelta'] ?? '+0%',
                              isDarkMode,
                            ),
                            Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                            _buildGlobalStat(
                              localizations.translate('totalCoinSupply'),
                              communityProvider.globalStats['totalSupply'] ?? '0 KOOK',
                              Icons.bubble_chart,
                              communityProvider.globalStats['supplyPercentage'] ?? '0%',
                              isDarkMode,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Community updates
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localizations.translate('communityUpdates'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: primaryTextColor,
                            ),
                            onPressed: () async {
                              await communityProvider.fetchCommunityPosts();
                            },
                            tooltip: localizations.translate('refreshPosts'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // List of community announcements/posts
                      communityProvider.posts.isEmpty
                          ? _buildEmptyPostsState(isDarkMode, localizations)
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: communityProvider.posts.length,
                              itemBuilder: (context, index) {
                                final post = communityProvider.posts[index];
                                return _buildSimpleCommunityPost(post: post, isDarkMode: isDarkMode, localizations: localizations);
                              },
                            ),
                      
                      const SizedBox(height: 24),
                      
                      // Community channels
                      Text(
                        localizations.translate('joinOfficialChannels'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Channels list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: communityProvider.channels.length,
                        itemBuilder: (context, index) {
                          final channel = communityProvider.channels[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildChannelButton(
                              channel: channel,
                              onTap: () => _openChannel(channel),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingState(bool isDarkMode, AppLocalizations localizations) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? Colors.purpleAccent : Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('loadingCommunityData'),
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyPostsState(bool isDarkMode, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 48,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate('noCommunityPosts'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('checkBackForUpdates'),
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTeamStat(String label, String value, AppLocalizations localizations) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGlobalStat(
    String title,
    String value,
    IconData icon,
    String subtitle,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.indigo.withOpacity(0.3)
                  : Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.indigo[200] : Colors.indigo,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: isDarkMode ? Colors.green[400] : Colors.green[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  // Simplified community post without like, comment, share buttons
  Widget _buildSimpleCommunityPost({
    required CommunityPost post,
    required bool isDarkMode,
    required AppLocalizations localizations,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[850] : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header with user info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: post.isOfficial ? Colors.indigo : Colors.indigo[200],
                  backgroundImage: post.userAvatar != null ? NetworkImage(post.userAvatar!) : null,
                  child: post.userAvatar == null
                      ? Icon(
                          post.isOfficial ? Icons.verified : Icons.person,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (post.isOfficial)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.blue[900] : Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              localizations.translate('official'),
                              style: TextStyle(
                                color: isDarkMode ? Colors.blue[200] : Colors.blue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      post.timeAgo,
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Post content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                post.content,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[300] : Colors.black87,
                ),
              ),
            ),
            
          // Image if available
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.indigo[900] : Colors.indigo[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: isDarkMode ? Colors.indigo[200] : Colors.indigo[300],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
  
 
  Widget _buildChannelButton({
    required CommunityChannel channel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: getColorForChannelType(channel.type),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              getIconForChannelType(channel.type),
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  channel.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  channel.subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper functions for channel type mapping
  IconData getIconForChannelType(ChannelType type) {
    switch (type) {
      case ChannelType.telegram:
        return Icons.telegram;
      case ChannelType.discord:
        return Icons.discord;
      case ChannelType.reddit:
        return Icons.reddit;
      case ChannelType.twitter:
        return Icons.send;
      case ChannelType.facebook:
        return Icons.facebook;
      case ChannelType.youtube:
        return Icons.play_circle;
      case ChannelType.medium:
        return Icons.article;
      case ChannelType.github:
        return Icons.code;
      default:
        return Icons.link;
    }
  }

  Color getColorForChannelType(ChannelType type) {
    switch (type) {
      case ChannelType.telegram:
        return const Color(0xFF0088CC);
      case ChannelType.discord:
        return const Color(0xFF5865F2);
      case ChannelType.reddit:
        return const Color(0xFFFF4500);
      case ChannelType.twitter:
        return const Color(0xFF1DA1F2);
      case ChannelType.facebook:
        return const Color(0xFF1877F2);
      case ChannelType.youtube:
        return const Color(0xFFFF0000);
      case ChannelType.medium:
        return Colors.black;
      case ChannelType.github:
        return const Color(0xFF333333);
      default:
        return Colors.indigo;
    }
  }
}