<!---
    File: get_servis_basvuru_detail.cfm
    Folder: AddOns/ezgi/e_partner/query
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Servis Başvuru Detay Sorgusu
--->
<cfparam name="url.basvuru_id" default="0">

<!--- Partner ID ve Company ID --->
<cfset partner_id = session.b2b.partnerId>
<cfset company_id = session.b2b.companyId>
<cfset basvuru_id = url.basvuru_id>

<!--- Başvuru detaylarını getir --->
<cftry>
    <cfquery name="get_basvuru_detail" datasource="#request.dsn3#">
        SELECT
            S.SERVICE_ID AS BASVURU_ID,
            S.SERVICE_NO AS BASVURU_NO,
            S.APPLY_DATE AS BASVURU_TARIHI,
            S.SERVICECAT_ID AS KATEGORI_ID,
            SA.SERVICECAT AS KATEGORI_ADI,
            S.SERVICE_HEAD AS KONU,
            S.SERVICE_DETAIL AS ACIKLAMA,
            S.PRIORITY_ID AS ONCELIK_ID,
            S.SERVICE_STATUS_ID,
            S.COMMETHOD_ID AS ILETISIM_SEKLI_ID,
            S.APPLICATOR_NAME AS ADI_SOYADI,
            S.BRING_MOBILE_NO AS CEP_TELEFONU,
            S.BRING_EMAIL AS MAIL_ADRESI,
            S.RECORD_DATE,
            S.RECORD_MEMBER
        FROM
            SERVICE S
            LEFT JOIN SERVICE_APPCAT SA ON SA.SERVICECAT_ID = S.SERVICECAT_ID
        WHERE
            S.SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#basvuru_id#">
            AND S.SERVICE_ACTIVE = 1
            AND S.SERVICE_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_id#">
            AND S.SERVICE_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#company_id#">
    </cfquery>
    
    <!--- Eğer kayıt bulunamadıysa --->
    <cfif get_basvuru_detail.recordcount eq 0>
        <cflocation url="index.cfm?fuseaction=partner.servis_islemleri&error=Başvuru bulunamadı" addtoken="no">
    </cfif>
    
    <!--- Öncelik bilgisini getir --->
    <cfset oncelik_adi = "">
    <cfif isDefined("get_basvuru_detail.ONCELIK_ID") 
          and not isNull(get_basvuru_detail.ONCELIK_ID)
          and isNumeric(get_basvuru_detail.ONCELIK_ID)
          and get_basvuru_detail.ONCELIK_ID gt 0>
        <cftry>
            <cfquery name="get_priority" datasource="#request.dsn#">
                SELECT PRIORITY
                FROM SETUP_PRIORITY
                WHERE PRIORITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_basvuru_detail.ONCELIK_ID#">
            </cfquery>
            <cfif get_priority.recordcount gt 0>
                <cfset oncelik_adi = get_priority.PRIORITY>
            </cfif>
        <cfcatch>
        </cfcatch>
        </cftry>
    </cfif>
    
    <!--- Durum bilgisini getir --->
    <cfset durum = "Bilinmiyor">
    <cfset stage = 0>
    <cfif isDefined("get_basvuru_detail.SERVICE_STATUS_ID") 
          and not isNull(get_basvuru_detail.SERVICE_STATUS_ID)
          and isNumeric(get_basvuru_detail.SERVICE_STATUS_ID)
          and get_basvuru_detail.SERVICE_STATUS_ID gt 0>
        <cftry>
            <cfquery name="get_status" datasource="#request.dsn#">
                SELECT STAGE
                FROM PROCESS_TYPE_ROWS
                WHERE PROCESS_ROW_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_basvuru_detail.SERVICE_STATUS_ID#">
            </cfquery>
            <cfif get_status.recordcount gt 0>
                <cfset stage = get_status.STAGE>
                <cfif stage eq 0>
                    <cfset durum = "Beklemede">
                <cfelseif stage eq 1>
                    <cfset durum = "Devam Ediyor">
                <cfelseif stage eq 3>
                    <cfset durum = "Tamamlandı">
                </cfif>
            </cfif>
        <cfcatch>
        </cfcatch>
        </cftry>
    </cfif>
    
    <!--- İletişim şekli bilgisini getir --->
    <cfset iletisim_sekli_adi = "">
    <cfif isDefined("get_basvuru_detail.ILETISIM_SEKLI_ID") 
          and not isNull(get_basvuru_detail.ILETISIM_SEKLI_ID)
          and isNumeric(get_basvuru_detail.ILETISIM_SEKLI_ID)
          and get_basvuru_detail.ILETISIM_SEKLI_ID gt 0>
        <cftry>
            <cfquery name="get_commethod" datasource="#request.dsn#">
                SELECT COMMETHOD
                FROM SETUP_COMMETHOD
                WHERE COMMETHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_basvuru_detail.ILETISIM_SEKLI_ID#">
            </cfquery>
            <cfif get_commethod.recordcount gt 0>
                <cfset iletisim_sekli_adi = get_commethod.COMMETHOD>
            </cfif>
        <cfcatch>
        </cfcatch>
        </cftry>
    </cfif>
    
    <!--- Yüklenen dosyaları getir --->
    <cfset get_service_files = QueryNew("FILE_ID,SERVICE_ID,FILE_NAME,SERVER_FILE_NAME,FILE_PATH,FILE_SIZE,FILE_TYPE,IS_IMAGE,IS_VIDEO,RECORD_DATE")>
    <cftry>
        <cfquery name="get_service_files" datasource="#request.dsn3#">
            SELECT
                FILE_ID,
                SERVICE_ID,
                FILE_NAME,
                SERVER_FILE_NAME,
                FILE_PATH,
                FILE_SIZE,
                FILE_TYPE,
                IS_IMAGE,
                IS_VIDEO,
                RECORD_DATE
            FROM
                SERVICE_FILES
            WHERE
                SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#basvuru_id#">
            ORDER BY
                RECORD_DATE ASC
        </cfquery>
    <cfcatch>
        <!--- Tablo yoksa boş query döndür --->
        <cfset get_service_files = QueryNew("FILE_ID,SERVICE_ID,FILE_NAME,SERVER_FILE_NAME,FILE_PATH,FILE_SIZE,FILE_TYPE,IS_IMAGE,IS_VIDEO,RECORD_DATE")>
    </cfcatch>
    </cftry>
    
<cfcatch>
    <cflocation url="index.cfm?fuseaction=partner.servis_islemleri&error=Başvuru detayları getirilirken bir hata oluştu" addtoken="no">
</cfcatch>
</cftry>

