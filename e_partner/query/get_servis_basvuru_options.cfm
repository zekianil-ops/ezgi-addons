<!---
    File: get_servis_basvuru_options.cfm
    Folder: AddOns/ezgi/e_partner/query
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Servis Başvuru Selectbox Seçenekleri
    Referans: V16/service/display/list_service.cfm ve V16/service/cfc/ServiceAction.cfc
--->
<!--- Kategori seçenekleri (SERVICE_APPCAT tablosundan - list_service.cfm'den) --->
<cfquery name="get_kategoriler" datasource="#request.dsn3#">
    SELECT 
        SERVICECAT_ID AS KATEGORI_ID,
        SERVICECAT AS KATEGORI_ADI
    FROM 
        SERVICE_APPCAT
    ORDER BY 
        SERVICECAT
</cfquery>

<!--- İletişim şekli seçenekleri (SETUP_COMMETHOD tablosundan - V16/service/query/get_com_method.cfm'den) --->
<cfquery name="get_iletisim_sekilleri" datasource="#request.dsn#">
    SELECT 
        COMMETHOD_ID AS ILETISIM_SEKLI_ID,
        COMMETHOD AS ILETISIM_SEKLI_ADI
    FROM 
        SETUP_COMMETHOD
    ORDER BY 
        COMMETHOD
</cfquery>

<!--- Öncelik seçenekleri (SETUP_PRIORITY tablosundan - list_service.cfm'den) --->
<cfquery name="get_oncelikler" datasource="#request.dsn#">
    SELECT 
        PRIORITY_ID AS ONCELIK_ID,
        PRIORITY AS ONCELIK_ADI
    FROM 
        SETUP_PRIORITY
    ORDER BY 
        PRIORITY_ID
</cfquery>

