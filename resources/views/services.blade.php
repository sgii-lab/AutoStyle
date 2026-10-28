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
