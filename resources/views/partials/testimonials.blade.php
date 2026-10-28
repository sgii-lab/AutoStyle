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
