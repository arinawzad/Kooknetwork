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
        // Only add team_id column if it doesn't already exist
        if (!Schema::hasColumn('users', 'team_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->unsignedBigInteger('team_id')->nullable()->after('id');
                
                $table->foreign('team_id')->references('id')->on('teams')
                    ->onDelete('set null');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Only drop the foreign key and column if they exist
        if (Schema::hasColumn('users', 'team_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropForeign(['team_id']);
                $table->dropColumn('team_id');
            });
        }
    }
};