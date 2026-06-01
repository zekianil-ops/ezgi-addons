<!---
    File: export_cari_ekstre_excel.cfm
    Folder: AddOns/ezgi/e_partner/query
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Cari Ekstre Excel Export
--->
<cfparam name="url.date1" default="">
<cfparam name="url.date2" default="">

<!--- Tarih formatı kontrolü --->
<cfif len(url.date1) and isdate(url.date1)>
    <cfset date1 = url.date1>
<cfelse>
    <cfset date1 = dateformat(dateadd("m",-1,now()),"yyyy-mm-dd")>
</cfif>

<cfif len(url.date2) and isdate(url.date2)>
    <cfset date2 = url.date2>
<cfelse>
    <cfset date2 = dateformat(now(),"yyyy-mm-dd")>
</cfif>

<!--- Partner'ın COMPANY_ID'si --->
<cfset partner_company_id = session.b2b.companyId>

<!--- DSN2 (dönem datasource) --->
<cfset dsn2 = request.dsn2>

<!--- Ana para birimini al --->
<cfif not structKeyExists(session, "b2b") or not structKeyExists(session.b2b, "compId") or not len(session.b2b.compId) or session.b2b.compId eq 0>
    <cfif isDefined("request.dsn2") and len(request.dsn2)>
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

<cfquery name="GET_DEFAULT_MONEY" datasource="#request.dsn#">
    SELECT TOP 1 SM.MONEY
    FROM SETUP_MONEY SM
    INNER JOIN SETUP_PERIOD SP ON SM.PERIOD_ID = SP.PERIOD_ID
    WHERE SP.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#comp_id_for_query#">
    AND SP.PERIOD_YEAR = <cfqueryparam cfsqltype="cf_sql_integer" value="#period_year_for_query#">
    AND SM.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#comp_id_for_query#">
    AND SM.RATE1 = 1 AND SM.RATE2 = 1 AND SM.MONEY_STATUS = 1
    ORDER BY SP.PERIOD_YEAR DESC
</cfquery>

<cfset default_money = "TL">
<cfif GET_DEFAULT_MONEY.recordcount gt 0>
    <cfset default_money = GET_DEFAULT_MONEY.MONEY>
</cfif>

<!--- Şirket bilgilerini al --->
<cfquery name="GET_COMPANY" datasource="#request.dsn#">
    SELECT COMPANY_NAME
    FROM OUR_COMPANY
    WHERE COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#comp_id_for_query#">
</cfquery>

<cfset company_name = "">
<cfif GET_COMPANY.recordcount gt 0>
    <cfset company_name = GET_COMPANY.COMPANY_NAME>
</cfif>

<!--- Devir bakiyesi --->
<cfquery name="GET_DEVIR" datasource="#dsn2#">
    SELECT 
        ISNULL(SUM(CASE WHEN FROM_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#"> THEN ACTION_VALUE ELSE 0 END), 0) AS DEVIR_ALACAK,
        ISNULL(SUM(CASE WHEN TO_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#"> THEN ACTION_VALUE ELSE 0 END), 0) AS DEVIR_BORC
    FROM CARI_ROWS
    WHERE ACTION_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date1#">
    AND (FROM_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#">
    OR TO_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#">)
    AND IS_CANCEL = 0
</cfquery>

<cfset devir_alacak = GET_DEVIR.DEVIR_ALACAK>
<cfset devir_borc = GET_DEVIR.DEVIR_BORC>
<cfset devir_bakiye = devir_borc - devir_alacak>

<!--- Ana sorgu --->
<cfquery name="CARI_ROWS_ALL" datasource="#dsn2#">
    SELECT 
        CR.ACTION_ID,
        CR.PAPER_NO,
        CR.ACTION_NAME,
        CR.ACTION_DETAIL,
        CR.ACTION_DATE,
        CR.ACTION_CURRENCY_ID,
        0 AS BORC,
        CR.ACTION_VALUE AS ALACAK,
        CR.ACTION_VALUE AS ACTION_VALUE
    FROM CARI_ROWS CR
    WHERE CR.FROM_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#">
    AND CR.ACTION_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date1#">
    AND CR.ACTION_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date2#">
    AND CR.IS_CANCEL = 0
    
    UNION ALL
    
    SELECT 
        CR.ACTION_ID,
        CR.PAPER_NO,
        CR.ACTION_NAME,
        CR.ACTION_DETAIL,
        CR.ACTION_DATE,
        CR.ACTION_CURRENCY_ID,
        CR.ACTION_VALUE AS BORC,
        0 AS ALACAK,
        CR.ACTION_VALUE AS ACTION_VALUE
    FROM CARI_ROWS CR
    WHERE CR.TO_CMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#partner_company_id#">
    AND CR.ACTION_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date1#">
    AND CR.ACTION_DATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#date2#">
    AND CR.IS_CANCEL = 0
    
    ORDER BY ACTION_DATE, ACTION_ID
</cfquery>

<!--- Toplamlar --->
<cfset gen_borc_top = devir_borc>
<cfset gen_ala_top = devir_alacak>
<cfset gen_bak_top = devir_bakiye>

<cfoutput query="CARI_ROWS_ALL">
    <cfset gen_borc_top = gen_borc_top + borc>
    <cfset gen_ala_top = gen_ala_top + alacak>
    <cfset gen_bak_top = gen_bak_top + borc - alacak>
</cfoutput>

<!--- Excel dosyası oluştur --->
<cfset filename = "Cari_Ekstre_#dateformat(date1,'yyyymmdd')#_#dateformat(date2,'yyyymmdd')#.xls">
<cfset spreadsheetData = SpreadsheetNew("Cari Ekstre", true)>

<!--- Başlık satırları --->
<cfset rowNum = 1>
<cfset SpreadsheetSetCellValue(spreadsheetData, "CARİ EKSTRE", rowNum, 1, "String")>
<cfset rowNum = rowNum + 1>
<cfif len(company_name)>
    <cfset SpreadsheetSetCellValue(spreadsheetData, company_name, rowNum, 1, "String")>
    <cfset rowNum = rowNum + 1>
</cfif>
<cfset SpreadsheetSetCellValue(spreadsheetData, "Hesap Ekstre Raporu", rowNum, 1, "String")>
<cfset rowNum = rowNum + 1>
<cfset rowNum = rowNum + 1>
<cfset SpreadsheetSetCellValue(spreadsheetData, "Tarih Aralığı: #dateformat(date1,'dd.mm.yyyy')# - #dateformat(date2,'dd.mm.yyyy')#", rowNum, 1, "String")>
<cfset rowNum = rowNum + 1>
<cfset SpreadsheetSetCellValue(spreadsheetData, "Para Birimi: #default_money#", rowNum, 1, "String")>
<cfset rowNum = rowNum + 1>

<!--- Devir Bakiyesi --->
<cfif devir_borc neq 0 or devir_alacak neq 0>
    <cfset SpreadsheetSetCellValue(spreadsheetData, "Devir Bakiyesi", rowNum, 1, "String")>
    <cfset rowNum = rowNum + 1>
    <cfset SpreadsheetSetCellValue(spreadsheetData, "Borç", rowNum, 1, "String")>
    <cfset SpreadsheetSetCellValue(spreadsheetData, "#numberformat(devir_borc, '999,999,999.99')# #default_money#", rowNum, 2, "String")>
    <cfset rowNum = rowNum + 1>
    <cfset SpreadsheetSetCellValue(spreadsheetData, "Alacak", rowNum, 1, "String")>
    <cfset SpreadsheetSetCellValue(spreadsheetData, "#numberformat(devir_alacak, '999,999,999.99')# #default_money#", rowNum, 2, "String")>
    <cfset rowNum = rowNum + 1>
    <cfset SpreadsheetSetCellValue(spreadsheetData, "Bakiye", rowNum, 1, "String")>
    <cfset bakiye_text = "#numberformat(abs(devir_bakiye), '999,999,999.99')# #default_money#">
    <cfif devir_bakiye gt 0>
        <cfset bakiye_text = bakiye_text & " (Borç)">
    <cfelse>
        <cfset bakiye_text = bakiye_text & " (Alacak)">
    </cfif>
    <cfset SpreadsheetSetCellValue(spreadsheetData, bakiye_text, rowNum, 2, "String")>
    <cfset rowNum = rowNum + 1>
</cfif>

<!--- Başlık formatı (PDF ile uyumlu gri tonlamalı) --->
<cfset headerFormat = StructNew()>
<cfset headerFormat.bold = true>
<cfset headerFormat.fgcolor = "grey_25_percent">
<cfset headerFormat.color = "black">
<cfset headerFormat.fontsize = 10>
<cfset headerFormat.alignment = "left">

<!--- Tablo başlıkları --->
<cfset headerRowNum = rowNum>
<cfset SpreadsheetSetCellValue(spreadsheetData, "No", rowNum, 1, "String")>
<cfset SpreadsheetSetCellValue(spreadsheetData, "Tarih", rowNum, 2, "String")>
<cfset SpreadsheetSetCellValue(spreadsheetData, "Belge No", rowNum, 3, "String")>
<cfset SpreadsheetSetCellValue(spreadsheetData, "İşlem", rowNum, 4, "String")>
<cfset SpreadsheetSetCellValue(spreadsheetData, "Açıklama", rowNum, 5, "String")>
<cfset SpreadsheetSetCellValue(spreadsheetData, "Borç", rowNum, 6, "String")>
<cfset SpreadsheetSetCellValue(spreadsheetData, "Alacak", rowNum, 7, "String")>
<cfset SpreadsheetSetCellValue(spreadsheetData, "Bakiye", rowNum, 8, "String")>
<cfset SpreadsheetSetCellValue(spreadsheetData, "B/A", rowNum, 9, "String")>
<!--- Başlık satırını formatla --->
<cfset SpreadsheetFormatRow(spreadsheetData, headerFormat, headerRowNum)>
<cfset rowNum = rowNum + 1>

<!--- Tablo satırları --->
<cfset bakiye = devir_bakiye>
<cfloop query="CARI_ROWS_ALL">
    <cfset bakiye = bakiye + borc - alacak>
    <cfset borc_str = "">
    <cfset alacak_str = "">
    <cfif borc gt 0>
        <cfif len(action_currency_id) and action_currency_id neq ''>
            <cfset borc_str = "#numberformat(borc, '999,999,999.99')# #HTMLEditFormat(action_currency_id)#">
        <cfelse>
            <cfset borc_str = "#numberformat(borc, '999,999,999.99')# #default_money#">
        </cfif>
    </cfif>
    <cfif alacak gt 0>
        <cfif len(action_currency_id) and action_currency_id neq ''>
            <cfset alacak_str = "#numberformat(alacak, '999,999,999.99')# #HTMLEditFormat(action_currency_id)#">
        <cfelse>
            <cfset alacak_str = "#numberformat(alacak, '999,999,999.99')# #default_money#">
        </cfif>
    </cfif>
    <cfset bakiye_indicator = "">
    <cfif bakiye gt 0>
        <cfset bakiye_indicator = "B">
    <cfelse>
        <cfset bakiye_indicator = "A">
    </cfif>
    <cfset SpreadsheetSetCellValue(spreadsheetData, currentrow, rowNum, 1, "Numeric")>
    <cfset SpreadsheetSetCellValue(spreadsheetData, dateformat(action_date, 'dd.mm.yyyy'), rowNum, 2, "String")>
    <cfset SpreadsheetSetCellValue(spreadsheetData, HTMLEditFormat(paper_no), rowNum, 3, "String")>
    <cfset SpreadsheetSetCellValue(spreadsheetData, HTMLEditFormat(action_name), rowNum, 4, "String")>
    <cfset SpreadsheetSetCellValue(spreadsheetData, HTMLEditFormat(action_detail), rowNum, 5, "String")>
    <cfset SpreadsheetSetCellValue(spreadsheetData, borc_str, rowNum, 6, "String")>
    <cfset SpreadsheetSetCellValue(spreadsheetData, alacak_str, rowNum, 7, "String")>
    <cfset SpreadsheetSetCellValue(spreadsheetData, "#numberformat(abs(bakiye), '999,999,999.99')# #default_money#", rowNum, 8, "String")>
    <cfset SpreadsheetSetCellValue(spreadsheetData, bakiye_indicator, rowNum, 9, "String")>
    <cfset rowNum = rowNum + 1>
</cfloop>

<!--- Genel Toplam formatı (PDF ile uyumlu gri tonlamalı) --->
<cfset totalFormat = StructNew()>
<cfset totalFormat.bold = true>
<cfset totalFormat.fgcolor = "grey_25_percent">
<cfset totalFormat.color = "black">
<cfset totalFormat.fontsize = 10>

<!--- Genel Toplam --->
<cfset rowNum = rowNum + 1>
<cfset totalRowNum = rowNum>
<cfset genel_toplam_indicator = "">
<cfif gen_bak_top gt 0>
    <cfset genel_toplam_indicator = "B">
<cfelse>
    <cfset genel_toplam_indicator = "A">
</cfif>
<cfset SpreadsheetSetCellValue(spreadsheetData, "GENEL TOPLAM", rowNum, 1, "String")>
<cfset SpreadsheetSetCellValue(spreadsheetData, "#numberformat(gen_borc_top, '999,999,999.99')# #default_money#", rowNum, 6, "String")>
<cfset SpreadsheetSetCellValue(spreadsheetData, "#numberformat(gen_ala_top, '999,999,999.99')# #default_money#", rowNum, 7, "String")>
<cfset SpreadsheetSetCellValue(spreadsheetData, "#numberformat(abs(gen_bak_top), '999,999,999.99')# #default_money#", rowNum, 8, "String")>
<cfset SpreadsheetSetCellValue(spreadsheetData, genel_toplam_indicator, rowNum, 9, "String")>
<!--- Genel Toplam satırını formatla --->
<cfset SpreadsheetFormatRow(spreadsheetData, totalFormat, totalRowNum)>

<!--- Excel dosyasını indir --->
<cfset tempFile = GetTempDirectory() & CreateUUID() & ".xls">
<cfspreadsheet action="write" filename="#tempFile#" name="spreadsheetData" sheetname="Cari Ekstre" overwrite="true">
<cfheader name="Content-Disposition" value="attachment;filename=#filename#">
<cfcontent type="application/vnd.ms-excel" file="#tempFile#" deletefile="true" reset="true">

