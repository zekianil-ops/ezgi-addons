<!---
    File: dashboard.cfm
    Folder: AddOns/ezgi/e_partner/display
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Dashboard
--->
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>B2B Partner Portal - Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: #f3f4f6;
            color: #1f2937;
        }
        .header {
            background: #ffffff;
            border-bottom: 1px solid #e5e7eb;
            padding: 16px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        .header h1 {
            color: #1e3a8a;
            font-size: 24px;
            font-weight: 700;
        }
        .user-info {
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .user-name {
            color: #374151;
            font-weight: 600;
        }
        .btn-logout {
            padding: 8px 16px;
            background: #ef4444;
            color: #ffffff;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
        }
        .btn-logout:hover {
            background: #dc2626;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 24px;
        }
        .welcome-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #ffffff;
            padding: 32px;
            border-radius: 12px;
            margin-bottom: 24px;
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }
        .welcome-card h2 {
            font-size: 28px;
            margin-bottom: 8px;
        }
        .welcome-card p {
            font-size: 16px;
            opacity: 0.9;
        }
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-top: 24px;
        }
        .dashboard-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }
        .dashboard-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
        }
        .dashboard-card h3 {
            color: #1e3a8a;
            font-size: 18px;
            margin-bottom: 12px;
        }
        .dashboard-card p {
            color: #6b7280;
            font-size: 14px;
            line-height: 1.6;
        }
        .navbar {
            background: #ffffff;
            border-bottom: 1px solid #e5e7eb;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        .navbar-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .navbar-menu {
            display: flex;
            list-style: none;
            margin: 0;
            padding: 0;
            gap: 0;
        }
        .navbar-menu li {
            margin: 0;
        }
        .navbar-menu a {
            display: block;
            padding: 16px 20px;
            color: #374151;
            text-decoration: none;
            font-weight: 500;
            font-size: 14px;
            transition: all 0.2s ease;
            border-bottom: 3px solid transparent;
        }
        .navbar-menu a:hover {
            color: #667eea;
            background: #f9fafb;
        }
        .navbar-menu a.active {
            color: #667eea;
            border-bottom-color: #667eea;
            background: #f9fafb;
        }
        .navbar-menu a i {
            margin-right: 8px;
        }
        @media (max-width: 768px) {
            .navbar-menu {
                flex-wrap: wrap;
            }
            .navbar-menu a {
                padding: 12px 16px;
                font-size: 13px;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>B2B Partner Portal</h1>
        <div class="user-info">
            <span class="user-name">
                <cfoutput>
                    <cfif len(session.b2b.partnerName) or len(session.b2b.partnerSurname)>
                        Hoş geldiniz, #session.b2b.partnerName# #session.b2b.partnerSurname#
                    <cfelse>
                        Hoş geldiniz, #session.b2b.username#
                    </cfif>
                </cfoutput>
            </span>
            <a href="index.cfm?fuseaction=partner.logout" class="btn-logout">Çıkış Yap</a>
        </div>
    </div>
    
    <!--- Menü Çubuğu --->
    <nav class="navbar">
        <div class="navbar-container">
            <ul class="navbar-menu">
                <li>
                    <a href="index.cfm?fuseaction=partner.dashboard" class="active">
                        <i>🏠</i> Ana Sayfa
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.products">
                        <i>📦</i> Ürünler
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.orders">
                        <i>🛒</i> Siparişler
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.invoices">
                        <i>📄</i> Faturalar
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.cari_ekstre">
                        <i>📋</i> Cari Ekstre
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.servis_islemleri">
                        <i>🔧</i> Servis İşlemleri
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.profile">
                        <i>👤</i> Profil
                    </a>
                </li>
            </ul>
        </div>
    </nav>
    
    <div class="container">
        <div class="welcome-card">
            <h2>Hoş Geldiniz!</h2>
            <p>B2B Partner Portal'a başarıyla giriş yaptınız.</p>
        </div>
        
        <!--- Debug Bilgileri (Test için) --->
        <div class="dashboard-card" style="background: ##fef3c7; border: 2px solid ##f59e0b;">
            <h3 style="color: ##92400e;">🔍 Debug Bilgileri (Test Modu)</h3>
            <cfoutput>
                <p style="color: ##78350f; font-size: 13px; line-height: 1.8;">
                    <strong>Login Durumu:</strong> 
                    <cfif isDefined("session.b2b") and isDefined("session.b2b.loggedIn") and session.b2b.loggedIn>
                        <span style="color: ##059669;">✓ Başarılı</span>
                    <cfelse>
                        <span style="color: ##dc2626;">✗ Başarısız</span>
                    </cfif><br>
                    <strong>Kullanıcı Adı:</strong> #session.b2b.username#<br>
                    <strong>Partner ID:</strong> #session.b2b.partnerId#<br>
                    <strong>Kullanıcı Şirket ID (COMPANY_ID):</strong> #session.b2b.companyId#<br>
                    <strong>Çalışılacak Şirket ID (COMP_ID):</strong> #isDefined("session.b2b.compId") ? session.b2b.compId : "Belirlenmedi (Setup'tan seçiniz)"#<br>
                    <strong>Şirket Adı:</strong> #session.b2b.fullName#<br>
                    <strong>Member Code:</strong> #session.b2b.memberCode#<br>
                    <strong>Ad Soyad:</strong> #session.b2b.partnerName# #session.b2b.partnerSurname#<br>
                    <strong>E-posta:</strong> #session.b2b.partnerEmail#<br>
                    <strong>Dönem Yılı:</strong> #isDefined("session.b2b.periodYear") ? session.b2b.periodYear : "Belirlenmedi"#<br>
                    <strong>Giriş Zamanı:</strong> #dateFormat(session.b2b.loginTime, "dd/mm/yyyy")# #timeFormat(session.b2b.loginTime, "HH:mm:ss")#<br>
                    <strong>DSN:</strong> #request.dsn#<br>
                    <strong>DSN1:</strong> #request.dsn1#<br>
                    <strong>DSN2:</strong> #request.dsn2#<br>
                    <strong>DSN3:</strong> #request.dsn3#
                </p>
            </cfoutput>
        </div>
        
        <div class="dashboard-grid">
            <div class="dashboard-card">
                <h3>📦 Ürün Kataloğu</h3>
                <p>Ürünleri görüntüleyin ve detaylarına ulaşın.</p>
            </div>
            
            <div class="dashboard-card">
                <h3>🛒 Sipariş Ver</h3>
                <p>Yeni sipariş oluşturun ve siparişlerinizi takip edin.</p>
            </div>
            
            <div class="dashboard-card">
                <h3>📊 Sipariş Takibi</h3>
                <p>Mevcut siparişlerinizin durumunu görüntüleyin.</p>
            </div>
            
            <div class="dashboard-card">
                <h3>📄 Faturalar</h3>
                <p>Faturalarınızı görüntüleyin ve indirin.</p>
            </div>
        </div>
    </div>
    
    <script>
        <!--- Aktif menü öğesini işaretle --->
        <cfoutput>
        var currentFuseaction = '#url.fuseaction#';
        var menuLinks = document.querySelectorAll('.navbar-menu a');
        
        menuLinks.forEach(function(link) {
            var href = link.getAttribute('href');
            if (href && href.indexOf('fuseaction=' + currentFuseaction) !== -1) {
                link.classList.add('active');
            }
        });
        </cfoutput>
    </script>
</body>
</html>

