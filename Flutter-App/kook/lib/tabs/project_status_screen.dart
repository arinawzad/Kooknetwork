import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';
import '../widgets/loading_widget.dart';
import '../localization/app_localizations.dart'; // Add this import

class ProjectStatusScreen extends StatefulWidget {
  const ProjectStatusScreen({super.key});

  @override
  State<ProjectStatusScreen> createState() => _ProjectStatusScreenState();
}

class _ProjectStatusScreenState extends State<ProjectStatusScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch projects when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Get localization instance
    final localizations = AppLocalizations.of(context);
    
    // Define text colors based on theme
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('projectRoadmap')),
        backgroundColor: isDarkMode ? Colors.deepPurple : Colors.indigo,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
            },
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          // Show loading while fetching data
          if (projectProvider.isLoading) {
            return LoadingOverlay(
              isLoading: true,
              backgroundColor: isDarkMode ? Colors.black54 : Colors.black38,
              spinnerColor: Colors.white,
              child: Center(
                child: Text(
                  localizations.translate('loadingProjects'),
                  style: TextStyle(color: primaryTextColor),
                ),
              ),
            );
          }
          
          // Get active and upcoming projects
          final activeProjects = projectProvider.activeProjects;
          final upcomingProjects = projectProvider.upcomingProjects;
          
          return RefreshIndicator(
            onRefresh: () => projectProvider.fetchProjects(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Summary 
                  _buildSummaryCards(activeProjects, upcomingProjects, localizations),
                  const SizedBox(height: 24),
                  
                  // Error message if any
                  if (projectProvider.errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDarkMode ? Colors.red.shade700 : Colors.red.shade200)
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              projectProvider.errorMessage!,
                              style: TextStyle(
                                color: isDarkMode ? Colors.red.shade300 : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Active Projects
                  if (activeProjects.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.translate('currentDevelopment'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        if (activeProjects.length > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? Colors.indigo.withOpacity(0.3)
                                  : Colors.indigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDarkMode 
                                    ? Colors.indigo.withOpacity(0.7)
                                    : Colors.indigo.withOpacity(0.5)
                              ),
                            ),
                            child: Text(
                              '${activeProjects.length} ${localizations.translate('projects')}',
                              style: TextStyle(
                                color: isDarkMode ? Colors.indigo.shade200 : Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // List of active projects
                    ...activeProjects.map((project) => _buildActiveProjectCard(project, isDarkMode, localizations)),
                    const SizedBox(height: 24),
                  ],
                  
                  // Upcoming Projects
                  if (upcomingProjects.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations.translate('comingSoon'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.deepPurple.withOpacity(0.3)
                                : Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDarkMode 
                                  ? Colors.deepPurple.withOpacity(0.7)
                                  : Colors.deepPurple.withOpacity(0.5)
                            ),
                          ),
                          child: Text(
                            '${upcomingProjects.length} ${localizations.translate('planned')}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.deepPurple.shade200 : Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // List of upcoming projects
                    ...upcomingProjects.map((project) => _buildUpcomingProjectCard(project, isDarkMode, localizations)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(List<Project> activeProjects, List<Project> upcomingProjects, AppLocalizations localizations) {
    // Calculate total progress of active projects
    double totalProgress = 0;
    if (activeProjects.isNotEmpty) {
      totalProgress = activeProjects.fold(0.0, (double sum, project) => sum + project.progress) / activeProjects.length;
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('developmentStatus'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                '${activeProjects.length}',
                localizations.translate('activeProjects'),
                Icons.rocket_launch,
              ),
              _buildSummaryItem(
                '${(totalProgress * 100).toInt()}%',
                localizations.translate('currentProgress'),
                Icons.trending_up,
              ),
              _buildSummaryItem(
                '${upcomingProjects.length}',
                localizations.translate('upcomingProjects'),
                Icons.update,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String count, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveProjectCard(Project project, bool isDarkMode, AppLocalizations localizations) {
    // Status color based on project status
    Color statusColor;
    String localizedStatus = _getLocalizedStatus(project.status, localizations);
    
    switch (project.status) {
      case 'Completed':
        statusColor = isDarkMode ? Colors.green.shade400 : Colors.green;
        break;
      case 'In Progress':
        statusColor = isDarkMode ? Colors.blue.shade300 : Colors.blue;
        break;
      case 'Planning':
        statusColor = isDarkMode ? Colors.amber.shade300 : Colors.amber;
        break;
      case 'On Hold':
        statusColor = isDarkMode ? Colors.orange.shade300 : Colors.orange;
        break;
      default:
        statusColor = isDarkMode ? Colors.grey.shade400 : Colors.grey;
    }
    
    // Priority color
    Color priorityColor;
    String localizedPriority = _getLocalizedPriority(project.priority, localizations);
    
    switch (project.priority) {
      case 'High':
        priorityColor = isDarkMode ? Colors.red.shade300 : Colors.red;
        break;
      case 'Medium':
        priorityColor = isDarkMode ? Colors.orange.shade300 : Colors.orange;
        break;
      case 'Low':
        priorityColor = isDarkMode ? Colors.green.shade300 : Colors.green;
        break;
      default:
        priorityColor = isDarkMode ? Colors.grey.shade400 : Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(isDarkMode ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    localizedStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: project.progress,
                backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(project.progress * 100).toInt()}% ${localizations.translate('complete')}',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            
            // Project details in rows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (project.dueDate != null)
                  _buildDetailItem(localizations.translate('dueDate'), _formatDate(project.dueDate!), Icons.calendar_today, isDarkMode: isDarkMode)
                else
                  const SizedBox.shrink(),
                  
                if (project.tasks != null && project.completedTasks != null)
                  _buildDetailItem(localizations.translate('tasks'), '${project.completedTasks}/${project.tasks}', Icons.check_box, isDarkMode: isDarkMode)
                else
                  const SizedBox.shrink(),
                  
                _buildDetailItem(
                  localizations.translate('priority'), 
                  localizedPriority, 
                  Icons.flag,
                  valueColor: priorityColor,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
            
            // Team members if available
            if (project.team != null && project.team!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.people, 
                    size: 16, 
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${localizations.translate('team')}: ',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      project.team!.join(', '),
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingProjectCard(Project project, bool isDarkMode, AppLocalizations localizations) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.deepPurple.withOpacity(0.3)
                  : Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_empty,
              color: isDarkMode ? Colors.deepPurple.shade200 : Colors.deepPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  localizations.translate('comingSoon'),
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.grey.shade800.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  localizations.translate('planned'),
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, {Color? valueColor, required bool isDarkMode}) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final iconColor = isDarkMode ? Colors.grey[400] : Colors.grey;
    
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? textColor,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
  
  // Helper method to translate project status
  String _getLocalizedStatus(String status, AppLocalizations localizations) {
    switch (status) {
      case 'Completed':
        return localizations.translate('completed');
      case 'In Progress':
        return localizations.translate('inProgress');
      case 'Planning':
        return localizations.translate('planning');
      case 'On Hold':
        return localizations.translate('onHold');
      default:
        return status;
    }
  }
  
  // Helper method to translate priority
  String _getLocalizedPriority(String priority, AppLocalizations localizations) {
    switch (priority) {
      case 'High':
        return localizations.translate('high');
      case 'Medium':
        return localizations.translate('medium');
      case 'Low':
        return localizations.translate('low');
      default:
        return priority;
    }
  }
}