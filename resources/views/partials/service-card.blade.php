<a href="{{ route('services') }}#{{ $s['slug'] }}" class="block overflow-hidden rounded-xl bg-white shadow-sm transition hover:shadow-md">
    @include('partials.photo', ['name' => 'service-' . $s['slug'] . '.jpg', 'alt' => $s['title'] . ' in Marondera', 'class' => 'h-40 w-full', 'icon' => $s['icon']])
    <div class="p-5">
        <div class="flex items-center gap-2 text-signal">
            @include('partials.icon', ['name' => $s['icon']])
            <h3 class="text-lg font-bold text-ink">{{ $s['title'] }}</h3>
        </div>
        <p class="mt-2 text-ink/70">{{ $s['desc'] }}</p>
        <p class="mt-3 text-sm font-bold text-ink">{{ $s['price'] }} →</p>
    </div>
</a>
