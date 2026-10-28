<?php

namespace App\Http\Controllers;

class PageController extends Controller
{
    public function home() { return view('home'); }
    public function services() { return view('services'); }
    public function about() { return view('about'); }
    public function contact() { return view('contact'); }

    public function area(string $slug)
    {
        $area = config("autostyle.area_pages.$slug");
        abort_unless($area, 404);

        return view('area', ['area' => $area, 'slug' => $slug]);
    }

    public function thanks()
    {
        if (! session('wa')) {
            return redirect()->route('home');
        }

        return view('thanks', ['wa' => session('wa')]);
    }

    public function sitemap()
    {
        $urls = [route('home'), route('services'), route('about'), route('contact')];
        foreach (array_keys(config('autostyle.area_pages')) as $slug) {
            $urls[] = route('area', $slug);
        }

        return response()->view('sitemap', compact('urls'))->header('Content-Type', 'application/xml');
    }

    public function robots()
    {
        return response("User-agent: *\nAllow: /\nSitemap: " . url('/sitemap.xml') . "\n")
            ->header('Content-Type', 'text/plain');
    }
}
