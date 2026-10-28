#!/usr/bin/env bash
# Autostyle v2 upgrade. Run from the Laravel project root AFTER autostyle-setup.sh:
#   bash ../autostyle-upgrade.sh
# It overwrites the earlier config, controllers, routes and views.
set -e
[ -f artisan ] || { echo "Run this from your Laravel project root."; exit 1; }

mkdir -p resources/views/partials public/images app/Http/Controllers
rm -f public/robots.txt

# ---------- CONFIG ----------
cat > config/autostyle.php <<'EOF'
<?php

return [
    'name' => 'Autostyle',
    'tagline' => 'Mobile mechanic. We come to you.',
    'phone' => '+263775338736',
    'phone_display' => '+263 77 533 8736',
    'whatsapp' => '263775338736', // no + sign
    'hours' => 'Mon–Sat 7:00–18:00 · Breakdown calls: ask us',
    'google_reviews_url' => null, // paste your Google review link once your profile exists

    // Flat list used by forms and schema
    'areas' => ['Marondera', 'Mashonaland East', 'Harare'],

    // One SEO page each: /mobile-mechanic/{slug}
    'area_pages' => [
        'marondera' => [
            'name' => 'Marondera',
            'intro' => 'Autostyle is based in Marondera. Call or WhatsApp and we come to your home, workplace or roadside anywhere in town.',
        ],
        'mashonaland-east' => [
            'name' => 'Mashonaland East',
            'intro' => 'We travel across Mashonaland East, including the towns and farms around Marondera. Send your location and we will confirm travel and price.',
        ],
        'harare' => [
            'name' => 'Harare',
            'intro' => 'Need a mechanic in Harare but cannot get your car to a workshop? We travel to Harare for diagnostics, servicing and repairs.',
        ],
    ],

    'trust' => [
        ['icon' => 'check', 'title' => 'Upfront quotes', 'text' => 'You know the price before work starts.'],
        ['icon' => 'pin', 'title' => 'We come to you', 'text' => 'Home, office or roadside. No towing.'],
        ['icon' => 'chat', 'title' => 'WhatsApp friendly', 'text' => 'Send photos and videos of the fault.'],
        ['icon' => 'phone', 'title' => 'Breakdown calls', 'text' => 'Call us when you are stuck.'],
    ],

    'services' => [
        [
            'slug' => 'diagnostics', 'title' => 'Diagnostics', 'icon' => 'search', 'price' => 'Quote on request',
            'desc' => 'Warning lights, strange noises, poor performance. We find the fault before you spend money.',
            'points' => ['Computer scan where your vehicle supports it', 'Road test and visual inspection', 'Clear explanation and repair quote'],
        ],
        [
            'slug' => 'minor-repairs', 'title' => 'Minor repairs', 'icon' => 'wrench', 'price' => 'Quote on request',
            'desc' => 'Small fixes done where your car is parked, so you do not lose a day at a workshop.',
            'points' => ['Batteries, belts, lights and filters', 'Brake pads and basic brake work', 'Leaks, hoses and small replacements'],
        ],
        [
            'slug' => 'vehicle-servicing', 'title' => 'Vehicle servicing', 'icon' => 'check', 'price' => 'Quote on request',
            'desc' => 'Regular servicing at your home or office to keep your vehicle reliable.',
            'points' => ['Oil and filter changes', 'Spark plugs and fluid checks', 'Safety check with a clear report'],
        ],
        [
            'slug' => 'major-mechanical-repairs', 'title' => 'Major mechanical repairs', 'icon' => 'gear', 'price' => 'Inspect then quote',
            'desc' => 'Bigger jobs, inspected first and quoted upfront so there are no surprises.',
            'points' => ['Clutch, suspension and steering', 'Cooling system and overheating faults', 'Engine and gearbox issues (assessed case by case)'],
        ],
        [
            'slug' => 'breakdown-assistance', 'title' => 'Breakdown assistance', 'icon' => 'alert', 'price' => 'Call for price',
            'desc' => 'Stuck on the road? Send your location on WhatsApp and we come to you.',
            'points' => ['Roadside diagnosis and repair where possible', 'Jump starts and battery replacement', 'Advice if the car needs a workshop'],
        ],
        [
            'slug' => 'not-sure', 'title' => 'Not sure? Tell us the problem', 'icon' => 'help', 'price' => 'Free advice',
            'desc' => 'Describe what is happening and we will tell you what it could be and what to do next.',
            'points' => ['Send photos, videos or a voice note', 'We advise before you commit', 'Quote if a visit is needed'],
        ],
    ],

    // PLACEHOLDERS: shown ONLY when APP_ENV=local so you can preview the layout.
    // They never appear on the live site. Replace with real customer reviews
    // (and remove 'placeholder' => true) once you have them.
    'testimonials' => [
        ['name' => 'Customer name', 'area' => 'Marondera', 'text' => 'Example review text. Replace with a real customer comment.', 'placeholder' => true],
        ['name' => 'Customer name', 'area' => 'Harare', 'text' => 'Example review text. Replace with a real customer comment.', 'placeholder' => true],
        ['name' => 'Customer name', 'area' => 'Mashonaland East', 'text' => 'Example review text. Replace with a real customer comment.', 'placeholder' => true],
    ],
];
EOF

# ---------- CONTROLLERS ----------
cat > app/Http/Controllers/PageController.php <<'EOF'
<?php

namespace App\Http\Controllers;

class PageController extends Controller
{
    public function home() { return view('home'); }
    public function services() { return view('services'); }
    public function about() { return view('about'); }
    public function contact() { return view('contact'); }

    public function area(string $slug)
    {
        $area = config("autostyle.area_pages.$slug");
        abort_unless($area, 404);

        return view('area', ['area' => $area, 'slug' => $slug]);
    }

    public function thanks()
    {
        if (! session('wa')) {
            return redirect()->route('home');
        }

        return view('thanks', ['wa' => session('wa')]);
    }

    public function sitemap()
    {
        $urls = [route('home'), route('services'), route('about'), route('contact')];
        foreach (array_keys(config('autostyle.area_pages')) as $slug) {
            $urls[] = route('area', $slug);
        }

        return response()->view('sitemap', compact('urls'))->header('Content-Type', 'application/xml');
    }

    public function robots()
    {
        return response("User-agent: *\nAllow: /\nSitemap: " . url('/sitemap.xml') . "\n")
            ->header('Content-Type', 'text/plain');
    }
}
EOF

cat > app/Http/Controllers/QuoteRequestController.php <<'EOF'
<?php

namespace App\Http\Controllers;

use App\Models\QuoteRequest;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class QuoteRequestController extends Controller
{
    public function store(Request $request)
    {
        // Honeypot: bots fill the hidden "website" field
        if ($request->filled('website')) {
            return redirect()->route('home');
        }

        $data = $request->validate([
            'name' => 'required|string|max:80',
            'phone' => ['required', 'regex:/^[0-9+\s()-]{7,20}$/'],
            'service' => ['required', Rule::in(collect(config('autostyle.services'))->pluck('title')->all())],
            'location' => ['required', Rule::in(config('autostyle.areas'))],
            'vehicle' => 'nullable|string|max:120',
            'message' => 'nullable|string|max:1000',
        ]);

        QuoteRequest::create($data);

        $text = "Hi Autostyle, I'm {$data['name']} ({$data['phone']}).\n"
            . "Service: {$data['service']}\nLocation: {$data['location']}\n"
            . 'Vehicle: ' . ($data['vehicle'] ?? '-') . "\n"
            . 'Issue: ' . ($data['message'] ?? '-');

        return redirect()->route('thanks')->with(
            'wa',
            'https://wa.me/' . config('autostyle.whatsapp') . '?text=' . rawurlencode($text)
        );
    }
}
EOF

# ---------- ROUTES ----------
cat > routes/web.php <<'EOF'
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
EOF

# ---------- PARTIALS ----------
cat > resources/views/partials/icon.blade.php <<'EOF'
<svg class="{{ $class ?? 'h-6 w-6' }}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
@switch($name)
    @case('search') <circle cx="11" cy="11" r="7"/><path d="M21 21l-4.35-4.35"/> @break
    @case('wrench') <path d="M21.75 6.75a4.5 4.5 0 01-4.884 4.484c-1.076-.091-2.264.071-2.95.904l-7.152 8.684a2.548 2.548 0 11-3.586-3.586l8.684-7.152c.833-.686.995-1.874.904-2.95a4.5 4.5 0 016.336-4.486l-3.276 3.276a3.004 3.004 0 002.25 2.25l3.276-3.276c.256.565.398 1.192.398 1.852z"/> @break
    @case('check') <circle cx="12" cy="12" r="9"/><path d="M8.5 12.5l2.5 2.5 4.5-5"/> @break
    @case('gear') <circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3M4.9 4.9L7 7M17 17l2.1 2.1M4.9 19.1L7 17M17 7l2.1-2.1"/> @break
    @case('alert') <path d="M12 3L2 20h20L12 3z"/><path d="M12 10v4M12 17h.01"/> @break
    @case('help') <circle cx="12" cy="12" r="9"/><path d="M9.5 9a2.5 2.5 0 115 0c0 1.5-2.5 2-2.5 4M12 17h.01"/> @break
    @case('pin') <path d="M12 21s7-6.2 7-11a7 7 0 10-14 0c0 4.8 7 11 7 11z"/><circle cx="12" cy="10" r="2.5"/> @break
    @case('chat') <path d="M21 12a8 8 0 01-11.6 7.1L3 21l1.9-5.4A8 8 0 1121 12z"/> @break
    @case('phone') <path d="M5 4h4l2 5-2.5 1.5a11 11 0 005 5L15 13l5 2v4a2 2 0 01-2 2A16 16 0 013 6a2 2 0 012-2z"/> @break
@endswitch
</svg>
EOF

cat > resources/views/partials/photo.blade.php <<'EOF'
@php $exists = file_exists(public_path('images/' . $name)); @endphp
@if ($exists)
    <img src="{{ asset('images/' . $name) }}" alt="{{ $alt ?? '' }}" loading="lazy" class="{{ $class ?? '' }} object-cover">
@else
    <div class="{{ $class ?? '' }} flex flex-col items-center justify-center gap-2 bg-gradient-to-br from-ink to-ink/70 p-3 text-center text-xs text-white/60">
        @include('partials.icon', ['name' => $icon ?? 'wrench', 'class' => 'h-10 w-10 text-signal'])
        @if (app()->environment('local'))
            <span>Add photo: public/images/{{ $name }}</span>
        @endif
    </div>
@endif
EOF

cat > resources/views/partials/service-card.blade.php <<'EOF'
<a href="{{ route('services') }}#{{ $s['slug'] }}" class="block overflow-hidden rounded-xl bg-white shadow-sm transition hover:shadow-md">
    @include('partials.photo', ['name' => 'service-' . $s['slug'] . '.jpg', 'alt' => $s['title'] . ' in Marondera', 'class' => 'h-40 w-full', 'icon' => $s['icon']])
    <div class="p-5">
        <div class="flex items-center gap-2 text-signal">
            @include('partials.icon', ['name' => $s['icon']])
            <h3 class="text-lg font-bold text-ink">{{ $s['title'] }}</h3>
        </div>
        <p class="mt-2 text-ink/70">{{ $s['desc'] }}</p>
        <p class="mt-3 text-sm font-bold text-ink">{{ $s['price'] }} →</p>
    </div>
</a>
EOF

cat > resources/views/partials/gallery.blade.php <<'EOF'
@php
    $all = collect(range(1, 6))->map(fn ($i) => "work-$i.jpg");
    $have = $all->filter(fn ($f) => file_exists(public_path('images/' . $f)));
    $show = app()->environment('local') ? $all : $have;
@endphp
@if ($show->isNotEmpty())
<section class="px-4 py-12">
    <div class="mx-auto max-w-5xl">
        <h2 class="text-3xl font-extrabold">Our work</h2>
        <p class="mt-2 text-ink/70">Real jobs, real vehicles, done on site.</p>
        <div class="mt-6 grid grid-cols-2 gap-3 md:grid-cols-3">
            @foreach ($show as $f)
                @include('partials.photo', ['name' => $f, 'alt' => 'Autostyle mobile mechanic at work', 'class' => 'aspect-[4/3] w-full rounded-xl'])
            @endforeach
        </div>
    </div>
</section>
@endif
EOF

cat > resources/views/partials/testimonials.blade.php <<'EOF'
@php
    $list = collect(config('autostyle.testimonials'))
        ->reject(fn ($t) => ($t['placeholder'] ?? false) && ! app()->environment('local'));
@endphp
@if ($list->isNotEmpty())
<section class="bg-white px-4 py-12">
    <div class="mx-auto max-w-5xl">
        <h2 class="text-3xl font-extrabold">What customers say</h2>
        <div class="mt-6 grid gap-4 md:grid-cols-3">
            @foreach ($list as $t)
                <figure class="relative rounded-xl bg-paper p-5">
                    @if ($t['placeholder'] ?? false)
                        <span class="absolute right-3 top-3 rounded bg-red-100 px-2 py-0.5 text-xs font-bold text-red-700">SAMPLE (local only)</span>
                    @endif
                    <div class="text-signal" aria-label="5 stars">★★★★★</div>
                    <blockquote class="mt-2 text-ink/80">“{{ $t['text'] }}”</blockquote>
                    <figcaption class="mt-3 text-sm font-bold">{{ $t['name'] }} · {{ $t['area'] }}</figcaption>
                </figure>
            @endforeach
        </div>
        @if (config('autostyle.google_reviews_url'))
            <p class="mt-6"><a class="font-bold underline" href="{{ config('autostyle.google_reviews_url') }}">Read our Google reviews →</a></p>
        @endif
    </div>
</section>
@endif
EOF

cat > resources/views/partials/quote-form.blade.php <<'EOF'
<section class="bg-ink px-4 py-12" id="quote">
    <div class="mx-auto max-w-xl rounded-xl bg-white p-6">
        <h2 class="text-2xl font-extrabold">Get a quote</h2>
        <p class="mb-4 text-ink/70">We reply by call or WhatsApp.</p>

        @if ($errors->any())
            <div class="mb-4 rounded-lg bg-red-100 p-3 text-sm text-red-800">Please check the details and try again.</div>
        @endif

        @php $input = 'mt-1 w-full rounded-lg border border-ink/20 p-3 text-base'; @endphp
        <form method="POST" action="{{ route('quote.store') }}" class="space-y-4">
            @csrf
            <input type="text" name="website" class="hidden" tabindex="-1" autocomplete="off">

            <label class="block font-semibold">Your name
                <input name="name" value="{{ old('name') }}" required class="{{ $input }}">
                @error('name')<span class="text-sm text-red-600">{{ $message }}</span>@enderror
            </label>
            <label class="block font-semibold">Phone / WhatsApp
                <input name="phone" type="tel" value="{{ old('phone') }}" required placeholder="077..." class="{{ $input }}">
                @error('phone')<span class="text-sm text-red-600">{{ $message }}</span>@enderror
            </label>
            <label class="block font-semibold">Service
                <select name="service" required class="{{ $input }}">
                    @foreach (config('autostyle.services') as $s)
                        <option @selected(old('service') === $s['title'])>{{ $s['title'] }}</option>
                    @endforeach
                </select>
            </label>
            <label class="block font-semibold">Where is the vehicle?
                <select name="location" required class="{{ $input }}">
                    @foreach (config('autostyle.areas') as $a)
                        <option @selected(old('location') === $a)>{{ $a }}</option>
                    @endforeach
                </select>
            </label>
            <label class="block font-semibold">Vehicle (make, model, year)
                <input name="vehicle" value="{{ old('vehicle') }}" placeholder="Toyota Hilux 2012" class="{{ $input }}">
            </label>
            <label class="block font-semibold">What is the problem?
                <textarea name="message" rows="3" class="{{ $input }}">{{ old('message') }}</textarea>
            </label>
            <button class="w-full rounded-lg bg-signal py-4 text-lg font-bold text-ink">Send request</button>
        </form>
    </div>
</section>
EOF

# ---------- LAYOUT ----------
cat > resources/views/layouts/app.blade.php <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', 'Autostyle | Mobile Mechanic in Marondera, Mash East & Harare')</title>
    <meta name="description" content="@yield('description', 'Autostyle is a mobile mechanic serving Marondera, Mashonaland East and Harare. Diagnostics, servicing, repairs and breakdown assistance. Call or WhatsApp for a quote.')">
    <meta name="theme-color" content="#1c1f23">
    <meta property="og:title" content="@yield('title', 'Autostyle | Mobile Mechanic in Marondera, Mash East & Harare')">
    <meta property="og:type" content="website">
    <meta property="og:url" content="{{ url()->current() }}">
    @if (file_exists(public_path('images/hero.jpg')))
        <meta property="og:image" content="{{ asset('images/hero.jpg') }}">
    @endif
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <script type="application/ld+json">
    {!! json_encode([
        '@context' => 'https://schema.org',
        '@type' => 'AutoRepair',
        'name' => config('autostyle.name'),
        'telephone' => config('autostyle.phone'),
        'url' => url('/'),
        'areaServed' => config('autostyle.areas'),
        'address' => ['@type' => 'PostalAddress', 'addressLocality' => 'Marondera', 'addressCountry' => 'ZW'],
    ], JSON_UNESCAPED_SLASHES) !!}
    </script>
</head>
<body class="bg-paper pb-20 font-sans text-ink antialiased md:pb-0">

<header class="relative bg-ink text-white">
    <div class="mx-auto flex max-w-5xl items-center justify-between px-4 py-3">
        <a href="{{ route('home') }}" class="text-xl font-extrabold tracking-tight">Auto<span class="text-signal">style</span></a>

        <nav class="hidden items-center gap-6 md:flex">
            <a href="{{ route('services') }}" class="hover:text-signal">Services</a>
            <a href="{{ route('about') }}" class="hover:text-signal">About</a>
            <a href="{{ route('contact') }}" class="hover:text-signal">Contact</a>
            <a href="tel:{{ config('autostyle.phone') }}" class="rounded-lg bg-signal px-4 py-2 font-bold text-ink">Call {{ config('autostyle.phone_display') }}</a>
        </nav>

        <details class="relative md:hidden">
            <summary class="cursor-pointer list-none rounded-lg border border-white/30 px-3 py-2 text-sm font-bold">Menu</summary>
            <div class="absolute right-0 z-40 mt-2 w-48 space-y-1 rounded-lg bg-white p-2 text-ink shadow-lg">
                <a class="block rounded p-2 hover:bg-paper" href="{{ route('home') }}">Home</a>
                <a class="block rounded p-2 hover:bg-paper" href="{{ route('services') }}">Services</a>
                <a class="block rounded p-2 hover:bg-paper" href="{{ route('about') }}">About</a>
                <a class="block rounded p-2 hover:bg-paper" href="{{ route('contact') }}">Contact</a>
            </div>
        </details>
    </div>
</header>

<main>@yield('content')</main>

<footer class="bg-ink px-4 py-10 text-sm text-white/70">
    <div class="mx-auto grid max-w-5xl gap-6 md:grid-cols-3">
        <div class="space-y-1">
            <p class="font-bold text-white">{{ config('autostyle.name') }} · Mobile mechanic</p>
            <p>{{ config('autostyle.hours') }}</p>
            <p><a class="underline" href="tel:{{ config('autostyle.phone') }}">{{ config('autostyle.phone_display') }}</a></p>
        </div>
        <div class="space-y-1">
            <p class="font-bold text-white">Areas</p>
            @foreach (config('autostyle.area_pages') as $slug => $a)
                <p><a class="underline" href="{{ route('area', $slug) }}">Mobile mechanic {{ $a['name'] }}</a></p>
            @endforeach
        </div>
        <div class="space-y-1">
            <p class="font-bold text-white">Pages</p>
            <p><a class="underline" href="{{ route('services') }}">Services</a></p>
            <p><a class="underline" href="{{ route('about') }}">About</a></p>
            <p><a class="underline" href="{{ route('contact') }}">Contact</a></p>
        </div>
    </div>
    <p class="mx-auto mt-6 max-w-5xl">© {{ date('Y') }} Autostyle</p>
</footer>

<nav class="fixed inset-x-0 bottom-0 z-50 grid grid-cols-2 gap-2 bg-ink p-2 md:hidden">
    <a href="tel:{{ config('autostyle.phone') }}" class="rounded-lg bg-signal py-3 text-center font-bold text-ink">Call now</a>
    <a href="https://wa.me/{{ config('autostyle.whatsapp') }}?text={{ rawurlencode('Hi Autostyle, I need a mechanic.') }}" class="rounded-lg bg-green-500 py-3 text-center font-bold text-white">WhatsApp</a>
</nav>

</body>
</html>
EOF

# ---------- HOME ----------
cat > resources/views/home.blade.php <<'EOF'
@extends('layouts.app')

@section('content')

@php $hero = file_exists(public_path('images/hero.jpg')); @endphp
<section class="bg-ink px-4 py-14 text-white"
    @if ($hero) style="background-image:linear-gradient(rgba(28,31,35,.82),rgba(28,31,35,.82)),url('{{ asset('images/hero.jpg') }}');background-size:cover;background-position:center" @endif>
    <div class="mx-auto max-w-5xl">
        <p class="mb-2 font-semibold text-signal">Marondera · Mash East · Harare</p>
        <h1 class="text-4xl font-extrabold leading-tight md:text-5xl">A mechanic that comes to you.</h1>
        <p class="mt-4 max-w-xl text-lg text-white/80">Diagnostics, servicing and repairs at your home, office or roadside. Upfront quotes, no towing needed.</p>
        <div class="mt-6 flex flex-col gap-3 sm:flex-row">
            <a href="tel:{{ config('autostyle.phone') }}" class="rounded-lg bg-signal px-6 py-4 text-center text-lg font-bold text-ink">Call {{ config('autostyle.phone_display') }}</a>
            <a href="https://wa.me/{{ config('autostyle.whatsapp') }}?text={{ rawurlencode('Hi Autostyle, I need a mechanic.') }}" class="rounded-lg bg-green-500 px-6 py-4 text-center text-lg font-bold text-white">WhatsApp us</a>
        </div>
    </div>
</section>

{{-- Trust strip --}}
<section class="bg-white px-4 py-8">
    <div class="mx-auto grid max-w-5xl gap-4 sm:grid-cols-2 lg:grid-cols-4">
        @foreach (config('autostyle.trust') as $t)
            <div class="flex items-start gap-3">
                <span class="mt-1 text-signal">@include('partials.icon', ['name' => $t['icon'], 'class' => 'h-7 w-7'])</span>
                <div><p class="font-bold">{{ $t['title'] }}</p><p class="text-sm text-ink/70">{{ $t['text'] }}</p></div>
            </div>
        @endforeach
    </div>
</section>

{{-- Services --}}
<section class="px-4 py-12" id="services">
    <div class="mx-auto max-w-5xl">
        <h2 class="text-3xl font-extrabold">What we do</h2>
        <div class="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            @foreach (config('autostyle.services') as $s)
                @include('partials.service-card', ['s' => $s])
            @endforeach
        </div>
    </div>
</section>

{{-- How it works --}}
<section class="bg-white px-4 py-12">
    <div class="mx-auto max-w-5xl">
        <h2 class="text-3xl font-extrabold">How it works</h2>
        <ol class="mt-6 grid gap-4 md:grid-cols-3">
            <li class="rounded-xl bg-paper p-5"><b class="text-signal">1.</b> Call, WhatsApp or send the form below.</li>
            <li class="rounded-xl bg-paper p-5"><b class="text-signal">2.</b> We confirm the problem and give you a price.</li>
            <li class="rounded-xl bg-paper p-5"><b class="text-signal">3.</b> We come to your location and fix it.</li>
        </ol>
    </div>
</section>

@include('partials.gallery')
@include('partials.testimonials')

{{-- Areas --}}
<section class="px-4 py-12">
    <div class="mx-auto max-w-5xl">
        <h2 class="text-3xl font-extrabold">Where we work</h2>
        <p class="mt-3 text-lg">Based in <b>Marondera</b>. We cover all of <b>Mashonaland East</b> and travel to <b>Harare</b>.</p>
        <div class="mt-4 flex flex-wrap gap-3">
            @foreach (config('autostyle.area_pages') as $slug => $a)
                <a href="{{ route('area', $slug) }}" class="rounded-full bg-white px-4 py-2 font-semibold shadow-sm hover:text-signal">Mobile mechanic {{ $a['name'] }} →</a>
            @endforeach
        </div>
    </div>
</section>

@include('partials.quote-form')

{{-- FAQ --}}
<section class="px-4 py-12">
    <div class="mx-auto max-w-5xl space-y-3">
        <h2 class="text-3xl font-extrabold">Questions</h2>
        <details class="rounded-xl bg-white p-4"><summary class="cursor-pointer font-bold">Do you charge a call-out fee?</summary>
            <p class="mt-2 text-ink/70">Travel depends on distance. We confirm the full price before we leave.</p></details>
        <details class="rounded-xl bg-white p-4"><summary class="cursor-pointer font-bold">Can you fix it on the spot?</summary>
            <p class="mt-2 text-ink/70">Most diagnostics, servicing and minor repairs, yes. For major work we inspect and quote first.</p></details>
        <details class="rounded-xl bg-white p-4"><summary class="cursor-pointer font-bold">Do you supply the parts?</summary>
            <p class="mt-2 text-ink/70">Edit this answer: say whether you supply parts or the customer can provide their own.</p></details>
        <details class="rounded-xl bg-white p-4"><summary class="cursor-pointer font-bold">How do I pay?</summary>
            <p class="mt-2 text-ink/70">Edit this answer with the payment methods you accept (cash, EcoCash, etc.).</p></details>
        <details class="rounded-xl bg-white p-4"><summary class="cursor-pointer font-bold">Is my car too far away?</summary>
            <p class="mt-2 text-ink/70">We serve Marondera, Mashonaland East and Harare. Send your location on WhatsApp and we will confirm.</p></details>
    </div>
</section>

@endsection
EOF

# ---------- SERVICES PAGE ----------
cat > resources/views/services.blade.php <<'EOF'
@extends('layouts.app')
@section('title', 'Mobile Mechanic Services in Marondera & Harare | Autostyle')
@section('description', 'Diagnostics, servicing, minor and major repairs and breakdown assistance by a mobile mechanic in Marondera, Mashonaland East and Harare.')

@section('content')
<section class="bg-ink px-4 py-10 text-white">
    <div class="mx-auto max-w-5xl">
        <h1 class="text-4xl font-extrabold">Our services</h1>
        <p class="mt-2 text-white/80">Everything done where your vehicle is.</p>
    </div>
</section>

<div class="mx-auto max-w-5xl space-y-6 px-4 py-10">
    @foreach (config('autostyle.services') as $s)
        <article id="{{ $s['slug'] }}" class="grid scroll-mt-4 overflow-hidden rounded-xl bg-white shadow-sm md:grid-cols-5">
            @include('partials.photo', ['name' => 'service-' . $s['slug'] . '.jpg', 'alt' => $s['title'], 'class' => 'h-48 w-full md:col-span-2 md:h-full', 'icon' => $s['icon']])
            <div class="p-6 md:col-span-3">
                <div class="flex items-center gap-2 text-signal">
                    @include('partials.icon', ['name' => $s['icon'], 'class' => 'h-7 w-7'])
                    <h2 class="text-2xl font-extrabold text-ink">{{ $s['title'] }}</h2>
                </div>
                <p class="mt-2 text-ink/70">{{ $s['desc'] }}</p>
                <ul class="mt-3 list-disc space-y-1 pl-5">
                    @foreach ($s['points'] as $p)<li>{{ $p }}</li>@endforeach
                </ul>
                <p class="mt-3 font-bold">{{ $s['price'] }}</p>
                <div class="mt-4 flex flex-wrap gap-2">
                    <a href="tel:{{ config('autostyle.phone') }}" class="rounded-lg bg-signal px-4 py-2 font-bold text-ink">Call</a>
                    <a href="https://wa.me/{{ config('autostyle.whatsapp') }}?text={{ rawurlencode('Hi Autostyle, I need help with: ' . $s['title']) }}" class="rounded-lg bg-green-500 px-4 py-2 font-bold text-white">WhatsApp</a>
                </div>
            </div>
        </article>
    @endforeach
</div>

@include('partials.quote-form')
@endsection
EOF

# ---------- ABOUT PAGE ----------
cat > resources/views/about.blade.php <<'EOF'
@extends('layouts.app')
@section('title', 'About Autostyle | Mobile Mechanic in Marondera')

@section('content')
<section class="bg-ink px-4 py-10 text-white">
    <div class="mx-auto max-w-5xl"><h1 class="text-4xl font-extrabold">About Autostyle</h1></div>
</section>

<div class="mx-auto grid max-w-5xl gap-8 px-4 py-10 md:grid-cols-2">
    <div class="space-y-4 text-lg">
        {{-- EDIT THIS TEXT: add your name, years of experience, training and qualifications --}}
        <p>Autostyle is a mobile mechanic service based in Marondera. We bring the workshop to you, so you do not lose time or money getting your vehicle to a garage.</p>
        <p>We serve Marondera, Mashonaland East and Harare, and give you a clear price before any work starts.</p>
        <p class="rounded-lg bg-white p-4 text-base text-ink/70">Tip: add your name, experience and any qualifications here. Customers trust a real person.</p>
        <a href="{{ route('contact') }}" class="inline-block rounded-lg bg-signal px-6 py-3 font-bold text-ink">Contact us</a>
    </div>
    @include('partials.photo', ['name' => 'about.jpg', 'alt' => 'The Autostyle mechanic', 'class' => 'aspect-[4/3] w-full rounded-xl', 'icon' => 'wrench'])
</div>

@include('partials.testimonials')
@endsection
EOF

# ---------- CONTACT PAGE ----------
cat > resources/views/contact.blade.php <<'EOF'
@extends('layouts.app')
@section('title', 'Contact Autostyle | Mobile Mechanic Marondera & Harare')

@section('content')
<section class="bg-ink px-4 py-10 text-white">
    <div class="mx-auto max-w-5xl"><h1 class="text-4xl font-extrabold">Contact us</h1></div>
</section>

<div class="mx-auto grid max-w-5xl gap-6 px-4 py-10 md:grid-cols-2">
    <div class="space-y-4">
        <a href="tel:{{ config('autostyle.phone') }}" class="block rounded-xl bg-signal p-5 text-xl font-extrabold text-ink">Call {{ config('autostyle.phone_display') }}</a>
        <a href="https://wa.me/{{ config('autostyle.whatsapp') }}?text={{ rawurlencode('Hi Autostyle, I need a mechanic.') }}" class="block rounded-xl bg-green-500 p-5 text-xl font-extrabold text-white">WhatsApp us</a>
        <div class="rounded-xl bg-white p-5">
            <p class="font-bold">Hours</p><p class="text-ink/70">{{ config('autostyle.hours') }}</p>
            <p class="mt-3 font-bold">Areas</p><p class="text-ink/70">{{ implode(', ', config('autostyle.areas')) }}</p>
        </div>
    </div>
    <iframe title="Map of Marondera" class="h-72 w-full rounded-xl border-0 md:h-full" loading="lazy"
        src="https://www.google.com/maps?q=Marondera,Zimbabwe&output=embed"></iframe>
</div>

@include('partials.quote-form')
@endsection
EOF

# ---------- AREA PAGE ----------
cat > resources/views/area.blade.php <<'EOF'
@extends('layouts.app')
@section('title', 'Mobile Mechanic in ' . $area['name'] . ' | Autostyle')
@section('description', 'Mobile mechanic in ' . $area['name'] . ': diagnostics, servicing, repairs and breakdown assistance. Call or WhatsApp Autostyle for a quote.')

@section('content')
<section class="bg-ink px-4 py-12 text-white">
    <div class="mx-auto max-w-5xl">
        <h1 class="text-4xl font-extrabold">Mobile mechanic in {{ $area['name'] }}</h1>
        <p class="mt-3 max-w-2xl text-lg text-white/80">{{ $area['intro'] }}</p>
        <div class="mt-6 flex flex-col gap-3 sm:flex-row">
            <a href="tel:{{ config('autostyle.phone') }}" class="rounded-lg bg-signal px-6 py-4 text-center text-lg font-bold text-ink">Call {{ config('autostyle.phone_display') }}</a>
            <a href="https://wa.me/{{ config('autostyle.whatsapp') }}?text={{ rawurlencode('Hi Autostyle, I need a mechanic in ' . $area['name'] . '.') }}" class="rounded-lg bg-green-500 px-6 py-4 text-center text-lg font-bold text-white">WhatsApp us</a>
        </div>
    </div>
</section>

<section class="px-4 py-12">
    <div class="mx-auto max-w-5xl">
        <h2 class="text-3xl font-extrabold">Services in {{ $area['name'] }}</h2>
        <div class="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            @foreach (config('autostyle.services') as $s)
                @include('partials.service-card', ['s' => $s])
            @endforeach
        </div>
    </div>
</section>

@include('partials.testimonials')
@include('partials.quote-form')
@endsection
EOF

# ---------- SITEMAP ----------
cat > resources/views/sitemap.blade.php <<'EOF'
{!! '<?xml version="1.0" encoding="UTF-8"?>' !!}
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
@foreach ($urls as $u)
    <url><loc>{{ $u }}</loc></url>
@endforeach
</urlset>
EOF

cat > public/images/README.txt <<'EOF'
Drop your real photos here (JPG, ideally under 300 KB each):

hero.jpg                  wide photo of you/van at work (home page background)
about.jpg                 you with your van or tools
work-1.jpg ... work-6.jpg gallery photos of real jobs
service-diagnostics.jpg
service-minor-repairs.jpg
service-vehicle-servicing.jpg
service-major-mechanical-repairs.jpg
service-breakdown-assistance.jpg
service-not-sure.jpg
EOF

php artisan config:clear
php artisan view:clear
npm run build || echo "npm build skipped. Run 'npm run dev' or 'npm run build' when your connection allows."
echo "Done. Add photos to public/images (see README.txt), then run: php artisan serve"
