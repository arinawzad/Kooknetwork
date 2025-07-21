<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use App\Models\User;
use App\Models\Team;

class MiningController extends Controller
{
    /**
     * Get mining status for the authenticated user
     * 
     * @return \Illuminate\Http\JsonResponse
     */
    public function getMiningStatus()
    {
        try {
            $user = Auth::user();
            
            // Check and update any ongoing mining session
            $user->checkMiningSession();
            
            // Current mining status
            $miningStatus = $user->mining_status ?? 'idle';
            
            // Calculate time remaining if mining is active
            $timeRemaining = null;
            if ($miningStatus === 'active' && $user->mining_session_end) {
                $endTime = new \DateTime($user->mining_session_end);
                $now = new \DateTime();
                
                if ($endTime > $now) {
                    $interval = $endTime->diff($now);
                    $timeRemaining = [
                        'hours' => $interval->h + ($interval->days * 24),
                        'minutes' => $interval->i,
                        'seconds' => $interval->s,
                        'total_seconds' => $endTime->getTimestamp() - $now->getTimestamp()
                    ];
                }
            }
            
            return response()->json([
                'status' => 'success',
                'data' => [
                    'mining_status' => $miningStatus,
                    'session_start' => $user->mining_session_start,
                    'session_end' => $user->mining_session_end,
                    'time_remaining' => $timeRemaining,
                    'current_session_earnings' => $miningStatus === 'active' 
                        ? number_format($user->getCurrentBalanceAttribute() - ($user->base_balance ?? 0), 2)
                        : '0.00',
                    'can_start_mining' => $user->canStartMining() ?? true
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Mining Status Check Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while checking mining status.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get mining statistics for the authenticated user
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getMiningStatistics()
    {
        try {
            $user = Auth::user();

            // Get latest user data
            $user = User::find($user->id);
            
            // Check and update any ongoing mining session
            $user->checkMiningSession();
            
            // Get team size using the same logic as in getTeamStats
            $teamMembersCount = 1; // Start with 1 for the current user
            
            // Check if the referral_relationships table exists and add referred users
            try {
                $referredUsers = DB::table('referral_relationships')
                    ->where('referrer_id', $user->id)
                    ->pluck('referred_id');
                    
                if ($referredUsers->count() > 0) {
                    // Add referred users count
                    $teamMembersCount += $referredUsers->count();
                }
            } catch (\Exception $e) {
                // If table doesn't exist, just continue with default count
                Log::warning('Could not query referral_relationships table: ' . $e->getMessage());
            }
            
            // Calculate active team members
            $activeCount = $user->mining_status === 'active' || 
                          ($user->mining_session_end >= Carbon::now()->subDay() && 
                           $user->mining_status === 'idle') ? 1 : 0;
                           
            try {
                $activeReferred = User::whereIn('id', $referredUsers ?? [])
                    ->where(function($query) {
                        $query->where('mining_status', 'active')
                            ->orWhere(function($q) {
                                $q->where('mining_session_end', '>=', Carbon::now()->subDay())
                                  ->where('mining_status', 'idle');
                            });
                    })
                    ->count();
                
                $activeCount += $activeReferred;
            } catch (\Exception $e) {
                Log::warning('Could not count active referred users: ' . $e->getMessage());
            }
            
            // Calculate inactive members
            $inactiveCount = $teamMembersCount - $activeCount;
            
            // Check if user is team owner and apply mining rate adjustments based on team activity
            $miningRateBonus = 0;
            
            if ($user->team_id) {
                $team = Team::find($user->team_id);
                if ($team && $team->owner_id === $user->id) {
                    // Base owner rate is 0.05 (0.04 + 0.01 owner bonus)
                    $baseOwnerRate = 0.05;
                    
                    // For active members: each active member adds 0.02 (excluding owner)
                    $activeTeamMembers = $activeCount - 1; // Exclude the owner
                    $miningRateBonus = $activeTeamMembers * 0.02;
                    
                    // Calculate final rate - owner gets 1.14 base + 0.02 per active team member
                    $adjustedMiningRate = $baseOwnerRate + $miningRateBonus;
                    
                    // Update mining rate if different
                    if (abs($adjustedMiningRate - $user->mining_rate) > 0.001) {
                        $originalRate = $user->mining_rate;
                        $user->mining_rate = $adjustedMiningRate;
                        $user->save();
                        
                        Log::info('Updated team owner mining rate', [
                            'user_id' => $user->id,
                            'team_id' => $user->team_id,
                            'base_owner_rate' => $baseOwnerRate,
                            'active_members' => $activeTeamMembers,
                            'bonus' => $miningRateBonus,
                            'original_rate' => $originalRate,
                            'new_rate' => $adjustedMiningRate
                        ]);
                    }
                }
            }

            return response()->json([
                'status' => 'success',
                'data' => [
                    'balance' => number_format($user->getCurrentBalanceAttribute(), 2),
                    'mining_rate' => number_format($user->mining_rate, 2),
                    'mining_rate_bonus' => $miningRateBonus > 0 ? "+" . number_format($miningRateBonus, 2) : null,
                    'team_size' => $teamMembersCount,
                    'active_members' => $activeCount,
                    'inactive_members' => $inactiveCount,
                    'days_active' => $user->created_at ? floor($user->created_at->diffInDays(now())) : 0,
                    'mining_status' => [
                        'current_status' => $user->mining_status ?? 'idle',
                        'session_start' => $user->mining_session_start,
                        'session_end' => $user->mining_session_end,
                        'can_start_mining' => $user->canStartMining() ?? true,
                        // Add current session earnings if active
                        'current_session_earnings' => $user->mining_status === 'active' 
                            ? number_format($user->getCurrentBalanceAttribute() - ($user->base_balance ?? 0), 2)
                            : '0.00'
                    ]
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Mining Statistics Error: ' . $e->getMessage());
            Log::error('Error Stack: ' . $e->getTraceAsString());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while retrieving mining statistics.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Start mining for the authenticated user
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function startMining()
    {
        try {
            return DB::transaction(function () {
                $user = Auth::user();

                // Check if user can start mining
                if (!$user->canStartMining()) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Cannot start mining. An active session is in progress.',
                    ], 400);
                }

                // Start mining session
                $user->startMining();

                return response()->json([
                    'status' => 'success',
                    'message' => 'Mining started successfully',
                    'data' => [
                        'mining_status' => $user->mining_status,
                        'session_start' => $user->mining_session_start,
                        'session_end' => $user->mining_session_end,
                        'initial_balance' => number_format($user->base_balance, 2),
                    ]
                ]);
            });
        } catch (\Exception $e) {
            Log::error('Mining Start Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while starting mining.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Complete mining session
     * Note: This endpoint is only for internal/admin use or
     * when the mining session naturally expires after 24 hours
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function completeMining()
    {
        try {
            return DB::transaction(function () {
                $user = Auth::user();
                
                // Check if mining session has completed its 24 hour duration
                if ($user->mining_status === 'active' && $user->mining_session_end) {
                    $endTime = new \DateTime($user->mining_session_end);
                    $now = new \DateTime();
                    
                    // If the session hasn't reached its end time, prevent manual completion
                    if ($endTime > $now) {
                        return response()->json([
                            'status' => 'error',
                            'message' => 'Mining sessions cannot be stopped early. Mining will continue for the full 24-hour period.',
                        ], 403); // Forbidden
                    }
                }

                // Complete mining session and get earnings
                $earnings = $user->completeMining();

                return response()->json([
                    'status' => 'success',
                    'message' => 'Mining session completed',
                    'data' => [
                        'earnings' => number_format($earnings, 2),
                        'total_balance' => number_format($user->base_balance, 2),
                        'mining_status' => $user->mining_status,
                        'days_active' => $user->created_at ? floor($user->created_at->diffInDays(now())) : 0,
                    ]
                ]);
            });
        } catch (\Exception $e) {
            Log::error('Mining Completion Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while completing mining.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get real-time balance during active mining
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getRealTimeBalance()
    {
        try {
            $user = Auth::user();

            // Check ongoing mining session
            $user->checkMiningSession();

            return response()->json([
                'status' => 'success',
                'data' => [
                    'current_balance' => number_format($user->getCurrentBalanceAttribute(), 2),
                    'base_balance' => number_format($user->base_balance ?? 0, 2),
                    'current_session_earnings' => number_format(
                        $user->getCurrentBalanceAttribute() - ($user->base_balance ?? 0), 
                        2
                    ),
                    'mining_status' => $user->mining_status,
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Real-time Balance Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while retrieving real-time balance.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}