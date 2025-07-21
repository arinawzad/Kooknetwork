@extends('layouts.app')

@section('title', 'Privacy Policy - KOOK Network')

@section('content')
<div class="max-w-4xl mx-auto px-4 py-12">
    <h1 class="text-3xl font-bold mb-6 text-gray-900">Privacy Policy</h1>
    
    <div class="prose prose-indigo max-w-none">
        <p class="text-gray-600 mb-6">Last updated: {{ now()->format('F d, Y') }}</p>
        
        <h2 class="text-2xl font-semibold mb-4">1. Information We Collect</h2>
        <p>At KOOK Network, we collect several types of information:</p>
        <ul class="list-disc pl-6 mb-4">
            <li>Personal identification information (Name, email address, phone number)</li>
            <li>Wallet addresses and cryptocurrency transaction data</li>
            <li>Device and usage information</li>
            <li>Location data</li>
        </ul>
        
        <h2 class="text-2xl font-semibold mb-4">2. How We Use Your Information</h2>
        <p>We use the collected information to:</p>
        <ul class="list-disc pl-6 mb-4">
            <li>Provide and maintain our service</li>
            <li>Notify you about changes to our service</li>
            <li>Allow you to participate in interactive features</li>
            <li>Provide customer support</li>
            <li>Gather analysis to improve our platform</li>
        </ul>
        
        <h2 class="text-2xl font-semibold mb-4">3. Data Security</h2>
        <p>We implement a variety of security measures to maintain the safety of your personal information:</p>
        <ul class="list-disc pl-6 mb-4">
            <li>SSL/TLS encryption</li>
            <li>Two-factor authentication</li>
            <li>Regular security audits</li>
            <li>Restricted access to personal information</li>
        </ul>
        
        <h2 class="text-2xl font-semibold mb-4">4. Your Rights</h2>
        <p>You have the right to:</p>
        <ul class="list-disc pl-6 mb-4">
            <li>Access your personal data</li>
            <li>Correct inaccurate information</li>
            <li>Request deletion of your data</li>
            <li>Opt-out of marketing communications</li>
        </ul>
        
        <h2 class="text-2xl font-semibold mb-4">5. Cookies and Tracking</h2>
        <p>We use cookies and similar tracking technologies to enhance user experience and analyze site traffic. For detailed information, please refer to our Cookie Policy.</p>
        
        <h2 class="text-2xl font-semibold mb-4">6. Contact Us</h2>
        <p>If you have any questions about this Privacy Policy, please contact us at:</p>
        <p class="font-semibold">Email: privacy@kooknetwork.com</p>
        <p class="font-semibold">Address: KOOK Network, Global Tech Hub, Digital City</p>
    </div>
    
    <div class="mt-8 bg-indigo-50 p-4 rounded-lg">
        <p class="text-sm text-gray-600">
            This privacy policy may be updated periodically. We encourage you to review it frequently.
        </p>
    </div>
</div>
@endsection