<!-- resources/views/email/email-verification-status.blade.php -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Verification Status</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 flex items-center justify-center min-h-screen">
    <div class="bg-white p-8 rounded-lg shadow-md w-96 text-center">
        @if ($status === 'success')
            <div class="mb-4">
                <svg class="mx-auto mb-4 w-16 h-16 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <h2 class="text-2xl font-bold text-green-600 mb-4">Email Verified</h2>
                <p class="text-gray-600 mb-4">{{ $message }}</p>
            </div>
        @else
            <div class="mb-4">
                <svg class="mx-auto mb-4 w-16 h-16 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <h2 class="text-2xl font-bold text-red-600 mb-4">Verification Failed</h2>
                <p class="text-gray-600 mb-4">{{ $message }}</p>
            </div>
        @endif

        <div class="mt-6">
            {{-- <a href="{{ url('/login') }}" class="w-full bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600 transition duration-300">
                Go to Login
            </a> --}}
        </div>
    </div>
</body>
</html>