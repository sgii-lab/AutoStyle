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
