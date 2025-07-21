<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Project;

class ProjectController extends Controller
{
    /**
     * Get all projects
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getProjects()
    {
        try {
            // Get the authenticated user's projects
            // You can modify this to filter by team or other criteria
            $projects = Project::all();
            
            return response()->json([
                'status' => 'success',
                'data' => $projects
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch projects',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Get a specific project
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function getProject($id)
    {
        try {
            $project = Project::findOrFail($id);
            
            return response()->json([
                'status' => 'success',
                'data' => $project
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Project not found',
                'error' => $e->getMessage()
            ], 404);
        }
    }
    
    /**
     * Create a new project
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function createProject(Request $request)
    {
        try {
            $validatedData = $request->validate([
                'name' => 'required|string|max:255',
                'status' => 'required|string|max:50',
                'progress' => 'required|numeric|min:0|max:1',
                'due_date' => 'nullable|date',
                'priority' => 'required|string|max:50',
                'tasks' => 'nullable|integer|min:0',
                'completed_tasks' => 'nullable|integer|min:0',
                'is_active' => 'required|boolean',
                'team' => 'nullable|array',
                'team.*' => 'string',
            ]);
            
            $project = Project::create($validatedData);
            
            return response()->json([
                'status' => 'success',
                'message' => 'Project created successfully',
                'data' => $project
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to create project',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Update a project
     *
     * @param \Illuminate\Http\Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateProject(Request $request, $id)
    {
        try {
            $validatedData = $request->validate([
                'name' => 'sometimes|string|max:255',
                'status' => 'sometimes|string|max:50',
                'progress' => 'sometimes|numeric|min:0|max:1',
                'due_date' => 'nullable|date',
                'priority' => 'sometimes|string|max:50',
                'tasks' => 'nullable|integer|min:0',
                'completed_tasks' => 'nullable|integer|min:0',
                'is_active' => 'sometimes|boolean',
                'team' => 'nullable|array',
                'team.*' => 'string',
            ]);
            
            $project = Project::findOrFail($id);
            $project->update($validatedData);
            
            return response()->json([
                'status' => 'success',
                'message' => 'Project updated successfully',
                'data' => $project
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to update project',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Delete a project
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function deleteProject($id)
    {
        try {
            $project = Project::findOrFail($id);
            $project->delete();
            
            return response()->json([
                'status' => 'success',
                'message' => 'Project deleted successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to delete project',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Update project progress
     *
     * @param \Illuminate\Http\Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateProgress(Request $request, $id)
    {
        try {
            $validatedData = $request->validate([
                'progress' => 'required|numeric|min:0|max:1',
                'completed_tasks' => 'nullable|integer|min:0',
            ]);
            
            $project = Project::findOrFail($id);
            
            // Update progress
            $project->progress = $validatedData['progress'];
            
            // Update completed tasks if provided
            if (isset($validatedData['completed_tasks'])) {
                $project->completed_tasks = $validatedData['completed_tasks'];
            }
            
            // Auto-update status based on progress
            if ($project->progress >= 1.0) {
                $project->status = 'Completed';
            } elseif ($project->progress > 0) {
                $project->status = 'In Progress';
            }
            
            $project->save();
            
            return response()->json([
                'status' => 'success',
                'message' => 'Project progress updated successfully',
                'data' => $project
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to update project progress',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Get active projects
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getActiveProjects()
    {
        try {
            $projects = Project::where('is_active', true)->get();
            
            return response()->json([
                'status' => 'success',
                'data' => $projects
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch active projects',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Get upcoming projects
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getUpcomingProjects()
    {
        try {
            $projects = Project::where('is_active', false)->get();
            
            return response()->json([
                'status' => 'success',
                'data' => $projects
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to fetch upcoming projects',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}