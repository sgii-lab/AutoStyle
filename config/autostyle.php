<?php

return [
    'name' => 'Autostyle',
    'tagline' => 'Mobile mechanic. We come to you.',
    'phone' => '+263775338736',
    'phone_display' => '+263 77 533 8736',
    'whatsapp' => '263775338736', // no + sign
    'hours' => 'Mon–Sat 7:00–18:00 · Breakdown calls: ask us',
    'google_reviews_url' => null, // paste your Google review link once your profile exists

    // Flat list used by forms and schema
    'areas' => ['Marondera', 'Mashonaland East', 'Harare'],

    // One SEO page each: /mobile-mechanic/{slug}
    'area_pages' => [
        'marondera' => [
            'name' => 'Marondera',
            'intro' => 'Autostyle is based in Marondera. Call or WhatsApp and we come to your home, workplace or roadside anywhere in town.',
        ],
        'mashonaland-east' => [
            'name' => 'Mashonaland East',
            'intro' => 'We travel across Mashonaland East, including the towns and farms around Marondera. Send your location and we will confirm travel and price.',
        ],
        'harare' => [
            'name' => 'Harare',
            'intro' => 'Need a mechanic in Harare but cannot get your car to a workshop? We travel to Harare for diagnostics, servicing and repairs.',
        ],
    ],

    'trust' => [
        ['icon' => 'check', 'title' => 'Upfront quotes', 'text' => 'You know the price before work starts.'],
        ['icon' => 'pin', 'title' => 'We come to you', 'text' => 'Home, office or roadside. No towing.'],
        ['icon' => 'chat', 'title' => 'WhatsApp friendly', 'text' => 'Send photos and videos of the fault.'],
        ['icon' => 'phone', 'title' => 'Breakdown calls', 'text' => 'Call us when you are stuck.'],
    ],

    'services' => [
        [
            'slug' => 'diagnostics', 'title' => 'Diagnostics', 'icon' => 'search', 'price' => 'Quote on request',
            'desc' => 'Warning lights, strange noises, poor performance. We find the fault before you spend money.',
            'points' => ['Computer scan where your vehicle supports it', 'Road test and visual inspection', 'Clear explanation and repair quote'],
        ],
        [
            'slug' => 'minor-repairs', 'title' => 'Minor repairs', 'icon' => 'wrench', 'price' => 'Quote on request',
            'desc' => 'Small fixes done where your car is parked, so you do not lose a day at a workshop.',
            'points' => ['Batteries, belts, lights and filters', 'Brake pads and basic brake work', 'Leaks, hoses and small replacements'],
        ],
        [
            'slug' => 'vehicle-servicing', 'title' => 'Vehicle servicing', 'icon' => 'check', 'price' => 'Quote on request',
            'desc' => 'Regular servicing at your home or office to keep your vehicle reliable.',
            'points' => ['Oil and filter changes', 'Spark plugs and fluid checks', 'Safety check with a clear report'],
        ],
        [
            'slug' => 'major-mechanical-repairs', 'title' => 'Major mechanical repairs', 'icon' => 'gear', 'price' => 'Inspect then quote',
            'desc' => 'Bigger jobs, inspected first and quoted upfront so there are no surprises.',
            'points' => ['Clutch, suspension and steering', 'Cooling system and overheating faults', 'Engine and gearbox issues (assessed case by case)'],
        ],
        [
            'slug' => 'breakdown-assistance', 'title' => 'Breakdown assistance', 'icon' => 'alert', 'price' => 'Call for price',
            'desc' => 'Stuck on the road? Send your location on WhatsApp and we come to you.',
            'points' => ['Roadside diagnosis and repair where possible', 'Jump starts and battery replacement', 'Advice if the car needs a workshop'],
        ],
        [
            'slug' => 'not-sure', 'title' => 'Not sure? Tell us the problem', 'icon' => 'help', 'price' => 'Free advice',
            'desc' => 'Describe what is happening and we will tell you what it could be and what to do next.',
            'points' => ['Send photos, videos or a voice note', 'We advise before you commit', 'Quote if a visit is needed'],
        ],
    ],

    // PLACEHOLDERS: shown ONLY when APP_ENV=local so you can preview the layout.
    // They never appear on the live site. Replace with real customer reviews
    // (and remove 'placeholder' => true) once you have them.
    'testimonials' => [
        ['name' => 'Customer name', 'area' => 'Marondera', 'text' => 'Example review text. Replace with a real customer comment.', 'placeholder' => true],
        ['name' => 'Customer name', 'area' => 'Harare', 'text' => 'Example review text. Replace with a real customer comment.', 'placeholder' => true],
        ['name' => 'Customer name', 'area' => 'Mashonaland East', 'text' => 'Example review text. Replace with a real customer comment.', 'placeholder' => true],
    ],
];
