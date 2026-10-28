<?php

use App\Http\Controllers\PageController;
use App\Http\Controllers\QuoteRequestController;
use Illuminate\Support\Facades\Route;

Route::get('/', [PageController::class, 'home'])->name('home');
Route::get('/services', [PageController::class, 'services'])->name('services');
Route::get('/about', [PageController::class, 'about'])->name('about');
Route::get('/contact', [PageController::class, 'contact'])->name('contact');
Route::get('/mobile-mechanic/{slug}', [PageController::class, 'area'])->name('area');
Route::get('/thanks', [PageController::class, 'thanks'])->name('thanks');
Route::get('/sitemap.xml', [PageController::class, 'sitemap']);
Route::get('/robots.txt', [PageController::class, 'robots']);
Route::post('/quote', [QuoteRequestController::class, 'store'])
    ->middleware('throttle:5,1')
    ->name('quote.store');
