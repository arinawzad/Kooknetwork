@extends('layouts.app')

@section('title', 'KOOK Network - Mobile Crypto Mining Community')

@section('content')
    <!-- Hero Section -->
    <section class="relative overflow-hidden bg-gradient-to-br from-primary-700 to-primary-900 text-white">
        <!-- Background Elements -->
        <div class="absolute top-0 right-0 w-full h-full overflow-hidden opacity-20">
            <div class="absolute top-10 right-10 w-80 h-80 bg-white/20 rounded-full blur-3xl"></div>
            <div class="absolute bottom-10 left-10 w-64 h-64 bg-primary-300/20 rounded-full blur-2xl"></div>
        </div>
        
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 md:py-28 relative z-10">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-16 items-center">
                <div class="reveal-item">
                    <div class="inline-flex items-center bg-white/10 backdrop-blur-lg px-4 py-2 rounded-full mb-6">
                        <span class="flex items-center justify-center bg-yellow-400 text-gray-900 w-6 h-6 rounded-full mr-2">
                            <i class="fas fa-bolt text-xs"></i>
                        </span>
                        <span class="text-sm font-medium">Beta Launch Now Live</span>
                    </div>
                    
                    <h1 class="text-4xl md:text-5xl lg:text-6xl font-extrabold mb-6 leading-tight">
                        Mobile Crypto Mining <br class="hidden lg:block">
                        <span class="bg-clip-text text-transparent bg-gradient-to-r from-white to-primary-200">Reimagined</span>
                    </h1>
                    
                    <p class="text-xl text-primary-100 mb-8 max-w-xl">
                        Transform your smartphone into a powerful crypto mining platform. Earn KOOK tokens, complete tasks, and build your mining team.
                    </p>
                    
                    <div class="flex flex-col sm:flex-row space-y-4 sm:space-y-0 sm:space-x-4 mb-10">
                        <a href="#download" class="bg-white text-primary-700 hover:bg-gray-100 px-6 py-3 rounded-lg text-lg font-semibold transition duration-300 shadow-lg flex items-center justify-center">
                            <i class="fas fa-download mr-2"></i>
                            Download App
                        </a>
                        <a href="#features" class="bg-primary-600/30 backdrop-blur-lg hover:bg-primary-600/50 text-white border border-primary-400/30 px-6 py-3 rounded-lg text-lg font-semibold transition duration-300 flex items-center justify-center">
                            <i class="fas fa-info-circle mr-2"></i>
                            Learn More
                        </a>
                    </div>
                    
                    <div class="flex items-center space-x-6">
                        <div class="flex -space-x-3">
                            <div class="w-12 h-12 rounded-full border-2 border-white/30 bg-white/10 backdrop-blur-lg flex items-center justify-center">
                                <i class="fas fa-user text-white"></i>
                            </div>
                            <div class="w-12 h-12 rounded-full border-2 border-white/30 bg-white/10 backdrop-blur-lg flex items-center justify-center">
                                <i class="fas fa-user text-white"></i>
                            </div>
                            <div class="w-12 h-12 rounded-full border-2 border-white/30 bg-white/10 backdrop-blur-lg flex items-center justify-center">
                                <i class="fas fa-user text-white"></i>
                            </div>
                        </div>
                        <div>
                            <p class="font-semibold text-lg">10,000+</p>
                            <p class="text-sm text-primary-200">Active Miners</p>
                        </div>
                    </div>
                </div>
                
                <div class="hidden md:flex justify-center relative reveal-item">
                    <div class="relative z-10">
                        <div class="absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full blur-2xl"></div>
                        <div class="absolute -bottom-10 -left-10 w-40 h-40 bg-primary-400/20 rounded-full blur-2xl"></div>
                        
                        <div class="bg-white/10 backdrop-blur-lg p-4 rounded-3xl shadow-2xl border border-white/20 rotate-3 transform transition duration-700 hover:rotate-0">
                            <div class="relative">
                                <img src="/assests/icon.png" alt="KOOK Network App" class="rounded-2xl shadow-lg hero-image w-40">
                                <div class="absolute -top-4 -right-4 bg-primary-500 text-white text-xs px-3 py-1 rounded-full shadow-lg">
                                    v1.0
                                </div>
                            </div>
                        </div>
                        
                        <!-- Floating elements -->
                        <div class="absolute -bottom-8 -left-16 bg-white/10 backdrop-blur-lg rounded-xl p-3 shadow-lg border border-white/20 animate-pulse-slow">
                            <div class="flex items-center space-x-2">
                                <div class="flex items-center justify-center bg-green-400 w-6 h-6 rounded-full">
                                    <i class="fas fa-chart-line text-xs"></i>
                                </div>
                                <div class="text-sm">
                                    <p class="font-bold">+2.4%</p>
                                    <p class="text-xs text-primary-200">Mining Rate</p>
                                </div>
                            </div>
                        </div>
                        
                        <div class="absolute -top-10 -left-20 bg-white/10 backdrop-blur-lg rounded-xl p-3 shadow-lg border border-white/20 animate-pulse-slow">
                            <div class="flex items-center space-x-2">
                                <div class="flex items-center justify-center bg-yellow-400 w-6 h-6 rounded-full">
                                    <i class="fas fa-coins text-xs text-gray-900"></i>
                                </div>
                                <div class="text-sm">
                                    <p class="font-bold">237 KOOK</p>
                                    <p class="text-xs text-primary-200">Your Balance</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        
    </section>

    <!-- Stats Section -->
    <section class="bg-white py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid grid-cols-2 md:grid-cols-4 gap-6 md:gap-8">
                <div class="bg-gray-50 p-6 rounded-xl shadow-sm text-center reveal-item">
                    <div class="text-4xl font-bold text-primary-600 mb-2">10K+</div>
                    <div class="text-gray-600">Active Miners</div>
                </div>
                <div class="bg-gray-50 p-6 rounded-xl shadow-sm text-center reveal-item">
                    <div class="text-4xl font-bold text-green-600 mb-2">50K+</div>
                    <div class="text-gray-600">Daily Tasks</div>
                </div>
                <div class="bg-gray-50 p-6 rounded-xl shadow-sm text-center reveal-item">
                    <div class="text-4xl font-bold text-purple-600 mb-2">1M+</div>
                    <div class="text-gray-600">KOOK Mined</div>
                </div>
                <div class="bg-gray-50 p-6 rounded-xl shadow-sm text-center reveal-item">
                    <div class="text-4xl font-bold text-blue-600 mb-2">24/7</div>
                    <div class="text-gray-600">Support</div>
                </div>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section id="features" class="bg-white py-16 md:py-24">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-16 reveal-item">
                <div class="inline-flex items-center text-sm font-semibold text-primary-600 mb-2">
                    <i class="fas fa-star mr-2"></i>
                    <span>POWERFUL FEATURES</span>
                </div>
                <h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-4">Everything You Need for Mobile Mining</h2>
                <p class="text-xl text-gray-600 max-w-3xl mx-auto">Maximize your crypto mining potential with these powerful features</p>
            </div>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-8 md:gap-10">
                <!-- Team Mining Feature -->
                <div class="feature-card bg-gradient-to-br from-indigo-50 to-indigo-100 p-8 rounded-2xl shadow-md reveal-item">
                    <div class="inline-flex items-center justify-center w-16 h-16 bg-indigo-500 text-white rounded-xl mb-6 shadow-lg">
                        <i class="fas fa-users text-2xl"></i>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 mb-3">Team Mining</h3>
                    <p class="text-gray-700 mb-6">Build your mining team and earn bonuses on their mining production. Earn up to 2% bonus per active member in your network.</p>
                    <a href="/team-mining" class="inline-flex items-center font-medium text-indigo-600 hover:text-indigo-800 transition">
                        Learn More
                        <i class="fas fa-arrow-right ml-2 text-sm"></i>
                    </a>
                </div>
                
                <!-- Tasks Feature -->
                <div class="feature-card bg-gradient-to-br from-purple-50 to-purple-100 p-8 rounded-2xl shadow-md reveal-item">
                    <div class="inline-flex items-center justify-center w-16 h-16 bg-purple-500 text-white rounded-xl mb-6 shadow-lg">
                        <i class="fas fa-tasks text-2xl"></i>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 mb-3">Earning Tasks</h3>
                    <p class="text-gray-700 mb-6">Complete daily tasks to earn extra KOOK tokens. Watch videos, join communities, participate in surveys, and more.</p>
                    <a href="/tasks" class="inline-flex items-center font-medium text-purple-600 hover:text-purple-800 transition">
                        Explore Tasks
                        <i class="fas fa-arrow-right ml-2 text-sm"></i>
                    </a>
                </div>
                
                <!-- Global Stats Feature -->
                <div class="feature-card bg-gradient-to-br from-green-50 to-green-100 p-8 rounded-2xl shadow-md reveal-item">
                    <div class="inline-flex items-center justify-center w-16 h-16 bg-green-500 text-white rounded-xl mb-6 shadow-lg">
                        <i class="fas fa-chart-line text-2xl"></i>
                    </div>
                    <h3 class="text-xl font-bold text-gray-900 mb-3">Global Network</h3>
                    <p class="text-gray-700 mb-6">Real-time tracking of network hashrate, active miners, token price, and total coin supply. All stats at your fingertips.</p>
                    <a href="/stats" class="inline-flex items-center font-medium text-green-600 hover:text-green-800 transition">
                        View Statistics
                        <i class="fas fa-arrow-right ml-2 text-sm"></i>
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- How It Works -->
    <section class="bg-gray-50 py-16 md:py-24">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-16 reveal-item">
                <div class="inline-flex items-center text-sm font-semibold text-primary-600 mb-2">
                    <i class="fas fa-info-circle mr-2"></i>
                    <span>HOW IT WORKS</span>
                </div>
                <h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-4">Simple Steps to Start Mining</h2>
                <p class="text-xl text-gray-600 max-w-3xl mx-auto">Get started with KOOK Network in just a few easy steps</p>
            </div>
            
            <div class="grid grid-cols-1 md:grid-cols-3 gap-8 md:gap-10">
                <!-- Step 1 -->
                <div class="bg-white p-8 rounded-2xl shadow-md hover:shadow-lg transition-shadow duration-300 relative reveal-item">
                    <div class="absolute -top-4 -left-4 w-10 h-10 bg-primary-600 text-white rounded-full flex items-center justify-center font-bold shadow-lg">1</div>
                    <div class="text-center mb-6">
                        <div class="inline-flex items-center justify-center w-20 h-20 bg-primary-100 text-primary-600 rounded-full mb-4">
                            <i class="fas fa-download text-3xl"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900">Download the App</h3>
                    </div>
                    <p class="text-gray-600 text-center">Download KOOK Network from the App Store or Google Play and create your account.</p>
                </div>
                
                <!-- Step 2 -->
                <div class="bg-white p-8 rounded-2xl shadow-md hover:shadow-lg transition-shadow duration-300 relative reveal-item">
                    <div class="absolute -top-4 -left-4 w-10 h-10 bg-primary-600 text-white rounded-full flex items-center justify-center font-bold shadow-lg">2</div>
                    <div class="text-center mb-6">
                        <div class="inline-flex items-center justify-center w-20 h-20 bg-primary-100 text-primary-600 rounded-full mb-4">
                            <i class="fas fa-play-circle text-3xl"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900">Start Mining</h3>
                    </div>
                    <p class="text-gray-600 text-center">Tap the start button to begin mining KOOK tokens with your device's unused resources.</p>
                </div>
                
                <!-- Step 3 -->
                <div class="bg-white p-8 rounded-2xl shadow-md hover:shadow-lg transition-shadow duration-300 relative reveal-item">
                    <div class="absolute -top-4 -left-4 w-10 h-10 bg-primary-600 text-white rounded-full flex items-center justify-center font-bold shadow-lg">3</div>
                    <div class="text-center mb-6">
                        <div class="inline-flex items-center justify-center w-20 h-20 bg-primary-100 text-primary-600 rounded-full mb-4">
                            <i class="fas fa-coins text-3xl"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900">Earn Rewards</h3>
                    </div>
                    <p class="text-gray-600 text-center">Collect your KOOK tokens, complete tasks, and invite friends to maximize earnings.</p>
                </div>
            </div>
        </div>
    </section>
    
    <!-- App Screenshots -->
    <section id="screenshots" class="py-16 md:py-24 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-16 reveal-item">
                <div class="inline-flex items-center text-sm font-semibold text-primary-600 mb-2">
                    <i class="fas fa-mobile-alt mr-2"></i>
                    <span>APP PREVIEW</span>
                </div>
                <h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-4">See KOOK Network in Action</h2>
                <p class="text-xl text-gray-600 max-w-3xl mx-auto">Modern interface designed for efficient crypto mining</p>
            </div>
            
            <div class="grid grid-cols-1 md:grid-cols-4 gap-6 md:gap-8 reveal-item">
                <div class="bg-gray-50 p-4 rounded-2xl shadow-md hover:shadow-lg transition-shadow duration-300">
                    <img src="/assests/screen/1.png" alt="Dashboard" class="rounded-xl w-full">
                    <p class="text-center font-medium text-gray-700 mt-4">Dashboard</p>
                </div>
                <div class="bg-gray-50 p-4 rounded-2xl shadow-md hover:shadow-lg transition-shadow duration-300">
                    <img src="/assests/screen/2.png" alt="Mining Screen" class="rounded-xl w-full">
                    <p class="text-center font-medium text-gray-700 mt-4">Mining Interface</p>
                </div>
                <div class="bg-gray-50 p-4 rounded-2xl shadow-md hover:shadow-lg transition-shadow duration-300">
                    <img src="/assests/screen/3.png" alt="Team Building" class="rounded-xl w-full">
                    <p class="text-center font-medium text-gray-700 mt-4">Team Building</p>
                </div>
                <div class="bg-gray-50 p-4 rounded-2xl shadow-md hover:shadow-lg transition-shadow duration-300">
                    <img src="/assests/screen/4.png" alt="Rewards" class="rounded-xl w-full">
                    <p class="text-center font-medium text-gray-700 mt-4">Rewards Center</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Community Section -->
    <section id="community" class="bg-gray-50 py-16 md:py-24">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid md:grid-cols-2 gap-12 items-center">
                <!-- Community Content -->
                <div class="reveal-item">
                    <div class="inline-flex items-center text-sm font-semibold text-primary-600 mb-2">
                        <i class="fas fa-users mr-2"></i>
                        <span>GLOBAL COMMUNITY</span>
                    </div>
                    <h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-6">Join Our Worldwide Mining Network</h2>
                    <p class="text-xl text-gray-600 mb-8">Connect with thousands of miners worldwide, share tips, and stay updated with the latest crypto trends and announcements.</p>
                    
                    <div class="grid grid-cols-2 gap-6 mb-8">
                        <a href="#" class="bg-white p-6 rounded-xl shadow-md hover:shadow-lg transition-shadow duration-300 group">
                            <div class="flex items-center">
                                <div class="w-12 h-12 bg-blue-100 text-blue-500 rounded-full flex items-center justify-center mr-4 group-hover:bg-blue-500 group-hover:text-white transition-colors duration-300">
                                    <i class="fab fa-telegram text-2xl"></i>
                                </div>
                                <div>
                                    <h3 class="font-bold text-gray-900">Telegram</h3>
                                    <p class="text-sm text-gray-600">5,000+ members</p>
                                </div>
                            </div>
                        </a>
                        <a href="#" class="bg-white p-6 rounded-xl shadow-md hover:shadow-lg transition-shadow duration-300 group">
                            <div class="flex items-center">
                                <div class="w-12 h-12 bg-indigo-100 text-indigo-500 rounded-full flex items-center justify-center mr-4 group-hover:bg-indigo-500 group-hover:text-white transition-colors duration-300">
                                    <i class="fab fa-discord text-2xl"></i>
                                </div>
                                <div>
                                    <h3 class="font-bold text-gray-900">Discord</h3>
                                    <p class="text-sm text-gray-600">3,000+ members</p>
                                </div>
                            </div>
                        </a>
                    </div>
                    
                    <div class="flex items-center p-4 bg-primary-50 border border-primary-100 rounded-lg">
                        <div class="mr-4 text-primary-500">
                            <i class="fas fa-info-circle text-xl"></i>
                        </div>
                        <p class="text-gray-700">Join our active communities to get the latest news, mining tips, and exclusive rewards!</p>
                    </div>
                </div>
                
                <!-- Testimonials -->
                <div class="reveal-item">
                    <div class="bg-white p-8 rounded-2xl shadow-lg">
                        <h3 class="text-2xl font-bold text-gray-900 mb-6">What Our Miners Say</h3>
                        
                        <div class="space-y-6">
                            <div class="bg-gray-50 p-6 rounded-xl">
                                <div class="flex items-center mb-4">
                                    <div class="w-12 h-12 bg-primary-100 rounded-full flex items-center justify-center mr-4">
                                        <span class="font-bold text-primary-600">JM</span>
                                    </div>
                                    <div>
                                        <h4 class="font-bold">John M.</h4>
                                        <div class="flex text-yellow-400">
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                        </div>
                                    </div>
                                </div>
                                <p class="text-gray-700">"I've been using KOOK Network for 3 months and have already earned 500+ tokens. The team mining feature is amazing!"</p>
                            </div>
                            
                            <div class="bg-gray-50 p-6 rounded-xl">
                                <div class="flex items-center mb-4">
                                    <div class="w-12 h-12 bg-primary-100 rounded-full flex items-center justify-center mr-4">
                                        <span class="font-bold text-primary-600">SL</span>
                                    </div>
                                    <div>
                                        <h4 class="font-bold">Sarah L.</h4>
                                        <div class="flex text-yellow-400">
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star-half-alt"></i>
                                        </div>
                                    </div>
                                </div>
                                <p class="text-gray-700">"The app runs smoothly on my phone and doesn't drain my battery. Daily tasks keep me engaged and earning."</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    
    <!-- FAQ Section -->
    <section id="faq" class="py-16 md:py-24 bg-white">
        <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-16 reveal-item">
                <div class="inline-flex items-center text-sm font-semibold text-primary-600 mb-2">
                    <i class="fas fa-question-circle mr-2"></i>
                    <span>FAQ</span>
                </div>
                <h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-4">Frequently Asked Questions</h2>
                <p class="text-xl text-gray-600">Everything you need to know about KOOK Network</p>
            </div>
            
            <div class="space-y-6 reveal-item">
                <div class="bg-gray-50 rounded-xl p-6">
                    <h3 class="font-bold text-lg text-gray-900 mb-2">What is KOOK Network?</h3>
                    <p class="text-gray-700">KOOK Network is a mobile crypto mining platform that allows you to mine cryptocurrency directly from your smartphone. It uses your device's spare computational resources to mine KOOK tokens.</p>
                </div>
                
                <div class="bg-gray-50 rounded-xl p-6">
                    <h3 class="font-bold text-lg text-gray-900 mb-2">Is it safe for my device?</h3>
                    <p class="text-gray-700">Yes, KOOK Network is designed to be battery-friendly and resource-efficient. The app includes smart technology that automatically pauses mining when your device is in active use or when the battery is low.</p>
                </div>
                
                <div class="bg-gray-50 rounded-xl p-6">
                    <h3 class="font-bold text-lg text-gray-900 mb-2">How do I earn KOOK tokens?</h3>
                    <p class="text-gray-700">You can earn KOOK tokens in multiple ways: through direct mining with your smartphone, completing in-app tasks, referring friends to your team, and participating in special events.</p>
                </div>
                
                <div class="bg-gray-50 rounded-xl p-6">
                    <h3 class="font-bold text-lg text-gray-900 mb-2">Can I withdraw my KOOK tokens?</h3>
                    <p class="text-gray-700">Yes, once you reach the minimum withdrawal threshold of 100 KOOK tokens, you can withdraw to your external wallet. The app supports various popular cryptocurrency wallets.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Download Section -->
<section id="download" class="bg-gradient-to-br from-primary-700 to-primary-900 text-white py-16 md:py-24 relative overflow-hidden">
    <!-- Background Elements -->
    <div class="absolute top-0 right-0 w-full h-full overflow-hidden opacity-20">
        <div class="absolute top-20 right-20 w-80 h-80 bg-white/20 rounded-full blur-3xl"></div>
        <div class="absolute bottom-20 left-20 w-64 h-64 bg-primary-300/20 rounded-full blur-2xl"></div>
    </div>
    
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
        <div class="max-w-3xl mx-auto text-center reveal-item">
            <h2 class="text-3xl md:text-5xl font-bold mb-6">Ready to Start Mining?</h2>
            <p class="text-xl text-primary-100 mb-12 max-w-2xl mx-auto">Download KOOK Network now and turn your smartphone into a crypto mining powerhouse. Join thousands of miners earning rewards every day.</p>
            
            <div class="flex flex-col sm:flex-row justify-center space-y-4 sm:space-y-0 sm:space-x-6 mb-12">
                <a href="#" class="bg-white text-primary-800 hover:bg-gray-100 px-8 py-4 rounded-xl text-lg font-semibold transition duration-300 inline-flex items-center justify-center shadow-lg">
                    <i class="fab fa-apple text-2xl mr-3"></i>
                    <div class="text-left">
                        <div class="text-xs">Download on the</div>
                        <div>App Store</div>
                    </div>
                </a>
                <a href="#" class="bg-white text-primary-800 hover:bg-gray-100 px-8 py-4 rounded-xl text-lg font-semibold transition duration-300 inline-flex items-center justify-center shadow-lg">
                    <i class="fab fa-google-play text-2xl mr-3"></i>
                    <div class="text-left">
                        <div class="text-xs">Get it on</div>
                        <div>Google Play</div>
                    </div>
                </a>
            </div>
            
            <div class="flex justify-center items-center">
                <span class="text-primary-200 mr-3">Available for:</span>
                <div class="flex space-x-4">
                    <span class="flex items-center"><i class="fab fa-android mr-1"></i> Android</span>
                    <span class="flex items-center"><i class="fab fa-apple mr-1"></i> iOS</span>
                    <span class="flex items-center"><i class="fab fa-windows mr-1"></i> Windows</span>
                </div>
            </div>
        </div>
    </div>
</section>
@endsection

@push('styles')
<style>
    /* Additional styles for the home page */
    .animate-fade-in {
        animation: fadeIn 1s ease-in-out forwards;
    }
    
    @keyframes fadeIn {
        0% {
            opacity: 0;
            transform: translateY(20px);
        }
        100% {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    /* Gradient text animation */
    .hero-gradient-text {
        background-size: 200% 200%;
        animation: gradientFlow 3s ease infinite;
    }
    
    @keyframes gradientFlow {
        0% {
            background-position: 0% 50%;
        }
        50% {
            background-position: 100% 50%;
        }
        100% {
            background-position: 0% 50%;
        }
    }
</style>
@endpush

@push('scripts')
<script>
    // Additional scripts for the home page
    document.addEventListener('DOMContentLoaded', function() {
        // Animated counter for stats
        const counters = document.querySelectorAll('.counter');
        const speed = 200;
        
        counters.forEach(counter => {
            const updateCount = () => {
                const target = parseInt(counter.getAttribute('data-target'));
                const count = parseInt(counter.innerText);
                const increment = target / speed;
                
                if (count < target) {
                    counter.innerText = Math.ceil(count + increment);
                    setTimeout(updateCount, 1);
                } else {
                    counter.innerText = target.toLocaleString();
                }
            };
            
            updateCount();
        });
    });
</script>
@endpush