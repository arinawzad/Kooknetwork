<!-- resources/views/auth/reset-redirect.blade.php -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Your Password - Kook</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            line-height: 1.6;
            color: #333;
            text-align: center;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background: linear-gradient(to bottom, #3949AB, #5E35B1);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .container {
            background-color: white;
            border-radius: 16px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            padding: 30px;
            margin-bottom: 20px;
        }
        .logo {
            width: 80px;
            height: 80px;
            background-color: #3949AB;
            border-radius: 50%;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            margin: 0 auto 20px;
        }
        h1 {
            color: #3949AB;
            margin-bottom: 20px;
        }
        .btn {
            display: inline-block;
            background-color: #3949AB;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 6px;
            margin: 20px 0;
            border: none;
            font-size: 16px;
            cursor: pointer;
            font-weight: 500;
        }
        .secondary-btn {
            background-color: #f4f6f9;
            color: #3949AB;
            border: 1px solid #3949AB;
        }
        .steps {
            text-align: left;
            margin: 20px 0;
        }
        .steps li {
            margin-bottom: 10px;
        }
        .footnote {
            color: rgba(255, 255, 255, 0.8);
            font-size: 14px;
            margin-top: 20px;
        }
        #token-display {
            background-color: #f4f6f9;
            padding: 10px;
            border-radius: 4px;
            font-family: monospace;
            margin: 10px 0;
            word-break: break-all;
        }
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">$</div>
        <h1>Reset Your Password</h1>
        
        <p>We'll now open the Kook app to complete your password reset.</p>
        
        <a href="{{ $appResetUrl }}" class="btn" id="open-app">Open Kook App</a>
        
        <div id="manual-instructions" class="hidden">
            <p>If the app didn't open automatically, please follow these steps:</p>
            
            <ol class="steps">
                <li>Open the Kook app on your device</li>
                <li>Go to the login screen</li>
                <li>Tap "Forgot Password"</li>
                <li>Enter your email: <strong>{{ $email }}</strong></li>
                <li>When prompted for the reset token, use:</li>
            </ol>
            
            <div id="token-display">{{ $token }}</div>
            
            <p>This token will expire in 60 minutes.</p>
        </div>
        
        <button class="btn secondary-btn" id="show-instructions">Show Manual Instructions</button>
    </div>
    
    <p class="footnote">&copy; {{ date('Y') }} Kook. All rights reserved.</p>

    <script>
        // Auto-click the Open App button after 2 seconds
        setTimeout(function() {
            document.getElementById('open-app').click();
        }, 2000);
        
        // Show manual instructions button functionality
        document.getElementById('show-instructions').addEventListener('click', function() {
            document.getElementById('manual-instructions').classList.remove('hidden');
            this.classList.add('hidden');
        });
        
        // If app doesn't open after 4 seconds, show manual instructions
        setTimeout(function() {
            document.getElementById('manual-instructions').classList.remove('hidden');
            document.getElementById('show-instructions').classList.add('hidden');
        }, 6000);
    </script>
</body>
</html>