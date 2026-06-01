<!---
    File: add_ezgi_operation_result_control.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/04/2022
    Description:
--->

<!---Kendinden Önceki Operasyon Durum Kontrolü--->
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
            PO.P_OPERATION_ID < #attributes.operation_id_# 
            <cfif get_station_info.PREVIOUS_OPERATION_END_CONTROL eq 1> <!---Kendinden Önceki Operasyonlar İçinde Başlamamış varmı?--->
            	AND PO.STAGE = 0
          	<cfelseif get_station_info.PREVIOUS_OPERATION_END_CONTROL eq 2><!---Kendinden Önceki Operasyonlar İçinde Bitmemiş varmı?--->
            	AND PO.STAGE IN (0,1)
            </cfif>
        ORDER BY 
            PO.P_OPERATION_ID
    </cfquery>
    
<cfelse>
	<cfset get_previous_operation_end_control.recordcount = 0>
</cfif>
<!---Kendinden Önceki Operasyon Durum Kontrolü--->

<!---Kendinden Önceki Üretim Sonuç Kontrolü--->
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
        S.PRODUCT_CODE, 
        S.PRODUCT_NAME,
        OTT.OPERATION_TYPE, 
      	OTT.OPERATION_CODE,
        ISNULL((
        	SELECT        
            	SUM(REAL_AMOUNT) AS REAL_AMOUNT
			FROM            
            	PRODUCTION_OPERATION_RESULT WITH (NOLOCK)
			WHERE        
            	OPERATION_ID = POO.P_OPERATION_ID
        ),0) AS REAL_AMOUNT
	FROM            
    	OPERATION_TYPES AS OTT WITH (NOLOCK) INNER JOIN
      	PRODUCTION_OPERATION AS POO WITH (NOLOCK) ON OTT.OPERATION_TYPE_ID = POO.OPERATION_TYPE_ID RIGHT OUTER JOIN
     	PRODUCTION_OPERATION AS PO WITH (NOLOCK) INNER JOIN
      	PRODUCTION_ORDERS AS PO1 WITH (NOLOCK) ON PO.P_ORDER_ID = PO1.PO_RELATED_ID INNER JOIN
     	STOCKS AS S WITH (NOLOCK) ON PO1.STOCK_ID = S.STOCK_ID ON POO.P_ORDER_ID = PO1.P_ORDER_ID
	WHERE        
    	PO.P_ORDER_ID = #attributes.upd_id# AND 
        PO.P_OPERATION_ID = #attributes.operation_id_#
 	ORDER BY
    	PO1.P_ORDER_NO
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
<!---Kendinden Önceki Üretim Sonuç Kontrolü--->

<!---Bu Üretime Ait Sarf Stok Kontrolü--->
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
    	PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
        PRODUCTION_ORDERS_STOCKS AS POS WITH (NOLOCK) ON PO.P_ORDER_ID = POS.P_ORDER_ID INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON POS.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
        #dsn2_alias#.GET_STOCK_LOCATION_SPECT_TOTAL AS GST WITH (NOLOCK) ON POS.STOCK_ID = GST.STOCK_ID AND ISNULL(POS.SPECT_MAIN_ID, 0) = ISNULL(GST.SPECT_VAR_ID, 0)
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
<!---Bu Üretime Ait Operasyon Durum Kontrolü--->
<cfif get_previous_operation_end_control.recordcount gt 0>
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
   		<cfsavecontent variable="title"><cfif get_station_info.PREVIOUS_OPERATION_END_CONTROL eq 1>Başlamayan <cfelse>Bitiş Yapmayan</cfif>Operasyon Kontrol</cfsavecontent>
    	<cf_box>
      		<cf_form_list>   
          		<thead>
          			<tr valign="middle">
           				<th style="width:35px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                   		<th style="width:350px;text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36376.Operasyonlar'></th>
                   		<!-- sil -->
                        	<th style="width:20px; text-align:center; vertical-align:middle" class="header_icn_none" ></th>
             			<!-- sil -->
             		</tr>
          		</thead>
         		<tbody>
             		<cfoutput query="get_previous_operation_end_control">
                  		<tr>
                     		<td style="text-align:right;">#get_previous_operation_end_control.currentrow#</td>
                        	<td style="text-align:left;">#get_previous_operation_end_control.OPERATION_TYPE#</td>
                      		<!-- sil -->
                               	<td style="text-align:center;">
                                	<cfif get_previous_operation_end_control.STAGE eq 0>
                                    	<img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='36583.Başlamadı'>">
                             		<cfelseif get_previous_operation_end_control.STAGE eq 3>
                                     	<img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='36584.Bitti'>">
                                 	<cfelseif get_previous_operation_end_control.STAGE eq 1>
                                     	<img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='36890.Başladı'>">
                                  	</cfif>
                            	</td>
                         	<!-- sil -->
                 		</tr>
                	</cfoutput>
           		</tbody>
        	</cf_form_list>
 		</cf_box>    
  	</div> 
    <script type="text/javascript">
		<cfif get_station_info.PREVIOUS_OPERATION_END_CONTROL eq 1>
 			alert("Bu Operasyon Öncesi Başlamamış Operasyonlar Mevcut Lütfen Önce Listedeki Operasyonları Başlatın!");
		<cfelse>
			alert("Bu Operasyon Öncesi Bitmemiş Operasyonlar Mevcut Lütfen Önce Listedeki Operasyonları Bitirin!");
		</cfif>
		window.opener.location.reload();
     	window.close();
 	</script>
	<cfabort> 	
</cfif>
<!---Bu Üretime Ait Sarf Stok Kontrolü--->
<cfif (get_ezgi_result_control_group.recordcount and get_ezgi_result_stocks_group.recordcount) or get_previous_operation_end_control.recordcount>
	<script type="text/javascript">
		windowopen('<cfoutput>#request.self#?fuseaction=production.popup_dsp_ezgi_operation_result_control&upd_id=#attributes.upd_id#&operation_id_=#attributes.operation_id_#</cfoutput>','longpage');
	</script>
</cfif> 

