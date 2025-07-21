<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\MiningController;
use App\Http\Controllers\API\MarketController;
use App\Http\Controllers\API\TaskController;
use App\Http\Controllers\API\CommunityController;
use App\Http\Controllers\API\ProfileController;
use App\Http\Controllers\API\ProjectController;
use App\Http\Controllers\API\TeamController;
use App\Http\Controllers\API\VersionController;

// Public routes
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Password reset routes
Route::post('/password/forgot', [AuthController::class, 'forgotPassword']);
// Add GET route for the password reset link that users click in their email
Route::get('/password/reset', [AuthController::class, 'showResetForm'])
    ->middleware(['signed'])
    ->name('password.reset');
// Keep existing POST route for actual password reset
Route::post('/password/reset', [AuthController::class, 'resetPassword'])
    ->name('password.update');

// Version check route (public)
Route::get('/version/check', [VersionController::class, 'checkVersion']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // User Authentication
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    
    // Profile Management
    Route::post('/user/profile', [ProfileController::class, 'updateProfile']);
    Route::post('/user/email', [ProfileController::class, 'updateEmail']);
    Route::post('/user/password', [ProfileController::class, 'updatePassword']);
    Route::post('/email/verification-notification', [ProfileController::class, 'resendVerificationEmail']);
    
    // Mining routes
    Route::get('/mining/statistics', [MiningController::class, 'getMiningStatistics']);
    Route::get('/mining/status', [MiningController::class, 'getMiningStatus']);
    Route::post('/mining/start', [MiningController::class, 'startMining']);
    Route::post('/mining/complete', [MiningController::class, 'completeMining']);
    Route::get('/mining/balance', [MiningController::class, 'getRealTimeBalance']);

    // Market routes
    Route::get('/market/prices', [MarketController::class, 'getMarketPrices']);
    
    // Task routes
    Route::get('/tasks', [TaskController::class, 'getTasks']);
    Route::post('/tasks/{taskId}/complete', [TaskController::class, 'completeTask']);
    Route::post('/tasks/{taskId}/verify', [TaskController::class, 'verifyTask']);
    
    // Community routes
    Route::get('/community/team-stats', [CommunityController::class, 'getTeamStats']);
    Route::get('/community/global-stats', [CommunityController::class, 'getGlobalStats']);
    Route::get('/community/posts', [CommunityController::class, 'getCommunityPosts']);
    Route::get('/community/channels', [CommunityController::class, 'getCommunityChannels']);
    Route::post('/community/invite', [CommunityController::class, 'generateInviteCode']);
    
    // Team routes
    Route::get('/team/members', [TeamController::class, 'getTeamMembers']);
    
    // Project routes
    Route::get('/projects', [ProjectController::class, 'getProjects']);
    Route::get('/projects/active', [ProjectController::class, 'getActiveProjects']);
    Route::get('/projects/upcoming', [ProjectController::class, 'getUpcomingProjects']);
    Route::get('/projects/{id}', [ProjectController::class, 'getProject']);
    Route::post('/projects', [ProjectController::class, 'createProject']);
    Route::put('/projects/{id}', [ProjectController::class, 'updateProject']);
    Route::delete('/projects/{id}', [ProjectController::class, 'deleteProject']);
    Route::patch('/projects/{id}/progress', [ProjectController::class, 'updateProgress']);
    
    // Version management (admin only)
    Route::post('/version/update', [VersionController::class, 'updateMinimumVersion']);
});

// Email verification routes
Route::get('/email/verify/{id}/{hash}', [ProfileController::class, 'verifyEmail'])
    ->middleware(['signed'])
    ->name('verification.verify');