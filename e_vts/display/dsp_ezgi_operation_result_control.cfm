<!---
    File: dsp_ezgi_operation_result_control.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/04/2022
    Description:
--->

<!---Kendinden Önceki Operasyon Durum Kontrolü--->
<cfif isdefined('attributes.operation_end_control') and operation_end_control eq 1>
    <cfquery name="get_station_info" datasource="#dsn3#">
        SELECT ISNULL(PREVIOUS_OPERATION_END_CONTROL, 0) AS PREVIOUS_OPERATION_END_CONTROL FROM WORKSTATIONS WHERE STATION_ID = #attributes.station_id_#
    </cfquery>
    <cfif get_station_info.PREVIOUS_OPERATION_END_CONTROL gt 0>
        <cfquery name="get_previous_operation_end_control" datasource="#dsn3#">
            SELECT 
                PO.STAGE, 
                OT.OPERATION_TYPE
            FROM     
                PRODUCTION_OPERATION AS PO WITH (NOLOCK) INNER JOIN
                OPERATION_TYPES AS OT WITH (NOLOCK) ON PO.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID
            WHERE  
                PO.P_ORDER_ID = #attributes.upd_id# AND 
                PO.P_OPERATION_ID < #attributes.operation_id_# AND 
                <cfif get_station_info.PREVIOUS_OPERATION_END_CONTROL eq 1> <!---Kendinden Önceki Operasyonlar İçinde Başlamamış varmı?--->
                    PO.STAGE = 0
                <cfelseif get_station_info.PREVIOUS_OPERATION_END_CONTROL eq 2><!---Kendinden Önceki Operasyonlar İçinde Bitmemiş varmı?--->
                    PO.STAGE IN (0,1)
                </cfif>
            ORDER BY 
                PO.P_OPERATION_ID
        </cfquery>
        
    <cfelse>
        <cfset get_previous_operation_end_control.recordcount = 0>
    </cfif>
</cfif>
<!---Kendinden Önceki Operasyon Durum Kontrolü--->

<cfquery name="get_ezgi_result_control" datasource="#dsn3#">
	SELECT        
    	PO1.STOCK_ID, 
        PO1.P_ORDER_ID, 
        PO1.P_ORDER_NO,
        PO1.LOT_NO, 
        PO1.QUANTITY, 
        PO1.IS_STAGE, 
        POO.STAGE, 
        POO.OPERATION_TYPE_ID, 
        POO.P_OPERATION_ID, 
        POO.AMOUNT,
        S.PRODUCT_CODE, 
        S.PRODUCT_NAME,
        OTT.OPERATION_TYPE, 
      	OTT.OPERATION_CODE,
        ISNULL((
        	SELECT        
            	SUM(REAL_AMOUNT) AS REAL_AMOUNT
			FROM            
            	PRODUCTION_OPERATION_RESULT
			WHERE        
            	OPERATION_ID = POO.P_OPERATION_ID
        ),0) AS REAL_AMOUNT
	FROM            
    	OPERATION_TYPES AS OTT INNER JOIN
      	PRODUCTION_OPERATION AS POO ON OTT.OPERATION_TYPE_ID = POO.OPERATION_TYPE_ID RIGHT OUTER JOIN
     	PRODUCTION_OPERATION AS PO INNER JOIN
      	PRODUCTION_ORDERS AS PO1 ON PO.P_ORDER_ID = PO1.PO_RELATED_ID INNER JOIN
     	STOCKS AS S ON PO1.STOCK_ID = S.STOCK_ID ON POO.P_ORDER_ID = PO1.P_ORDER_ID
	WHERE        
    	PO.P_ORDER_ID = #attributes.upd_id# AND 
        PO.P_OPERATION_ID = #attributes.operation_id_#
 	ORDER BY
    	PO1.P_ORDER_NO
</cfquery>
<cfquery name="get_ezgi_result_stocks" datasource="#dsn3#">
	SELECT        
    	POS.STOCK_ID, 
        POS.SPECT_MAIN_ID, 
        SUM(POS.AMOUNT) AS AMOUNT, 
        GST.SPECT_VAR_ID, 
        ISNULL(GST.PRODUCT_STOCK, 0) AS PRODUCT_STOCK,
        S.PRODUCT_CODE, 
        S.PRODUCT_NAME,
        S.BARCOD
	FROM            
    	PRODUCTION_ORDERS AS PO INNER JOIN
        PRODUCTION_ORDERS_STOCKS AS POS ON PO.P_ORDER_ID = POS.P_ORDER_ID INNER JOIN
        STOCKS AS S ON POS.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
        #dsn2_alias#.GET_STOCK_LOCATION_SPECT_TOTAL AS GST ON POS.STOCK_ID = GST.STOCK_ID AND ISNULL(POS.SPECT_MAIN_ID, 0) = ISNULL(GST.SPECT_VAR_ID, 0)
	WHERE        
    	PO.P_ORDER_ID = #attributes.upd_id# AND 
        ISNULL(S.IS_ADD_XML, 0) <> 1 AND <!---Kanban Ürünlere Bakma--->
        ISNULL(S.IS_ZERO_STOCK,0) <> 1 <!---0 sTOKLA çALIŞ Ürünlere Bakma--->
 	GROUP BY 
     	POS.STOCK_ID, 
    	POS.SPECT_MAIN_ID, 
      	GST.SPECT_VAR_ID,
     	ISNULL(GST.PRODUCT_STOCK, 0),
   		S.PRODUCT_CODE, 
        S.PRODUCT_NAME,
        S.BARCOD
</cfquery>
<cfquery name="get_ezgi_result_control_group" dbtype="query">
	SELECT
    	STOCK_ID, 
        P_ORDER_ID, 
        P_ORDER_NO,
        LOT_NO, 
        QUANTITY, 
        IS_STAGE, 
        PRODUCT_CODE, 
        PRODUCT_NAME
   	FROM
    	get_ezgi_result_control
  	WHERE
    	IS_STAGE <>2
   	GROUP BY
    	STOCK_ID, 
        P_ORDER_ID, 
        P_ORDER_NO,
        LOT_NO, 
        QUANTITY, 
        IS_STAGE, 
        PRODUCT_CODE, 
        PRODUCT_NAME	
</cfquery>
<cfquery name="get_ezgi_result_stocks_group" dbtype="query">
	SELECT        
    	STOCK_ID, 
        SPECT_MAIN_ID, 
        AMOUNT, 
        SPECT_VAR_ID, 
        PRODUCT_STOCK,
        PRODUCT_CODE, 
        PRODUCT_NAME,
        BARCOD
	FROM
    	get_ezgi_result_stocks
   	WHERE
    	AMOUNT > PRODUCT_STOCK
</cfquery>
<cfif get_ezgi_result_control_group.recordcount and get_ezgi_result_stocks_group.recordcount>
	<cfsavecontent variable="right_menu">
    	<input type="button" name="bslamadi" value="Başlamadı" style="width:100px; font-size:10px; height:30px; background-color:orange">
        <input type="button" name="bsladi" value="Çalışıyor" style="width:100px; font-size:10px; height:30px; background-color:blue">
        <input type="button" name="eksik" value="Eksik Kapama" style="width:100px; font-size:10px; height:30px; background-color:green">
        <input type="button" name="bitti" value="Bitti" style="width:100px; font-size:10px; height:30px; background-color:red">&nbsp;&nbsp;
    </cfsavecontent>	
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cfif get_ezgi_result_control_group.recordcount>
            <cf_box scroll="0">
            	<cfsavecontent variable="title">Üretim Kontrol</cfsavecontent>
                <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1" right_images="#right_menu#">
                    <cf_form_list>   
                        <thead>
                            <tr valign="middle">
                                <th style="width:35px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                                <th style="width:100px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='41701.Lot No'></th>
                                <th style="width:100px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='45276.Üretim Emir No'></th>
                                <th style="width:350px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                <th style="width:100px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57635.Miktar'></th>
                                <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36376.Operasyonlar'></th>
                                <!-- sil -->
                                <th style="width:20px; text-align:center; vertical-align:middle" class="header_icn_none" ></th>
                                <!-- sil -->
                            </tr>
                        </thead>
                        <tbody>
                            <cfif get_ezgi_result_control_group.recordcount>
                                <cfoutput query="get_ezgi_result_control_group">
                                    <cfquery name="get_operations" dbtype="query">
                                        SELECT        
                                            P_OPERATION_ID, 
                                            OPERATION_TYPE_ID, 
                                            OPERATION_CODE, 
                                            OPERATION_TYPE, 
                                            AMOUNT, 
                                            STAGE,
                                            SUM(REAL_AMOUNT) AS REAL_AMOUNT
                                        FROM  
                                            get_ezgi_result_control        
                                        WHERE        
                                            P_ORDER_ID = #get_ezgi_result_control_group.P_ORDER_ID#
                                        GROUP BY 
                                            P_OPERATION_ID, 
                                            OPERATION_TYPE_ID, 
                                            OPERATION_CODE, 
                                            OPERATION_TYPE, 
                                            AMOUNT, 
                                            STAGE
                                        ORDER BY
                                            OPERATION_CODE
                                    </cfquery>
                                    <tr>
                                        <td style="text-align:right; " nowrap="nowrap">#CURRENTROW#</td>
                                        <td style="text-align:center;">#LOT_NO#</td>
                                        <td style="text-align:center;" nowrap="nowrap">#P_ORDER_NO#</td>
                                        <td style="text-align:left;" nowrap="nowrap">#PRODUCT_NAME#</td>
                                        <td style="text-align:right;">#AmountFormat(QUANTITY,2)#</td>
                                        <td style="text-align:left; width:50%" title="">
                                            <cfif len(get_operations.P_OPERATION_ID)>
                                                <cfloop query="get_operations">
                                                    
                                                    <input type="button" name="operation_#P_OPERATION_ID#" title="Biten : #get_operations.REAL_AMOUNT#" value="#OPERATION_TYPE#" id="operation_#P_OPERATION_ID#" onclick="operation(#P_OPERATION_ID#);" style="width:100px; font-size:10px; height:30px; background-color:<cfif STAGE eq 0>orange<cfelseif STAGE eq 1>blue<cfelse>red</cfif>">
                                                </cfloop>
                                            <cfelse> 
                                                <input type="button" name="operation#currentrow#" value="Tanımsız" id="operation#currentrow#" onclick="operation_tanimsiz(#currentrow#);" style="width:100px; height:30px; background-color:gray">
                                            </cfif>
                                        </td>
                                        <!-- sil -->
                                        <td style="text-align:center;">
                                            <cfif IS_STAGE eq 0>
                                                <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='36583.Başlamadı'>">
                                            <cfelseif IS_STAGE eq 4>
                                                <img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='36584.Bitti'>">
                                            <cfelseif IS_STAGE eq 2>
                                                <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='36584.Bitti'>">
                                            <cfelseif IS_STAGE eq 1>
                                                <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='36890.Başladı'>">
                                            </cfif>
                                        </td>
                                        <!-- sil -->
                                    </tr>
                                </cfoutput>
                            </cfif>
                        </tbody>
                    </cf_form_list>
                </cf_box>
            </cf_box>
        </cfif>
        <cfif get_ezgi_result_stocks_group.recordcount>
            <cf_box scroll="0">
            	<cfsavecontent variable="title">Stok Kontrol</cfsavecontent>
                <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
                    <cf_form_list>
                    	<thead>
                            <tr valign="middle">
                                <th style="width:35px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                                <th style="width:100px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57633.Barkod'></th>
                                <th style="width:100px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58800.Ürün Kodu'></th>
                                <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                <th style="width:100px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='33968.İhtiyaç'></th>
                                <th style="width:100px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='39425.Depo Miktarı'></th>
                            </tr>
                        </thead>
                        <tbody>
                        	<cfif get_ezgi_result_stocks_group.recordcount>
                                <cfoutput query="get_ezgi_result_stocks_group">
                                	<tr>
                                        <td style="text-align:right;" nowrap="nowrap">#CURRENTROW#</td>
                                        <td style="text-align:left;" nowrap="nowrap">#BARCOD#</td>
                                        <td style="text-align:left;" nowrap="nowrap">#PRODUCT_CODE#</td>
                                        <td style="text-align:left;" nowrap="nowrap">#PRODUCT_NAME#</td>
                                        <td style="text-align:right;">#AmountFormat(AMOUNT,2)#</td>
                                        <td style="text-align:right;">#AmountFormat(PRODUCT_STOCK,2)#</td>
                                 	</tr>
                                </cfoutput>
                        	</cfif>
                    	</tbody>
                    </cf_form_list>
                </cf_box>
            </cf_box>
        </cfif>
    </div>
</cfif> 
