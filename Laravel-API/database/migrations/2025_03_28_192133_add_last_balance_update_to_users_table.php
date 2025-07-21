<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddMiningColumnsToUsersTable extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            // Add base balance column
            if (!Schema::hasColumn('users', 'base_balance')) {
                $table->decimal('base_balance', 15, 2)->default(0)->after('team_id');
            }
            
            // Add mining rate column
            if (!Schema::hasColumn('users', 'mining_rate')) {
                $table->decimal('mining_rate', 8, 2)->default(0.25)->after('base_balance');
            }
            
            // Add last balance update timestamp
            if (!Schema::hasColumn('users', 'last_balance_update')) {
                $table->timestamp('last_balance_update')->nullable()->after('mining_rate');
            }
            
            // Add mining session start
            if (!Schema::hasColumn('users', 'mining_session_start')) {
                $table->timestamp('mining_session_start')->nullable()->after('last_balance_update');
            }
            
            // Add mining session end
            if (!Schema::hasColumn('users', 'mining_session_end')) {
                $table->timestamp('mining_session_end')->nullable()->after('mining_session_start');
            }
            
            // Add mining status
            if (!Schema::hasColumn('users', 'mining_status')) {
                $table->enum('mining_status', ['idle', 'active', 'completed', 'failed'])->default('idle')->after('mining_session_end');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            // Columns to potentially remove
            $columnsToRemove = [
                'base_balance', 
                'mining_rate', 
                'last_balance_update',
                'mining_session_start', 
                'mining_session_end', 
                'mining_status'
            ];

            // Drop columns only if they exist
            foreach ($columnsToRemove as $column) {
                if (Schema::hasColumn('users', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
}