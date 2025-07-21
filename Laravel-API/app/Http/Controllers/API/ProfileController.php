<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use App\Http\Resources\UserResource;
use Illuminate\Validation\ValidationException;
use Illuminate\Auth\Events\Registered;
use Illuminate\Foundation\Auth\EmailVerificationRequest;
use App\Models\User;

class ProfileController extends Controller
{
    /**
     * Update user profile information
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateProfile(Request $request)
    {
        try {
            $user = Auth::user();
            
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Update user info
            $user->name = $request->name;
            $user->save();
            
            return response()->json([
                'status' => 'success',
                'message' => 'Profile updated successfully',
                'user' => new UserResource($user),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to update profile',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update user email
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateEmail(Request $request)
    {
        try {
            $user = Auth::user();
            
            $validator = Validator::make($request->all(), [
                'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
                'password' => 'required|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Verify current password
            if (!Hash::check($request->password, $user->password)) {
                throw ValidationException::withMessages([
                    'password' => ['The provided password is incorrect.'],
                ]);
            }

            // Store previous email to check if it changed
            $previousEmail = $user->email;
            
            // Update email
            $user->email = $request->email;
            $user->email_verified_at = null; // Reset email verification
            $user->save();
            
            // If email changed, send verification email
            if ($previousEmail !== $request->email) {
                $user->sendEmailVerificationNotification();
            }
            
            return response()->json([
                'status' => 'success',
                'message' => 'Email updated successfully. Please verify your new email address.',
                'user' => new UserResource($user),
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to update email',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update user password
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updatePassword(Request $request)
    {
        try {
            $user = Auth::user();
            
            $validator = Validator::make($request->all(), [
                'current_password' => 'required|string',
                'password' => 'required|string|min:8|confirmed',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Verify current password
            if (!Hash::check($request->current_password, $user->password)) {
                throw ValidationException::withMessages([
                    'current_password' => ['The provided password is incorrect.'],
                ]);
            }

            // Update password
            $user->password = Hash::make($request->password);
            $user->save();
            
            // Revoke all existing tokens except current
            if ($request->has('logout_other_devices') && $request->logout_other_devices) {
                $user->tokens()->where('id', '!=', $request->user()->currentAccessToken()->id)->delete();
            }
            
            return response()->json([
                'status' => 'success',
                'message' => 'Password updated successfully',
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to update password',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Resend email verification link
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function resendVerificationEmail(Request $request)
    {
        try {
            $user = Auth::user();
            
            if ($user->hasVerifiedEmail()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Email already verified'
                ], 400);
            }

            $user->sendEmailVerificationNotification();
            
            return response()->json([
                'status' => 'success',
                'message' => 'Verification link sent'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to send verification email',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Verify email
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @param  string  $hash
     * @return \Illuminate\Http\JsonResponse
     */
    public function verifyEmail(Request $request, $id, $hash)
    {
        try {
            $user = User::findOrFail($id);
            
            if (! hash_equals((string) $hash, sha1($user->getEmailForVerification()))) {
                return view('email.email-verification-status', [
                    'status' => 'error',
                    'message' => 'Invalid verification link'
                ]);
            }

            if ($user->hasVerifiedEmail()) {
                return view('email.email-verification-status', [
                    'status' => 'success',
                    'message' => 'Email already verified'
                ]);
            }

            if ($user->markEmailAsVerified()) {
                event(new \Illuminate\Auth\Events\Verified($user));
            }

            return view('email.email-verification-status', [
                'status' => 'success',
                'message' => 'Email has been verified'
            ]);
        } catch (\Exception $e) {
            return view('email.email-verification-status', [
                'status' => 'error',
                'message' => 'An error occurred while verifying your email'
            ]);
        }
    }  
}