<!---
    File: setup.cfm
    Folder: AddOns/ezgi/e_partner/display
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Setup Sayfası
--->
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>B2B Partner Portal - Setup</title>
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
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 24px;
        }
        .setup-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 32px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            margin-bottom: 24px;
        }
        .setup-card h2 {
            color: #1e3a8a;
            font-size: 24px;
            margin-bottom: 24px;
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
        .btn-save {
            padding: 12px 24px;
            background: #667eea;
            color: #ffffff;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .btn-save:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }
        .info-box {
            background: #f0f9ff;
            border: 1px solid #bae6fd;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 24px;
        }
        .info-box p {
            color: #0369a1;
            font-size: 14px;
            line-height: 1.6;
        }
        .success-message {
            background: #d1fae5;
            border: 1px solid #6ee7b7;
            color: #065f46;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .error-message {
            background: #fee2e2;
            border: 1px solid #fca5a5;
            color: #991b1b;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
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
                    <a href="index.cfm?fuseaction=partner.dashboard">
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
                    <a href="index.cfm?fuseaction=partner.price_lists">
                        <i>💰</i> Fiyat Listeleri
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.reports">
                        <i>📊</i> Raporlar
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.profile">
                        <i>👤</i> Profil
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.cari_ekstre">
                        <i>📋</i> Cari Ekstre
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.setup" class="active">
                        <i>⚙️</i> Setup
                    </a>
                </li>
            </ul>
        </div>
    </nav>
    
    <div class="container">
        <div class="setup-card">
            <h2>⚙️ Sistem Ayarları</h2>
            
            <cfif structKeyExists(url, "success")>
                <div class="success-message">
                    ✓ Ayarlar başarıyla kaydedildi!
                </div>
            </cfif>
            
            <cfif structKeyExists(url, "error")>
                <div class="error-message">
                    ✗ #HTMLEditFormat(url.error)#
                </div>
            </cfif>
            
            <div class="info-box">
                <p>
                    <strong>Bilgi:</strong> Seçtiğiniz şirket (COMP_ID) DSN2 ve DSN3'ü belirler. 
                    PERIOD_YEAR değeri otomatik olarak seçilen şirket için en son aktif dönemden alınır. 
                    Sadece seçtiğiniz şirketle işlem yapabilirsiniz.
                    <br><br>
                    <strong>Not:</strong> Eğer <code>config.cfm</code> dosyasında COMP_ID tanımlıysa, 
                    bu sayfadaki seçim yerine config dosyasındaki değer kullanılır.
                </p>
            </div>
            
            <!--- OUR_COMPANY listesini al --->
            <cfquery name="getCompanies" datasource="#request.dsn#">
                SELECT        
                    COMP_ID, 
                    COMPANY_NAME, 
                    NICK_NAME, 
                    TAX_OFFICE, 
                    TAX_NO
                FROM            
                    OUR_COMPANY
                ORDER BY 
                    COMPANY_NAME
            </cfquery>
            
            <form name="setupForm" method="post" action="index.cfm?fuseaction=partner.setup_process">
                <div class="form-group">
                    <label for="comp_id">Çalışılacak Şirket (COMP_ID)</label>
                    <select 
                        id="comp_id" 
                        name="comp_id" 
                        required 
                        style="width: 100%; padding: 12px 16px; border: 2px solid #e5e7eb; border-radius: 8px; font-size: 14px;">
                        <option value="">-- Şirket Seçiniz --</option>
                        <cfoutput query="getCompanies">
                            <option value="#COMP_ID#" <cfif isDefined("session.b2b.compId") and session.b2b.compId eq COMP_ID>selected</cfif>>
                                #COMPANY_NAME# <cfif len(NICK_NAME)>(#NICK_NAME#)</cfif> - #TAX_NO#
                            </option>
                        </cfoutput>
                    </select>
                    <p style="color: #6b7280; font-size: 12px; margin-top: 4px;">
                        Bu şirket DSN2 ve DSN3'ü belirler. Sadece seçilen şirketle işlem yapabilirsiniz.
                    </p>
                </div>
                
                <div class="form-group">
                    <label>Mevcut Ayarlar</label>
                    <cfoutput>
                        <p style="color: #6b7280; font-size: 14px; margin-top: 8px;">
                            <strong>Kullanıcı Şirket ID (COMPANY_ID):</strong> #isDefined("session.b2b.companyId") ? session.b2b.companyId : "Belirlenmedi"#<br>
                            <strong>Çalışılacak Şirket ID (COMP_ID):</strong> #isDefined("session.b2b.compId") ? session.b2b.compId : "Belirlenmedi"#<br>
                            <strong>DSN:</strong> #request.dsn#<br>
                            <strong>DSN1:</strong> #request.dsn1#<br>
                            <strong>DSN2:</strong> #request.dsn2#<br>
                            <strong>DSN3:</strong> #request.dsn3#<br>
                            <strong>PERIOD_YEAR:</strong> #isDefined("session.b2b.periodYear") ? session.b2b.periodYear : "Belirlenmedi"#
                        </p>
                    </cfoutput>
                </div>
                
                <button type="submit" class="btn-save">Kaydet</button>
            </form>
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

