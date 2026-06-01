<!---
    File: get_cari_ekstre.cfm
    Folder: AddOns/ezgi/e_partner/query
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Cari Ekstre Query
--->
<cfparam name="attributes.date1" default="">
<cfparam name="attributes.date2" default="">
<cfparam name="url.date1" default="">
<cfparam name="url.date2" default="">
<cfparam name="url.page" default="1">
<cfparam name="attributes.page" default="#url.page#">
<cfparam name="attributes.maxrows" default="50">

<!--- Tarih formatı kontrolü --->
<cfif len(url.date1) and isdate(url.date1)>
    <cfset date1 = url.date1>
<cfelseif isdefined("attributes.date1") and len(attributes.date1) and isdate(attributes.date1)>
    <cfset date1 = attributes.date1>
<cfelse>
    <cfset date1 = dateformat(dateadd("m",-1,now()),"yyyy-mm-dd")>
</cfif>

<cfif len(url.date2) and isdate(url.date2)>
    <cfset date2 = url.date2>
<cfelseif isdefined("attributes.date2") and len(attributes.date2) and isdate(attributes.date2)>
    <cfset date2 = attributes.date2>
<cfelse>
    <cfset date2 = dateformat(now(),"yyyy-mm-dd")>
</cfif>

<!--- Partner'ın COMPANY_ID'si --->
<cfset partner_company_id = session.b2b.companyId>

<!--- DSN2 (dönem datasource) --->
<cfset dsn2 = request.dsn2>

<!--- COMP_ID ve PERIOD_YEAR kontrolü --->
<cfif not structKeyExists(session, "b2b") or not structKeyExists(session.b2b, "compId") or not len(session.b2b.compId) or session.b2b.compId eq 0>
    <!--- DSN2'den compId çıkarmayı dene --->
    <cfif isDefined("request.dsn2") and len(request.dsn2)>
        <!--- DSN2 formatı: demo_ezgiyazilim_2025_1 -> compId = 1 --->
        <cfset dsn2_parts = listToArray(request.dsn2, "_")>
        <cfif arrayLen(dsn2_parts) gte 3>
            <cfset comp_id_for_query = dsn2_parts[arrayLen(dsn2_parts)]>
            <cfset period_year_for_query = dsn2_parts[arrayLen(dsn2_parts)-1]>
        <cfelse>
            <cfset comp_id_for_query = 1>
            <cfset period_year_for_query = year(now())>
        </cfif>
    <cfelse>
        <cfset comp_id_for_query = 1>
        <cfset period_year_for_query = year(now())>
    </cfif>
<cfelse>
    <cfset comp_id_for_query = session.b2b.compId>
    <cfif not structKeyExists(session.b2b, "periodYear") or not len(session.b2b.periodYear)>
        <cfset period_year_for_query = year(now())>
    <cfelse>
        <cfset period_year_for_query = session.b2b.periodYear>
    </cfif>
</cfif>

<!--- Ana para birimini al (SETUP_MONEY tablosundan) --->
<cfquery name="GET_DEFAULT_MONEY" datasource="#request.dsn#">
    SELECT TOP 1
        SM.MONEY
    FROM
        SETUP_MONEY SM
        INNER JOIN SETUP_PERIOD SP ON SM.PERIOD_ID = SP.PERIOD_ID
    WHERE
        SP.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#comp_id_for_query#">
        AND SP.PERIOD_YEAR = <cfqueryparam cfsqltype="cf_sql_integer" value="#period_year_for_query#">
        AND SM.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#comp_id_for_query#">
        AND SM.RATE1 = 1 
        AND SM.RATE2 = 1
        AND SM.MONEY_STATUS = 1
    ORDER BY
        SP.PERIOD_YEAR DESC
</cfquery>

<cfif GET_DEFAULT_MONEY.recordcount gt 0>
    <cfset default_money = GET_DEFAULT_MONEY.MONEY>
<cfelse>
    <cfset default_money = "TL">
</cfif>

<!--- Devir bakiyesi hesaplama (tarih aralığından önceki kayıtlar) --->
<cfquery name="GET_DEVIR" datasource="#dsn2#">
    SELECT 
        ISNULL(SUM(CASE WHEN FROM_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#"> THEN ACTION_VALUE ELSE 0 END), 0) AS DEVIR_ALACAK,
        ISNULL(SUM(CASE WHEN TO_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#"> THEN ACTION_VALUE ELSE 0 END), 0) AS DEVIR_BORC
    FROM 
        CARI_ROWS
    WHERE 
        ACTION_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date1#">
        AND (
            FROM_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#">
            OR TO_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#">
        )
        AND IS_CANCEL = 0
</cfquery>

<cfset devir_alacak = GET_DEVIR.DEVIR_ALACAK>
<cfset devir_borc = GET_DEVIR.DEVIR_BORC>
<cfset devir_bakiye = devir_borc - devir_alacak>

<!--- Ana sorgu: UNION ALL ile borç ve alacak kayıtlarını birleştir --->
<cfquery name="CARI_ROWS_ALL" datasource="#dsn2#">
    SELECT 
        CR.ACTION_ID,
        CR.CARI_ACTION_ID,
        CR.ACTION_TYPE_ID,
        CR.ACTION_TABLE,
        CR.OTHER_MONEY,
        CR.ACTION_CURRENCY_ID,
        CR.PAPER_NO,
        CR.ACTION_NAME,
        CR.ACTION_DETAIL,
        CR.ACTION_DATE,
        CR.DUE_DATE,
        CR.RECORD_DATE,
        0 AS BORC,
        CR.ACTION_VALUE AS ALACAK,
        CR.ACTION_VALUE AS ACTION_VALUE,
        ISNULL(CR.ACTION_VALUE_2, 0) AS ALACAK2,
        ISNULL(CR.OTHER_CASH_ACT_VALUE, 0) AS OTHER_CASH_ACT_VALUE
    FROM 
        CARI_ROWS CR
    WHERE 
        CR.FROM_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#">
        AND CR.ACTION_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date1#">
        AND CR.ACTION_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date2#">
        AND CR.IS_CANCEL = 0
    
    UNION ALL
    
    SELECT 
        CR.ACTION_ID,
        CR.CARI_ACTION_ID,
        CR.ACTION_TYPE_ID,
        CR.ACTION_TABLE,
        CR.OTHER_MONEY,
        CR.ACTION_CURRENCY_ID,
        CR.PAPER_NO,
        CR.ACTION_NAME,
        CR.ACTION_DETAIL,
        CR.ACTION_DATE,
        CR.DUE_DATE,
        CR.RECORD_DATE,
        CR.ACTION_VALUE AS BORC,
        0 AS ALACAK,
        CR.ACTION_VALUE AS ACTION_VALUE,
        ISNULL(CR.ACTION_VALUE_2, 0) AS ALACAK2,
        ISNULL(CR.OTHER_CASH_ACT_VALUE, 0) AS OTHER_CASH_ACT_VALUE
    FROM 
        CARI_ROWS CR
    WHERE 
        CR.TO_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#">
        AND CR.ACTION_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date1#">
        AND CR.ACTION_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date2#">
        AND CR.IS_CANCEL = 0
    
    ORDER BY 
        ACTION_DATE,
        RECORD_DATE,
        ACTION_ID
</cfquery>

<!--- Toplam kayıt sayısı --->
<cfset totalrecords = CARI_ROWS_ALL.recordcount>

<!--- Sayfalama hesaplama --->
<cfset startrow = ((attributes.page - 1) * attributes.maxrows) + 1>
<cfset endrow = startrow + attributes.maxrows - 1>

<!--- Bakiye hesaplama için değişkenler --->
<cfset gen_borc_top = devir_borc>
<cfset gen_ala_top = devir_alacak>
<cfset gen_bak_top = devir_bakiye>

<!--- Toplam borç ve alacak hesaplama (tarih aralığındaki kayıtlar için) --->
<cfquery name="GET_TOTALS" datasource="#dsn2#">
    SELECT 
        ISNULL(SUM(CASE WHEN TO_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#"> THEN ACTION_VALUE ELSE 0 END), 0) AS TOTAL_BORC,
        ISNULL(SUM(CASE WHEN FROM_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#"> THEN ACTION_VALUE ELSE 0 END), 0) AS TOTAL_ALACAK
    FROM 
        CARI_ROWS
    WHERE 
        ACTION_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date1#">
        AND ACTION_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date2#">
        AND (
            FROM_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#">
            OR TO_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#">
        )
        AND IS_CANCEL = 0
</cfquery>

<!--- Genel toplam = Devir + Tarih aralığındaki toplamlar --->
<cfset gen_borc_top = devir_borc + GET_TOTALS.TOTAL_BORC>
<cfset gen_ala_top = devir_alacak + GET_TOTALS.TOTAL_ALACAK>
<cfset gen_bak_top = gen_borc_top - gen_ala_top>

