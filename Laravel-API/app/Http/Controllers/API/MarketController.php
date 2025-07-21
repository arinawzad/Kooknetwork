<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class MarketController extends Controller
{
    /**
     * Get current market prices
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getMarketPrices()
    {
        // This would typically come from an external API or database
        // Mocking sample data for demonstration
        $marketPrices = [
            [
                'name' => 'Kook Coin',
                'symbol' => 'KOOK',
                'price' => 1.45,
                'change' => 5.7,
            ],
            [
                'name' => 'Bitcoin',
                'symbol' => 'BTC',
                'price' => 63248.10,
                'change' => 2.3,
            ],
            [
                'name' => 'Ethereum',
                'symbol' => 'ETH',
                'price' => 2751.82,
                'change' => -1.2,
            ]
        ];

        return response()->json([
            'status' => 'success',
            'data' => $marketPrices
        ]);
    }
}