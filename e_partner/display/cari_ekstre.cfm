<!---
    File: cari_ekstre.cfm
    Folder: AddOns/ezgi/e_partner/display
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Cari Ekstre
--->
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>B2B Partner Portal - Cari Ekstre</title>
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
        @media (max-width: 768px) {
            .navbar-menu {
                flex-wrap: wrap;
            }
            .navbar-menu a {
                padding: 12px 16px;
                font-size: 13px;
            }
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 24px;
        }
        .page-header {
            background: #ffffff;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        .page-header h2 {
            color: #1e3a8a;
            font-size: 28px;
            margin-bottom: 8px;
        }
        .page-header p {
            color: #6b7280;
            font-size: 14px;
        }
        .content-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
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
                    <a href="index.cfm?fuseaction=partner.cari_ekstre" class="active">
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
        <div class="page-header">
            <h2>📋 Cari Ekstre</h2>
            <p>Cari hesap ekstre bilgilerinizi görüntüleyin</p>
        </div>
        
        <!--- Query dosyasını include et --->
        <cfinclude template="../query/get_cari_ekstre.cfm">
        
        <!--- Filtre Formu --->
        <div class="content-card" style="margin-bottom: 24px;">
            <h3 style="margin-bottom: 16px; color: #1e3a8a;">Filtreler</h3>
            <cfform name="filter_form" method="get" action="index.cfm">
                <input type="hidden" name="fuseaction" value="partner.cari_ekstre">
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 16px;">
                    <div>
                        <label style="display: block; margin-bottom: 8px; font-weight: 600; color: #374151;">Başlangıç Tarihi</label>
                        <input type="date" name="date1" value="<cfoutput>#dateformat(date1,'yyyy-mm-dd')#</cfoutput>" style="width: 100%; padding: 8px; border: 1px solid #d1d5db; border-radius: 6px;">
                    </div>
                    <div>
                        <label style="display: block; margin-bottom: 8px; font-weight: 600; color: #374151;">Bitiş Tarihi</label>
                        <input type="date" name="date2" value="<cfoutput>#dateformat(date2,'yyyy-mm-dd')#</cfoutput>" style="width: 100%; padding: 8px; border: 1px solid #d1d5db; border-radius: 6px;">
                    </div>
                </div>
                <!--- İleride kullanılacak: İşlem Dövizli Ekstre Filtresi --->
                <!--- 
                <div style="margin-bottom: 16px;">
                    <label style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
                        <input type="checkbox" name="is_currency_filter" value="1" <cfif isDefined("attributes.is_currency_filter") and attributes.is_currency_filter eq 1>checked</cfif> style="width: 18px; height: 18px; cursor: pointer;">
                        <span style="font-weight: 600; color: #374151;">İşlem Dövizli Ekstre</span>
                    </label>
                </div>
                <div id="currency_filter_section" style="display: none; margin-bottom: 16px;">
                    <label style="display: block; margin-bottom: 8px; font-weight: 600; color: #374151;">Para Birimi</label>
                    <select name="currency_id" style="width: 100%; max-width: 300px; padding: 8px; border: 1px solid #d1d5db; border-radius: 6px;">
                        <option value="">Tüm Para Birimleri</option>
                        <!--- Para birimleri listesi buraya eklenecek --->
                    </select>
                </div>
                --->
                <div style="display: flex; gap: 12px;">
                    <button type="submit" style="padding: 10px 24px; background: #667eea; color: #ffffff; border: none; border-radius: 6px; font-weight: 600; cursor: pointer;">Filtrele</button>
                    <a href="index.cfm?fuseaction=partner.cari_ekstre" style="padding: 10px 24px; background: #6b7280; color: #ffffff; border: none; border-radius: 6px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-block;">Temizle</a>
                </div>
            </cfform>
        </div>
        
        <!--- Devir Bakiyesi --->
        <cfif devir_borc neq 0 or devir_alacak neq 0>
            <div class="content-card" style="margin-bottom: 24px; background: ##fef3c7; border-left: 4px solid ##f59e0b;">
                <h3 style="margin-bottom: 12px; color: ##92400e;">Devir Bakiyesi</h3>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px;">
                    <div>
                        <div style="color: ##6b7280; font-size: 14px;">Borç</div>
                        <div style="font-size: 20px; font-weight: 700; color: ##dc2626;"><cfoutput>#numberformat(devir_borc, '999,999,999.99')# #default_money#</cfoutput></div>
                    </div>
                    <div>
                        <div style="color: ##6b7280; font-size: 14px;">Alacak</div>
                        <div style="font-size: 20px; font-weight: 700; color: ##059669;"><cfoutput>#numberformat(devir_alacak, '999,999,999.99')# #default_money#</cfoutput></div>
                    </div>
                    <div>
                        <div style="color: ##6b7280; font-size: 14px;">Bakiye</div>
                        <div style="font-size: 20px; font-weight: 700; color: <cfif devir_bakiye gt 0>##dc2626<cfelse>##059669</cfif>;">
                            <cfoutput>#numberformat(abs(devir_bakiye), '999,999,999.99')# #default_money#</cfoutput>
                            <span style="font-size: 14px; color: ##6b7280;">(<cfif devir_bakiye gt 0>B<cfelse>A</cfif>)</span>
                        </div>
                    </div>
                </div>
            </div>
        </cfif>
        
        <!--- Cari Ekstre Tablosu --->
        <div class="content-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 style="color: #1e3a8a;">Cari Ekstre Listesi</h3>
                <div style="display: flex; align-items: center; gap: 12px;">
                    <div style="color: #6b7280; font-size: 14px;">
                        <cfoutput>Toplam #totalrecords# kayıt</cfoutput>
                    </div>
                    <div style="display: flex; gap: 8px;">
                        <cfoutput>
                        <a href="index.cfm?fuseaction=partner.export_cari_ekstre_pdf&date1=#dateformat(date1,'yyyy-mm-dd')#&date2=#dateformat(date2,'yyyy-mm-dd')#" 
                           style="padding: 8px 16px; background: ##dc2626; color: ##ffffff; border: none; border-radius: 6px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; font-size: 13px;">
                            📄 PDF İndir
                        </a>
                        <a href="index.cfm?fuseaction=partner.export_cari_ekstre_excel&date1=#dateformat(date1,'yyyy-mm-dd')#&date2=#dateformat(date2,'yyyy-mm-dd')#" 
                           style="padding: 8px 16px; background: ##059669; color: ##ffffff; border: none; border-radius: 6px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; font-size: 13px;">
                            📊 Excel İndir
                        </a>
                        </cfoutput>
                    </div>
                </div>
            </div>
            
            <cfif CARI_ROWS_ALL.recordcount gt 0>
                <div style="overflow-x: auto;">
                    <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
                        <thead>
                            <tr style="background: ##f3f4f6; border-bottom: 2px solid ##e5e7eb;">
                                <th style="padding: 10px 8px; text-align: left; font-weight: 600; color: ##374151; font-size: 12px; white-space: nowrap; width: 50px;">No</th>
                                <th style="padding: 10px 8px; text-align: left; font-weight: 600; color: ##374151; font-size: 12px; white-space: nowrap; width: 100px;">Tarih</th>
                                <th style="padding: 10px 8px; text-align: left; font-weight: 600; color: ##374151; font-size: 12px; white-space: nowrap; width: 100px;">Belge No</th>
                                <th style="padding: 10px 8px; text-align: left; font-weight: 600; color: ##374151; font-size: 12px; min-width: 200px;">İşlem</th>
                                <th style="padding: 10px 8px; text-align: left; font-weight: 600; color: ##374151; font-size: 12px; min-width: 200px;">Açıklama</th>
                                <th style="padding: 10px 8px; text-align: right; font-weight: 600; color: ##374151; font-size: 12px; white-space: nowrap; width: 120px;">Borç</th>
                                <th style="padding: 10px 8px; text-align: right; font-weight: 600; color: ##374151; font-size: 12px; white-space: nowrap; width: 120px;">Alacak</th>
                                <th style="padding: 10px 8px; text-align: right; font-weight: 600; color: ##374151; font-size: 12px; white-space: nowrap; width: 120px;">Bakiye</th>
                                <th style="padding: 10px 8px; text-align: center; font-weight: 600; color: ##374151; font-size: 12px; white-space: nowrap; width: 50px;">B/A</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfset bakiye = devir_bakiye>
                            
                            <cfoutput query="CARI_ROWS_ALL" startrow="#startrow#" maxrows="#attributes.maxrows#">
                                <cfset bakiye = bakiye + borc - alacak>
                                
                                <tr style="border-bottom: 1px solid ##e5e7eb; line-height: 1.5;">
                                    <td style="padding: 10px 8px; color: ##6b7280; font-size: 13px; vertical-align: top;">#currentrow#</td>
                                    <td style="padding: 10px 8px; color: ##374151; font-size: 13px; white-space: nowrap; vertical-align: top;">#dateformat(action_date, 'dd.mm.yyyy')#</td>
                                    <td style="padding: 10px 8px; color: ##374151; font-size: 13px; white-space: nowrap; vertical-align: top;">#HTMLEditFormat(paper_no)#</td>
                                    <td style="padding: 10px 8px; color: ##374151; font-size: 13px; word-wrap: break-word; max-width: 300px; vertical-align: top;">#HTMLEditFormat(action_name)#</td>
                                    <td style="padding: 10px 8px; color: ##374151; font-size: 13px; word-wrap: break-word; max-width: 300px; vertical-align: top;">
                                        <cfif len(action_detail) and action_detail neq ''>#HTMLEditFormat(action_detail)#<cfelse>-</cfif>
                                    </td>
                                    <td style="padding: 10px 8px; text-align: right; color: <cfif borc gt 0>##dc2626<cfelse>##6b7280</cfif>; font-size: 13px; white-space: nowrap; vertical-align: top;">
                                        <cfif borc gt 0>#numberformat(borc, '999,999,999.99')# <cfif len(action_currency_id) and action_currency_id neq ''>#HTMLEditFormat(action_currency_id)#<cfelse>#default_money#</cfif><cfelse>-</cfif>
                                    </td>
                                    <td style="padding: 10px 8px; text-align: right; color: <cfif alacak gt 0>##059669<cfelse>##6b7280</cfif>; font-size: 13px; white-space: nowrap; vertical-align: top;">
                                        <cfif alacak gt 0>#numberformat(alacak, '999,999,999.99')# <cfif len(action_currency_id) and action_currency_id neq ''>#HTMLEditFormat(action_currency_id)#<cfelse>#default_money#</cfif><cfelse>-</cfif>
                                    </td>
                                    <td style="padding: 10px 8px; text-align: right; font-weight: 600; color: <cfif bakiye gt 0>##dc2626<cfelse>##059669</cfif>; font-size: 13px; white-space: nowrap; vertical-align: top;">
                                        #numberformat(abs(bakiye), '999,999,999.99')# #default_money#
                                    </td>
                                    <td style="padding: 10px 8px; text-align: center; color: ##6b7280; font-size: 13px; white-space: nowrap; vertical-align: top;">
                                        <cfif bakiye gt 0>B<cfelse>A</cfif>
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                        <tfoot>
                            <cfoutput>
                            <tr style="background: ##f9fafb; border-top: 2px solid ##e5e7eb; font-weight: 700; line-height: 1.5;">
                                <td colspan="5" style="padding: 12px 8px; text-align: right; color: ##374151; font-size: 13px; font-weight: 700;">Genel Toplam:</td>
                                <td style="padding: 12px 8px; text-align: right; color: ##dc2626; font-size: 13px; font-weight: 700; white-space: nowrap;">#numberformat(gen_borc_top, '999,999,999.99')# #default_money#</td>
                                <td style="padding: 12px 8px; text-align: right; color: ##059669; font-size: 13px; font-weight: 700; white-space: nowrap;">#numberformat(gen_ala_top, '999,999,999.99')# #default_money#</td>
                                <td style="padding: 12px 8px; text-align: right; color: <cfif gen_bak_top gt 0>##dc2626<cfelse>##059669</cfif>; font-size: 13px; font-weight: 700; white-space: nowrap;">
                                    #numberformat(abs(gen_bak_top), '999,999,999.99')# #default_money#
                                </td>
                                <td style="padding: 12px 8px; text-align: center; color: ##6b7280; font-size: 13px; font-weight: 700; white-space: nowrap;">
                                    <cfif gen_bak_top gt 0>B<cfelse>A</cfif>
                                </td>
                            </tr>
                            </cfoutput>
                        </tfoot>
                    </table>
                </div>
                
                <!--- Sayfalama --->
                <cfif totalrecords gt attributes.maxrows>
                    <div style="display: flex; justify-content: center; align-items: center; gap: 8px; margin-top: 24px;">
                        <cfset totalpages = ceiling(totalrecords / attributes.maxrows)>
                        
                        <cfoutput>
                            <cfif attributes.page gt 1>
                                <a href="index.cfm?fuseaction=partner.cari_ekstre&date1=#URLEncodedFormat(dateformat(date1,'yyyy-mm-dd'))#&date2=#URLEncodedFormat(dateformat(date2,'yyyy-mm-dd'))#&page=#attributes.page-1#" 
                                   style="padding: 8px 16px; background: ##667eea; color: ##ffffff; border-radius: 6px; text-decoration: none; font-weight: 600;">Önceki</a>
                            </cfif>
                            
                            <cfloop from="1" to="#totalpages#" index="p">
                                <cfif p eq attributes.page>
                                    <span style="padding: 8px 16px; background: ##667eea; color: ##ffffff; border-radius: 6px; font-weight: 600;">#p#</span>
                                <cfelse>
                                    <a href="index.cfm?fuseaction=partner.cari_ekstre&date1=#URLEncodedFormat(dateformat(date1,'yyyy-mm-dd'))#&date2=#URLEncodedFormat(dateformat(date2,'yyyy-mm-dd'))#&page=#p#" 
                                       style="padding: 8px 16px; background: ##e5e7eb; color: ##374151; border-radius: 6px; text-decoration: none;">#p#</a>
                                </cfif>
                            </cfloop>
                            
                            <cfif attributes.page lt totalpages>
                                <a href="index.cfm?fuseaction=partner.cari_ekstre&date1=#URLEncodedFormat(dateformat(date1,'yyyy-mm-dd'))#&date2=#URLEncodedFormat(dateformat(date2,'yyyy-mm-dd'))#&page=#attributes.page+1#" 
                                   style="padding: 8px 16px; background: ##667eea; color: ##ffffff; border-radius: 6px; text-decoration: none; font-weight: 600;">Sonraki</a>
                            </cfif>
                        </cfoutput>
                    </div>
                </cfif>
            <cfelse>
                <div style="padding: 48px; text-align: center; color: #6b7280;">
                    <p style="font-size: 18px; margin-bottom: 8px;">Kayıt bulunamadı</p>
                    <p style="font-size: 14px;">Seçilen tarih aralığında cari ekstre kaydı bulunmamaktadır.</p>
                </div>
            </cfif>
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

