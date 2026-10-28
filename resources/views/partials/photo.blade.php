@php $exists = file_exists(public_path('images/' . $name)); @endphp
@if ($exists)
    <img src="{{ asset('images/' . $name) }}" alt="{{ $alt ?? '' }}" loading="lazy" class="{{ $class ?? '' }} object-cover">
@else
    <div class="{{ $class ?? '' }} flex flex-col items-center justify-center gap-2 bg-gradient-to-br from-ink to-ink/70 p-3 text-center text-xs text-white/60">
        @include('partials.icon', ['name' => $icon ?? 'wrench', 'class' => 'h-10 w-10 text-signal'])
        @if (app()->environment('local'))
            <span>Add photo: public/images/{{ $name }}</span>
        @endif
    </div>
@endif
