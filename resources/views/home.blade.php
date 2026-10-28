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
