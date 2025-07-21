import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/verification_dialog.dart';
import '../localization/app_localizations.dart'; // Add this import

class TaskTab extends StatefulWidget {
  const TaskTab({super.key});

  @override
  State<TaskTab> createState() => _TaskTabState();
}

class _TaskTabState extends State<TaskTab> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch tasks using the provider
      await Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    } catch (error) {
      // Get localization instance
      final localizations = AppLocalizations.of(context);
      
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.translate('errorLoadingTasks')}: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleTaskAction(Task task) async {
    // Get localization instance
    final localizations = AppLocalizations.of(context);
    
    // Task type determines the action
    switch (task.actionType) {
      case TaskActionType.url:
        // Launch URL (like Telegram join link)
        if (task.actionData != null) {
          try {
            final url = Uri.parse(task.actionData!);
            // Skip canLaunchUrl check to avoid the platform channel error
            await launchUrl(
              url, 
              mode: LaunchMode.externalApplication,
            ).then((success) {
              if (success) {
                // Show verification dialog after returning to app
                _showVerificationDialog(task);
              } else {
                _showErrorMessage('${localizations.translate('couldNotLaunch')} ${task.actionData}');
              }
            });
          } catch (e) {
            _showErrorMessage('${localizations.translate('errorLaunchingUrl')}: $e');
          }
        }
        break;
        
      case TaskActionType.video:
        // Launch video URL
        if (task.actionData != null) {
          try {
            final url = Uri.parse(task.actionData!);
            // Skip canLaunchUrl check to avoid the platform channel error
            await launchUrl(url).then((success) {
              if (success) {
                // Show verification dialog after returning to app
                _showVerificationDialog(task);
              } else {
                _showErrorMessage(localizations.translate('couldNotLaunchVideo'));
              }
            });
          } catch (e) {
            _showErrorMessage('${localizations.translate('errorLaunchingVideo')}: $e');
          }
        }
        break;
        
      case TaskActionType.inApp:
        // Handle in-app tasks directly
        _showVerificationDialog(task);
        break;
        
      case TaskActionType.simple:
        // Simple toggle task - mark as completed immediately
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        await taskProvider.completeTask(task.id);
        break;
        
      default:
        _showErrorMessage(localizations.translate('unknownTaskType'));
    }
  }

  void _showVerificationDialog(Task task) {
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => VerificationDialog(
        task: task,
        onVerify: (String code) async {
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          try {
            final success = await taskProvider.verifyTask(task.id, code);
            if (success) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.translate('taskCompletedSuccess')),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              _showErrorMessage(localizations.translate('invalidVerification'));
            }
          } catch (error) {
            _showErrorMessage('${localizations.translate('errorVerifying')}: $error');
          }
        },
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Get localization instance
    final localizations = AppLocalizations.of(context);
    
    // Define text colors based on theme
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.grey;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('miningTasks'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('completeTasksToEarn'),
            style: TextStyle(
              fontSize: 16,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Rewards summary
          Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              final completedRewards = taskProvider.completedRewards;
              final pendingRewards = taskProvider.pendingRewards;
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.indigo, Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.translate('completed'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${completedRewards.toStringAsFixed(1)} KOOK',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white30,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.translate('pending'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${pendingRewards.toStringAsFixed(1)} KOOK',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.translate('availableTasks'),
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
                onPressed: _loadTasks,
                tooltip: localizations.translate('refreshTasks'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? Colors.purpleAccent : Colors.indigo,
                      ),
                    ),
                  )
                : Consumer<TaskProvider>(
                    builder: (context, taskProvider, _) {
                      final tasks = taskProvider.tasks;
                      
                      if (tasks.isEmpty) {
                        return _buildEmptyState(isDarkMode, localizations);
                      }
                      
                      return RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              // Add background color for dark mode
                              color: isDarkMode ? Colors.grey[850] : null,
                              child: InkWell(
                                onTap: task.isCompleted 
                                    ? null 
                                    : () => _handleTaskAction(task),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Task status indicator
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: task.isCompleted
                                              ? Colors.green
                                              : (isDarkMode ? Colors.grey[700] : Colors.grey.withOpacity(0.2)),
                                        ),
                                        child: task.isCompleted
                                            ? const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Task content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    task.title,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      decoration: task.isCompleted
                                                          ? TextDecoration.lineThrough
                                                          : null,
                                                      color: task.isCompleted
                                                          ? (isDarkMode ? Colors.grey[400] : Colors.grey)
                                                          : primaryTextColor,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isDarkMode
                                                        ? Colors.indigo.withOpacity(0.3)
                                                        : Colors.indigo.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '+${task.reward.toStringAsFixed(1)} KOOK',
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.indigo[200] : Colors.indigo,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 14,
                                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${localizations.translate('due')}: ${_formatDate(task.dueDate)}',
                                                  style: TextStyle(
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                // Task type icon
                                                _buildTaskTypeIcon(task.actionType, isDarkMode),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _getTaskTypeLabel(task.actionType, localizations),
                                                  style: TextStyle(
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (task.description != null && task.description!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  task.description!,
                                                  style: TextStyle(
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Action indicator
                                      if (!task.isCompleted)
                                        Icon(
                                          Icons.chevron_right,
                                          color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTypeIcon(TaskActionType type, bool isDarkMode) {
    IconData icon;
    
    switch (type) {
      case TaskActionType.url:
        icon = Icons.link;
        break;
      case TaskActionType.video:
        icon = Icons.play_circle_outline;
        break;
      case TaskActionType.inApp:
        icon = Icons.apps;
        break;
      case TaskActionType.simple:
        icon = Icons.check_circle_outline;
        break;
      default:
        icon = Icons.task_alt;
    }
    
    return Icon(
      icon,
      size: 14,
      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
    );
  }

  String _getTaskTypeLabel(TaskActionType type, AppLocalizations localizations) {
    switch (type) {
      case TaskActionType.url:
        return localizations.translate('externalLink');
      case TaskActionType.video:
        return localizations.translate('watchVideo');
      case TaskActionType.inApp:
        return localizations.translate('inAppTask');
      case TaskActionType.simple:
        return localizations.translate('simpleTask');
      default:
        return localizations.translate('task');
    }
  }

  Widget _buildEmptyState(bool isDarkMode, AppLocalizations localizations) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.grey;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in,
            size: 64,
            color: isDarkMode ? Colors.indigo[200] : Colors.indigo[300],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate('noTasksAvailable'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('checkBackLater'),
            style: TextStyle(
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadTasks,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.deepPurple : Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(localizations.translate('refresh')),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}