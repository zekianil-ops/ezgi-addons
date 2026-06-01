<!---
    File: login.cfm
    Folder: AddOns/ezgi/e_partner/display
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Giriş Sayfası
--->
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>B2B Partner Portal - Giriş</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .login-container {
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            width: 100%;
            max-width: 420px;
            padding: 40px;
        }
        .login-header {
            text-align: center;
            margin-bottom: 32px;
        }
        .login-header h1 {
            color: #1e3a8a;
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
        }
        .login-header p {
            color: #6b7280;
            font-size: 14px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            color: #374151;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 8px;
        }
        .form-group input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        .btn-login {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #ffffff;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 8px;
        }
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }
        .btn-login:active {
            transform: translateY(0);
        }
        .error-message {
            background: #fee2e2;
            color: #b91c1c;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            display: none;
        }
        .error-message.show {
            display: block;
        }
        .logo {
            text-align: center;
            margin-bottom: 24px;
        }
        .logo img {
            max-width: 150px;
            height: auto;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="logo">
            <!--- Logo varsa buraya eklenebilir --->
            <h2 style="color: #1e3a8a;">B2B Partner Portal</h2>
        </div>
        
        <div class="login-header">
            <h1>Hoş Geldiniz</h1>
            <p>Lütfen giriş bilgilerinizi girin</p>
        </div>
        
        <cfif structKeyExists(url, "error") and len(trim(url.error))>
            <div class="error-message show" id="errorMessage" style="display: block !important; background: #fee2e2; color: #b91c1c; padding: 12px; border-radius: 8px; margin-bottom: 20px;">
                <cfoutput>#HTMLEditFormat(url.error)#</cfoutput>
            </div>
        </cfif>
        
        <!--- Debug Link (Test için) --->
        <div style="text-align: center; margin-bottom: 10px;">
            <a href="index.cfm?fuseaction=partner.login_process&debug=1" style="font-size: 12px; color: #667eea;">🔍 Debug Bilgileri</a>
        </div>
        
        <form name="loginForm" method="post" action="index.cfm?fuseaction=partner.login_process" onsubmit="return validateLogin();">
            <div class="form-group">
                <label for="username">Kullanıcı Adı</label>
                <input type="text" id="username" name="username" required autocomplete="username" placeholder="Kullanıcı adınızı girin">
            </div>
            
            <div class="form-group">
                <label for="password">Şifre</label>
                <input type="password" id="password" name="password" required autocomplete="current-password" placeholder="Şifrenizi girin">
            </div>
            
            <button type="submit" class="btn-login">Giriş Yap</button>
        </form>
    </div>
    
    <script>
        function validateLogin() {
            var username = document.getElementById('username').value.trim();
            var password = document.getElementById('password').value;
            
            if (!username || !password) {
                alert('Lütfen kullanıcı adı ve şifrenizi girin.');
                return false;
            }
            
            return true;
        }
    </script>
</body>
</html>

