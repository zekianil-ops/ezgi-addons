<!---
    File: list_servis_basvuru.cfm
    Folder: AddOns/ezgi/e_partner/display
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Servis Başvuru Liste Sayfası
--->
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>B2B Partner Portal - Servis İşlemleri</title>
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
        .navbar-menu a i {
            margin-right: 8px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 24px;
        }
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }
        .page-header h2 {
            color: #1e3a8a;
            font-size: 28px;
            margin-bottom: 8px;
        }
        .page-header p {
            color: #6b7280;
            font-size: 16px;
        }
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
        }
        .btn-primary {
            background: #667eea;
            color: #ffffff;
        }
        .btn-primary:hover {
            background: #5568d3;
        }
        .content-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        .table-wrapper {
            overflow-x: auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        thead {
            background: #f9fafb;
        }
        th {
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #374151;
            font-size: 14px;
            border-bottom: 2px solid #e5e7eb;
        }
        td {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
            font-size: 14px;
            color: #1f2937;
        }
        tbody tr {
            transition: background 0.2s ease;
        }
        tbody tr:hover {
            background: #f9fafb;
            cursor: pointer;
        }
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .status-pending {
            background: #fef3c7;
            color: #92400e;
        }
        .status-in-progress {
            background: #dbeafe;
            color: #1e40af;
        }
        .status-completed {
            background: #d1fae5;
            color: #065f46;
        }
        .no-records {
            text-align: center;
            padding: 40px;
            color: #6b7280;
        }
        @media (max-width: 768px) {
            .navbar-menu {
                flex-wrap: wrap;
            }
            .navbar-menu a {
                padding: 12px 16px;
                font-size: 13px;
            }
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 16px;
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
                    <a href="index.cfm?fuseaction=partner.cari_ekstre">
                        <i>📋</i> Cari Ekstre
                    </a>
                </li>
                <li>
                    <a href="index.cfm?fuseaction=partner.servis_islemleri" class="active">
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
        <div class="page-header">
            <div>
                <h2>🔧 Servis İşlemleri</h2>
                <p>Servis başvurularınızı görüntüleyin ve yönetin</p>
            </div>
            <a href="index.cfm?fuseaction=partner.add_servis_basvuru" class="btn btn-primary">+ Yeni Başvuru</a>
        </div>
        
        <!--- Hata/Başarı Mesajları --->
        <cfif isDefined("url.error") and len(url.error)>
            <div style="background: ##fee2e2; color: ##991b1b; padding: 12px; border-radius: 6px; margin-bottom: 20px; border-left: 4px solid ##ef4444;">
                <cfoutput>#HTMLEditFormat(url.error)#</cfoutput>
            </div>
        </cfif>
        <cfif isDefined("url.success") and len(url.success)>
            <div style="background: ##d1fae5; color: ##065f46; padding: 12px; border-radius: 6px; margin-bottom: 20px; border-left: 4px solid ##10b981;">
                <cfoutput>#HTMLEditFormat(url.success)#</cfoutput>
            </div>
        </cfif>
        <cfif isDefined("session.b2b.error_message") and len(session.b2b.error_message)>
            <div style="background: ##fee2e2; color: ##991b1b; padding: 12px; border-radius: 6px; margin-bottom: 20px; border-left: 4px solid ##ef4444;">
                <cfoutput>#HTMLEditFormat(session.b2b.error_message)#</cfoutput>
            </div>
            <cfset structDelete(session.b2b, "error_message")>
        </cfif>
        
        <div class="content-card">
            <!--- Query dosyasını include et --->
            <cfinclude template="../query/get_servis_basvuru.cfm">
            <cfinclude template="../query/get_servis_basvuru_options.cfm">
            <cfoutput query="get_kategoriler">
                <cfset 'KATEGORI_ADI_#KATEGORI_ID#' = KATEGORI_ADI>
            </cfoutput>
            <cfoutput query="get_oncelikler">
                <cfset 'ONCELIK_ADI_#ONCELIK_ID#' = ONCELIK_ADI>
            </cfoutput>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Başvuru No</th>
                            <th>Başvuru Tarihi</th>
                            <th>Kategori</th>
                            <th>Konu</th>
                            <th>Öncelik</th>
                            <th>Durum</th>
                            <th>İşlem</th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif isDefined("get_servis_basvuru") and get_servis_basvuru.recordcount gt 0>
                            <cfoutput query="get_servis_basvuru">
                                <tr onclick="window.location.href='index.cfm?fuseaction=partner.upd_servis_basvuru&basvuru_id=#basvuru_id#'">
                                    <td>#HTMLEditFormat(basvuru_no)#</td>
                                    <td>#dateformat(basvuru_tarihi, 'dd.mm.yyyy')#</td>
                                    <td><cfif isDefined('KATEGORI_ADI_#KATEGORI_ID#')>#Evaluate('KATEGORI_ADI_#KATEGORI_ID#')#</cfif></td>
                                    <td>#HTMLEditFormat(konu)#</td>
                                    <td><cfif isDefined('ONCELIK_ADI_#ONCELIK_ID#')>#Evaluate('ONCELIK_ADI_#ONCELIK_ID#')#</cfif></td>
                                    <td>
                                        <span class="status-badge status-pending">Beklemede</span>
                                    </td>
                                    <td>
                                        <a href="index.cfm?fuseaction=partner.upd_servis_basvuru&basvuru_id=#basvuru_id#" style="color: ##667eea; text-decoration: none;">Detay</a>
                                    </td>
                                </tr>
                            </cfoutput>
                        <cfelse>
                            <tr>
                                <td colspan="7" class="no-records">
                                    Henüz servis başvurunuz bulunmamaktadır.
                                    <br><br>
                                    <a href="index.cfm?fuseaction=partner.add_servis_basvuru" class="btn btn-primary">Yeni Başvuru Oluştur</a>
                                </td>
                            </tr>
                        </cfif>
                    </tbody>
                </table>
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

