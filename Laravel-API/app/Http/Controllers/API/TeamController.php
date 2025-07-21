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

class TeamController extends Controller
{
    /**
     * Get team members for the authenticated user's team
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getTeamMembers()
    {
        try {
            $user = Auth::user();
            
            // Ensure user has a team
            if (!$user->team_id) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'User does not have a team',
                ], 400);
            }
            
            // Get team information
            $team = Team::find($user->team_id);
            if (!$team) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Team not found',
                ], 404);
            }
            
            // Check if user is the team owner
            $isOwner = $team->owner_id === $user->id;
            
            $teamMembers = [];
            
            // If user is the team owner, get members based on referral relationships
            if ($isOwner) {
                try {
                    $referredUsers = DB::table('referral_relationships')
                        ->where('referrer_id', $user->id)
                        ->pluck('referred_id');
                        
                    if ($referredUsers->count() > 0) {
                        $teamMembersCollection = User::whereIn('id', $referredUsers)->get();
                        
                        foreach ($teamMembersCollection as $member) {
                            // Calculate if user is active (mined in last 24 hours)
                            $isActive = $member->mining_status === 'active' || 
                                ($member->mining_session_end && $member->mining_session_end >= Carbon::now()->subDay() && 
                                 $member->mining_status === 'idle');
                            
                            // Format last active time
                            $lastActive = null;
                            if ($member->last_balance_update) {
                                $lastActiveTime = new Carbon($member->last_balance_update);
                                if ($lastActiveTime->isToday()) {
                                    $lastActive = $lastActiveTime->format('h:i A');
                                } else if ($lastActiveTime->isYesterday()) {
                                    $lastActive = 'Yesterday';
                                } else {
                                    $lastActive = $lastActiveTime->format('M d, Y');
                                }
                            }
                            
                            // Format joined date
                            $joinedAt = new Carbon($member->created_at);
                            $joinedText = $joinedAt->diffForHumans();
                            
                            $teamMembers[] = [
                                'id' => $member->id,
                                'name' => $member->name,
                                'is_active' => $isActive,
                                'mining_rate' => round($member->mining_rate, 2),
                                'joined_at' => $joinedText,
                                'last_active' => $lastActive,
                            ];
                        }
                    }
                } catch (\Exception $e) {
                    // If table doesn't exist, log warning and continue
                    Log::warning('Could not query referral_relationships table: ' . $e->getMessage());
                }
            } else {
                // If user is not the owner, find who referred them
                try {
                    $referrer = DB::table('referral_relationships')
                        ->where('referred_id', $user->id)
                        ->first();
                        
                    if ($referrer) {
                        $teamOwner = User::find($referrer->referrer_id);
                        
                        if ($teamOwner) {
                            // Format data for team owner
                            $isActive = $teamOwner->mining_status === 'active' || 
                                ($teamOwner->mining_session_end && $teamOwner->mining_session_end >= Carbon::now()->subDay() && 
                                $teamOwner->mining_status === 'idle');
                                
                            $lastActive = null;
                            if ($teamOwner->last_balance_update) {
                                $lastActiveTime = new Carbon($teamOwner->last_balance_update);
                                if ($lastActiveTime->isToday()) {
                                    $lastActive = $lastActiveTime->format('h:i A');
                                } else if ($lastActiveTime->isYesterday()) {
                                    $lastActive = 'Yesterday';
                                } else {
                                    $lastActive = $lastActiveTime->format('M d, Y');
                                }
                            }
                            
                            $joinedAt = new Carbon($teamOwner->created_at);
                            $joinedText = $joinedAt->diffForHumans();
                            
                            $teamMembers[] = [
                                'id' => $teamOwner->id,
                                'name' => $teamOwner->name . ' (Team Owner)',
                                'is_active' => $isActive,
                                'mining_rate' => round($teamOwner->mining_rate, 2),
                                'joined_at' => $joinedText,
                                'last_active' => $lastActive ?? 'Unknown',
                            ];
                            
                            // Get other team members (people referred by the same owner)
                            $teamMates = DB::table('referral_relationships')
                                ->where('referrer_id', $teamOwner->id)
                                ->where('referred_id', '!=', $user->id)
                                ->pluck('referred_id');
                                
                            if ($teamMates->count() > 0) {
                                $teamMatesCollection = User::whereIn('id', $teamMates)->get();
                                
                                foreach ($teamMatesCollection as $member) {
                                    $isActive = $member->mining_status === 'active' || 
                                        ($member->mining_session_end && $member->mining_session_end >= Carbon::now()->subDay() && 
                                        $member->mining_status === 'idle');
                                    
                                    $lastActive = null;
                                    if ($member->last_balance_update) {
                                        $lastActiveTime = new Carbon($member->last_balance_update);
                                        if ($lastActiveTime->isToday()) {
                                            $lastActive = $lastActiveTime->format('h:i A');
                                        } else if ($lastActiveTime->isYesterday()) {
                                            $lastActive = 'Yesterday';
                                        } else {
                                            $lastActive = $lastActiveTime->format('M d, Y');
                                        }
                                    }
                                    
                                    $joinedAt = new Carbon($member->created_at);
                                    $joinedText = $joinedAt->diffForHumans();
                                    
                                    $teamMembers[] = [
                                        'id' => $member->id,
                                        'name' => $member->name,
                                        'is_active' => $isActive,
                                        'mining_rate' => round($member->mining_rate, 2),
                                        'joined_at' => $joinedText,
                                        'last_active' => $lastActive,
                                    ];
                                }
                            }
                        }
                    }
                } catch (\Exception $e) {
                    Log::warning('Could not query referrer information: ' . $e->getMessage());
                }
            }
            
            // Add the current user
            $isUserActive = $user->mining_status === 'active' || 
                ($user->mining_session_end && $user->mining_session_end >= Carbon::now()->subDay() && 
                $user->mining_status === 'idle');
                
            $lastActive = null;
            if ($user->last_balance_update) {
                $lastActiveTime = new Carbon($user->last_balance_update);
                if ($lastActiveTime->isToday()) {
                    $lastActive = $lastActiveTime->format('h:i A');
                } else if ($lastActiveTime->isYesterday()) {
                    $lastActive = 'Yesterday';
                } else {
                    $lastActive = $lastActiveTime->format('M d, Y');
                }
            }
            
            $joinedAt = new Carbon($user->created_at);
            $joinedText = $joinedAt->diffForHumans();
            
            $currentUser = [
                'id' => $user->id,
                'name' => $user->name . ' (You)',
                'is_active' => $isUserActive,
                'mining_rate' => round($user->mining_rate, 2),
                'joined_at' => $joinedText,
                'last_active' => 'Now',
            ];
            
            // Add current user at beginning of array
            array_unshift($teamMembers, $currentUser);
            
            return response()->json([
                'status' => 'success',
                'data' => $teamMembers,
                'is_owner' => $isOwner
            ]);
        } catch (\Exception $e) {
            Log::error('Get Team Members Error: ' . $e->getMessage());
            Log::error('Error Stack: ' . $e->getTraceAsString());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while retrieving team members.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}