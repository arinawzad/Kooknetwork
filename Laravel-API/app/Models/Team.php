<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Team extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'code',
        'owner_id',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'owner_id' => 'integer',
    ];

    /**
     * Boot the model with custom logic
     */
    protected static function boot()
    {
        parent::boot();

        // Generate a unique team code and name if not provided
        static::creating(function ($team) {
            // Generate team code if not set
            if (empty($team->code)) {
                $team->code = Str::random(8);
            }

            // Generate a default name if not set
            if (empty($team->name)) {
                $team->name = 'Team ' . Str::random(4);
            }
        });
    }

    /**
     * Get the owner of the team
     */
    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    /**
     * Get all users in the team
     */
    public function users()
    {
        return $this->hasMany(User::class);
    }
}