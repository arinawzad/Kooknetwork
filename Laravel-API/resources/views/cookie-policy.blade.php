@extends('layouts.app')

@section('title', 'Cookie Policy - KOOK Network')

@section('content')
<div class="max-w-4xl mx-auto px-4 py-12">
    <h1 class="text-3xl font-bold mb-6 text-gray-900">Cookie Policy</h1>
    
    <div class="prose prose-indigo max-w-none">
        <p class="text-gray-600 mb-6">Last updated: {{ now()->format('F d, Y') }}</p>
        
        <h2 class="text-2xl font-semibold mb-4">1. What Are Cookies?</h2>
        <p>Cookies are small text files placed on your device to collect standard internet log information and visitor behavior data. When you visit our website, we may collect information from you automatically through cookies.</p>
        
        <h2 class="text-2xl font-semibold mb-4">2. Types of Cookies We Use</h2>
        <h3 class="text-xl font-semibold mb-3">Essential Cookies</h3>
        <p>These are necessary for the basic functioning of our website:</p>
        <ul class="list-disc pl-6 mb-4">
            <li>Session management</li>
            <li>Security features</li>
            <li>Authentication</li>
        </ul>
        
        <h3 class="text-xl font-semibold mb-3">Analytics Cookies</h3>
        <p>These help us understand how users interact with our website:</p>
        <ul class="list-disc pl-6 mb-4">
            <li>Page visits</li>
            <li>Time spent on pages</li>
            <li>User interactions</li>
        </ul>
        
        <h3 class="text-xl font-semibold mb-3">Performance Cookies</h3>
        <p>These improve website performance and user experience:</p>
        <ul class="list-disc pl-6 mb-4">
            <li>Caching</li>
            <li>Load balancing</li>
            <li>Content delivery</li>
        </ul>
        
        <h2 class="text-2xl font-semibold mb-4">3. How We Use Cookies</h2>
        <p>KOOK Network uses cookies to:</p>
        <ul class="list-disc pl-6 mb-4">
            <li>Remember your login details</li>
            <li>Understand website traffic</li>
            <li>Personalize user experience</li>
            <li>Analyze and improve our services</li>
        </ul>
        
        <h2 class="text-2xl font-semibold mb-4">4. Managing Cookies</h2>
        <p>You can control and/or delete cookies as you wish. Most web browsers allow some control of most cookies through browser settings. To find out more about cookies, including how to see what cookies have been set and how to manage and delete them, visit <a href="https://www.aboutcookies.org" class="text-indigo-600">www.aboutcookies.org</a>.</p>
        
        <h2 class="text-2xl font-semibold mb-4">5. Third-Party Cookies</h2>
        <p>We may use third-party services that set cookies, including:</p>
        <ul class="list-disc pl-6 mb-4">
            <li>Google Analytics</li>
            <li>Cloudflare</li>
            <li>Performance monitoring tools</li>
        </ul>
        
        <h2 class="text-2xl font-semibold mb-4">6. Consent</h2>
        <p>By using our website, you consent to the use of cookies as described in this policy. You can withdraw consent at any time by adjusting your browser settings.</p>
    </div>
    
    <div class="mt-8 bg-indigo-50 p-4 rounded-lg">
        <p class="text-sm text-gray-600">
            This cookie policy may be updated periodically. We recommend reviewing it regularly.
        </p>
    </div>
</div>
@endsection