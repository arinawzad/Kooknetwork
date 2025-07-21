import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/token_storage.dart';

class MiningProvider with ChangeNotifier {
  // Mining statistics
  Map<String, dynamic> _miningStatistics = {
    'balance': '0',
    'mining_rate': '0',
    'team_size': '0',
    'days_active': '0',
    'mining_status': {
      'current_status': 'idle',
      'session_start': null,
      'session_end': null,
      'can_start_mining': true,
      'current_session_earnings': '0.00'
    }
  };

  // Market prices
  List<Map<String, dynamic>> _marketPrices = [];

  // Timer for balance updates
  Timer? _balanceUpdateTimer;

  // Loading and error states
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic> get miningStatistics => _miningStatistics;
  List<Map<String, dynamic>> get marketPrices => _marketPrices;
  bool get isLoading => _isLoading;
  bool get isMining => _miningStatistics['mining_status']?['current_status'] == 'active';
  String? get error => _error;

  // Check mining status when app starts
  Future<void> checkMiningStatus() async {
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
        Uri.parse('${ApiConfig.baseUrl}/mining/status'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success') {
          // Update mining status in statistics
          _miningStatistics['mining_status'] = {
            'current_status': responseData['data']['mining_status'],
            'session_start': responseData['data']['session_start'],
            'session_end': responseData['data']['session_end'],
            'can_start_mining': responseData['data']['can_start_mining'],
            'current_session_earnings': responseData['data']['current_session_earnings'],
          };
          
          // Start balance updates if mining is active
          if (responseData['data']['mining_status'] == 'active') {
            startBalanceUpdates();
          }
        }
      } else {
        throw Exception(json.decode(response.body)['message'] ?? 'Failed to check mining status');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error checking mining status: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch mining statistics
  Future<void> fetchMiningStatistics() async {
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
        Uri.parse('${ApiConfig.baseUrl}/mining/statistics'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        _miningStatistics = {
          'balance': responseData['data']['balance']?.toString() ?? '0',
          'mining_rate': responseData['data']['mining_rate']?.toString() ?? '0',
          'team_size': responseData['data']['team_size']?.toString() ?? '0',
          'days_active': responseData['data']['days_active']?.toString() ?? '0',
          'mining_status': responseData['data']['mining_status'] ?? {
            'current_status': 'idle',
            'session_start': null,
            'session_end': null,
            'can_start_mining': true,
            'current_session_earnings': '0.00'
          }
        };
        
        // Check if mining is active and start balance updates
        if (_miningStatistics['mining_status']['current_status'] == 'active') {
          startBalanceUpdates();
        }
      } else {
        throw Exception(json.decode(response.body)['message'] ?? 'Failed to fetch mining statistics');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching mining statistics: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch market prices
  Future<void> fetchMarketPrices() async {
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
        Uri.parse('${ApiConfig.baseUrl}/market/prices'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        _marketPrices = (responseData['data'] as List).map((coin) => {
          'name': coin['name'],
          'symbol': coin['symbol'],
          'price': coin['price']?.toString() ?? '0',
          'change': coin['change']?.toString() ?? '0%',
          'isPositive': (coin['change'] ?? 0) >= 0,
        }).toList();
      } else {
        throw Exception(json.decode(response.body)['message'] ?? 'Failed to fetch market prices');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching market prices: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start mining method
  Future<void> startMining() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/mining/start'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Update mining status
        if (_miningStatistics.containsKey('mining_status')) {
          _miningStatistics['mining_status'] = {
            'current_status': responseData['data']['mining_status'],
            'session_start': responseData['data']['session_start'],
            'session_end': responseData['data']['session_end'],
            'can_start_mining': false,
            'current_session_earnings': '0.00'
          };
        }
        
        // Start periodic balance updates
        startBalanceUpdates();
      } else {
        throw Exception(json.decode(response.body)['message'] ?? 'Failed to start mining');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error starting mining: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Complete mining session - This is now an internal method
  // that shouldn't be directly called by the UI, but will be used
  // when a mining session naturally completes after 24 hours
  Future<void> _completeMining() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/mining/complete'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Stop balance updates
        _balanceUpdateTimer?.cancel();
        
        // Update mining status and balance
        _miningStatistics['balance'] = responseData['data']['total_balance'];
        _miningStatistics['days_active'] = responseData['data']['days_active'].toString();
        
        if (_miningStatistics.containsKey('mining_status')) {
          _miningStatistics['mining_status']['current_status'] = responseData['data']['mining_status'];
          _miningStatistics['mining_status']['can_start_mining'] = true;
          _miningStatistics['mining_status']['current_session_earnings'] = '0.00';
        }
      } else {
        throw Exception(json.decode(response.body)['message'] ?? 'Failed to complete mining');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error completing mining: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Start periodic balance updates during active mining
  void startBalanceUpdates() {
    // Cancel any existing timer
    _balanceUpdateTimer?.cancel();
    
    // Start a new timer for periodic updates
    _balanceUpdateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _updateRealTimeBalance();
    });
  }

  // Stop balance updates
  void stopBalanceUpdates() {
    _balanceUpdateTimer?.cancel();
    _balanceUpdateTimer = null;
  }

  // Get real-time balance during active mining
  Future<void> _updateRealTimeBalance() async {
    try {
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      if (token == null) {
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/mining/balance'),
        headers: ApiConfig.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success') {
          _miningStatistics['balance'] = responseData['data']['current_balance'];
          
          if (_miningStatistics.containsKey('mining_status')) {
            _miningStatistics['mining_status']['current_session_earnings'] = 
                responseData['data']['current_session_earnings'];
            
            // If mining stopped in backend, update UI
            if (responseData['data']['mining_status'] != 'active') {
              _miningStatistics['mining_status']['current_status'] = responseData['data']['mining_status'];
              _miningStatistics['mining_status']['can_start_mining'] = true;
              stopBalanceUpdates();
            }
          }
          
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating real-time balance: $e');
      // Don't stop the timer on error, just skip this update
    }
  }

  @override
  void dispose() {
    _balanceUpdateTimer?.cancel();
    super.dispose();
  }
}