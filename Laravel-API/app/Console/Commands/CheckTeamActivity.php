<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Models\Team;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class CheckTeamActivity extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:check-team-activity';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Check team member activity and decrease owner mining rate if inactive';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Checking team activity...');
        
        // Get all teams
        $teams = Team::has('users', '>', 1) // Teams with at least 2 members
                     ->with('owner')
                     ->get();
                     
        $this->info('Found ' . $teams->count() . ' teams to check.');
        
        foreach ($teams as $team) {
            // Skip if no owner
            if (!$team->owner) {
                $this->warn('Team ' . $team->id . ' has no owner.');
                continue;
            }
            
            // Get inactive users (no mining activity in the last 24 hours)
            $inactiveUsers = User::where('team_id', $team->id)
                ->where('id', '!=', $team->owner_id) // Exclude owner
                ->where(function ($query) {
                    $query->where('mining_status', '!=', 'active')
                          ->orWhere(function ($q) {
                              $q->where('mining_status', '=', 'active')
                                ->where('mining_session_start', '<', Carbon::now()->subHours(24));
                          });
                })
                ->get();
                
            // If there are inactive users, decrease owner's mining rate
            if ($inactiveUsers->count() > 0) {
                $owner = $team->owner;
                $decreaseAmount = 0.005 * $inactiveUsers->count(); // 0.005 per inactive user
                
                // Don't let mining rate go below 1.0
                $newMiningRate = max(1.0, $owner->mining_rate - $decreaseAmount);
                $actualDecrease = $owner->mining_rate - $newMiningRate;
                
                if ($actualDecrease > 0) {
                    // Update owner's mining rate
                    $owner->mining_rate = $newMiningRate;
                    $owner->save();
                    
                    $this->info("Decreased owner {$owner->id}'s mining rate by {$actualDecrease} due to {$inactiveUsers->count()} inactive users.");
                    
                    // Log the decrease
                    Log::info('Team owner mining rate decreased', [
                        'owner_id' => $owner->id,
                        'team_id' => $team->id,
                        'inactive_users' => $inactiveUsers->count(),
                        'decrease_amount' => $actualDecrease,
                        'new_mining_rate' => $newMiningRate,
                    ]);
                }
            } else {
                $this->info("Team {$team->id} has all members active.");
            }
        }
        
        $this->info('Team activity check completed.');
    }
}