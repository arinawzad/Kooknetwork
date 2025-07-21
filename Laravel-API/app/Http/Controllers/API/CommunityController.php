<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Carbon\Carbon;
use App\Models\Team;
use App\Models\User;

class CommunityController extends Controller
{
    /**
     * Get team statistics for the authenticated user
     *
     * @return \Illuminate\Http\JsonResponse
     */
  
     public function getTeamStats()
     {
         try {
             $user = Auth::user();
             
             // Get latest user data
             $user = User::find($user->id);
             
             // Check if user has a team
             if (!$user->team_id) {
                 // No team - create one for this user
                 $team = Team::create([
                     'name' => $user->name . "'s Team",
                     'code' => strtoupper(Str::random(8)),
                     'owner_id' => $user->id,
                 ]);
                 
                 // Update user with new team
                 $user->team_id = $team->id;
                 
                 // Add owner bonus if not already applied
                 if ($user->mining_rate == 0.04) { // Default rate
                     $user->mining_rate += 0.01; // Owner gets a 14% bonus
                 }
                 
                 $user->save();
                 
                 Log::info('Created new team for user in getTeamStats', [
                     'user_id' => $user->id,
                     'team_id' => $team->id,
                     'team_code' => $team->code
                 ]);
             } else {
                 // User has a team - load it
                 $team = Team::find($user->team_id);
                 
                 // If team not found (database inconsistency), create a new one
                 if (!$team) {
                     $team = Team::create([
                         'name' => $user->name . "'s Team",
                         'code' => strtoupper(Str::random(8)),
                         'owner_id' => $user->id,
                     ]);
                     
                     $user->team_id = $team->id;
                     $user->save();
                     
                     Log::warning('Team not found for user, created new one', [
                         'user_id' => $user->id,
                         'old_team_id' => $user->team_id,
                         'new_team_id' => $team->id
                     ]);
                 }
             }
             
             // Check if user has a personal invite code
             $inviteCode = DB::table('user_invite_codes')
                 ->where('user_id', $user->id)
                 ->first();
                 
             // If no personal invite code exists, create one
             if (!$inviteCode) {
                 $personalCode = strtoupper(Str::random(8));
                 
                 DB::table('user_invite_codes')->insert([
                     'user_id' => $user->id,
                     'team_id' => $team->id,
                     'code' => $personalCode,
                     'created_at' => now(),
                     'updated_at' => now()
                 ]);
                 
                 Log::info('Created missing invite code', [
                     'user_id' => $user->id,
                     'team_id' => $team->id,
                     'personal_code' => $personalCode
                 ]);
                 
                 $inviteCode = (object)[
                     'code' => $personalCode
                 ];
             }
             
             // Count team members including the user
             $teamMembers = []; 
             $teamMembersCount = 1; // Start with 1 for the current user
             $activeCount = $user->mining_status === 'active' || 
                            ($user->mining_session_end >= Carbon::now()->subDay() && 
                             $user->mining_status === 'idle') ? 1 : 0;
             
             // Check if the referral_relationships table exists and add referred users
             try {
                 $referredUsers = DB::table('referral_relationships')
                     ->where('referrer_id', $user->id)
                     ->pluck('referred_id');
                     
                 if ($referredUsers->count() > 0) {
                     // Count referred users
                     $teamMembersCount += $referredUsers->count();
                     
                     // Count active referred users
                     $activeReferred = User::whereIn('id', $referredUsers)
                         ->where(function($query) {
                             $query->where('mining_status', 'active')
                                 ->orWhere(function($q) {
                                     $q->where('mining_session_end', '>=', Carbon::now()->subDay())
                                       ->where('mining_status', 'idle');
                                 });
                         })
                         ->count();
                     
                     $activeCount += $activeReferred;
                 }
             } catch (\Exception $e) {
                 // If table doesn't exist, just continue with default counts
                 Log::warning('Could not query referral_relationships table: ' . $e->getMessage());
             }
             
             // Calculate inactive members
             $inactiveCount = $teamMembersCount - $activeCount;
             
             // Calculate maximum team size
             $maxTeamSize = 1000;
             $slotsAvailable = $maxTeamSize - $teamMembersCount;
             
             // Calculate mining bonus based on team size (2% per member, excluding self)
             $miningBonus = ($teamMembersCount - 1) * 2; // -1 to exclude self
             
             // Apply penalty for inactive members (-2% per inactive member)
             $inactivePenalty = $inactiveCount * 2;
             
             // Final mining bonus after penalty
             $finalMiningBonus = max(0, $miningBonus - $inactivePenalty);
             
             // Set inactive penalty to null when there's no inactive members
             $inactivePenaltyDisplay = $inactiveCount > 0 ? "-{$inactivePenalty}%" : "null";
             
             Log::info('Team Stats Retrieved', [
                 'user_id' => $user->id,
                 'team_id' => $team->id,
                 'team_members_count' => $teamMembersCount,
                 'active_members_count' => $activeCount,
                 'inactive_members_count' => $inactiveCount,
                 'mining_bonus_raw' => $miningBonus,
                 'inactive_penalty' => $inactivePenaltyDisplay,
                 'final_mining_bonus' => $finalMiningBonus,
                 'personal_code' => $inviteCode->code,
                 'is_owner' => $team->owner_id === $user->id
             ]);
             
             return response()->json([
                 'status' => 'success',
                 'data' => [
                     'team_members_count' => $teamMembersCount,
                     'active_members_count' => $activeCount,
                     'inactive_members_count' => $inactiveCount,
                     'mining_bonus' => "+{$finalMiningBonus}%",
                     'inactive_penalty' => $inactivePenaltyDisplay,
                     'team_name' => $team->name,
                     'invite_code' => $inviteCode->code,
                     'is_owner' => $team->owner_id === $user->id,
                     'max_team_size' => $maxTeamSize,
                     'slots_available' => $slotsAvailable,
                 ]
             ]);
         } catch (\Exception $e) {
             Log::error('Get Team Stats Error: ' . $e->getMessage());
             Log::error('Error Stack: ' . $e->getTraceAsString());
             
             return response()->json([
                 'status' => 'error',
                 'message' => 'An error occurred while retrieving team statistics.',
                 'error' => $e->getMessage()
             ], 500);
         }
     }
    
    /**
     * Get global network statistics
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getGlobalStats()
    {
        try {
            // Get total active users count
            $activeMiners = DB::table('users')
                ->where('mining_status', 'active')
                ->count();
                
            // Get active miners from yesterday for comparison
            $yesterday = Carbon::now()->subDay();
            $activeMinersDelta = $activeMiners - DB::table('users')
                ->where('created_at', '<', $yesterday)
                ->where('mining_status', 'active')
                ->count();
                
            // Format the active miners count for display
            $formattedActiveMiners = $this->formatLargeNumber($activeMiners);
            $formattedDelta = '+' . number_format($activeMinersDelta) . ' today';
            
            // Calculate network hashrate (simplified version - based on active users and their mining rates)
            $totalMiningRate = DB::table('users')
                ->where('mining_status', 'active')
                ->sum('mining_rate');
            
            // Convert mining rate to hashrate (fictional conversion)
            $hashrate = $totalMiningRate * 10; // Just a placeholder conversion
            
            // Compare to previous week's hashrate
            $lastWeekHashrate = DB::table('users')
                ->where('mining_status', 'active')
                ->where('updated_at', '>=', Carbon::now()->subWeek())
                ->sum('mining_rate') * 10;
                
            $hashratePercentChange = $lastWeekHashrate > 0 
                ? (($hashrate - $lastWeekHashrate) / $lastWeekHashrate) * 100 
                : 0;
                
            // Format hashrate for display
            $formattedHashrate = $this->formatHashrate($hashrate);
            $formattedHashrateChange = ($hashratePercentChange >= 0 ? '+' : '') . 
                number_format($hashratePercentChange, 1) . '% this week';
                
            // Get total supply (sum of all user balances)
            $totalSupply = DB::table('users')->sum('base_balance');
            
            // Maximum supply as a constant (for the fictional coin)
            $maxSupply = 100000000; // 100 million KOOK
            $supplyPercentage = ($totalSupply / $maxSupply) * 100;
            
            // Format supply for display
            $formattedSupply = $this->formatLargeNumber($totalSupply) . ' KOOK';
            $formattedSupplyPercentage = number_format($supplyPercentage, 0) . '% of max supply';
            
            return response()->json([
                'status' => 'success',
                'data' => [
                    'activeMiners' => $formattedActiveMiners,
                    'activeMinersDelta' => $formattedDelta,
                    'hashrate' => $formattedHashrate,
                    'hashrateDelta' => $formattedHashrateChange,
                    'totalSupply' => $formattedSupply,
                    'supplyPercentage' => $formattedSupplyPercentage,
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Get Global Stats Error: ' . $e->getMessage());
            
            // Fall back to static data in case of error
            return response()->json([
                'status' => 'success',
                'data' => [
                    'activeMiners' => '3.2M',
                    'activeMinersDelta' => '+12,500 today',
                    'hashrate' => '142.5 PH/s',
                    'hashrateDelta' => '+3.2% this week',
                    'totalSupply' => '25.6M KOOK',
                    'supplyPercentage' => '58% of max supply',
                ]
            ]);
        }
    }
    
    /**
     * Get community posts
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getCommunityPosts()
    {
        try {
            $user = Auth::user();
            
            // Check if there are posts in the database
            $posts = DB::table('community_posts')
                ->orderBy('created_at', 'desc')
                ->limit(10)
                ->get();
                
            // If no posts in database, return static data
            if ($posts->isEmpty()) {
                $posts = [
                    [
                        'id' => 1,
                        'username' => 'Kook Team aa',
                        'user_avatar' => null,
                        'created_at' => Carbon::now()->subHours(2)->toIso8601String(),
                        'content' => 'Important update: We\'re upgrading our network infrastructure next week. Mining rates may fluctuate during this period. Thank you for your patience!',
                        'image_url' => null,
                        'likes' => 57,
                        'comments' => 23,
                        'is_official' => 1,
                        'is_liked' => 0,
                    ],
                    
                   
                    
                ];
            } else {
                // Process posts from the database
                $posts = $posts->map(function ($post) use ($user) {
                    // Check if user has liked this post
                    $isLiked = DB::table('post_likes')
                        ->where('post_id', $post->id)
                        ->where('user_id', $user->id)
                        ->exists();
                        
                    return [
                        'id' => $post->id,
                        'username' => $post->username,
                        'user_avatar' => $post->user_avatar,
                        'created_at' => $post->created_at,
                        'content' => $post->content,
                        'image_url' => $post->image_url,
                        'likes' => $post->likes,
                        'comments' => $post->comments,
                        'is_official' => $post->is_official,
                        'is_liked' => $isLiked ? 1 : 0,
                    ];
                })->toArray();
            }
            
            return response()->json([
                'status' => 'success',
                'data' => $posts
            ]);
        } catch (\Exception $e) {
            Log::error('Get Community Posts Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while retrieving community posts.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Get community channels
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getCommunityChannels()
    {
        try {
            // Get channels from database
            $channels = DB::table('community_channels')
                ->where('is_active', true)
                ->orderBy('sort_order')
                ->get();
                
            // If no channels in database, return static data
            if ($channels->isEmpty()) {
                $channels = [
                    [
                        'id' => 1,
                        'title' => 'Telegram',
                        'subtitle' => 'Join 245k members',
                        'url' => 'https://t.me/kookcoin',
                        'type' => 'telegram',
                    ],
                    [
                        'id' => 2,
                        'title' => 'Discord',
                        'subtitle' => '125k active users',
                        'url' => 'https://discord.gg/kook',
                        'type' => 'discord',
                    ],
                    [
                        'id' => 3,
                        'title' => 'Reddit',
                        'subtitle' => 'r/KookOfficial',
                        'url' => 'https://reddit.com/r/KookOfficial',
                        'type' => 'reddit',
                    ],
                ];
            } else {
                $channels = $channels->toArray();
            }
            
            return response()->json([
                'status' => 'success',
                'data' => $channels
            ]);
        } catch (\Exception $e) {
            Log::error('Get Community Channels Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while retrieving community channels.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Generate an invite code for team
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function generateInviteCode(Request $request)
    {
        try {
            // Get authenticated user with all current data
            $user = User::find(Auth::id());
            if (!$user) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'User not found',
                ], 404);
            }
    
            // Check if user has a team - if not, create one
            if (!$user->team_id) {
                // Create a new team with a permanent code
                $team = Team::create([
                    'name' => $user->name . "'s Team",
                    'code' => strtoupper(Str::random(8)),
                    'owner_id' => $user->id,
                ]);
                
                // Update user with new team
                $user->team_id = $team->id;
                
                // Add owner bonus
                $user->mining_rate += 0.01; // Owner gets a 14% bonus
                $user->save();
                
                Log::info('Created new team for invite code', [
                    'user_id' => $user->id,
                    'team_id' => $team->id,
                    'team_code' => $team->code
                ]);
            } else {
                $team = Team::find($user->team_id);
                
                // If team doesn't exist, create a new one
                if (!$team) {
                    $team = Team::create([
                        'name' => $user->name . "'s Team",
                        'code' => strtoupper(Str::random(8)),
                        'owner_id' => $user->id,
                    ]);
                    
                    $user->team_id = $team->id;
                    $user->save();
                    
                    Log::warning('Team not found for user, created new one', [
                        'user_id' => $user->id,
                        'new_team_id' => $team->id
                    ]);
                }
            }
            
            // Count current team members
            $teamMembersCount = DB::table('referral_relationships')
                ->where('referrer_id', $user->id)
                ->count();
                
            $maxTeamSize = 1000;
            if ($teamMembersCount >= $maxTeamSize) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Your team has reached the maximum size of ' . $maxTeamSize . ' members.',
                ], 400);
            }
            
            // Check if the user already has a personal invite code
            $inviteCode = DB::table('user_invite_codes')
                ->where('user_id', $user->id)
                ->first();
                
            // If an invite code exists but is for a different team, update it
            if ($inviteCode && $inviteCode->team_id != $team->id) {
                DB::table('user_invite_codes')
                    ->where('id', $inviteCode->id)
                    ->update([
                        'team_id' => $team->id,
                        'updated_at' => now()
                    ]);
                    
                $userInviteCode = $inviteCode->code;
                
                Log::info('Updated existing invite code team reference', [
                    'user_id' => $user->id,
                    'invite_code' => $userInviteCode,
                    'old_team_id' => $inviteCode->team_id,
                    'new_team_id' => $team->id
                ]);
            }
            // If no invite code exists, create a new one
            elseif (!$inviteCode) {
                $userInviteCode = strtoupper(Str::random(8));
                DB::table('user_invite_codes')->insert([
                    'user_id' => $user->id,
                    'team_id' => $team->id,
                    'code' => $userInviteCode,
                    'created_at' => now(),
                    'updated_at' => now()
                ]);
                
                Log::info('Created new personal invite code', [
                    'user_id' => $user->id,
                    'team_id' => $team->id,
                    'invite_code' => $userInviteCode
                ]);
            }
            // Use existing invite code if it's already correct
            else {
                $userInviteCode = $inviteCode->code;
            }
            
            // Return the user's invite code with team information
            return response()->json([
                'status' => 'success',
                'message' => 'Team invite code retrieved successfully',
                'data' => [
                    'invite_code' => $userInviteCode,
                    'expires_at' => null, // Never expires
                    'team_id' => $team->id,
                    'team_name' => $team->name,
                    'team_members_count' => $teamMembersCount,
                    'slots_available' => $maxTeamSize - $teamMembersCount,
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Get Invite Code Error: ' . $e->getMessage());
            Log::error('Error Stack: ' . $e->getTraceAsString());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while retrieving invite code.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Format large numbers for display (e.g., 1200000 => 1.2M)
     *
     * @param int $number
     * @return string
     */
    private function formatLargeNumber($number)
    {
        if ($number >= 1000000000) {
            return number_format($number / 1000000000, 1) . 'B';
        } else if ($number >= 1000000) {
            return number_format($number / 1000000, 1) . 'M';
        } else if ($number >= 1000) {
            return number_format($number / 1000, 1) . 'K';
        }
        
        return number_format($number);
    }

    /**
     * Format hashrate for display
     *
     * @param float $hashrate
     * @return string
     */
    private function formatHashrate($hashrate)
    {
        if ($hashrate >= 1000000000) {
            return number_format($hashrate / 1000000000, 1) . ' PH/s';
        } else if ($hashrate >= 1000000) {
            return number_format($hashrate / 1000000, 1) . ' TH/s';
        } else if ($hashrate >= 1000) {
            return number_format($hashrate / 1000, 1) . ' GH/s';
        }
        
        return number_format($hashrate, 1) . ' MH/s';
    }
}