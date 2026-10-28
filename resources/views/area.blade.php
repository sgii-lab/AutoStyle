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
