@extends('layouts.app')

@section('title', 'Terms of Service - KOOK Network')

@section('content')
<!-- Hero Section -->
<section class="bg-gradient-to-r from-primary-700 to-primary-900 py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center text-white">
            <h1 class="text-4xl font-bold mb-4">Terms of Service</h1>
            <p class="text-primary-100">Our rules and guidelines for using KOOK Network</p>
        </div>
    </div>
</section>

<!-- Content Section -->
<section class="py-12 bg-gray-50">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <!-- Last Updated Info -->
            <div class="bg-primary-50 p-4 border-b border-primary-100">
                <p class="text-gray-600 flex items-center">
                    <i class="fas fa-calendar-alt mr-2 text-primary-500"></i>
                    Last updated: {{ now()->format('F d, Y') }}
                </p>
            </div>
            
            <!-- Terms Content -->
            <div class="p-6 md:p-8">
                <div class="prose prose-primary max-w-none">
                    <!-- Section 1 -->
                    <div class="mb-8 p-6 bg-white rounded-lg border border-gray-100 shadow-sm">
                        <h2 class="text-2xl font-semibold mb-4 text-primary-700 flex items-center">
                            <span class="flex items-center justify-center w-8 h-8 bg-primary-100 text-primary-600 rounded-full mr-3 text-sm">1</span>
                            Acceptance of Terms
                        </h2>
                        <p>By accessing and using the KOOK Network platform, you agree to these Terms of Service. If you do not agree, please do not use our service.</p>
                    </div>
                    
                    <!-- Section 2 -->
                    <div class="mb-8 p-6 bg-white rounded-lg border border-gray-100 shadow-sm">
                        <h2 class="text-2xl font-semibold mb-4 text-primary-700 flex items-center">
                            <span class="flex items-center justify-center w-8 h-8 bg-primary-100 text-primary-600 rounded-full mr-3 text-sm">2</span>
                            User Eligibility
                        </h2>
                        <ul class="list-none pl-0 mb-4">
                            <li class="flex items-start mb-3">
                                <i class="fas fa-check-circle text-green-500 mt-1 mr-3"></i>
                                <span>You must be at least 18 years old</span>
                            </li>
                            <li class="flex items-start mb-3">
                                <i class="fas fa-check-circle text-green-500 mt-1 mr-3"></i>
                                <span>You must have legal capacity to enter into agreements</span>
                            </li>
                            <li class="flex items-start mb-3">
                                <i class="fas fa-check-circle text-green-500 mt-1 mr-3"></i>
                                <span>You must not be located in a jurisdiction where use of our service is prohibited</span>
                            </li>
                        </ul>
                    </div>
                    
                    <!-- Section 3 -->
                    <div class="mb-8 p-6 bg-white rounded-lg border border-gray-100 shadow-sm">
                        <h2 class="text-2xl font-semibold mb-4 text-primary-700 flex items-center">
                            <span class="flex items-center justify-center w-8 h-8 bg-primary-100 text-primary-600 rounded-full mr-3 text-sm">3</span>
                            User Account
                        </h2>
                        <p>When you create an account with KOOK Network, you agree to:</p>
                        <ul class="list-none pl-0 mb-4">
                            <li class="flex items-start mb-3">
                                <i class="fas fa-check-circle text-green-500 mt-1 mr-3"></i>
                                <span>Provide accurate and complete information</span>
                            </li>
                            <li class="flex items-start mb-3">
                                <i class="fas fa-check-circle text-green-500 mt-1 mr-3"></i>
                                <span>Maintain the confidentiality of your account</span>
                            </li>
                            <li class="flex items-start mb-3">
                                <i class="fas fa-check-circle text-green-500 mt-1 mr-3"></i>
                                <span>Accept responsibility for all activities under your account</span>
                            </li>
                        </ul>
                    </div>
                    
                    <!-- Section 4 -->
                    <div class="mb-8 p-6 bg-white rounded-lg border border-gray-100 shadow-sm">
                        <h2 class="text-2xl font-semibold mb-4 text-primary-700 flex items-center">
                            <span class="flex items-center justify-center w-8 h-8 bg-primary-100 text-primary-600 rounded-full mr-3 text-sm">4</span>
                            Mining and Rewards
                        </h2>
                        <p>KOOK Network provides a platform for cryptocurrency mining and task-based rewards. By using our service, you understand that:</p>
                        <ul class="list-none pl-0 mb-4">
                            <li class="flex items-start mb-3">
                                <i class="fas fa-exclamation-circle text-yellow-500 mt-1 mr-3"></i>
                                <span>Rewards are not guaranteed and may fluctuate</span>
                            </li>
                            <li class="flex items-start mb-3">
                                <i class="fas fa-exclamation-circle text-yellow-500 mt-1 mr-3"></i>
                                <span>Mining performance depends on various factors</span>
                            </li>
                            <li class="flex items-start mb-3">
                                <i class="fas fa-exclamation-circle text-yellow-500 mt-1 mr-3"></i>
                                <span>KOOK Network is not responsible for market value changes</span>
                            </li>
                        </ul>
                    </div>
                    
                    <!-- Section 5 -->
                    <div class="mb-8 p-6 bg-white rounded-lg border border-gray-100 shadow-sm">
                        <h2 class="text-2xl font-semibold mb-4 text-primary-700 flex items-center">
                            <span class="flex items-center justify-center w-8 h-8 bg-primary-100 text-primary-600 rounded-full mr-3 text-sm">5</span>
                            Prohibited Activities
                        </h2>
                        <p>Users are prohibited from:</p>
                        <ul class="list-none pl-0 mb-4">
                            <li class="flex items-start mb-3">
                                <i class="fas fa-times-circle text-red-500 mt-1 mr-3"></i>
                                <span>Using multiple accounts</span>
                            </li>
                            <li class="flex items-start mb-3">
                                <i class="fas fa-times-circle text-red-500 mt-1 mr-3"></i>
                                <span>Engaging in fraudulent activities</span>
                            </li>
                            <li class="flex items-start mb-3">
                                <i class="fas fa-times-circle text-red-500 mt-1 mr-3"></i>
                                <span>Attempting to manipulate the mining or reward system</span>
                            </li>
                            <li class="flex items-start mb-3">
                                <i class="fas fa-times-circle text-red-500 mt-1 mr-3"></i>
                                <span>Sharing account credentials</span>
                            </li>
                        </ul>
                    </div>
                    
                    <!-- Section 6 -->
                    <div class="mb-8 p-6 bg-white rounded-lg border border-gray-100 shadow-sm">
                        <h2 class="text-2xl font-semibold mb-4 text-primary-700 flex items-center">
                            <span class="flex items-center justify-center w-8 h-8 bg-primary-100 text-primary-600 rounded-full mr-3 text-sm">6</span>
                            Intellectual Property
                        </h2>
                        <p>All content, software, and design elements of KOOK Network are the property of our company and protected by intellectual property laws.</p>
                    </div>
                    
                    <!-- Section 7 -->
                    <div class="mb-8 p-6 bg-white rounded-lg border border-gray-100 shadow-sm">
                        <h2 class="text-2xl font-semibold mb-4 text-primary-700 flex items-center">
                            <span class="flex items-center justify-center w-8 h-8 bg-primary-100 text-primary-600 rounded-full mr-3 text-sm">7</span>
                            Limitation of Liability
                        </h2>
                        <p>KOOK Network is not liable for:</p>
                        <ul class="list-none pl-0 mb-4">
                            <li class="flex items-start mb-3">
                                <i class="fas fa-shield-alt text-gray-500 mt-1 mr-3"></i>
                                <span>Loss of cryptocurrency</span>
                            </li>
                            <li class="flex items-start mb-3">
                                <i class="fas fa-shield-alt text-gray-500 mt-1 mr-3"></i>
                                <span>Technical issues or downtime</span>
                            </li>
                            <li class="flex items-start mb-3">
                                <i class="fas fa-shield-alt text-gray-500 mt-1 mr-3"></i>
                                <span>User errors or misconduct</span>
                            </li>
                        </ul>
                    </div>
                    
                    <!-- Section 8 -->
                    <div class="mb-8 p-6 bg-white rounded-lg border border-gray-100 shadow-sm">
                        <h2 class="text-2xl font-semibold mb-4 text-primary-700 flex items-center">
                            <span class="flex items-center justify-center w-8 h-8 bg-primary-100 text-primary-600 rounded-full mr-3 text-sm">8</span>
                            Modifications to Service
                        </h2>
                        <p>We reserve the right to modify, suspend, or discontinue any part of our service at any time without notice.</p>
                    </div>
                    
                    <!-- Section 9 -->
                    <div class="mb-8 p-6 bg-white rounded-lg border border-gray-100 shadow-sm">
                        <h2 class="text-2xl font-semibold mb-4 text-primary-700 flex items-center">
                            <span class="flex items-center justify-center w-8 h-8 bg-primary-100 text-primary-600 rounded-full mr-3 text-sm">9</span>
                            Dispute Resolution
                        </h2>
                        <p>Any disputes shall be resolved through arbitration in accordance with the rules of [Your Jurisdiction].</p>
                    </div>
                </div>
            </div>
            
            <!-- Agreement Notice -->
            <div class="bg-primary-50 p-6 border-t border-primary-100">
                <div class="flex items-start">
                    <div class="flex-shrink-0 mt-1">
                        <i class="fas fa-info-circle text-primary-600 text-xl"></i>
                    </div>
                    <div class="ml-4">
                        <p class="text-gray-700">
                            By continuing to use KOOK Network, you acknowledge that you have read and understood these Terms of Service.
                        </p>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Contact Info -->
        <div class="mt-8 text-center">
            <p class="text-gray-600">Have questions about our Terms of Service?</p>
            <a href="/contact" class="inline-flex items-center text-primary-600 hover:text-primary-800 font-medium mt-2">
                <i class="fas fa-envelope mr-2"></i>
                Contact Our Support Team
            </a>
        </div>
    </div>
</section>
@endsection