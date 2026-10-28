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
