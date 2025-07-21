<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'status',
        'progress',
        'due_date',
        'priority',
        'tasks',
        'completed_tasks',
        'is_active',
        'team',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'progress' => 'float',
        'tasks' => 'integer',
        'completed_tasks' => 'integer',
        'is_active' => 'boolean',
        'team' => 'array',
        'due_date' => 'date',
    ];
}