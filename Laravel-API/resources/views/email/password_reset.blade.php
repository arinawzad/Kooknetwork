<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Reset Request</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f4f6f9;
        }
        .container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            padding: 30px;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo {
            max-width: 150px;
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
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            font-size: 12px;
            color: #777;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Reset Your Password</h1>
        </div>

        <p>Hello,</p>

        <p>You have requested to reset your password for your {{ config('app.name') }} account. Click the button below to reset your password:</p>

        <div style="text-align: center;">
            <a href="{{ $resetUrl }}" class="btn">Reset Password</a>
        </div>

        <p>If you did not request a password reset, please ignore this email or contact support if you have any concerns.</p>

        <p>This link will expire in 60 minutes.</p>

        <div class="footer">
            <p>&copy; {{ date('Y') }} {{ config('app.name') }}. All rights reserved.</p>
            <p>If you're having trouble clicking the "Reset Password" button, copy and paste the URL below into your web browser:</p>
            <p>{{ $resetUrl }}</p>
        </div>
    </div>
</body>
</html>