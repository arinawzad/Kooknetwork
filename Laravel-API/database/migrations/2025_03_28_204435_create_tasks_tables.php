<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Create tasks table
        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->double('reward', 8, 2);
            $table->date('due_date');
            $table->boolean('is_active')->default(true);
            $table->enum('action_type', ['url', 'video', 'in_app', 'simple'])->default('simple');
            $table->text('action_data')->nullable(); // URL or other action data
            $table->string('verification_code')->nullable(); // Code for verification
            $table->timestamps();
        });

        // Create task completions table
        Schema::create('task_completions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('task_id')->constrained()->onDelete('cascade');
            $table->string('verification_code')->nullable();
            $table->timestamp('completed_at');
            $table->timestamps();
            
            // Each user can complete a task only once
            $table->unique(['user_id', 'task_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('task_completions');
        Schema::dropIfExists('tasks');
    }
};