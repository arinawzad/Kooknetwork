// lib/providers/task_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../config/api_config.dart';
import '../utils/token_storage.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Task> get tasks => [..._tasks];
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Calculate total rewards
  double get completedRewards {
    return _tasks
        .where((task) => task.isCompleted)
        .fold(0.0, (sum, task) => sum + task.reward);
  }
  
  double get pendingRewards {
    return _tasks
        .where((task) => !task.isCompleted)
        .fold(0.0, (sum, task) => sum + task.reward);
  }

  // Fetch tasks from API
  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/tasks'),
        headers: ApiConfig.getHeaders(token: token),
      );

      print('Task API response status: ${response.statusCode}');
      print('Task API response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final List<dynamic> taskList = responseData['data'];
          
          print('Received ${taskList.length} tasks from API');
          
          _tasks = taskList.map((taskJson) => Task.fromJson(taskJson)).toList();
          
          print('Parsed ${_tasks.length} tasks successfully');
          
          // Sort tasks: incomplete tasks first, then by due date
          _tasks.sort((a, b) {
            if (a.isCompleted != b.isCompleted) {
              return a.isCompleted ? 1 : -1;
            }
            return a.dueDate.compareTo(b.dueDate);
          });
        } else {
          print('API returned success but unexpected data format: $responseData');
          _tasks = [];
        }
      } else {
        throw Exception(response.body.isNotEmpty 
            ? json.decode(response.body)['message'] 
            : 'Failed to fetch tasks - Status code: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      print('Error fetching tasks: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Complete a task (for simple tasks)
  Future<bool> completeTask(int taskId) async {
    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/tasks/$taskId/complete'),
        headers: ApiConfig.getHeaders(token: token),
      );

      print('Complete task API response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success') {
          // Update local task status
          final index = _tasks.indexWhere((task) => task.id == taskId);
          if (index != -1) {
            _tasks[index] = _tasks[index].copyWith(isCompleted: true);
            notifyListeners();
          }
          return true;
        } else {
          return false;
        }
      } else {
        throw Exception(response.body.isNotEmpty 
            ? json.decode(response.body)['message'] 
            : 'Failed to complete task - Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error completing task: $e');
      return false;
    }
  }

  // Verify a task with code
  Future<bool> verifyTask(int taskId, String code) async {
    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/tasks/$taskId/verify'),
        headers: {
          ...ApiConfig.getHeaders(token: token),
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'verification_code': code,
        }),
      );

      print('Verify task API response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success') {
          // Update local task status
          final index = _tasks.indexWhere((task) => task.id == taskId);
          if (index != -1) {
            _tasks[index] = _tasks[index].copyWith(isCompleted: true);
            notifyListeners();
          }
          return true;
        } else {
          return false;
        }
      } else {
        throw Exception(response.body.isNotEmpty 
            ? json.decode(response.body)['message'] 
            : 'Failed to verify task - Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error verifying task: $e');
      return false;
    }
  }
}