<cfparam name="attributes._miktar" default="1">
<cfset iid = attributes.virtual_offer_row_id>
<cfset toplam = 0>
<cfset ozel_bayi_toplam = 0>
<cfset maliyet_toplam = 0>
<cfquery name="get_money" datasource="#dsn#">
	SELECT MONEY, RATE2 FROM SETUP_MONEY WHERE PERIOD_ID = #session.ep.period_id# AND (MONEY_STATUS = 1)
</cfquery> 
<cfoutput query="get_money">
	<cfset 'RATE2_#MONEY#' = RATE2>
</cfoutput>
<cfquery name="get_product" datasource="#dsn3#">
	SELECT  
    	EZGI_ID,      
    	VIRTUAL_OFFER_ROW_ID, 
        PRODUCT_TYPE, 
        PRODUCT_ID, 
        STOCK_ID, 
        STOCK_CODE,
       	BOY, 
      	EN, 
       	DERINLIK, 
        PRODUCT_CODE_2, 
        PRODUCT_NAME,
        ISNULL((SELECT IS_PROTOTYPE FROM STOCKS WHERE STOCK_ID = EZGI_VIRTUAL_OFFER_ROW.STOCK_ID),0) AS IS_PROTOTIP,
        ISNULL((SELECT MAIN_PROTOTIP_TYPE FROM EZGI_DESIGN_MAIN_ROW WHERE DESIGN_MAIN_RELATED_ID = EZGI_VIRTUAL_OFFER_ROW.STOCK_ID AND MAIN_PROTOTIP_ID IS NULL),0) AS MAIN_PROTOTIP_TYPE
	FROM            
   		EZGI_VIRTUAL_OFFER_ROW
	WHERE        
    	VIRTUAL_OFFER_ROW_ID IN (#attributes.virtual_offer_row_id#)
</cfquery> 
<cfset product_code_list = ''>
<cfset satirlar = queryNew("STOCK_ID,PRODUCT_CODE,PRODUCT_NAME,purchase_price,purchase_price_money,cost_price,cost_price_money,amount,MAIN_UNIT,PRIVATE_PRICE_MONEY,PRIVATE_PRICE,PRIVATE_PRICE_TYPE,PIECE_TYPE", "integer,VarChar,VarChar,Decimal,VarChar,Decimal,VarChar,Decimal,VarChar,VarChar,Decimal,integer,integer") />
<cfloop query="get_product">
    <cfquery name="get_row" datasource="#dsn3#">
        <cfif get_product.IS_PROTOTIP>
            <cfif get_product.MAIN_PROTOTIP_TYPE eq 1> <!---Kapı İse--->
                SELECT 
                    1 AS TYPE,
                    STOCK_ID,
                    PRODUCT_CODE,
                    PRODUCT_NAME,
                    ISNULL(PURCHASE_PRICE,0) PURCHASE_PRICE,
                    ISNULL(PURCHASE_PRICE_MONEY,'#session.ep.money#') AS PURCHASE_PRICE_MONEY,
                    COST_PRICE,
                    COST_PRICE_MONEY,
                    MAIN_UNIT,
                    LAST_AMOUNT AMOUNT,
                 	PRIVATE_PRICE_TYPE, 
                    ISNULL(PRIVATE_PRICE_MONEY,'#session.ep.money#') as PRIVATE_PRICE_MONEY, 
                  	ISNULL(PRIVATE_PRICE,0) PRIVATE_PRICE,
                    PIECE_TYPE
                FROM 
                    EZGI_VIRTUAL_OFFER_ROW_DETAIL 
                WHERE 
                    EZGI_ID = #get_product.EZGI_ID#
               	UNION ALL
              	SELECT 
                    1 AS TYPE,
                    STOCK_ID,
                    PRODUCT_CODE,
                    PRODUCT_NAME,
                    ISNULL(PURCHASE_PRICE,0) PURCHASE_PRICE,
                    ISNULL(PURCHASE_PRICE_MONEY,'#session.ep.money#') AS PURCHASE_PRICE_MONEY,
                    COST_PRICE,
                    COST_PRICE_MONEY,
                    MAIN_UNIT,
                    LAST_AMOUNT AMOUNT,
                 	PRIVATE_PRICE_TYPE, 
                    ISNULL(PRIVATE_PRICE_MONEY,'#session.ep.money#') as PRIVATE_PRICE_MONEY, 
                  	ISNULL(PRIVATE_PRICE,0) PRIVATE_PRICE,
                    PIECE_TYPE
                FROM 
                    EZGI_VIRTUAL_OFFER_ROW_DETAIL_TEMP
                WHERE 
                    EZGI_ID = #get_product.EZGI_ID#
            <cfelse>
                SELECT 
                    2 AS TYPE,
                    STOCK_ID,
                    PRODUCT_CODE,
                    PRODUCT_NAME,
                    ISNULL(PURCHASE_PRICE,0) PURCHASE_PRICE,
                    ISNULL(PURCHASE_PRICE_MONEY,'#session.ep.money#') AS PURCHASE_PRICE_MONEY,
                    COST_PRICE,
                    COST_PRICE_MONEY,
                    MAIN_UNIT,
                    AMOUNT,
                    PRIVATE_PRICE_TYPE, 
                    ISNULL(PRIVATE_PRICE_MONEY,'#session.ep.money#') as PRIVATE_PRICE_MONEY, 
                  	ISNULL(PRIVATE_PRICE,0) PRIVATE_PRICE,
                    PIECE_TYPE
                FROM 
                    EZGI_VIRTUAL_OFFER_ROW_DETAIL 
                WHERE 
                    EZGI_ID = #get_product.EZGI_ID#
               	UNION ALL
             	SELECT 
                    2 AS TYPE,
                    STOCK_ID,
                    PRODUCT_CODE,
                    PRODUCT_NAME,
                    ISNULL(PURCHASE_PRICE,0) PURCHASE_PRICE,
                    ISNULL(PURCHASE_PRICE_MONEY,'#session.ep.money#') AS PURCHASE_PRICE_MONEY,
                    COST_PRICE,
                    COST_PRICE_MONEY,
                    MAIN_UNIT,
                    AMOUNT,
                    PRIVATE_PRICE_TYPE, 
                    ISNULL(PRIVATE_PRICE_MONEY,'#session.ep.money#') as PRIVATE_PRICE_MONEY, 
                  	ISNULL(PRIVATE_PRICE,0) PRIVATE_PRICE,
                    PIECE_TYPE
                FROM 
                    EZGI_VIRTUAL_OFFER_ROW_DETAIL_TEMP
                WHERE 
                    EZGI_ID = #get_product.EZGI_ID#
            </cfif>
        <cfelse>
            SELECT 
                3 AS TYPE,
                STOCK_ID,
                STOCK_CODE PRODUCT_CODE,
                PRODUCT_NAME,
                ISNULL(PURCHASE_PRICE,0) PURCHASE_PRICE,
             	ISNULL(PURCHASE_PRICE_MONEY,'#session.ep.money#') AS PURCHASE_PRICE_MONEY,
                COST_PRICE,
                COST_PRICE_MONEY,
                UNIT MAIN_UNIT,
                QUANTITY AS AMOUNT,
                0 AS PRIVATE_PRICE_TYPE, 
             	'#session.ep.money#' AS PRIVATE_PRICE_MONEY, 
             	0 AS PRIVATE_PRICE,
                0 as PIECE_TYPE,
            FROM 
                EZGI_VIRTUAL_OFFER_ROW
            WHERE 
                EZGI_ID = #get_product.EZGI_ID#	
         	UNION ALL
            SELECT 
                3 AS TYPE,
                STOCK_ID,
                STOCK_CODE PRODUCT_CODE,
                PRODUCT_NAME,
                ISNULL(PURCHASE_PRICE,0) PURCHASE_PRICE,
             	ISNULL(PURCHASE_PRICE_MONEY,'#session.ep.money#') AS PURCHASE_PRICE_MONEY,
                COST_PRICE,
                COST_PRICE_MONEY,
                UNIT MAIN_UNIT,
                QUANTITY AS AMOUNT,
                0 AS PRIVATE_PRICE_TYPE, 
             	'#session.ep.money#' AS PRIVATE_PRICE_MONEY, 
             	0 AS PRIVATE_PRICE,
                0 as PIECE_TYPE,
            FROM 
                EZGI_VIRTUAL_OFFER_ROW_TEMP
            WHERE 
                EZGI_ID = #get_product.EZGI_ID#
        </cfif>
    </cfquery>
    <cfloop query="get_row">
    	<cfif len(PRODUCT_CODE)>
         	<cfset temp = QueryAddRow(satirlar)>
            <cfset Temp = QuerySetCell(satirlar, "STOCK_ID", STOCK_ID)>
         	<cfset Temp = QuerySetCell(satirlar, "PRODUCT_CODE", PRODUCT_CODE)>
           	<cfset Temp = QuerySetCell(satirlar, "PRODUCT_NAME", PRODUCT_NAME)>
            <cfset Temp = QuerySetCell(satirlar, "PRIVATE_PRICE_TYPE", PRIVATE_PRICE_TYPE)>
            <cfset Temp = QuerySetCell(satirlar, "PRIVATE_PRICE_MONEY", PRIVATE_PRICE_MONEY)>
            <cfset Temp = QuerySetCell(satirlar, "PRIVATE_PRICE", PRIVATE_PRICE)>
            <cfset Temp = QuerySetCell(satirlar, "PURCHASE_PRICE", PURCHASE_PRICE)>
         	<cfset Temp = QuerySetCell(satirlar, "COST_PRICE", COST_PRICE)>
            <cfif len(PURCHASE_PRICE_MONEY)>
            	<cfset Temp = QuerySetCell(satirlar, "PURCHASE_PRICE_MONEY", PURCHASE_PRICE_MONEY)>
            <cfelse>
            	<cfset Temp = QuerySetCell(satirlar, "PURCHASE_PRICE_MONEY", '#session.ep.money#')>
            </cfif>
            <cfif len(COST_PRICE_MONEY)>
            	<cfset Temp = QuerySetCell(satirlar, "COST_PRICE_MONEY", COST_PRICE_MONEY)>
            <cfelse>
                <cfset Temp = QuerySetCell(satirlar, "COST_PRICE_MONEY", '#session.ep.money#')>
            </cfif>
            
         	<cfset Temp = QuerySetCell(satirlar, "AMOUNT", AMOUNT)>
            <cfset Temp = QuerySetCell(satirlar, "MAIN_UNIT", MAIN_UNIT)>
            <cfset Temp = QuerySetCell(satirlar, "PIECE_TYPE", PIECE_TYPE)>
        <cfelse>
        	<script type="text/javascript">
				alert("#PRODUCT_NAME# Ürünün Stok Kodu Yoktur.!");
				window.close()
			</script>
        </cfif>
    </cfloop>
</cfloop>
<cfquery name="GET_ROWS" dbtype="query">
	SELECT
    	STOCK_ID,
    	PRODUCT_CODE,
      	PRODUCT_NAME,
      	PURCHASE_PRICE,
      	PURCHASE_PRICE_MONEY,
     	COST_PRICE,
      	COST_PRICE_MONEY,
      	MAIN_UNIT,
        PRIVATE_PRICE_MONEY,
        PRIVATE_PRICE,
        PRIVATE_PRICE_TYPE,
    	SUM(AMOUNT) AS AMOUNT,
        PIECE_TYPE
  	FROM
    	satirlar
  	GROUP BY
    	STOCK_ID,
    	PRODUCT_CODE,
      	PRODUCT_NAME,
      	PURCHASE_PRICE,
      	PURCHASE_PRICE_MONEY,
     	COST_PRICE,
      	COST_PRICE_MONEY,
      	MAIN_UNIT,
        PRIVATE_PRICE_MONEY,
        PRIVATE_PRICE,
        PRIVATE_PRICE_TYPE,
        PIECE_TYPE
    ORDER BY
    	PIECE_TYPE,
    	PRODUCT_CODE
</cfquery>
<cfsavecontent variable="message"><cf_get_lang dictionary_id='37330.Malzeme Listesi'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
   <div class="col col-12">
		<cf_box title="#message#" >
        	<cf_grid_list>
            	<thead>
					<tr>
                    	<th rowspan="2" width="20" style="text-align:center"><cf_get_lang_main no='75.No'></th>
                        <th rowspan="2" width="120" style="text-align:center"><cf_get_lang_main no='106.Stok Kodu'></th>
                        <th rowspan="2" style="text-align:center"><cf_get_lang_main no='809.Ürün Adı'></th>
                        <th rowspan="2" width="100" style="text-align:center"><cf_get_lang_main no='223.Miktar'></th>
                        <th colspan="5" height="10px" width="40" style="text-align:center"><cf_get_lang dictionary_id='1236.Bayi Alış Fiyatı'></th>
                        <cfif Listfind(session.ep.POWER_USER_LEVEL_ID,56)>
                            <th colspan="4" width="40" style="text-align:center"><cf_get_lang dictionary_id='37817.Maliyet Fiyatı'></th>
                        </cfif>
                   	</tr>
                    <tr>
                        <th width="70" height="10px" style="text-align:center"><cf_get_lang_main no='672.Fiyat'></th>
                        <th width="70" style="text-align:center"><cf_get_lang dictionary_id='34720.Özel Fiyat'></th>
                        <th width="40" style="text-align:center"><cf_get_lang_main no='265.Döviz'></th>
                        <th width="70" style="text-align:center"><cf_get_lang_main no='261.Tutar'></th>
                        <th width="40" style="text-align:center"><cf_get_lang_main no='265.Döviz'></th>
                        <cfif Listfind(session.ep.POWER_USER_LEVEL_ID,56)>
                            <th width="70" style="text-align:center"><cf_get_lang_main no='672.Fiyat'></th>
                            <th width="40" style="text-align:center"><cf_get_lang_main no='265.Döviz'></th>
                            <th width="70" style="text-align:center"><cf_get_lang_main no='261.Tutar'></th>
                            <th width="40" style="text-align:center"><cf_get_lang_main no='265.Döviz'></th>
                        </cfif>
                     </tr>
               	</thead>
                <tbody>
                	<cfif get_rows.recordcount> 
        				<cfoutput query="get_rows">
                          	<tr> 
                                <td height="15px" style="text-align:center">#currentrow#&nbsp;</td>
                                <td >&nbsp;#get_rows.PRODUCT_CODE#</td>
                                <td class="thc">&nbsp;#get_rows.PRODUCT_NAME#</td>
                                <td  style="text-align:right">#TlFormat(AMOUNT,2)# &nbsp;#Left(get_rows.MAIN_UNIT,2)#</td>
                                <td  style="text-align:right">#TlFormat(get_rows.PURCHASE_PRICE,2)#</td>
                                <td  style="text-align:right; color:red">
                                	<cfset ozel_fiyat = 0>
                                	<cfif get_product.MAIN_PROTOTIP_TYPE eq 1 and PIECE_TYPE eq 0> <!---Kapı İse--->
                                    	<cfquery name="get_standart" datasource="#dsn3#">
                                        	SELECT     
                                            	ISNULL(EMR.IS_STANDART,0) IS_STANDART
											FROM        
                                            	EZGI_DESIGN_MAIN_ROW AS EDM INNER JOIN
                  								EZGI_VIRTUAL_OFFER_ROW_MEASURE AS EM ON EDM.MEASURE_ID = EM.MEASURE_ID INNER JOIN
                  								EZGI_VIRTUAL_OFFER_ROW_MEASURE_ROW AS EMR ON EM.MEASURE_ID = EMR.MEASURE_ID
											WHERE     
                                            	EDM.DESIGN_MAIN_RELATED_ID = #get_rows.STOCK_ID# AND 
                                                EMR.MEASURE_TYPE = 1 AND 
                                                EMR.MEASURE = #get_product.BOY#
                                        </cfquery>
                                        <cfif get_standart.IS_STANDART eq 0>
											<cfif get_rows.PRIVATE_PRICE_TYPE eq 1><!---Özel Fiyat Tipi Sabit mi?--->
                                                <cfif isdefined('RATE2_#get_rows.PURCHASE_PRICE_MONEY#')>
                                                    <cfset ozel_bayi_toplam = ozel_bayi_toplam+((get_rows.PRIVATE_PRICE*Evaluate('RATE2_#get_rows.PURCHASE_PRICE_MONEY#'))+(get_rows.PURCHASE_PRICE*get_rows.amount*Evaluate('RATE2_#get_rows.PURCHASE_PRICE_MONEY#')))>
                                                    <cfset ozel_fiyat = ((get_rows.PRIVATE_PRICE*Evaluate('RATE2_#get_rows.PURCHASE_PRICE_MONEY#'))+(get_rows.PURCHASE_PRICE*get_rows.amount*Evaluate('RATE2_#get_rows.PURCHASE_PRICE_MONEY#')))>
                                                    #TlFormat((get_rows.PRIVATE_PRICE*Evaluate('RATE2_#get_rows.PURCHASE_PRICE_MONEY#'))+(get_rows.PURCHASE_PRICE*get_rows.amount*Evaluate('RATE2_#get_rows.PURCHASE_PRICE_MONEY#')),2)#
                                                </cfif>
                                            <cfelseif get_rows.PRIVATE_PRICE_TYPE eq 2><!---Özel Fiyat Tipi Yüzde mi?--->
                                                <cfset ozel_bayi_toplam = ozel_bayi_toplam+((get_rows.PRIVATE_PRICE/100)*(get_rows.PURCHASE_PRICE*get_rows.amount*Evaluate('RATE2_#get_rows.PURCHASE_PRICE_MONEY#')))>
                                                <cfset ozel_fiyat = ((get_rows.PRIVATE_PRICE/100)*(get_rows.PURCHASE_PRICE*get_rows.amount*Evaluate('RATE2_#get_rows.PURCHASE_PRICE_MONEY#')))>
                                                #TlFormat((get_rows.PRIVATE_PRICE/100)*(get_rows.PURCHASE_PRICE*get_rows.amount*Evaluate('RATE2_#get_rows.PURCHASE_PRICE_MONEY#')),2)#
                                            </cfif>
                                        </cfif>
                                    </cfif>
                                </td>
                                <td >&nbsp;#get_rows.PURCHASE_PRICE_MONEY#</td>
                                <td  style="text-align:right">
                                    <cfif isdefined('RATE2_#get_rows.PURCHASE_PRICE_MONEY#')>
                                        #TlFormat(AMOUNT*((PURCHASE_PRICE*Evaluate('RATE2_#get_rows.PURCHASE_PRICE_MONEY#'))+ozel_fiyat),2)#
                                        <cfset toplam = toplam+(AMOUNT*((PURCHASE_PRICE*Evaluate('RATE2_#get_rows.PURCHASE_PRICE_MONEY#'))+ozel_fiyat))>
                                    <cfelse>
                                        #TlFormat(0,2)#
                                    </cfif>
                                </td>
                                
                                <td >&nbsp;#session.ep.money#</td>
                                <cfif Listfind(session.ep.POWER_USER_LEVEL_ID,56)>
                                    <td  style="text-align:right">#TlFormat(get_rows.COST_PRICE,2)#</td>
                                    <td >&nbsp;#get_rows.COST_PRICE_MONEY#</td>
                                    <td  style="text-align:right">
                                        <cfif isdefined('RATE2_#get_rows.COST_PRICE_MONEY#')>
                                            #TlFormat(COST_PRICE*AMOUNT*Evaluate('RATE2_#get_rows.COST_PRICE_MONEY#'),2)#
                                            <cfset maliyet_toplam = maliyet_toplam+(COST_PRICE*AMOUNT*Evaluate('RATE2_#get_rows.COST_PRICE_MONEY#'))>
                                        <cfelse>
                                            #TlFormat(0,2)#
                                        </cfif>
                                    </td>
                                    <td >&nbsp;#session.ep.money#</td>
                                </cfif>
                        	</tr>
            			</cfoutput>
                   	<cfelse>
                        <tr>
                            <td  colspan="13">Listelenecek Kayıt Bulunamadı.</td>
                        </tr>
                    </cfif>
              	</tbody>
                <tfoot>
                	<tr>
                        <td colspan="5" align="left" valign="middle" height="10">&nbsp;&nbsp;
                            <strong>Genel Toplam</strong>   
                        </td>
                        <td valign="middle" style="text-align:right; color:red"><strong><cfoutput>#TlFormat(ozel_bayi_toplam,2)#</cfoutput></strong></td>
                        <td>&nbsp;</td> 
                        <td valign="middle" style="text-align:right"><strong><cfoutput>#TlFormat(TOPLAM,2)#</cfoutput></strong></td>
                        <td align="left" valign="middle" ><strong><cfoutput>&nbsp;#session.ep.money#</cfoutput></strong></td>
                        <cfif Listfind(session.ep.POWER_USER_LEVEL_ID,56)>
                            <td colspan="2"></td>
                            <td valign="middle" style="text-align:right"><strong><cfoutput>#TlFormat(MALIYET_TOPLAM,2)#</cfoutput></strong></td>
                            <td align="left" valign="middle" ><strong><cfoutput>&nbsp;#session.ep.money#</cfoutput></strong></td>
                        </cfif>
                    </tr>
                </tfoot>
         	</cf_grid_list>
     	</cf_box>
  	</div>
</div>
