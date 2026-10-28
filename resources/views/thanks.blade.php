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
