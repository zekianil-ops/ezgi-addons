<!---
    File: index.cfm
    Folder: AddOns/ezgi/e_partner
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Ana Giriş Noktası
--->
<cfprocessingdirective suppresswhitespace="Yes">
    <!--- Fuseaction kontrolü --->
    <cfparam name="url.fuseaction" default="partner.login">
    
    <!--- Fuseaction'a göre sayfa yönlendirmesi --->
    <cfswitch expression="#url.fuseaction#">
        
        <!--- Login Sayfası --->
        <cfcase value="partner.login">
            <cfinclude template="display/login.cfm">
        </cfcase>
        
        <!--- Login İşlemi --->
        <cfcase value="partner.login_process">
            <cfinclude template="query/login_process.cfm">
        </cfcase>
        
        <!--- Logout İşlemi --->
        <cfcase value="partner.logout">
            <cfinclude template="query/logout.cfm">
        </cfcase>
        
        <!--- Dashboard --->
        <cfcase value="partner.dashboard">
            <cfinclude template="display/dashboard.cfm">
        </cfcase>
        
        <!--- Ürünler --->
        <cfcase value="partner.products">
            <cfinclude template="display/products.cfm">
        </cfcase>
        
        <!--- Siparişler --->
        <cfcase value="partner.orders">
            <cfinclude template="display/orders.cfm">
        </cfcase>
        
        <!--- Faturalar --->
        <cfcase value="partner.invoices">
            <cfinclude template="display/invoices.cfm">
        </cfcase>
        
        <!--- Fiyat Listeleri --->
        <cfcase value="partner.price_lists">
            <cfinclude template="display/price_lists.cfm">
        </cfcase>
        
        <!--- Raporlar --->
        <cfcase value="partner.reports">
            <cfinclude template="display/reports.cfm">
        </cfcase>
        
        <!--- Profil --->
        <cfcase value="partner.profile">
            <cfinclude template="display/profile.cfm">
        </cfcase>
        
        <!--- Cari Ekstre --->
        <cfcase value="partner.cari_ekstre">
            <cfinclude template="display/cari_ekstre.cfm">
        </cfcase>
        
        <!--- Cari Ekstre PDF Export --->
        <cfcase value="partner.export_cari_ekstre_pdf">
            <cfinclude template="query/export_cari_ekstre_pdf.cfm">
        </cfcase>
        
        <!--- Cari Ekstre Excel Export --->
        <cfcase value="partner.export_cari_ekstre_excel">
            <cfinclude template="query/export_cari_ekstre_excel.cfm">
        </cfcase>
        
        <!--- Servis İşlemleri (Liste) --->
        <cfcase value="partner.servis_islemleri">
            <cfinclude template="display/list_servis_basvuru.cfm">
        </cfcase>
        
        <!--- Servis Başvuru Ekleme --->
        <cfcase value="partner.add_servis_basvuru">
            <cfinclude template="display/add_servis_basvuru.cfm">
        </cfcase>
        
        <!--- Servis Başvuru Ekleme İşlemi --->
        <cfcase value="partner.add_servis_basvuru_process">
            <cfinclude template="query/add_servis_basvuru.cfm">
        </cfcase>
        
        <!--- Servis Başvuru Detay/Güncelleme --->
        <cfcase value="partner.upd_servis_basvuru">
            <cfinclude template="display/upd_servis_basvuru.cfm">
        </cfcase>
        
        <!--- Servis Başvuru Dosya Ekleme İşlemi --->
        <cfcase value="partner.add_servis_basvuru_file">
            <cfinclude template="query/add_servis_basvuru_file.cfm">
        </cfcase>
        
        <!--- Setup --->
        <cfcase value="partner.setup">
            <cfinclude template="display/setup.cfm">
        </cfcase>
        
        <!--- Setup İşlemi --->
        <cfcase value="partner.setup_process">
            <cfinclude template="query/setup_process.cfm">
        </cfcase>
        
        <!--- Varsayılan: Login --->
        <cfdefaultcase>
            <cfinclude template="display/login.cfm">
        </cfdefaultcase>
        
    </cfswitch>
</cfprocessingdirective>

