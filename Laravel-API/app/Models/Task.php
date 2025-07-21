<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'title',
        'description',
        'reward',
        'due_date',
        'is_active',
        'action_type',
        'action_data',
        'verification_code',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'due_date' => 'date',
        'reward' => 'double',
        'is_active' => 'boolean',
    ];

    /**
     * Task completions relationship
     */
    public function completions()
    {
        return $this->hasMany(TaskCompletion::class);
    }
}

class TaskCompletion extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'user_id',
        'task_id',
        'verification_code',
        'completed_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'completed_at' => 'datetime',
    ];

    /**
     * User relationship
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Task relationship
     */
    public function task()
    {
        return $this->belongsTo(Task::class);
    }
}