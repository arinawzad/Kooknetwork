<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'team_id',
        'base_balance',
        'mining_rate',
        'last_balance_update',
        'mining_session_start',
        'mining_session_end',
        'mining_status'
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'base_balance' => 'decimal:2',
        'mining_rate' => 'decimal:2',
        'last_balance_update' => 'datetime',
        'mining_session_start' => 'datetime',
        'mining_session_end' => 'datetime',
    ];
    
    /**
     * Get the team that the user belongs to
     */
    public function team()
    {
        return $this->belongsTo(Team::class);
    }

    /**
     * Get the user's personal invite code
     * 
     * @return string|null
     */
    public function getPersonalInviteCode()
    {
        // Check if user_invite_codes table exists
        try {
            $inviteCode = DB::table('user_invite_codes')
                ->where('user_id', $this->id)
                ->first();
            
            if ($inviteCode) {
                return $inviteCode->code;
            }
        } catch (\Exception $e) {
            Log::error('Error getting personal invite code: ' . $e->getMessage());
        }
        
        // Fall back to team code if available
        if ($this->team_id) {
            try {
                $team = DB::table('teams')->where('id', $this->team_id)->first();
                if ($team) {
                    return $team->code;
                }
            } catch (\Exception $e) {
                Log::error('Error getting team code: ' . $e->getMessage());
            }
        }
        
        return null;
    }

    /**
     * Calculate dynamic balance
     * 
     * @return float
     */
    public function calculateCurrentBalance()
    {
        // Base passive income rate (when not mining)
        $passiveRate = 0.05; // 0.05 per hour when idle

        // If no last balance update, set it to account creation
        if (!$this->last_balance_update) {
            $this->last_balance_update = $this->created_at;
            $this->save();
        }

        // Calculate time elapsed since last balance update
        $now = now();
        $lastUpdate = $this->last_balance_update;
        $hoursElapsed = $lastUpdate->diffInHours($now);

        // Calculate earnings based on mining status
        if ($this->mining_status === 'active' && $this->mining_session_start) {
            // Get team size for bonus calculation
            $teamSizeBonus = 0;
            if ($this->team_id) {
                $teamSize = DB::table('users')
                    ->where('team_id', $this->team_id)
                    ->count();
                $teamSizeBonus = $teamSize * 0.1;
            }
            
            $activeRate = $this->mining_rate * (1 + $teamSizeBonus);
            
            // Calculate earnings (capped at 24 hours)
            $maxHours = 24;
            $hoursInSession = min($this->mining_session_start->diffInHours($now), $maxHours);
            $activeEarnings = $activeRate * $hoursInSession;

            return ($this->base_balance ?? 0) + $activeEarnings;
        } else {
            // Passive income when idle
            $passiveEarnings = $passiveRate * $hoursElapsed;
            return ($this->base_balance ?? 0) + $passiveEarnings;
        }
    }

    /**
     * Update balance and last update timestamp
     */
    public function updateBalance()
    {
        $currentBalance = $this->calculateCurrentBalance();
        
        // Update base balance and last update timestamp
        $this->base_balance = $currentBalance;
        $this->last_balance_update = now();
        $this->save();

        return $currentBalance;
    }

    /**
     * Get the current balance
     * 
     * @return float
     */
    public function getCurrentBalanceAttribute()
    {
        return $this->calculateCurrentBalance();
    }

    /**
     * Start a new mining session
     */
    public function startMining()
    {
        // Update balance before starting new session
        $this->updateBalance();

        // Ensure user can start mining
        if (!$this->canStartMining()) {
            throw new \Exception('Cannot start mining. An active session is in progress.');
        }
        
        // Set mining session details
        $this->mining_session_start = now();
        $this->mining_session_end = now()->addHours(24);
        $this->mining_status = 'active';
        $this->save();

        return $this;
    }

    /**
     * Complete mining session and finalize balance
     */
    public function completeMining()
    {
        // Validate active mining session
        if ($this->mining_status !== 'active') {
            throw new \Exception('No active mining session to complete.');
        }

        // Update final balance
        $finalBalance = $this->updateBalance();
        
        // Reset mining session
        $this->mining_status = 'completed';
        $this->mining_session_start = null;
        $this->mining_session_end = null;
        $this->save();

        // Log mining session
        Log::info('Mining Session Completed', [
            'user_id' => $this->id,
            'final_balance' => $finalBalance,
        ]);

        return $finalBalance - ($this->base_balance ?? 0);
    }

    /**
     * Check if user can start mining
     */
    public function canStartMining()
    {
        // If no active mining session or previous session has ended
        if (!$this->mining_session_start || 
            $this->mining_status === 'completed' || 
            $this->mining_status === 'failed' ||
            $this->mining_status === 'idle') {
            return true;
        }

        // Check if current session is still within 24-hour window
        $sessionStart = $this->mining_session_start;

        // If session is active but not completed
        if ($this->mining_status === 'active') {
            // Check if 24 hours have passed
            return $sessionStart->diffInHours(now()) >= 24;
        }

        return false;
    }

    /**
     * Check and update mining session status
     */
    public function checkMiningSession()
    {
        // If no active session, do nothing
        if ($this->mining_status !== 'active') {
            return null;
        }

        // Check if session end time has passed
        $now = now();
        if ($this->mining_session_end && $now > $this->mining_session_end) {
            // Complete the mining session
            return $this->completeMining();
        }

        return null;
    }
}