<!---
    File: export_cari_ekstre_pdf.cfm
    Folder: AddOns/ezgi/e_partner/query
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Cari Ekstre PDF Export
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

<!--- PDF oluştur --->
<cfset filename = "Cari_Ekstre_#dateformat(date1,'yyyymmdd')#_#dateformat(date2,'yyyymmdd')#.pdf">
<cfheader name="Content-Disposition" value="attachment;filename=#filename#">
<cfcontent type="application/pdf" reset="true">

<cfdocument format="pdf" pagetype="a4" orientation="portrait" marginleft="0.5" marginright="0.5" margintop="0.8" marginbottom="0.8">
    <style type="text/css">
        body { 
            font-family: Arial, Helvetica, sans-serif; 
            font-size: 7pt; 
            color: ##000000;
            line-height: 1.3;
        }
        .header {
            border-bottom: 1px solid ##000000;
            padding-bottom: 6px;
            margin-bottom: 8px;
        }
        .header-title {
            font-size: 14pt;
            font-weight: bold;
            color: ##000000;
            text-align: center;
            margin-bottom: 3px;
            letter-spacing: 0.3px;
        }
        .header-company {
            font-size: 9pt;
            color: ##000000;
            text-align: center;
            margin-bottom: 3px;
            font-weight: 600;
        }
        .header-subtitle {
            font-size: 8pt;
            color: ##000000;
            text-align: center;
            margin-bottom: 0;
            font-weight: normal;
        }
        .info-section {
            background-color: ##e8e8e8;
            border: 1px solid ##808080;
            padding: 6px;
            margin-bottom: 8px;
        }
        .info-row {
            margin-bottom: 3px;
        }
        .info-label {
            display: inline-block;
            width: 110px;
            font-weight: bold;
            color: ##000000;
            font-size: 7pt;
        }
        .info-value {
            display: inline-block;
            color: ##000000;
            font-size: 7pt;
        }
        .summary-box {
            background-color: ##e0e0e0;
            border: 1px solid ##808080;
            padding: 6px;
            margin-bottom: 8px;
        }
        .summary-title {
            font-size: 8pt;
            font-weight: bold;
            color: ##000000;
            margin-bottom: 5px;
            border-bottom: 1px solid ##000000;
            padding-bottom: 3px;
        }
        .summary-item {
            display: inline-block;
            width: 32%;
            vertical-align: top;
            padding-right: 8px;
        }
        .summary-label {
            font-size: 7pt;
            color: ##000000;
            margin-bottom: 2px;
            font-weight: 600;
        }
        .summary-value {
            font-size: 9pt;
            font-weight: bold;
            color: ##000000;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 6px;
            border: 1px solid ##000000;
        }
        thead {
            background-color: ##e8e8e8;
        }
        th {
            color: ##000000;
            font-weight: bold;
            padding: 5px 3px;
            text-align: left;
            font-size: 7pt;
            border-right: 1px solid ##808080;
            border-bottom: 2px solid ##808080;
            text-transform: uppercase;
            letter-spacing: 0.2px;
        }
        th:last-child {
            border-right: none;
        }
        th.text-right {
            text-align: right;
        }
        th.text-center {
            text-align: center;
        }
        tbody tr {
            border-bottom: 1px solid ##000000;
        }
        tbody tr:nth-child(even) {
            background-color: ##f0f0f0;
        }
        td {
            padding: 4px 3px;
            border-right: 1px solid ##000000;
            border-bottom: 1px solid ##000000;
            font-size: 7pt;
            vertical-align: top;
            color: ##000000;
        }
        td:last-child {
            border-right: none;
        }
        tbody tr:last-child td {
            border-bottom: none;
        }
        .text-right {
            text-align: right;
        }
        .text-center {
            text-align: center;
        }
        tfoot {
            background-color: ##e8e8e8;
        }
        tfoot tr {
            border-top: 2px solid ##808080;
        }
        tfoot td {
            font-weight: bold;
            font-size: 8pt;
            padding: 5px 3px;
            border-right: 1px solid ##808080;
            border-top: 1px solid ##808080;
            background-color: ##e8e8e8;
            color: ##000000;
        }
        tfoot td:last-child {
            border-right: none;
        }
        .footer {
            margin-top: 10px;
            padding-top: 6px;
            border-top: 1px solid ##808080;
            text-align: center;
            font-size: 6pt;
            color: ##000000;
        }
    </style>
    
    <cfoutput>
    <div class="header">
        <div class="header-title">CARİ EKSTRE</div>
        <cfif len(company_name)>
            <div class="header-company">#HTMLEditFormat(company_name)#</div>
        </cfif>
        <div class="header-subtitle">Hesap Ekstre Raporu</div>
    </div>
    
    <div style="background-color: ##e8e8e8; border: 1px solid ##808080; padding: 6px; margin-bottom: 8px;">
        <div style="margin-bottom: 3px;">
            <span style="display: inline-block; width: 110px; font-weight: bold; color: ##000000; font-size: 7pt;">Tarih Aralığı:</span>
            <span style="display: inline-block; color: ##000000; font-size: 7pt;">#dateformat(date1,'dd.mm.yyyy')# - #dateformat(date2,'dd.mm.yyyy')#</span>
        </div>
        <div style="margin-bottom: 3px;">
            <span style="display: inline-block; width: 110px; font-weight: bold; color: ##000000; font-size: 7pt;">Para Birimi:</span>
            <span style="display: inline-block; color: ##000000; font-size: 7pt;">#default_money#</span>
        </div>
    </div>
    
    <cfif devir_borc neq 0 or devir_alacak neq 0>
        <div class="summary-box">
            <div class="summary-title">📊 Devir Bakiyesi</div>
            <div class="summary-grid">
                <div class="summary-item">
                    <div class="summary-label">Borç</div>
                    <div class="summary-value">#numberformat(devir_borc, '999,999,999.99')# #default_money#</div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Alacak</div>
                    <div class="summary-value">#numberformat(devir_alacak, '999,999,999.99')# #default_money#</div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Bakiye</div>
                    <div class="summary-value">
                        #numberformat(abs(devir_bakiye), '999,999,999.99')# #default_money# 
                        (<cfif devir_bakiye gt 0>Borç<cfelse>Alacak</cfif>)
                    </div>
                </div>
            </div>
        </div>
    </cfif>
    
    <table>
        <thead>
            <tr style="background-color: ##e8e8e8;">
                <th style="width: 20px; background-color: ##e8e8e8; color: ##000000; border-right: 1px solid ##808080; border-bottom: 2px solid ##808080;">No</th>
                <th style="width: 55px; background-color: ##e8e8e8; color: ##000000; border-right: 1px solid ##808080; border-bottom: 2px solid ##808080;">Tarih</th>
                <th style="width: 60px; background-color: ##e8e8e8; color: ##000000; border-right: 1px solid ##808080; border-bottom: 2px solid ##808080;">Belge No</th>
                <th style="width: 100px; background-color: ##e8e8e8; color: ##000000; border-right: 1px solid ##808080; border-bottom: 2px solid ##808080;">İşlem</th>
                <th style="width: 120px; background-color: ##e8e8e8; color: ##000000; border-right: 1px solid ##808080; border-bottom: 2px solid ##808080;">Açıklama</th>
                <th style="width: 75px; background-color: ##e8e8e8; color: ##000000; border-right: 1px solid ##808080; border-bottom: 2px solid ##808080; text-align: right;">Borç</th>
                <th style="width: 75px; background-color: ##e8e8e8; color: ##000000; border-right: 1px solid ##808080; border-bottom: 2px solid ##808080; text-align: right;">Alacak</th>
                <th style="width: 75px; background-color: ##e8e8e8; color: ##000000; border-right: 1px solid ##808080; border-bottom: 2px solid ##808080; text-align: right;">Bakiye</th>
                <th style="width: 25px; background-color: ##e8e8e8; color: ##000000; border-bottom: 2px solid ##808080; text-align: center;">B/A</th>
            </tr>
        </thead>
        <tbody>
            <cfset bakiye = devir_bakiye>
            <cfloop query="CARI_ROWS_ALL">
                <cfset bakiye = bakiye + borc - alacak>
                <tr>
                    <td style="text-align: center; color: ##000000;">#currentrow#</td>
                    <td>#dateformat(action_date, 'dd.mm.yyyy')#</td>
                    <td>#HTMLEditFormat(paper_no)#</td>
                    <td>#HTMLEditFormat(action_name)#</td>
                    <td>#HTMLEditFormat(action_detail)#</td>
                    <td class="text-right">
                        <cfif borc gt 0>
                            #numberformat(borc, '999,999,999.99')# <cfif len(action_currency_id) and action_currency_id neq ''>#HTMLEditFormat(action_currency_id)#<cfelse>#default_money#</cfif>
                        <cfelse>-</cfif>
                    </td>
                    <td class="text-right">
                        <cfif alacak gt 0>
                            #numberformat(alacak, '999,999,999.99')# <cfif len(action_currency_id) and action_currency_id neq ''>#HTMLEditFormat(action_currency_id)#<cfelse>#default_money#</cfif>
                        <cfelse>-</cfif>
                    </td>
                    <td class="text-right">
                        #numberformat(abs(bakiye), '999,999,999.99')# #default_money#
                    </td>
                    <td class="text-center" style="font-weight: bold; color: ##000000;"><cfif bakiye gt 0>B<cfelse>A</cfif></td>
                </tr>
            </cfloop>
        </tbody>
        <tfoot>
            <tr style="background-color: ##e8e8e8; border-top: 2px solid ##808080;">
                <td colspan="5" style="background-color: ##e8e8e8; color: ##000000; font-size: 9pt; font-weight: bold; text-align: right; border-right: 1px solid ##808080; border-top: 1px solid ##808080; padding: 5px 3px;"><strong>GENEL TOPLAM</strong></td>
                <td style="background-color: ##e8e8e8; color: ##000000; font-weight: bold; text-align: right; border-right: 1px solid ##808080; border-top: 1px solid ##808080; padding: 5px 3px;"><strong>#numberformat(gen_borc_top, '999,999,999.99')# #default_money#</strong></td>
                <td style="background-color: ##e8e8e8; color: ##000000; font-weight: bold; text-align: right; border-right: 1px solid ##808080; border-top: 1px solid ##808080; padding: 5px 3px;"><strong>#numberformat(gen_ala_top, '999,999,999.99')# #default_money#</strong></td>
                <td style="background-color: ##e8e8e8; color: ##000000; font-weight: bold; text-align: right; border-right: 1px solid ##808080; border-top: 1px solid ##808080; padding: 5px 3px;">
                    <strong>#numberformat(abs(gen_bak_top), '999,999,999.99')# #default_money#</strong>
                </td>
                <td style="background-color: ##e8e8e8; color: ##000000; font-weight: bold; text-align: center; border-top: 1px solid ##808080; padding: 5px 3px;"><cfif gen_bak_top gt 0>B<cfelse>A</cfif></td>
            </tr>
        </tfoot>
    </table>
    
    <div class="footer">
        <div>Bu rapor elektronik ortamda oluşturulmuştur. #dateformat(now(),'dd.mm.yyyy HH:nn')# tarihinde yazdırılmıştır.</div>
    </div>
    </cfoutput>
</cfdocument>

