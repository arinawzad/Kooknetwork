<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Models\Task;
use App\Models\TaskCompletion;
use Carbon\Carbon;

class TaskController extends Controller
{
    /**
     * Get available tasks for the authenticated user
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getTasks()
    {
        try {
            $user = Auth::user();
            
            // Get all tasks
            $tasks = DB::table('tasks')
                ->select(
                    'tasks.id',
                    'tasks.title',
                    'tasks.description',
                    'tasks.reward',
                    'tasks.due_date',
                    'tasks.action_type',
                    'tasks.action_data',
                    DB::raw('CASE WHEN task_completions.id IS NOT NULL THEN true ELSE false END as is_completed')
                )
                ->leftJoin('task_completions', function ($join) use ($user) {
                    $join->on('tasks.id', '=', 'task_completions.task_id')
                         ->where('task_completions.user_id', '=', $user->id);
                })
                ->where('tasks.is_active', true)
                ->orderBy('due_date', 'asc')
                ->get();
            
            return response()->json([
                'status' => 'success',
                'data' => $tasks
            ]);
        } catch (\Exception $e) {
            Log::error('Get Tasks Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while retrieving tasks.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Complete a simple task (no verification needed)
     *
     * @param int $taskId
     * @return \Illuminate\Http\JsonResponse
     */
    public function completeTask($taskId)
    {
        try {
            return DB::transaction(function () use ($taskId) {
                $user = Auth::user();
                
                // Check if task exists
                $task = DB::table('tasks')->where('id', $taskId)->first();
                
                if (!$task) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Task not found.'
                    ], 404);
                }
                
                // Check if task already completed
                $alreadyCompleted = DB::table('task_completions')
                    ->where('task_id', $taskId)
                    ->where('user_id', $user->id)
                    ->exists();
                
                if ($alreadyCompleted) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Task already completed.'
                    ], 400);
                }
                
                // Check if it's a simple task
                if ($task->action_type !== 'simple') {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'This task requires verification.'
                    ], 400);
                }
                
                // Record task completion
                DB::table('task_completions')->insert([
                    'user_id' => $user->id,
                    'task_id' => $taskId,
                    'completed_at' => Carbon::now(),
                    'created_at' => Carbon::now(),
                    'updated_at' => Carbon::now()
                ]);
                
                // Add reward to user's balance
                $user->base_balance += $task->reward;
                $user->save();
                
                return response()->json([
                    'status' => 'success',
                    'message' => 'Task completed successfully',
                    'data' => [
                        'task_id' => $taskId,
                        'reward' => $task->reward,
                        'new_balance' => $user->base_balance
                    ]
                ]);
            });
        } catch (\Exception $e) {
            Log::error('Complete Task Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while completing the task.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Verify and complete a task with verification code
     *
     * @param Request $request
     * @param int $taskId
     * @return \Illuminate\Http\JsonResponse
     */
    public function verifyTask(Request $request, $taskId)
    {
        try {
            // Validate the request
            $request->validate([
                'verification_code' => 'required|string'
            ]);
            
            return DB::transaction(function () use ($request, $taskId) {
                $user = Auth::user();
                $verificationCode = $request->input('verification_code');
                
                // Check if task exists and verification code matches
                $task = DB::table('tasks')
                    ->where('id', $taskId)
                    ->where('verification_code', $verificationCode)
                    ->first();
                
                if (!$task) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Invalid verification code or task not found.'
                    ], 400);
                }
                
                // Check if task already completed
                $alreadyCompleted = DB::table('task_completions')
                    ->where('task_id', $taskId)
                    ->where('user_id', $user->id)
                    ->exists();
                
                if ($alreadyCompleted) {
                    return response()->json([
                        'status' => 'error',
                        'message' => 'Task already completed.'
                    ], 400);
                }
                
                // Record task completion
                DB::table('task_completions')->insert([
                    'user_id' => $user->id,
                    'task_id' => $taskId,
                    'verification_code' => $verificationCode,
                    'completed_at' => Carbon::now(),
                    'created_at' => Carbon::now(),
                    'updated_at' => Carbon::now()
                ]);
                
                // Add reward to user's balance
                $user->base_balance += $task->reward;
                $user->save();
                
                return response()->json([
                    'status' => 'success',
                    'message' => 'Task verified and completed successfully',
                    'data' => [
                        'task_id' => $taskId,
                        'reward' => $task->reward,
                        'new_balance' => $user->base_balance
                    ]
                ]);
            });
        } catch (\Exception $e) {
            Log::error('Verify Task Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while verifying the task.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}