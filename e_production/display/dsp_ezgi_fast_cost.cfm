<!---
    File: dsp_ezgi_fast_cost.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.keyword" default=''>
<cfparam name="attributes.is_form_submitted" default="1">
<cfquery name="GET_MONEY" datasource="#DSN#">
	SELECT     
    	MONEY, 
        RATE2
	FROM         
    	SETUP_MONEY
  	where
    	PERIOD_ID = #session.ep.period_id#
</cfquery>
<cfoutput query="GET_MONEY">
	<cfset 'RATE2_#MONEY#' = RATE2>
</cfoutput>
<cfquery name="get_stock_info" datasource="#dsn3#">
	SELECT IS_KARMA FROM STOCKS WHERE STOCK_ID =  #attributes.sid#
</cfquery>
<cfquery name="get_costs" datasource="#dsn3#">
	<cfif get_stock_info.IS_KARMA>
        SELECT       
        	<cfif isdefined('attributes.price_type') and attributes.price_type eq 2>
                SUM(KP.PRODUCT_AMOUNT*E.MIKTAR)* STANDART_PRICE AS TOTAL_PRICE,
                STANDART_PRICE  AS PRICE,
                STANDART_MONEY AS MONEY,
            <cfelse>  
                SUM(KP.PRODUCT_AMOUNT*E.MIKTAR) * CASE WHEN LAST_INVOICE_PRICE <= 0 THEN STANDART_PRICE ELSE LAST_INVOICE_PRICE END AS TOTAL_PRICE, 
                CASE WHEN LAST_INVOICE_PRICE <= 0 THEN STANDART_PRICE ELSE LAST_INVOICE_PRICE END AS PRICE, 
                CASE WHEN LAST_INVOICE_PRICE <= 0 THEN STANDART_MONEY ELSE LAST_INVOICE_MONEY END AS MONEY, 
            </cfif>
            SUM(KP.PRODUCT_AMOUNT*E.MIKTAR) AS MIKTAR,
            STOCKS.STOCK_ID, 
            STOCKS.PRODUCT_ID, 
            STOCKS.STOCK_CODE,
            STOCKS.PRODUCT_NAME,
            (
                SELECT        
                    MAIN_UNIT
                FROM     
                    PRODUCT_UNIT
                WHERE        
                    PRODUCT_UNIT_ID = STOCKS.PRODUCT_UNIT_ID
            ) AS MAIN_UNIT
        FROM            
            EZGI_PRODUCT_TREE AS E INNER JOIN
            STOCKS AS S1 ON E.ANA_URUN = S1.STOCK_CODE INNER JOIN
            STOCKS ON E.STOKKODU = STOCKS.STOCK_CODE INNER JOIN
            #dsn1_alias#.KARMA_PRODUCTS AS KP ON S1.STOCK_ID = KP.STOCK_ID
        WHERE        
            E.KIRILIM = 1 AND 
            KP.KARMA_PRODUCT_ID =  #attributes.pid# 
        GROUP BY 
            E.LAST_INVOICE_MONEY, 
            E.STANDART_MONEY, 
            E.STANDART_PRICE, 
            E.LAST_INVOICE_PRICE, 
            STOCKS.STOCK_ID, 
            STOCKS.PRODUCT_ID, 
            STOCKS.STOCK_CODE,
            STOCKS.PRODUCT_NAME, 
            STOCKS.PRODUCT_UNIT_ID
        ORDER BY 
            STOCKS.STOCK_CODE
  	<cfelse>
        SELECT  
            <cfif isdefined('attributes.price_type') and attributes.price_type eq 2>
                SUM(E.MIKTAR)* STANDART_PRICE AS TOTAL_PRICE,
                STANDART_PRICE  AS PRICE,
                STANDART_MONEY AS MONEY,
            <cfelse>   
                SUM(E.MIKTAR)* CASE WHEN LAST_INVOICE_PRICE <= 0 THEN STANDART_PRICE ELSE LAST_INVOICE_PRICE END AS TOTAL_PRICE, 
                CASE WHEN LAST_INVOICE_PRICE <= 0 THEN STANDART_PRICE ELSE LAST_INVOICE_PRICE END AS PRICE,
                CASE WHEN LAST_INVOICE_PRICE <= 0 THEN STANDART_MONEY ELSE LAST_INVOICE_MONEY END AS MONEY, 
            </cfif>
            SUM(E.MIKTAR) AS MIKTAR, 
            STOCKS.STOCK_ID, 
            STOCKS.PRODUCT_ID, 
            STOCKS.STOCK_CODE, 
            STOCKS.PRODUCT_NAME,
            (SELECT MAIN_UNIT FROM PRODUCT_UNIT WHERE PRODUCT_UNIT_ID = STOCKS.PRODUCT_UNIT_ID) MAIN_UNIT
        FROM         
            EZGI_PRODUCT_TREE AS E INNER JOIN
            STOCKS AS S1 ON E.ANA_URUN = S1.STOCK_CODE INNER JOIN
            STOCKS ON E.STOKKODU = STOCKS.STOCK_CODE
        WHERE     
            E.KIRILIM = 1 AND 
         	S1.STOCK_ID = #attributes.sid#
        GROUP BY
            E.LAST_INVOICE_MONEY,
            E.STANDART_MONEY,
            E.STANDART_PRICE,
            E.LAST_INVOICE_PRICE,
            STOCKS.STOCK_ID, 
            STOCKS.PRODUCT_ID, 
            STOCKS.STOCK_CODE, 
            STOCKS.PRODUCT_NAME,
            STOCKS.PRODUCT_UNIT_ID
        ORDER BY
            STOCKS.STOCK_CODE
 	</cfif>
</cfquery>
<cfset c_toplam= 0>
<cfform action="#request.self#?fuseaction=prod.popup_dsp_ezgi_fast_cost&sid=#attributes.sid#" method="post">
    <cfsavecontent variable="urun_agaci"><cf_get_lang dictionary_id='140.Ürün Ağacı'></cfsavecontent>
	<cf_medium_list_search title="#urun_agaci#">
		<cf_medium_list_search_area>
			<table>
				<tr>
					
				</tr>
			</table>
		</cf_medium_list_search_area>
	</cf_medium_list_search>
</cfform>
<table width="100%">
	<tr>
    	<td>
            <cf_box title="" style="width:99%; margin-top:10px;">
                <cf_ajax_list>
                    <thead>
                        <tr>
                            <th width="35"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th width="120"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <th width="90"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <th width="50"><cf_get_lang dictionary_id='57636.Birim'></th>
                            <th width="90"><cf_get_lang dictionary_id='57638.Birim Fiyat'></th>
                            <th width="50"><cf_get_lang dictionary_id='57677.Döviz'></th>
                            <th width="90"><cf_get_lang dictionary_id='57673.Tutar'></th>
                            <th width="50"><cf_get_lang dictionary_id='57677.Döviz'></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif get_costs.recordcount>
							<cfoutput query="get_costs">
                                <tr> 
                                    <td>#currentrow#</td>
                                    <td>#stock_code#</td>
                                    <td>#Product_name#</td>
                                    <td style="text-align:right;">#tlformat(miktar)#</td>
                                    <td>&nbsp;#MAIN_UNIT#</td>
                                    <td style="text-align:right;">#tlformat(price)#</td>
                                    <td>&nbsp;#Money#</td>
                                    <td style="text-align:right;">#tlformat(price*miktar)#</td>
                                    <td>&nbsp;#Money#</td>
                                    <cfset c_toplam= c_toplam+(price*miktar*Evaluate('RATE2_#MONEY#'))>
                                </tr>
                            </cfoutput>
                            <tfoot>
                                <tr>
                                    <td colspan="7" align="left" ><strong><cf_get_lang dictionary_id='57492.Toplam'></strong></td>
                                    <td style="text-align:right"><strong><cfoutput>#tlformat(c_toplam)#</cfoutput></strong></td>
                                    <td>&nbsp;<strong><cfoutput>#session.ep.Money#</cfoutput></strong></td>
                                </tr>
                            </tfoot>
                        <cfelse>
                            <tr> 
                                <td colspan="14" height="20"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
                            </tr>
                        </cfif>
                    </tbody>
                </cf_ajax_list>
            </cf_box>
        </td>
    </tr>
</table>