<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Validator;

class VersionController extends Controller
{
    /**
     * Check if app version is up to date
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function checkVersion(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_version' => 'required|string',
            'platform' => 'required|in:android,ios',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $platform = $request->platform;
        $currentVersion = $request->current_version;
        
        // Get the minimum required version from cache or database
        // You could use a settings table in your database instead
        $minimumVersion = Cache::get("minimum_version_{$platform}", '1.0.0');
        $latestVersion = Cache::get("latest_version_{$platform}", '1.0.0');
        $updateUrl = $platform === 'android' 
            ? 'https://play.google.com/store/apps/details?id=com.yourapp.id' 
            : 'https://apps.apple.com/app/yourapp/id123456789';

        // Compare versions using version_compare PHP function
        $needsUpdate = version_compare($currentVersion, $minimumVersion, '<');
        $hasNewVersion = version_compare($currentVersion, $latestVersion, '<');

        return response()->json([
            'status' => true,
            'data' => [
                'current_version' => $currentVersion,
                'minimum_version' => $minimumVersion,
                'latest_version' => $latestVersion,
                'needs_update' => $needsUpdate,
                'has_new_version' => $hasNewVersion,
                'update_url' => $updateUrl,
                'update_message' => $needsUpdate 
                    ? 'A required update is available. Please update to continue using the app.' 
                    : ($hasNewVersion ? 'A new version is available with exciting features!' : null),
                'force_update' => $needsUpdate,
            ]
        ], 200);
    }

    /**
     * Update minimum version (admin only)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateMinimumVersion(Request $request)
    {
        // In a real app, add authorization check here to ensure only admins can update
        // if (!$request->user()->isAdmin()) {
        //     return response()->json(['status' => false, 'message' => 'Unauthorized'], 403);
        // }

        $validator = Validator::make($request->all(), [
            'platform' => 'required|in:android,ios',
            'minimum_version' => 'required|string',
            'latest_version' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $platform = $request->platform;
        
        // Store new minimum and latest versions in cache
        // In production, you should use a database table for persistence
        Cache::put("minimum_version_{$platform}", $request->minimum_version, now()->addYears(1));
        Cache::put("latest_version_{$platform}", $request->latest_version, now()->addYears(1));

        return response()->json([
            'status' => true,
            'message' => 'Version requirements updated successfully',
            'data' => [
                'platform' => $platform,
                'minimum_version' => $request->minimum_version,
                'latest_version' => $request->latest_version,
            ]
        ], 200);
    }
}