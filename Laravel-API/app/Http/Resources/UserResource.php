<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            
            // Email verification status
            'email_verified_at' => $this->email_verified_at,
            'email_verified' => $this->hasVerifiedEmail(),
            
            // Dynamic balance calculation
            'balance' => number_format($this->getCurrentBalanceAttribute(), 2),
            'base_balance' => number_format($this->base_balance ?? 0, 2),
            'mining_rate' => number_format($this->mining_rate, 2),
            
            'days_active' => $this->created_at ? floor($this->created_at->diffInDays(now())) : 0,
            
            // Mining session details
            'mining_status' => [
                'current_status' => $this->mining_status ?? 'idle',
                'session_start' => $this->mining_session_start,
                'session_end' => $this->mining_session_end,
                'can_start_mining' => $this->canStartMining() ?? true,
                'current_session_earnings' => $this->mining_status === 'active' 
                    ? number_format($this->getCurrentBalanceAttribute() - ($this->base_balance ?? 0), 2)
                    : '0.00'
            ],
            
            // Team information
            'team' => $this->team ? [
                'id' => $this->team->id,
                'name' => $this->team->name,
                'code' => $this->team->code,
                'members_count' => $this->team->users()->count(),
                'is_owner' => $this->team->owner_id === $this->id,
            ] : null,
            
            // Timestamps
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}