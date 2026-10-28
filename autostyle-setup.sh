#!/usr/bin/env bash
# Autostyle MVP generator. Run from the ROOT of a fresh Laravel 12 project:
#   composer create-project laravel/laravel autostyle && cd autostyle
#   bash ../autostyle-setup.sh
set -e
[ -f artisan ] || { echo "Run this from your Laravel project root."; exit 1; }

mkdir -p resources/views/layouts app/Http/Controllers app/Models

# ---------- CONFIG ----------
cat > config/autostyle.php <<'EOF'
<?php

return [
    'name' => 'Autostyle',
    'tagline' => 'Mobile mechanic. We come to you.',
    'phone' => '+263775338736',
    'phone_display' => '+263 77 533 8736',
    'whatsapp' => '263775338736', // no + sign for wa.me links
    'hours' => 'Mon–Sat 7:00–18:00 · Breakdown calls: ask us',
    'areas' => ['Marondera', 'Mashonaland East', 'Harare'],
    'services' => [
        'Diagnostics' => 'Warning lights, strange noises, poor performance. We find the fault before you spend money.',
        'Minor repairs' => 'Brakes, batteries, belts, lights, filters, small fixes done at your home or work.',
        'Vehicle servicing' => 'Oil, filters, plugs and safety checks, done where your car is parked.',
        'Major mechanical repairs' => 'Clutch, suspension, cooling and engine work. Quoted upfront after inspection.',
        'Breakdown assistance' => 'Stuck on the road? Call or WhatsApp your location and we come to you.',
        'Not sure? Tell us the problem' => 'Describe what is happening and we will advise and quote.',
    ],
];
EOF

# ---------- MIGRATION ----------
cat > database/migrations/2026_10_20_000000_create_quote_requests_table.php <<'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('quote_requests', function (Blueprint $t) {
            $t->id();
            $t->string('name');
            $t->string('phone');
            $t->string('service');
            $t->string('location');
            $t->string('vehicle')->nullable();
            $t->text('message')->nullable();
            $t->string('status')->default('new');
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('quote_requests');
    }
};
EOF

# ---------- MODEL ----------
cat > app/Models/QuoteRequest.php <<'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QuoteRequest extends Model
{
    protected $guarded = [];
}
EOF

# ---------- CONTROLLERS ----------
cat > app/Http/Controllers/PageController.php <<'EOF'
<?php

namespace App\Http\Controllers;

class PageController extends Controller
{
    public function home()
    {
        return view('home');
    }

    public function thanks()
    {
        if (! session('wa')) {
            return redirect()->route('home');
        }

        return view('thanks', ['wa' => session('wa')]);
    }
}
EOF

cat > app/Http/Controllers/QuoteRequestController.php <<'EOF'
<?php

namespace App\Http\Controllers;

use App\Models\QuoteRequest;
use Illuminate\Http\Request;

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
            'service' => 'required|in:' . implode(',', array_keys(config('autostyle.services'))),
            'location' => 'required|in:' . implode(',', config('autostyle.areas')),
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
Route::get('/thanks', [PageController::class, 'thanks'])->name('thanks');
Route::post('/quote', [QuoteRequestController::class, 'store'])
    ->middleware('throttle:5,1')
    ->name('quote.store');
EOF

# ---------- CSS / JS ----------
cat > resources/css/app.css <<'EOF'
@import 'tailwindcss';

@source '../views/**/*.blade.php';

@theme {
    --font-sans: ui-sans-serif, system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
    --color-ink: #1c1f23;
    --color-signal: #ff8a00;
    --color-paper: #f7f5f0;
}
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
<body class="bg-paper text-ink font-sans antialiased pb-20 md:pb-0">

<header class="bg-ink text-white">
    <div class="mx-auto flex max-w-5xl items-center justify-between px-4 py-3">
        <a href="{{ route('home') }}" class="text-xl font-extrabold tracking-tight">
            Auto<span class="text-signal">style</span>
        </a>
        <a href="tel:{{ config('autostyle.phone') }}" class="hidden rounded-lg bg-signal px-4 py-2 font-bold text-ink md:block">
            Call {{ config('autostyle.phone_display') }}
        </a>
    </div>
</header>

<main>@yield('content')</main>

<footer class="bg-ink px-4 py-8 text-sm text-white/70">
    <div class="mx-auto max-w-5xl space-y-1">
        <p class="font-bold text-white">{{ config('autostyle.name') }} · Mobile mechanic</p>
        <p>Serving {{ implode(', ', config('autostyle.areas')) }}</p>
        <p>{{ config('autostyle.hours') }}</p>
        <p>© {{ date('Y') }} Autostyle</p>
    </div>
</footer>

{{-- Sticky call / WhatsApp bar (mobile) --}}
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

{{-- Hero --}}
<section class="bg-ink px-4 py-12 text-white">
    <div class="mx-auto max-w-5xl">
        <p class="mb-2 font-semibold text-signal">Marondera · Mash East · Harare</p>
        <h1 class="text-4xl font-extrabold leading-tight md:text-5xl">
            A mechanic that comes to you.
        </h1>
        <p class="mt-4 max-w-xl text-lg text-white/80">
            Diagnostics, servicing and repairs at your home, office or roadside. Upfront quotes, no towing needed.
        </p>
        <div class="mt-6 flex flex-col gap-3 sm:flex-row">
            <a href="tel:{{ config('autostyle.phone') }}" class="rounded-lg bg-signal px-6 py-4 text-center text-lg font-bold text-ink">
                Call {{ config('autostyle.phone_display') }}
            </a>
            <a href="https://wa.me/{{ config('autostyle.whatsapp') }}?text={{ rawurlencode('Hi Autostyle, I need a mechanic.') }}"
               class="rounded-lg bg-green-500 px-6 py-4 text-center text-lg font-bold text-white">
                WhatsApp us
            </a>
        </div>
    </div>
</section>

{{-- Services --}}
<section class="px-4 py-12" id="services">
    <div class="mx-auto max-w-5xl">
        <h2 class="text-3xl font-extrabold">What we do</h2>
        <div class="mt-6 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            @foreach (config('autostyle.services') as $title => $desc)
                <div class="rounded-xl bg-white p-5 shadow-sm">
                    <h3 class="text-lg font-bold">{{ $title }}</h3>
                    <p class="mt-2 text-ink/70">{{ $desc }}</p>
                </div>
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

{{-- Areas --}}
<section class="px-4 py-12">
    <div class="mx-auto max-w-5xl">
        <h2 class="text-3xl font-extrabold">Where we work</h2>
        <p class="mt-3 text-lg">
            Based in <b>Marondera</b>. We cover all of <b>Mashonaland East</b> and travel to <b>Harare</b> too.
            Not sure if we reach you? Send us your location.
        </p>
    </div>
</section>

{{-- Quote form --}}
<section class="bg-ink px-4 py-12" id="quote">
    <div class="mx-auto max-w-xl rounded-xl bg-white p-6">
        <h2 class="text-2xl font-extrabold">Get a quote</h2>
        <p class="mb-4 text-ink/70">We reply by call or WhatsApp.</p>

        @if ($errors->any())
            <div class="mb-4 rounded-lg bg-red-100 p-3 text-sm text-red-800">
                Please check the highlighted details and try again.
            </div>
        @endif

        <form method="POST" action="{{ route('quote.store') }}" class="space-y-4">
            @csrf
            <input type="text" name="website" class="hidden" tabindex="-1" autocomplete="off">

            @php $input = 'mt-1 w-full rounded-lg border border-ink/20 p-3 text-base'; @endphp

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
                    @foreach (array_keys(config('autostyle.services')) as $s)
                        <option @selected(old('service') === $s)>{{ $s }}</option>
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

{{-- FAQ --}}
<section class="px-4 py-12">
    <div class="mx-auto max-w-5xl space-y-4">
        <h2 class="text-3xl font-extrabold">Questions</h2>
        <details class="rounded-xl bg-white p-4"><summary class="font-bold">Do you charge a call-out fee?</summary>
            <p class="mt-2 text-ink/70">Travel charges depend on distance. We confirm the full price before we leave.</p></details>
        <details class="rounded-xl bg-white p-4"><summary class="font-bold">Can you fix it on the spot?</summary>
            <p class="mt-2 text-ink/70">Most diagnostics, servicing and minor repairs, yes. For major work we inspect and quote first.</p></details>
        <details class="rounded-xl bg-white p-4"><summary class="font-bold">How do you take payment?</summary>
            <p class="mt-2 text-ink/70">Tell us when you book. Update this answer with the methods you accept (cash, EcoCash, etc.).</p></details>
    </div>
</section>

@endsection
EOF

# ---------- THANKS ----------
cat > resources/views/thanks.blade.php <<'EOF'
@extends('layouts.app')

@section('title', 'Request received | Autostyle')

@section('content')
<section class="px-4 py-16">
    <div class="mx-auto max-w-xl text-center">
        <h1 class="text-3xl font-extrabold">Thank you, we got your request.</h1>
        <p class="mt-3 text-lg text-ink/70">For the fastest reply, send the details on WhatsApp now.</p>
        <a href="{{ $wa }}" class="mt-6 inline-block rounded-lg bg-green-500 px-8 py-4 text-lg font-bold text-white">
            Continue on WhatsApp
        </a>
        <p class="mt-6"><a class="underline" href="{{ route('home') }}">Back to home</a></p>
    </div>
</section>
@endsection
EOF

# ---------- FINISH ----------
sed -i 's/^APP_NAME=.*/APP_NAME=Autostyle/' .env 2>/dev/null || true
php artisan migrate --force
npm install
npm run build
echo "Done. Run: php artisan serve   (and npm run dev in a second terminal while editing)"
