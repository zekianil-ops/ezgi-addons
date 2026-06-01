<!---
    File: add_ezgi_order_inquiry_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Adres Sorgulama
---> 
<cfparam name="attributes.add_order_barcod" default="">
<cfif isdefined('attributes.is_submitted')>
	<cfquery name="get_serial" datasource="#dsn3#">
    	SELECT 
        	ESOS.STOCK_ID,
            ISNULL(ESOS.SPECT_ID,0) SPECT_ID,
        	O.ORDER_ID, 
            O.ORDER_NUMBER, 
            ORR.ORDER_ROW_ID, 
            EVOS.SERIAL_NO, 
            ESOS.PRODUCT_NAME, 
            ESOS.PALET_BARCODE, 
            ESOS.SHELF_CODE, 
            ESOS.DEPO
		FROM     
        	ORDERS AS O INNER JOIN
            ORDER_ROW AS ORR ON O.ORDER_ID = ORR.ORDER_ID INNER JOIN
            EZGI_WM_SERIAL_NO_ORDER_LAST_STATUS AS EVOS ON ORR.ORDER_ROW_ID = EVOS.RESERVE_ORDER_ROW_ID INNER JOIN
            EZGI_WM_SERIAL_NO_LAST_STATUS AS ESOS ON EVOS.SERIAL_NO = ESOS.SERIAL_NO
		WHERE  
        	O.ORDER_NUMBER LIKE '#attributes.add_order_barcod#'
		ORDER BY 
        	ESOS.STOCK_ID,
            ESOS.SPECT_ID,
        	ESOS.SHELF_CODE, 
            ESOS.PALET_BARCODE, 
            EVOS.SERIAL_NO
    </cfquery>
<cfelse>
	<cfset get_serial.recordcount =0>
</cfif> 
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
      	<cfform name="add_ezgi_order_inquiry_warehouse" id="add_ezgi_order_inquiry_warehouse" action="" method="post">
        	<input name="is_submitted" type="hidden" value="1">	
            <cf_basket_form id="add_ezgi_package_transfer">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_elements>
                            	<div class="col col-12 uniqueRow" id="first_area">
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='58211.Sipariş'></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-barcod">
                                                <input id="add_order_barcod" name="add_order_barcod" type="text" value="">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
               				</cf_box_elements>
                    		<cf_box_footer>
                            	<div class="col col-12">
                                    <div class="col col-6" style="text-align:right">
                               		</div>
                                    <div class="col col-6" style="text-align:right;" id="onay_div">
                                        
                                 	</div>
                              	</div>
              				</cf_box_footer>
                       	</div>
                  	</div>
              	</div>
    		</cf_basket_form>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id="58211.Sipariş No"> : <cfoutput>#attributes.add_order_barcod#</cfoutput></cfsavecontent>
        	<cf_box title="#title#">
            	<cf_grid_list>
                   	<thead>
                       	<tr>
                        	<th><cf_get_lang dictionary_id="58577.Sıra"></th>
                            <th><cf_get_lang dictionary_id="58763.Depo"></th>
                            <th><cf_get_lang dictionary_id="45254.Raf No"></th>
                            <th><cf_get_lang dictionary_id="37244.Palet"></th>
                            <th><cf_get_lang dictionary_id="57637.Seri No"></th>
                           <!--- <th><cf_get_lang dictionary_id="58221.Ürün Adı"></th>--->
                     	</tr>
                 	</thead>
                 	<tbody name="table1" id="table1">
                    	<cfif get_serial.recordcount>
                        	<cfset satir_adet = 0>
							<cfoutput query="get_serial">
                            	<cfset satir_adet = satir_adet+1>
                              	<tr>
                                	<input type="hidden" name="row_control_#currentrow#" id="row_control_#currentrow#" value="0">
                                 	<td style="text-align:center;" style="cursor:pointer" onClick="seviye(#currentrow#)">#currentrow#</td>
                                    <td style="text-align:center">#DEPO#</td>
                                    <td style="text-align:center">#SHELF_CODE#</td>
                                	<td style="text-align:center">#PALET_BARCODE#</td>
                                  	<td style="text-align:center">#SERIAL_NO#</td>
                                   	<!---<td style="text-align:left">#PRODUCT_NAME#</td>--->
                              	</tr>
                                <cfif get_serial.recordcount eq get_serial.currentrow or (get_serial.recordcount neq get_serial.currentrow and get_serial.stock_id[get_serial.currentrow+1] neq get_serial.stock_id)>
                                	
                                    <tr>
                                        <td colspan="4" style="font-weight:bolder; font-size:10px">#PRODUCT_NAME#</td>
                                        <td style="text-align:center">#satir_adet#</td>
                                    </tr>
                                    <cfset satir_adet = 0>
                                </cfif>
                            </cfoutput>
                        </cfif>
                    </tbody>
           		</cf_grid_list>
          	</cf_box>
      	</cfform>
   	</cf_box>
</div>
<script language="javascript" type="text/javascript">
	document.getElementById('add_order_barcod').focus();
	setTimeout("document.getElementById('add_order_barcod').select();",1000);
	document.onkeydown = checkKeycode
	function checkKeycode(e) /*Barkod Okuyup Enter Basıldığında*/
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			document.getElementById("add_ezgi_order_inquiry_warehouse").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=stock.add_ezgi_order_inquiry_warehouse";
			document.getElementById("add_ezgi_order_inquiry_warehouse").submit();	
		}
	}
	function seviye(row)
	{
		if(document.getElementById('row_control_'+row).value==0)
		{
			document.getElementById('row_control_'+row).value = 1;
			document.getElementById('tr_'+row).style.display=''
		}
		else
		{
			document.getElementById('row_control_'+row).value = 0;
			document.getElementById('tr_'+row).style.display='none'
		}
	}
</script>