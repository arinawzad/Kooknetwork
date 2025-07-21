// lib/tabs/team_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/community_provider.dart';
import '../localization/app_localizations.dart'; // Add this import

class TeamTab extends StatefulWidget {
  const TeamTab({super.key});

  @override
  State<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends State<TeamTab> {
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTeamData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);
      await teamProvider.fetchTeamMembers();
      
      // Also update community provider to keep team stats in sync
      final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
      await communityProvider.fetchTeamStats();
    } catch (error) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.translate('errorLoadingTeamData')}: $error'),
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

  @override
  Widget build(BuildContext context) {
    // Get current theme mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Get localization instance
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CommunityProvider>(
          builder: (context, communityProvider, _) => Text(
            communityProvider.teamStats['name'] ?? localizations.translate('myTeam'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: isDarkMode ? Colors.deepPurple : Colors.indigo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTeamData,
            tooltip: localizations.translate('refresh'),
          ),
        ],
      ),
      body: _isLoading 
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? Colors.purpleAccent : Colors.indigo,
                ),
              ),
            )
          : _buildTeamContent(isDarkMode, localizations),
    );
  }
  
  Widget _buildTeamContent(bool isDarkMode, AppLocalizations localizations) {
    // Define text colors based on theme
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.grey[600];
    
    return Consumer2<TeamProvider, CommunityProvider>(
      builder: (context, teamProvider, communityProvider, _) {
        if (teamProvider.teamMembers.isEmpty) {
          return _buildEmptyState(isDarkMode, localizations);
        }
        
        // Filter members based on search query
        final filteredMembers = _searchQuery.isEmpty 
            ? teamProvider.teamMembers 
            : teamProvider.teamMembers.where((member) => 
                member.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        
        return RefreshIndicator(
          onRefresh: _loadTeamData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team stats summary
                _buildTeamSummary(teamProvider, communityProvider, isDarkMode, localizations),
                
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: localizations.translate('searchTeamMembers'),
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode ? Colors.deepPurpleAccent : Colors.indigo,
                        ),
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    style: TextStyle(
                      color: primaryTextColor,
                    ),
                    cursorColor: isDarkMode ? Colors.deepPurpleAccent : Colors.indigo,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                
                // Team members section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        filteredMembers.length == teamProvider.teamMembers.length
                            ? '${localizations.translate('teamMembers')} (${filteredMembers.length})'
                            : '${localizations.translate('showing')} ${filteredMembers.length} ${localizations.translate('of')} ${teamProvider.teamMembers.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Member cards
                filteredMembers.isEmpty
                    ? _buildNoSearchResults(isDarkMode, localizations)
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = filteredMembers[index];
                          return _buildMemberCard(member, isDarkMode, localizations);
                        },
                      ),
                
                const SizedBox(height: 16),
                
                // Team bonus explanation
                _buildBonusExplanation(teamProvider, isDarkMode, localizations),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildNoSearchResults(bool isDarkMode, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('noMatchingMembers'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.translate('tryDifferentSearch'),
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(bool isDarkMode, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 60,
            color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate('noTeamMembersFound'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('teamEmpty'),
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadTeamData,
            icon: const Icon(Icons.refresh),
            label: Text(localizations.translate('refresh')),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.deepPurple : Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTeamSummary(TeamProvider teamProvider, CommunityProvider communityProvider, bool isDarkMode, AppLocalizations localizations) {
    final activeCount = teamProvider.activeMembers;
    final inactiveCount = teamProvider.inactiveMembers;
    final totalCount = teamProvider.teamMembers.length;
    
    // Calculate mining stats
    final miningBonus = (totalCount - 1) * 2; // 2% per member, excluding self
    final penalty = inactiveCount * 2;
    final netBonus = max(0, miningBonus - penalty);
    
    return Container(
      width: double.infinity,
      color: isDarkMode ? Colors.deepPurple : Colors.indigo,
      child: Column(
        children: [
          // Team stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Team stats counters
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCounter(localizations.translate('total'), totalCount, isDarkMode ? Colors.deepPurpleAccent : Colors.indigo, isDarkMode),
                    _buildStatCounter(localizations.translate('active'), activeCount, Colors.green, isDarkMode),
                    _buildStatCounter(localizations.translate('inactive'), inactiveCount, Colors.red, isDarkMode),
                  ],
                ),
                
                const SizedBox(height: 20),
                Divider(height: 1, color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                const SizedBox(height: 20),
                
                // Mining bonus info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.translate('teamBonus'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+$miningBonus%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.green[400] : Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            localizations.translate('inactivePenalty'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            inactiveCount > 0 ? '-$penalty%' : localizations.translate('none'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: inactiveCount > 0 
                                  ? (isDarkMode ? Colors.red[400] : Colors.red[700])
                                  : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            localizations.translate('netBonus'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+$netBonus%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: netBonus > 0 
                                  ? (isDarkMode ? Colors.blue[400] : Colors.blue[700])
                                  : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Available slots
                LinearProgressIndicator(
                  value: totalCount / 1000, // 1000 max team size
                  backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  color: isDarkMode ? Colors.deepPurpleAccent : Colors.indigo,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${communityProvider.teamStats['available'] ?? 1000-totalCount} ${localizations.translate('slotsAvailable')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCounter(String label, int count, Color color, bool isDarkMode) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDarkMode && color == Colors.indigo ? Colors.deepPurpleAccent : color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }
  
  Widget _buildMemberCard(TeamMember member, bool isDarkMode, AppLocalizations localizations) {
    final isCurrentUser = member.name.contains('(${localizations.translate('you')})');
    final isOwner = member.isOwner || member.name.contains(localizations.translate('teamOwner'));
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[850] : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isCurrentUser 
              ? Border.all(
                  color: isDarkMode ? Colors.deepPurpleAccent.withOpacity(0.5) : Colors.indigo.withOpacity(0.5), 
                  width: 2,
                ) 
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // User avatar
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOwner 
                            ? [Colors.amber.shade200, Colors.amber.shade400]
                            : isDarkMode
                                ? [Colors.deepPurple.shade300, Colors.deepPurple.shade500]
                                : [Colors.indigo.shade200, Colors.indigo.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        member.name.isNotEmpty 
                            ? member.name.split(' ')[0][0].toUpperCase() 
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  // Status indicator
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: member.isActive ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDarkMode ? Colors.grey[850]! : Colors.white, width: 2),
                      ),
                    ),
                  ),
                  // Owner crown
                  if (isOwner)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${localizations.translate('joined')} ${member.joinedAt}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    if (member.miningRate > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${localizations.translate('miningRate')}: ${member.miningRate.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Status and last active
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: member.isActive 
                          ? (isDarkMode ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.1))
                          : (isDarkMode ? Colors.red.withOpacity(0.2) : Colors.red.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      member.isActive ? localizations.translate('active') : localizations.translate('inactive'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: member.isActive 
                            ? (isDarkMode ? Colors.green[400] : Colors.green[700])
                            : (isDarkMode ? Colors.red[400] : Colors.red[700]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${localizations.translate('lastActive')}: ${member.lastActive ?? localizations.translate('unknown')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBonusExplanation(TeamProvider provider, bool isDarkMode, AppLocalizations localizations) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[850] : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline, 
                  color: isDarkMode ? Colors.deepPurpleAccent : Colors.indigo
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.translate('howTeamBonusesWork'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              localizations.translate('teamMemberBonus'),
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              localizations.translate('inactivePenaltyExplanation'),
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              localizations.translate('maximumTeamSize'),
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            provider.isTeamOwner 
                ? Text(
                    localizations.translate('keepTeamActive'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: isDarkMode ? Colors.deepPurpleAccent : Colors.indigo,
                    ),
                  )
                : Text(
                    localizations.translate('stayActive'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: isDarkMode ? Colors.deepPurpleAccent : Colors.indigo,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
  
  // Helper function to safely get max value
  int max(int a, int b) => a > b ? a : b;
}