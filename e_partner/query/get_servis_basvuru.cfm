<!---
    File: get_servis_basvuru.cfm
    Folder: AddOns/ezgi/e_partner/query
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Servis Başvuru Liste Sorgusu
    Referans: V16/service/cfc/ServiceAction.cfc - list_service fonksiyonu
--->
<cfparam name="url.page" default="1">
<cfparam name="url.maxrows" default="20">

<!--- Partner ID ve Company ID --->
<cfset partner_id = session.b2b.partnerId>
<cfset company_id = session.b2b.companyId>

<!--- Sayfalama --->
<cfset page = url.page>
<cfset maxrows = url.maxrows>
<cfset startrow = ((page-1)*maxrows)+1>

<!--- Basit sorgu ile tüm verileri al --->

    <cfquery name="get_servis_basvuru" datasource="#request.dsn3#">
        SELECT
            S.SERVICE_ID AS BASVURU_ID,
            S.SERVICE_NO AS BASVURU_NO,
            S.APPLY_DATE AS BASVURU_TARIHI,
            S.SERVICECAT_ID AS KATEGORI_ID,
            SA.SERVICECAT AS KATEGORI_ADI,
            S.SERVICE_HEAD AS KONU,
            S.PRIORITY_ID AS ONCELIK_ID,
            CAST('' AS VARCHAR(200)) AS ONCELIK_ADI,
            S.SERVICE_STATUS_ID,
            CAST(0 AS INTEGER) AS STAGE,
            CAST('Bilinmiyor' AS VARCHAR(50)) AS DURUM,
            S.RECORD_DATE,
            COUNT(*) OVER() AS QUERY_COUNT
        FROM
            SERVICE S
            LEFT JOIN SERVICE_APPCAT SA ON SA.SERVICECAT_ID = S.SERVICECAT_ID
        WHERE
            S.SERVICE_ACTIVE = 1
            AND S.SERVICE_PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_id#">
            AND S.SERVICE_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#company_id#">
        ORDER BY
            S.RECORD_DATE DESC
    </cfquery>
    <!--- Toplam kayıt sayısı --->
    <cfset totalrecords = get_servis_basvuru.recordcount>
    

