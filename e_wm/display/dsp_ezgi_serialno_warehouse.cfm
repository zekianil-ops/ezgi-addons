<!---
    File: ajax_ezgi_pallets_to_storage_shelf_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2025
    Description: Siparişe Ürün Bağlama Ajax
--->
<cfif isdefined("attributes.crtrow")>
	<cfset attributes.crtrow = attributes.crtrow>
<cfelseif isdefined("attributes.row_number")>
	<cfset attributes.crtrow = attributes.row_number>
</cfif>
<cfquery name="GET_STOCKS_ALL" datasource="#DSN3#" maxrows="5"><!---Rezerve Edilmeyen Ürünler WM Depoda Aranıyor.(Sevkiyata Ayrılmamışsa)--->
	SELECT 
     	2 AS RESERVE_TYPE,
    	EN.SHELF_CODE, 
   		EN.PALET_BARCODE, 
     	EN.SERIAL_NO,
      	ED.DEPO_NAME,
  		PP.COLLECT_SORT,
    	PP.SHELF_SORT,
    	PP.SHELF_TYPE
	FROM     
      	EZGI_WM_DEPARTMENTS AS ED WITH (NOLOCK) INNER JOIN
       	EZGI_WM_SERIAL_NO_LAST_STATUS AS EN WITH (NOLOCK) ON ED.DEPARTMENT_ID = EN.DEPARTMENT_ID AND ED.LOCATION_ID = EN.LOCATION_ID INNER JOIN
    	PRODUCT_PLACE AS PP WITH (NOLOCK) ON EN.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID INNER JOIN
      	STOCKS AS S ON EN.STOCK_ID = S.STOCK_ID
	WHERE  
 		EN.SHIP_RESULT_ID IS NULL AND 
    	EN.SHIP_RESULT_TYPE IS NULL AND 
     	EN.STOCK_ID = #attributes.stock_id# AND 
    	PP.SHELF_TYPE <> 5 AND
    	ISNULL(S.IS_PRODUCTION, 0) = 1 AND
    	<cfif len(attributes.spect_main_id) and attributes.spect_main_id gt 0>
    		EN.SPECT_ID = #attributes.spect_main_id# AND
    	</cfif>
    	EN.SERIAL_NO IN
    	  				(
    	                	SELECT 
    	    					SERIAL_NO
    	   					FROM      
    	    					EZGI_WM_SERIAL_NO_ORDER_LAST_STATUS
    	   					WHERE   
    	    					ISNULL(RESERVE_ORDER_ROW_ID, 0) = 0
    	              	)
 	UNION ALL
  	SELECT 
   		2 AS RESERVE_TYPE,
      	EN.SHELF_CODE, 
    	EN.PALET_BARCODE, 
    	EN.SERIAL_NO,
    	ED.DEPO_NAME,
    	PP.COLLECT_SORT,
    	PP.SHELF_SORT,
    	PP.SHELF_TYPE
	FROM     
    	EZGI_WM_DEPARTMENTS AS ED WITH (NOLOCK) INNER JOIN
     	EZGI_WM_SERIAL_NO_LAST_STATUS AS EN WITH (NOLOCK) ON ED.DEPARTMENT_ID = EN.DEPARTMENT_ID AND ED.LOCATION_ID = EN.LOCATION_ID INNER JOIN
 		PRODUCT_PLACE AS PP WITH (NOLOCK) ON EN.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID INNER JOIN
  		STOCKS AS S ON EN.STOCK_ID = S.STOCK_ID
	WHERE  
   		EN.SHIP_RESULT_ID IS NULL AND 
    	EN.SHIP_RESULT_TYPE IS NULL AND 
    	EN.STOCK_ID = #attributes.stock_id# AND 
    	PP.SHELF_TYPE <> 5 AND
    	ISNULL(S.IS_PRODUCTION, 0) = 0
	ORDER BY 
     	PP.SHELF_TYPE,
    	PP.SHELF_SORT, 
    	PP.COLLECT_SORT,
    	EN.SERIAL_NO
</cfquery>
<cfif isdefined('attributes.ship_id')>
	<cfset GET_STOCKS_ALL.recordcount = 0>
	<cfquery name="GET_STOCKS_ORDER" datasource="#DSN3#"><!---Sipariş İçin Rezerve Edilmiş Ürünler Tüm Depolarda Aranıyor.--->
    	SELECT 
        	1 AS RESERVE_TYPE,
        	EN.SHELF_CODE, 
         	EN.PALET_BARCODE, 
      		EO.SERIAL_NO, 
         	ED.DEPO_NAME, 
        	PP.SHELF_TYPE,
           	PP.SHELF_SORT, 
       		PP.COLLECT_SORT
		FROM     
        	EZGI_WM_SERIAL_NO_ORDER_LAST_STATUS AS EO WITH (NOLOCK) INNER JOIN
          	EZGI_WM_SERIAL_NO_LAST_STATUS AS EN WITH (NOLOCK) ON EO.SERIAL_NO = EN.SERIAL_NO INNER JOIN
          	EZGI_WM_DEPARTMENTS AS ED WITH (NOLOCK) ON EN.DEPARTMENT_ID = ED.DEPARTMENT_ID AND EN.LOCATION_ID = ED.LOCATION_ID LEFT JOIN
          	PRODUCT_PLACE AS PP WITH (NOLOCK) ON EN.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID
		WHERE  
       		EO.RESERVE_ORDER_ROW_ID IN
                      				(
                                    	<cfif attributes.ship_type eq 1>
                                      		SELECT ORDER_ROW_ID FROM EZGI_SHIP_RESULT_ROW WHERE SHIP_RESULT_ID = #attributes.ship_id#
                                      	<cfelse>
                                         	SELECT ORDER_ROW_ID FROM EZGI_SHIP_RESULT_INTERNALDEMAND_ROW WHERE SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
                                      	</cfif>
                                	) AND 
     		EN.PRODUCT_PLACE_ID NOT IN
                      				(
                                   		SELECT 
                                        	PRODUCT_PLACE_ID
                       					FROM      
                                       		PRODUCT_PLACE
                       					WHERE   
                                       		SHELF_TYPE = 5 AND 
                                         	PLACE_STATUS = 1
                                	) AND
       		EN.STOCK_ID = #attributes.stock_id#
       		<cfif len(attributes.spect_main_id) and attributes.spect_main_id gt 0>
         		AND EN.SPECT_ID = #attributes.spect_main_id#
      		</cfif>
     	ORDER BY 
        	PP.SHELF_TYPE,
         	PP.SHELF_SORT, 
         	PP.COLLECT_SORT
	</cfquery>
	<cfif get_stocks_order.recordcount or get_stocks_all.recordcount>
   		<cfif get_stocks_order.recordcount>
        	<cfsavecontent variable="header_">Siparişe Rezerve Seri Nolar</cfsavecontent>
            <div class="col col-12 col-xs-12">
                <cf_box title="#header_#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
                    <cf_grid_list>
                        <thead>
                            <tr>
                                <th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                <th style="width:100%"><cf_get_lang dictionary_id='58763.Depo'></th>
                                <th style="width:40px"><cf_get_lang dictionary_id='45667.Raf'></th>
                                <th style="width:40px"><cf_get_lang dictionary_id='37244.Palet'></th>
                                <th style="width:50px"><cf_get_lang dictionary_id='57637.Seri No'></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfif get_stocks_order.recordcount>
                                <cfoutput query="get_stocks_order">
                                    <tr id="row#currentrow#" height="20">
                                        <td style="text-align:right">#currentrow#</td>
                                                <td style="text-align:center">#DEPO_NAME#</td>
                                                <td style="text-align:center;">#SHELF_CODE#</td>
                                        <td style="text-align:center;">#PALET_BARCODE#</td>
                                        <td style="text-align:center;">#SERIAL_NO#</td>
                                    </tr>
                                </cfoutput>
                            </cfif>
                        </tbody>
                    </cf_grid_list>
                </cf_box>
            </div>
  		</cfif>
    	<cfif not get_stocks_order.recordcount and get_stocks_all.recordcount>
          	<cfsavecontent variable="header_">Rezerve Edilebilecek Seri No lar</cfsavecontent>
            <div class="col col-12 col-xs-12">
                <cf_box title="#header_#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
                    <cf_grid_list>
                        <thead>
                            <tr>
                                <th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                <th style="width:100%"><cf_get_lang dictionary_id='58763.Depo'></th>
                                <th style="width:40px"><cf_get_lang dictionary_id='45667.Raf'></th>
                                <th style="width:40px"><cf_get_lang dictionary_id='37244.Palet'></th>
                                <th style="width:50px"><cf_get_lang dictionary_id='57637.Seri No'></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfif GET_STOCKS_ALL.recordcount>
                                <cfoutput query="GET_STOCKS_ALL">
                                    <tr id="row#currentrow#" height="20">
                                        <td style="text-align:right">#currentrow#</td>
                                                <td style="text-align:center">#DEPO_NAME#</td>
                                                <td style="text-align:center;">#SHELF_CODE#</td>
                                        <td style="text-align:center;">#PALET_BARCODE#</td>
                                        <td style="text-align:center;">#SERIAL_NO#</td>
                                    </tr>
                                </cfoutput>
                            </cfif>
                        </tbody>
                    </cf_grid_list>
                </cf_box>
            </div>
     	</cfif>
	<cfelse><!---Hiç Seri No Bulunamamışsa--->
    	<cfsavecontent variable="header_">Seri Nolar</cfsavecontent>
            <div class="col col-12 col-xs-12">
                <cf_box title="#header_#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
                    <cf_grid_list>
                        <thead>
                            <tr>
                                <th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                <th style="width:100%"><cf_get_lang dictionary_id='58763.Depo'></th>
                                <th style="width:40px"><cf_get_lang dictionary_id='45667.Raf'></th>
                                <th style="width:40px"><cf_get_lang dictionary_id='37244.Palet'></th>
                                <th style="width:50px"><cf_get_lang dictionary_id='57637.Seri No'></th>
                            </tr>
                        </thead>
                        <tbody>
                           	<tr>
                                <td colspan="5"><cf_get_lang dictionary_id='57484.Kayıt Bulunamadı'>!</td>
                            </tr>
                        </tbody>
                    </cf_grid_list>
                </cf_box>
            </div>
	</cfif>
<cfelse>
	<cfsavecontent variable="header_">Hangi Adreste Var ?</cfsavecontent>
	<div class="col col-12 col-xs-12">
    	<cf_box title="#header_#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
      		<cf_grid_list>
          		<thead>
              		<tr>
                		<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                 		<th style="width:100%"><cf_get_lang dictionary_id='58763.Depo'></th>
                  		<th style="width:40px"><cf_get_lang dictionary_id='45667.Raf'></th>
                  		<th style="width:40px"><cf_get_lang dictionary_id='37244.Palet'></th>
                		<th style="width:50px"><cf_get_lang dictionary_id='57637.Seri No'></th>
           			</tr>
        		</thead>
            	<tbody>
             		<cfif GET_STOCKS_ALL.recordcount>
                		<cfoutput query="GET_STOCKS_ALL">
                   			<tr id="row#currentrow#" height="20">
                        		<td style="text-align:right">#currentrow#</td>
                                        <td style="text-align:center">#DEPO_NAME#</td>
                                        <td style="text-align:center;">#SHELF_CODE#</td>
                				<td style="text-align:center;">#PALET_BARCODE#</td>
                				<td style="text-align:center;">#SERIAL_NO#</td>
							</tr>
                 		</cfoutput>
           			</cfif>
               	</tbody>
        	</cf_grid_list>
     	</cf_box>
   	</div>                                
</cfif>
