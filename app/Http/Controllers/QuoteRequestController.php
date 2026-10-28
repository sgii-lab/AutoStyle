<?php

namespace App\Http\Controllers;

use App\Models\QuoteRequest;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class QuoteRequestController extends Controller
{
    public function store(Request $request)
    {
        // Honeypot: bots fill the hidden "website" field
        if ($request->filled('website')) {
            return redirect()->route('home');
        }

        $data = $request->validate([
            'name' => 'required|string|max:80',
            'phone' => ['required', 'regex:/^[0-9+\s()-]{7,20}$/'],
            'service' => ['required', Rule::in(collect(config('autostyle.services'))->pluck('title')->all())],
            'location' => ['required', Rule::in(config('autostyle.areas'))],
            'vehicle' => 'nullable|string|max:120',
            'message' => 'nullable|string|max:1000',
        ]);

        QuoteRequest::create($data);

        $text = "Hi Autostyle, I'm {$data['name']} ({$data['phone']}).\n"
            . "Service: {$data['service']}\nLocation: {$data['location']}\n"
            . 'Vehicle: ' . ($data['vehicle'] ?? '-') . "\n"
            . 'Issue: ' . ($data['message'] ?? '-');

        return redirect()->route('thanks')->with(
            'wa',
            'https://wa.me/' . config('autostyle.whatsapp') . '?text=' . rawurlencode($text)
        );
    }
}
