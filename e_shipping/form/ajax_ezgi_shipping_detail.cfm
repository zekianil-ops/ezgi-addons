<cfquery name="get_detail_info" datasource="#dsn3#">
	SELECT 
    	<cfif isdefined('attributes.ship_result_id')>    
            ESRR.SHIP_RESULT_ID, 
            ESRR.SHIP_RESULT_ROW_ID,
        <cfelseif isdefined('attributes.ship_result_internaldemand_id')>
        	ESRR.SHIP_RESULT_INTERNALDEMAND_ID, 
            ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID,
        </cfif>
        ESRR.ORDER_ROW_AMOUNT AS QUANTITY,
        ORW.STOCK_ID, 
        ORW.PRODUCT_ID, 
        ORW.SPECT_VAR_ID,
        ORW.ORDER_ID, 
        PU.MAIN_UNIT, 
        S.STOCK_CODE, 
      	S.PRODUCT_NAME
	FROM   
    	<cfif isdefined('attributes.ship_result_id')>        
    		EZGI_SHIP_RESULT_ROW AS ESRR INNER JOIN
        <cfelseif isdefined('attributes.ship_result_internaldemand_id')>
        	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR INNER JOIN
        </cfif>
        ORDER_ROW AS ORW ON ESRR.ORDER_ROW_ID = ORW.ORDER_ROW_ID INNER JOIN
        PRODUCT_UNIT AS PU ON ORW.PRODUCT_ID = PU.PRODUCT_ID INNER JOIN
        STOCKS AS S ON ORW.STOCK_ID = S.STOCK_ID
	WHERE 
    	<cfif isdefined('attributes.ship_result_id')>     
    		ESRR.SHIP_RESULT_ID = #attributes.ship_result_id# AND 
        <cfelseif isdefined('attributes.ship_result_internaldemand_id')>
        	ESRR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_result_internaldemand_id# AND 
        </cfif>
        PU.IS_MAIN = 1
</cfquery>
<table id="iliskili_sevk_detay" width="100%">
	<tr>
		<td>
			 <cf_medium_list>
				<thead>
					<tr> 
						<th style="width:25px"><cf_get_lang dictionary_id='58577.Sıra'></th>
						<th style="width:100px"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
						<th style="width:220px"><cf_get_lang dictionary_id='57657.Ürün'></th>
                        <th style="width:70px"><cf_get_lang dictionary_id='57647.Spekt'></th>
                        <th style="width:70px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                        <th style="width:50px"><cf_get_lang dictionary_id='57636.Birim'></th>
                        <!---<th style="width:20px"></th>--->
					</tr>
              	</thead>
                <tbody>
                	<cfif get_detail_info.recordcount>
                     	<cfoutput query="get_detail_info">
              				<tr>
                            	<td style="text-align:right">#currentrow#</td>
                                <td>#STOCK_CODE#</td>
                                <td>#PRODUCT_NAME#</td> 
                                <td>#SPECT_VAR_ID#</td>
                                <td style="text-align:right">#AmountFormat(QUANTITY)#</td>
                                <td>#MAIN_UNIT#</td>
                                <!---<td>
									<cfif isdefined('attributes.ship_result_id')>     
										<a href="javascript://" onClick="sil(#SHIP_RESULT_ROW_ID#,#ORDER_ID#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>
									<cfelseif isdefined('attributes.ship_result_internaldemand_id')>
										<a href="javascript://" onClick="sil(#SHIP_RESULT_INTERNALDEMAND_ROW_ID#,#ORDER_ID#);"><img src="/images/delete_list.gif" align="absmiddle" border="0"></a>
									</cfif>
                                </td>--->     
                         	</tr>
                     	</cfoutput>
                  	</cfif>
              	</tbody>
          	 </cf_medium_list>            
		</td>
	</tr>
</table>
</table>
<script language="javascript">
	function sil(ship_result_row_id,order_id)
	{	<cfif isdefined('attributes.ship_result_id')> 
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_shipping&ship_result_row_id='+ship_result_row_id+'&order_id='+order_id;
		<cfelseif isdefined('attributes.ship_result_internaldemand_id')>
		window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=sales.emptypopup_del_ezgi_shipping_internaldemand&ship_result_internaldemand_row_id='+ship_result_row_id+'&order_id='+order_id;
		</cfif>
	}
</script>