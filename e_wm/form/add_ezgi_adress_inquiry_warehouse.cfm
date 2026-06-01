<!---
    File: add_ezgi_adress_inquiry_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Adres Sorgulama
---> 
<cfparam name="attributes.add_other_barcod" default="">
<cfif isdefined('attributes.is_submitted')>
	<cfquery name="get_serial" datasource="#dsn3#">
    	SELECT 
        	CASE
            	WHEN O.COMPANY_ID IS NOT NULL THEN
                   (
                    SELECT     
                      	NICKNAME
					FROM         
                    	#dsn_alias#.COMPANY
					WHERE     
                   		COMPANY_ID = O.COMPANY_ID
                  	)
             	WHEN O.CONSUMER_ID IS NOT NULL THEN      
                   	(	
                  	SELECT     
                     	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
					FROM         
                      	#dsn_alias#.CONSUMER
					WHERE     
                		CONSUMER_ID = O.CONSUMER_ID
               		)
                   	
          	END AS UNVAN,
        	E.SERIAL_NO, 
            E.STOCK_ID, 
            E.SPECT_ID, 
            E.PALET_BARCODE, 
            E.PRODUCT_NAME, 
            E.SHELF_CODE,
        	O.ORDER_NUMBER
		FROM     
      		EZGI_WM_IS_SERIAL_NO_LIVE INNER JOIN
          	EZGI_WM_SERIAL_NO_LAST_STATUS AS E ON EZGI_WM_IS_SERIAL_NO_LIVE.SERIAL_NO = E.SERIAL_NO LEFT OUTER JOIN
         	ORDER_ROW AS ORR INNER JOIN
         	EZGI_WM_SERIAL_NO_ORDER_LAST_STATUS AS OE ON ORR.ORDER_ROW_ID = OE.RESERVE_ORDER_ROW_ID INNER JOIN
       		ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID ON E.SERIAL_NO = OE.SERIAL_NO
		WHERE  
        	E.SHELF_CODE = '#attributes.add_other_barcod#'
		ORDER BY 
        	E.PALET_BARCODE, 
            E.SERIAL_NO
    </cfquery>
<cfelse>
	<cfset get_serial.recordcount =0>
</cfif> 
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
      	<cfform name="add_ezgi_adress_inquiry_warehouse" id="add_ezgi_adress_inquiry_warehouse" action="" method="post">
        	<input name="is_submitted" type="hidden" value="1">	
            <cf_basket_form id="add_ezgi_package_transfer">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_elements>
                            	<div class="col col-12 uniqueRow" id="first_area">
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='45254.Raf No'></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-barcod">
                                                <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
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
            <cfsavecontent variable="title"><cf_get_lang dictionary_id="45667.Raf"> : <cfoutput>#attributes.add_other_barcod#</cfoutput></cfsavecontent>
        	<cf_box title="#title#">
            	<cf_grid_list>
                   	<thead>
                       	<tr>
                        	<th><cf_get_lang dictionary_id="58577.Sıra"></th>
                            <th><cf_get_lang dictionary_id="37244.Palet"></th>
                            <th><cf_get_lang dictionary_id="58211.Sipariş No"></th>
                            <th><cf_get_lang dictionary_id="58061.Cari"></th>
                            <th><cf_get_lang dictionary_id="57637.Seri No"></th>
                            <th><cf_get_lang dictionary_id="58221.Ürün Adı"></th>
                     	</tr>
                 	</thead>
                 	<tbody name="table1" id="table1">
                    	<cfif get_serial.recordcount>
							<cfoutput query="get_serial">
                              	<tr>
                                 	<td style="text-align:center">#currentrow#</td>
                                	<td style="text-align:center">#PALET_BARCODE#</td>
                                  	<td style="text-align:center">#ORDER_NUMBER#</td>
                                    <td style="text-align:left">#UNVAN#</td>
                                    <td style="text-align:center">#SERIAL_NO#</td>
                                   	<td style="text-align:left">#PRODUCT_NAME#</td>
                              	</tr>
                            </cfoutput>
                        </cfif>
                    </tbody>
           		</cf_grid_list>
          	</cf_box>
      	</cfform>
   	</cf_box>
</div>
<script language="javascript" type="text/javascript">
	document.getElementById('add_other_barcod').focus();
	setTimeout("document.getElementById('add_other_barcod').select();",1000);
	document.onkeydown = checkKeycode
	function checkKeycode(e) /*Barkod Okuyup Enter Basıldığında*/
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			document.getElementById("add_ezgi_adress_inquiry_warehouse").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=stock.add_ezgi_adress_inquiry_warehouse";
			document.getElementById("add_ezgi_adress_inquiry_warehouse").submit();	
		}
	}
	
</script>