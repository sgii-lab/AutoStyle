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
