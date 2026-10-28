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
