<section class="bg-ink px-4 py-12" id="quote">
    <div class="mx-auto max-w-xl rounded-xl bg-white p-6">
        <h2 class="text-2xl font-extrabold">Get a quote</h2>
        <p class="mb-4 text-ink/70">We reply by call or WhatsApp.</p>

        @if ($errors->any())
            <div class="mb-4 rounded-lg bg-red-100 p-3 text-sm text-red-800">Please check the details and try again.</div>
        @endif

        @php $input = 'mt-1 w-full rounded-lg border border-ink/20 p-3 text-base'; @endphp
        <form method="POST" action="{{ route('quote.store') }}" class="space-y-4">
            @csrf
            <input type="text" name="website" class="hidden" tabindex="-1" autocomplete="off">

            <label class="block font-semibold">Your name
                <input name="name" value="{{ old('name') }}" required class="{{ $input }}">
                @error('name')<span class="text-sm text-red-600">{{ $message }}</span>@enderror
            </label>
            <label class="block font-semibold">Phone / WhatsApp
                <input name="phone" type="tel" value="{{ old('phone') }}" required placeholder="077..." class="{{ $input }}">
                @error('phone')<span class="text-sm text-red-600">{{ $message }}</span>@enderror
            </label>
            <label class="block font-semibold">Service
                <select name="service" required class="{{ $input }}">
                    @foreach (config('autostyle.services') as $s)
                        <option @selected(old('service') === $s['title'])>{{ $s['title'] }}</option>
                    @endforeach
                </select>
            </label>
            <label class="block font-semibold">Where is the vehicle?
                <select name="location" required class="{{ $input }}">
                    @foreach (config('autostyle.areas') as $a)
                        <option @selected(old('location') === $a)>{{ $a }}</option>
                    @endforeach
                </select>
            </label>
            <label class="block font-semibold">Vehicle (make, model, year)
                <input name="vehicle" value="{{ old('vehicle') }}" placeholder="Toyota Hilux 2012" class="{{ $input }}">
            </label>
            <label class="block font-semibold">What is the problem?
                <textarea name="message" rows="3" class="{{ $input }}">{{ old('message') }}</textarea>
            </label>
            <button class="w-full rounded-lg bg-signal py-4 text-lg font-bold text-ink">Send request</button>
        </form>
    </div>
</section>
