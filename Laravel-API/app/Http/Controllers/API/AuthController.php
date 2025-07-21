<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Team;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Exception;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Facades\Mail;

class AuthController extends Controller
{
    /**
     * Register a new user
     *
     * @param RegisterRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(RegisterRequest $request)
    {
        try {
            return DB::transaction(function () use ($request) {
                // Track referring user for mining bonus
                $referringUser = null;
                
                // Check if team code was provided for referral bonus
                if ($request->filled('team_code')) {
                    Log::info('Team code provided in registration', ['code' => $request->team_code]);
                    
                    // Find the user who owns this invite code
                    $inviteCode = DB::table('user_invite_codes')
                        ->where('code', $request->team_code)
                        ->first();
                    
                    if ($inviteCode) {
                        $referringUser = User::find($inviteCode->user_id);
                        
                        Log::info('Found referring user from invite code', [
                            'code' => $request->team_code,
                            'referring_user_id' => $inviteCode->user_id
                        ]);
                        
                        // Check if this referrer already has 1000 team members
                        $currentTeamCount = DB::table('referral_relationships')
                            ->where('referrer_id', $inviteCode->user_id)
                            ->count();
                            
                        if ($currentTeamCount >= 1000) {
                            throw ValidationException::withMessages([
                                'team_code' => ['This team has reached its maximum capacity of 1000 members.'],
                            ]);
                        }
                    } else {
                        throw ValidationException::withMessages([
                            'team_code' => ['The provided team code is invalid.'],
                        ]);
                    }
                }

                // Create a new team for this user (everyone gets their own team)
                $team = Team::create([
                    'name' => $request->name . "'s Team",
                    'code' => strtoupper(Str::random(8)),
                    'owner_id' => null, // Will set after user creation
                ]);
                
                Log::info('Created new team for user', [
                    'team_id' => $team->id,
                    'team_name' => $team->name,
                    'team_code' => $team->code
                ]);

                // Create the user with their own team
                $user = User::create([
                    'name' => $request->name,
                    'email' => $request->email,
                    'password' => Hash::make($request->password),
                    'team_id' => $team->id,  // User has their own team
                    'mining_rate' => 0.04,    // Default rate
                    'mining_status' => 'idle',
                    'last_balance_update' => now(),
                ]);
                
                // Set this user as the owner of their team
                $team->owner_id = $user->id;
                $team->save();
                
                // Give owner bonus for their own team
                $user->mining_rate += 0.01; // 14% bonus for team owner
                $user->save();
                
                Log::info('Set user as team owner with bonus', [
                    'user_id' => $user->id,
                    'team_id' => $team->id,
                    'mining_rate' => $user->mining_rate
                ]);
                
                // If there was a referring user, set up the relationship and give them a referral bonus
                if ($referringUser && $referringUser->id !== $user->id) {
                    // Track the referral relationship
                    DB::table('referral_relationships')->insert([
                        'referrer_id' => $referringUser->id,
                        'referred_id' => $user->id,
                        'invite_code' => $request->team_code,
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                    
                    // Give referring user a mining bonus
                    $referringUser->mining_rate += 0.02; // 2% bonus per referral
                    $referringUser->save();
                    
                    Log::info('Increased mining rate for referrer', [
                        'referring_user_id' => $referringUser->id,
                        'new_user_id' => $user->id,
                        'new_mining_rate' => $referringUser->mining_rate
                    ]);
                }
                
                // Create a personal invite code for the new user
                $personalCode = strtoupper(Str::random(8));
                DB::table('user_invite_codes')->insert([
                    'user_id' => $user->id,
                    'team_id' => $team->id,
                    'code' => $personalCode,
                    'created_at' => now(),
                    'updated_at' => now()
                ]);
                
                Log::info('Created personal invite code', [
                    'user_id' => $user->id,
                    'team_id' => $team->id,
                    'invite_code' => $personalCode
                ]);

                // Create auth token
                $token = $user->createToken('auth_token')->plainTextToken;

                return response()->json([
                    'status' => 'success',
                    'message' => 'User registered successfully',
                    'user' => new UserResource($user),
                    'token' => $token,
                ], 201);
            });
        } catch (ValidationException $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
                'errors' => $e->errors()
            ], 422);
        } catch (Exception $e) {
            Log::error('Registration Error: ' . $e->getMessage());
            Log::error('Trace: ' . $e->getTraceAsString());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An unexpected error occurred during registration.',
                'error' => $e->getMessage()
            ], 500);
        }
    }


    /**
     * Login user and create token
     *
     * @param LoginRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(LoginRequest $request)
    {
        try {
            $user = User::where('email', $request->email)->first();

            if (!$user || !Hash::check($request->password, $user->password)) {
                throw ValidationException::withMessages([
                    'email' => ['The provided credentials are incorrect.'],
                ]);
            }

            // Revoke all existing tokens
            $user->tokens()->delete();
            
            // In your login method:
            $token = $user->createToken('auth_token', ['*'], now()->addYear())->plainTextToken;

            return response()->json([
                'status' => 'success',
                'message' => 'Login successful',
                'user' => new UserResource($user),
                'token' => $token,
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
                'errors' => $e->errors()
            ], 422);
        } catch (Exception $e) {
            Log::error('Login Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An unexpected error occurred during login.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get authenticated user
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function user(Request $request)
    {
        try {
            return response()->json([
                'status' => 'success',
                'user' => new UserResource($request->user()),
            ]);
        } catch (Exception $e) {
            Log::error('Get User Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while retrieving user information.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Logout user (revoke token)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request)
    {
        try {
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'status' => 'success',
                'message' => 'Successfully logged out',
            ]);
        } catch (Exception $e) {
            Log::error('Logout Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred during logout.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Send password reset link
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function forgotPassword(Request $request)
    {
        try {
            $request->validate([
                'email' => 'required|email|exists:users,email'
            ]);

            // Generate a unique reset token
            $token = Str::random(60);

            // Store reset token and email in password_resets table
            DB::table('password_resets')->updateOrInsert(
                ['email' => $request->email],
                [
                    'email' => $request->email,
                    'token' => Hash::make($token),
                    'created_at' => now()
                ]
            );

            // Generate signed reset password URL (now using the GET route)
            $resetUrl = URL::temporarySignedRoute(
                'password.reset', 
                now()->addMinutes(60), 
                [
                    'email' => $request->email,
                    'token' => $token
                ]
            );

            // Send reset link via email
            try {
                Mail::send('email.password_reset', [
                    'resetUrl' => $resetUrl,
                    'email' => $request->email
                ], function ($message) use ($request) {
                    $message->to($request->email)
                        ->subject('Password Reset Request');
                });
            } catch (Exception $emailError) {
                // Log email sending error but still return success
                Log::error('Password Reset Email Error: ' . $emailError->getMessage());
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Password reset link sent to your email'
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
                'errors' => $e->errors()
            ], 422);
        } catch (Exception $e) {
            Log::error('Forgot Password Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while processing your request.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display password reset form or redirect to app
     * 
     * @param Request $request
     * @return \Illuminate\View\View
     */
    public function showResetForm(Request $request)
    {
        // Check for valid signature
        if (!$request->hasValidSignature()) {
            abort(401, 'Invalid or expired reset link.');
        }

        // For API, we'll redirect to the app with a custom URL scheme
        // But we'll also provide a web page with instructions in case the app isn't installed
        $appResetUrl = "kook://password-reset?email=" . urlencode($request->email) . "&token=" . urlencode($request->token);
        
        // Return a view that tries to open the app and provides fallback instructions
        return view('email.reset-redirect', [
            'appResetUrl' => $appResetUrl,
            'email' => $request->email,
            'token' => $request->token
        ]);
    }

    /**
     * Reset password
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function resetPassword(Request $request)
    {
        try {
            $request->validate([
                'email' => 'required|email|exists:users,email',
                'password' => 'required|confirmed|min:8',
                'token' => 'required'
            ]);

            // Find the password reset record
            $passwordReset = DB::table('password_resets')
                ->where('email', $request->email)
                ->first();

            // Validate reset token
            if (!$passwordReset || !Hash::check($request->token, $passwordReset->token)) {
                throw ValidationException::withMessages([
                    'token' => ['Invalid or expired reset token.']
                ]);
            }

            // Check token expiration (1 hour)
            if (now()->diffInHours($passwordReset->created_at) > 1) {
                throw ValidationException::withMessages([
                    'token' => ['Reset token has expired.']
                ]);
            }

            // Update user password
            $user = User::where('email', $request->email)->first();
            $user->password = Hash::make($request->password);
            $user->save();

            // Delete the password reset token
            DB::table('password_resets')
                ->where('email', $request->email)
                ->delete();

            return response()->json([
                'status' => 'success',
                'message' => 'Password reset successfully'
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
                'errors' => $e->errors()
            ], 422);
        } catch (Exception $e) {
            Log::error('Password Reset Error: ' . $e->getMessage());
            
            return response()->json([
                'status' => 'error',
                'message' => 'An error occurred while resetting your password.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}