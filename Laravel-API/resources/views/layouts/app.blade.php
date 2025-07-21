<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'KOOK Network - Crypto Mining Community')</title>
      <link rel="icon" type="image/x-icon" href="/assests/icon.png">

    <meta name="description" content="Join KOOK Network - The ultimate crypto mining community with team bonuses, tasks, and global mining statistics.">
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: {
                            50: '#f5f3ff',
                            100: '#ede9fe',
                            200: '#ddd6fe',
                            300: '#c4b5fd',
                            400: '#a78bfa',
                            500: '#8b5cf6',
                            600: '#7c3aed',
                            700: '#6d28d9',
                            800: '#5b21b6',
                            900: '#4c1d95',
                        },
                    },
                    fontFamily: {
                        sans: ['Inter', 'sans-serif'],
                    },
                    animation: {
                        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
                    }
                }
            }
        };
    </script>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Custom styles -->
    <style>
        /* Custom scrollbar */
        ::-webkit-scrollbar {
            width: 10px;
            height: 10px;
        }
        
        ::-webkit-scrollbar-track {
            background: #f1f1f1;
        }
        
        ::-webkit-scrollbar-thumb {
            background: #d4d4d8;
            border-radius: 5px;
        }
        
        ::-webkit-scrollbar-thumb:hover {
            background: #a1a1aa;
        }
        
        /* Smooth transitions */
        .nav-link {
            position: relative;
            transition: all 0.3s ease;
        }
        
        .nav-link::after {
            content: '';
            position: absolute;
            width: 0;
            height: 2px;
            bottom: -4px;
            left: 0;
            background-color: #7c3aed;
            transition: width 0.3s ease;
        }
        
        .nav-link:hover::after {
            width: 100%;
        }
        
        /* Card hover effects */
        .feature-card {
            transition: all 0.3s ease;
        }
        
        .feature-card:hover {
            transform: translateY(-8px);
        }
        
        /* Hero section animation */
        .hero-image {
            animation: float 6s ease-in-out infinite;
        }
        
        @keyframes float {
            0% {
                transform: translateY(0px) rotate(-3deg);
            }
            50% {
                transform: translateY(-15px) rotate(0deg);
            }
            100% {
                transform: translateY(0px) rotate(-3deg);
            }
        }
    </style>
    
    @stack('styles')
</head>
<body class="font-sans antialiased text-gray-800 bg-gray-50 min-h-screen flex flex-col">
    <!-- Announcement Bar -->
    <div class="bg-primary-700 text-white py-2 text-center text-sm">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex items-center justify-center">
                <i class="fas fa-bell mr-2 animate-pulse"></i>
                <span>New 2023 Mining Rewards Program now available!</span>
                <a href="#" class="ml-2 underline hover:text-primary-200 transition">Learn more</a>
            </div>
        </div>
    </div>
    
    <!-- Navigation -->
    <nav class="bg-white shadow-sm sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center">
                    <div class="flex-shrink-0 flex items-center">
                        <div >
                            <img src="./assests/icon.png" class="w-10  rounded-lg mr-2">
                        </div>
                        <span class="text-xl font-bold text-gray-900">KOOK <span class="text-primary-600">Network</span></span>
                    </div>
                </div>
                
                <div class="hidden md:ml-6 md:flex md:items-center md:space-x-8">
                    <a href="/" class="nav-link px-3 py-2 text-sm font-medium text-gray-800 hover:text-primary-600">Home</a>
                    <a href="#features" class="nav-link px-3 py-2 text-sm font-medium text-gray-800 hover:text-primary-600">Features</a>
                    <a href="#community" class="nav-link px-3 py-2 text-sm font-medium text-gray-800 hover:text-primary-600">Community</a>
                    <a href="#faq" class="nav-link px-3 py-2 text-sm font-medium text-gray-800 hover:text-primary-600">FAQ</a>
                    <a href="#download" class="bg-gradient-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 text-white px-4 py-2 rounded-lg text-sm font-medium transition duration-300 shadow-md hover:shadow-lg">
                        Download App
                    </a>
                </div>
                
                <div class="-mr-2 flex items-center md:hidden">
                    <!-- Mobile menu button -->
                    <button type="button" class="inline-flex items-center justify-center p-2 rounded-md text-gray-500 hover:text-gray-700 hover:bg-gray-100 focus:outline-none" aria-controls="mobile-menu" aria-expanded="false" id="mobile-menu-button">
                        <span class="sr-only">Open main menu</span>
                        <i class="fas fa-bars" id="menu-icon"></i>
                    </button>
                </div>
            </div>
        </div>
        
        <!-- Mobile menu -->
        <div class="hidden md:hidden" id="mobile-menu">
            <div class="pt-2 pb-3 space-y-1 border-t">
                <a href="/" class="block px-3 py-2 text-base font-medium text-gray-900 hover:bg-primary-50 hover:text-primary-600">Home</a>
                <a href="#features" class="block px-3 py-2 text-base font-medium text-gray-900 hover:bg-primary-50 hover:text-primary-600">Features</a>
                <a href="#community" class="block px-3 py-2 text-base font-medium text-gray-900 hover:bg-primary-50 hover:text-primary-600">Community</a>
                <a href="#faq" class="block px-3 py-2 text-base font-medium text-gray-900 hover:bg-primary-50 hover:text-primary-600">FAQ</a>
                <a href="#download" class="block px-3 py-2 text-base font-medium text-primary-600 hover:bg-primary-50">Download App</a>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="flex-grow">
        @yield('content')
    </main>

    <!-- Footer -->
    <footer class="bg-gray-900 text-white pt-16 pb-8">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-12">
                <div class="space-y-4">
                    <div class="flex items-center">
                    <div >
                            <img src="./assests/icon.png" class="w-10  rounded-lg mr-2">
                        </div>
                        <span class="text-xl font-bold">KOOK <span class="text-primary-400">Network</span></span>
                    </div>
                    <p class="text-gray-400">The ultimate crypto mining community with team bonuses, tasks, and global mining statistics.</p>
                    <div class="flex space-x-4 pt-2">
                        <a href="#" class="text-gray-400 hover:text-white transition">
                            <i class="fab fa-telegram text-xl"></i>
                        </a>
                        <a href="#" class="text-gray-400 hover:text-white transition">
                            <i class="fab fa-discord text-xl"></i>
                        </a>
                        <a href="#" class="text-gray-400 hover:text-white transition">
                            <i class="fab fa-twitter text-xl"></i>
                        </a>
                        <a href="#" class="text-gray-400 hover:text-white transition">
                            <i class="fab fa-facebook text-xl"></i>
                        </a>
                    </div>
                </div>
                
                <div class="space-y-4">
                    <h3 class="text-lg font-semibold">Quick Links</h3>
                    <ul class="space-y-2">
                        <li><a href="/" class="text-gray-400 hover:text-white transition">Home</a></li>
                        <li><a href="#features" class="text-gray-400 hover:text-white transition">Features</a></li>
                        <li><a href="#community" class="text-gray-400 hover:text-white transition">Community</a></li>
                        <li><a href="#download" class="text-gray-400 hover:text-white transition">Download</a></li>
                    </ul>
                </div>
                
                <div class="space-y-4">
                    <h3 class="text-lg font-semibold">Legal</h3>
                    <ul class="space-y-2">
                        <li><a href="{{ route('privacy-policy') }}" class="text-gray-400 hover:text-white transition">Privacy Policy</a></li>
                        <li><a href="{{ route('terms-of-service') }}" class="text-gray-400 hover:text-white transition">Terms of Service</a></li>
                        <li><a href="{{ route('cookie-policy') }}" class="text-gray-400 hover:text-white transition">Cookie Policy</a></li>
                    </ul>
                </div>
                
                <div class="space-y-4">
                    <h3 class="text-lg font-semibold">Contact</h3>
                    <p class="text-gray-400">Have questions? We're here to help!</p>
                    <p class="text-gray-400 flex items-center">
                        <i class="fas fa-envelope mr-2 text-primary-400"></i>
                        support@kooknetwork.com
                    </p>
                    <p class="text-gray-400 flex items-center">
                        <i class="fas fa-headset mr-2 text-primary-400"></i>
                        24/7 Support
                    </p>
                </div>
            </div>
            
            <div class="mt-12 pt-8 border-t border-gray-800 text-center text-gray-400">
                <p>&copy; 2023 KOOK Network. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <!-- Scripts -->
    <script>
        // Mobile menu toggle
        document.getElementById('mobile-menu-button').addEventListener('click', function() {
            const menu = document.getElementById('mobile-menu');
            const icon = document.getElementById('menu-icon');
            
            if (menu.classList.contains('hidden')) {
                menu.classList.remove('hidden');
                icon.classList.remove('fa-bars');
                icon.classList.add('fa-times');
            } else {
                menu.classList.add('hidden');
                icon.classList.remove('fa-times');
                icon.classList.add('fa-bars');
            }
        });
        
        // Smooth scrolling for anchor links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                
                const targetId = this.getAttribute('href');
                if (targetId === '#') return;
                
                const targetElement = document.querySelector(targetId);
                if (targetElement) {
                    window.scrollTo({
                        top: targetElement.offsetTop - 80,
                        behavior: 'smooth'
                    });
                    
                    // Close mobile menu if open
                    const mobileMenu = document.getElementById('mobile-menu');
                    if (!mobileMenu.classList.contains('hidden')) {
                        mobileMenu.classList.add('hidden');
                        document.getElementById('menu-icon').classList.remove('fa-times');
                        document.getElementById('menu-icon').classList.add('fa-bars');
                    }
                }
            });
        });
        
        // Scroll reveal animation
        const observerOptions = {
            root: null,
            rootMargin: '0px',
            threshold: 0.1
        };
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate-fade-in');
                    entry.target.classList.remove('opacity-0');
                    observer.unobserve(entry.target);
                }
            });
        }, observerOptions);
        
        document.querySelectorAll('.reveal-item').forEach(item => {
            item.classList.add('opacity-0');
            observer.observe(item);
        });
    </script>
    
    @stack('scripts')
</body>
</html>