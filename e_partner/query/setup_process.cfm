<!---
    File: setup_process.cfm
    Folder: AddOns/ezgi/e_partner/query
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Setup İşlemi
--->
<cftry>
    <cfparam name="form.comp_id" default="">
    
    <!--- Form kontrolü --->
    <cfif not len(trim(form.comp_id)) or not isNumeric(trim(form.comp_id))>
        <cflocation url="index.cfm?fuseaction=partner.setup&error=#URLEncodedFormat('COMP_ID geçerli bir sayı olmalıdır')#" addtoken="false">
        <cfabort>
    </cfif>
    
    <cfset compId = trim(form.comp_id)>
    
    <!--- Seçilen şirketin OUR_COMPANY tablosunda olup olmadığını kontrol et --->
    <cfquery name="checkCompany" datasource="#request.dsn#">
        SELECT        
            COMP_ID, 
            COMPANY_NAME
        FROM            
            OUR_COMPANY
        WHERE        
            (COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#compId#">)
    </cfquery>
    
    <!--- Şirket kontrolü --->
    <cfif checkCompany.recordcount eq 0>
        <cflocation url="index.cfm?fuseaction=partner.setup&error=#URLEncodedFormat('Seçilen şirket bulunamadı')#" addtoken="false">
        <cfabort>
    </cfif>
    
    <!--- PERIOD_YEAR'ı sorgu ile al (COMP_ID'ye göre) --->
    <cfquery name="getPeriod" datasource="#request.dsn#">
        SELECT        
            TOP (1) PERIOD_ID, 
            PERIOD, 
            PERIOD_YEAR, 
            OUR_COMPANY_ID, 
            PERIOD_DATE, 
            OTHER_MONEY, 
            STANDART_PROCESS_MONEY
        FROM            
            SETUP_PERIOD
        WHERE        
            (OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#compId#">)
        ORDER BY 
            PERIOD_YEAR DESC
    </cfquery>
    
    <!--- PERIOD_YEAR kontrolü --->
    <cfif getPeriod.recordcount eq 0>
        <cflocation url="index.cfm?fuseaction=partner.setup&error=#URLEncodedFormat('Bu şirket için aktif dönem bulunamadı')#" addtoken="false">
        <cfabort>
    </cfif>
    
    <cfset periodYear = getPeriod.PERIOD_YEAR>
    
    <!--- Session'ı güncelle --->
    <cfscript>
        session.b2b.compId = compId; // Çalışılacak şirket ID (DSN2 ve DSN3'ü belirler)
        session.b2b.periodYear = periodYear;
        // COMPANY_ID login'den gelir, burada değiştirilmez
    </cfscript>
    
    <!--- Setup sayfasına başarı mesajı ile yönlendir --->
    <cflocation url="index.cfm?fuseaction=partner.setup&success=1" addtoken="false">
    
    <cfcatch type="database">
        <cflocation url="index.cfm?fuseaction=partner.setup&error=#URLEncodedFormat('Veritabanı hatası: ' & cfcatch.message)#" addtoken="false">
        <cfabort>
    </cfcatch>
    <cfcatch type="any">
        <cflocation url="index.cfm?fuseaction=partner.setup&error=#URLEncodedFormat('Hata: ' & cfcatch.message)#" addtoken="false">
        <cfabort>
    </cfcatch>
</cftry>

