<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('home');
})->name('home');

Route::get('/privacy-policy', function () {
    return view('privacy-policy');
})->name('privacy-policy');

Route::get('/terms-of-service', function () {
    return view('terms-of-service');
})->name('terms-of-service');

Route::get('/cookie-policy', function () {
    return view('cookie-policy');
})->name('cookie-policy');

Route::get('/Team-Mining', function () {
    return view('Team-Mining');
})->name('Team-Mining');