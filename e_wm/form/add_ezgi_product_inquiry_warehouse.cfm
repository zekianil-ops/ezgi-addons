<!---
    File: add_ezgi_product_inquiry_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/04/2024
    Description: Ürün Sorgulama
---> 
<cfparam name="attributes.add_order_barcod" default="">
<cfparam name="attributes.spect_main_id" default="">
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.spect_name" default="">
<cfquery name="GET_DEFAULT" datasource="#dsn3#">
	SELECT EAN FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfif not (GET_DEFAULT.recordcount and len(GET_DEFAULT.EAN))>
	<script type="text/javascript">
		alert("Ilk Olarak Default Tanımları Yapınız!");
		window.history.go(-1);
	</script>
</cfif>
<cfif isdefined('attributes.is_submitted')>
	<cfif len(attributes.add_order_barcod)>
    	<cfset barcode = left(attributes.add_order_barcod,GET_DEFAULT.EAN)>
        <cfset spectmainid =0>
        <cfif len(attributes.add_order_barcod) gt GET_DEFAULT.EAN>
        	<cfset spectmainid = MID(attributes.add_order_barcod,GET_DEFAULT.EAN+1,LEN(attributes.add_order_barcod))>
        </cfif>
    </cfif>
	<cfquery name="get_serial" datasource="#dsn3#">
    	SELECT DISTINCT 
         	O.ORDER_NUMBER, 
            ORR.ORDER_ROW_ID,
            ESOS.SERIAL_NO, 
            ESOS.PRODUCT_NAME, 
            ESOS.PALET_BARCODE, 
            ESOS.SHELF_CODE, 
            ESOS.DEPO, 
            ESOS.STOCK_ID, 
            S.BARCOD, 
            ESOS.SPECT_ID, 
            S.IS_PROTOTYPE 
		FROM     
       		EZGI_WM_SERIAL_NO_LAST_STATUS AS ESOS INNER JOIN
         	STOCKS AS S ON ESOS.STOCK_ID = S.STOCK_ID INNER JOIN
         	EZGI_WM_IS_SERIAL_NO_LIVE AS EVL ON ESOS.SERIAL_NO = EVL.SERIAL_NO LEFT OUTER JOIN
          	EZGI_WM_ORDER_LAST_STATUS AS EVLL INNER JOIN
         	ORDERS AS O INNER JOIN
     		ORDER_ROW AS ORR ON O.ORDER_ID = ORR.ORDER_ID ON EVLL.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON ESOS.SERIAL_NO = EVLL.SERIAL_NO
		WHERE  
    		ISNULL(S.IS_PROTOTYPE, 0) = 0
        	<cfif len(attributes.add_order_barcod)> 
                AND S.BARCOD = '#barcode#'
   			</cfif>
            <cfif len(attributes.product_name) and len(attributes.stock_id)>
            	AND ESOS.STOCK_ID = #attributes.stock_id#
            </cfif>
      	UNION ALL
    	SELECT DISTINCT 
         	O.ORDER_NUMBER, 
            ORR.ORDER_ROW_ID,
            ESOS.SERIAL_NO, 
            ESOS.PRODUCT_NAME, 
            ESOS.PALET_BARCODE, 
            ESOS.SHELF_CODE, 
            ESOS.DEPO, 
            ESOS.STOCK_ID, 
            S.BARCOD, 
            ESOS.SPECT_ID, 
            S.IS_PROTOTYPE 
		FROM     
       		EZGI_WM_SERIAL_NO_LAST_STATUS AS ESOS INNER JOIN
            STOCKS AS S ON ESOS.STOCK_ID = S.STOCK_ID INNER JOIN
            (
            	SELECT 
                	EWM.SERIAL_NO, 
                    EWM.ORDER_ROW_ID AS RESERVE_ORDER_ROW_ID
				FROM     
                	EZGI_WM_ORDER_LAST_STATUS AS EWM INNER JOIN
                  	EZGI_WM_IS_SERIAL_NO_LIVE AS EVL ON EWM.SERIAL_NO = EVL.SERIAL_NO
           	) AS TBL ON ESOS.SERIAL_NO = TBL.SERIAL_NO LEFT OUTER JOIN
       		ORDERS AS O INNER JOIN
        	ORDER_ROW AS ORR ON O.ORDER_ID = ORR.ORDER_ID ON TBL.RESERVE_ORDER_ROW_ID = ORR.ORDER_ROW_ID
		WHERE  
    		ISNULL(S.IS_PROTOTYPE,0) = 1
       		<cfif len(attributes.add_order_barcod)> 
                AND S.BARCOD = '#barcode#'
                AND ESOS.SPECT_ID = #spectmainid#
            </cfif>
            <cfif len(attributes.product_name) and len(attributes.stock_id)>
            	AND ESOS.STOCK_ID = #attributes.stock_id#
            </cfif>
            <cfif len(attributes.spect_name) and len(attributes.spect_main_id)>
            	AND ESOS.SPECT_ID = #attributes.spect_main_id#
            </cfif>
    </cfquery>
<cfelse>
	<cfset get_serial.recordcount =0>
</cfif> 
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
      	<cfform name="add_ezgi_product_inquiry_warehouse" id="add_ezgi_product_inquiry_warehouse" action="" method="post">
        	<input name="is_submitted" type="hidden" value="1">	
            <cf_basket_form id="add_ezgi_package_transfer">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_search>
                            	<div class="form-group" id="item-barcod">
                                 	<input id="add_order_barcod" name="add_order_barcod" type="text" placeholder="<cf_get_lang dictionary_id='39093.Ürün Barkodu'>" value="">
                               	</div>
                              	<div class="form-group">
                                 	<cf_wrk_search_button search_function='input_control()' button_type="4">
                             	</div>
               				</cf_box_search>
                          	<cf_box_search_detail>
                                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="1" sort="true">
                                  	<div class="form-group" id="item-product_name">
                                        <label class="col col-12"><cf_get_lang dictionary_id='57657.Ürün'></label>
                                        <div class="col col-12">
                                            <div class="input-group">
                                                <input type="hidden" name="stock_id" id="stock_id" value="<cfoutput>#attributes.stock_id#</cfoutput>">
                                                <input type="hidden" name="product_id" id="product_id" value="<cfoutput>#attributes.product_id#</cfoutput>">
                                                <input type="text"   name="product_name"  id="product_name"   value="<cfoutput>#attributes.product_name#</cfoutput>" passthrough="readonly=yes" onfocus="AutoComplete_Create('product_name','PRODUCT_NAME','PRODUCT_NAME,STOCK_CODE,','get_product_autocomplete','0','PRODUCT_ID,STOCK_ID','product_id,stock_id','','3','225');" autocomplete="off">
                                                <span class="input-group-addon icon-ellipsis btnPointer" title="" onClick="spect_remove();windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=add_ezgi_product_inquiry_warehouse.stock_id&product_id=add_ezgi_product_inquiry_warehouse.product_id&field_name=add_ezgi_product_inquiry_warehouse.product_name&keyword='+encodeURIComponent(document.add_ezgi_product_inquiry_warehouse.product_name.value),'list');"></span>
                                            </div>
                                        </div>
                                    </div>  
                                </div>
                                <div class="col col-3 col-md-4 col-sm-6 col xs-12" type="column" index="2" sort="true">
                                    <div class="form-group" id="item-spect_name">
                                        <label class="col col-12"><cf_get_lang dictionary_id='57647.Spec'></label>
                                        <div class="col col-12">
                                            <div class="input-group">
                                                <input type="hidden" name="spect_main_id" id="spect_main_id" value="<cfoutput>#attributes.spect_main_id#</cfoutput>">
                                                <input type="text" name="spect_name" id="spect_name" value="<cfoutput>#attributes.spect_name#</cfoutput>" style="width:110px;">
                                                <span class="input-group-addon icon-ellipsis btnPointer" title="" onClick="product_control();"></span>
                                            </div>
                                        </div>
                                    </div>
               					</div>
							</cf_box_search_detail>
                       	</div>
                  	</div>
              	</div>
    		</cf_basket_form>
            <cfsavecontent variable="title"><th><cf_get_lang dictionary_id="58221.Ürün Adı"> : <cfoutput><cfif isdefined('attributes.is_submitted')>#get_serial.PRODUCT_NAME#</cfif></cfoutput></cfsavecontent>
        	<cf_box title="#title#">
            	<cf_grid_list>
                   	<thead>
                       	<tr>
                        	<th><cf_get_lang dictionary_id="58577.Sıra"></th>
                            <th><cf_get_lang dictionary_id="58763.Depo"></th>
                            <th><cf_get_lang dictionary_id="45254.Raf No"></th>
                            <th><cf_get_lang dictionary_id="37244.Palet"></th>
                            <th><cf_get_lang dictionary_id="57637.Seri No"></th>
                            <th><cf_get_lang dictionary_id="58211.Sipariş No"></th>
                     	</tr>
                 	</thead>
                 	<tbody name="table1" id="table1">
                    	<cfif get_serial.recordcount>
							<cfoutput query="get_serial">
                            	<cfquery name="GET_DURUM" datasource="#dsn3#">
                                	SELECT 
                                    	PROCESS_NO, 
                                        PROCESS_CAT, 
                                        PURCHASE_START_DATE
									FROM     
                                    	SERVICE_GUARANTY_NEW
									WHERE  
                                    	SERIAL_NO = N'#SERIAL_NO#' AND 
                                        IN_OUT = 1
                                </cfquery>
                                <cfset belge = ''>
                                <cfif GET_DURUM.recordcount>
                                	<cfif GET_DURUM.PROCESS_CAT eq 171>
                                    	<cfset belge = 'Üretim Sonucu'>
                                    <cfelseif GET_DURUM.PROCESS_CAT eq 115>
                                		<cfset belge = 'Sayım Sonucu'>
                                	<cfelseif GET_DURUM.PROCESS_CAT eq 76>
                                    	<cfset belge = 'Mal Alım İrsaliyesi'>
                                    </cfif>
                                </cfif>
                              	<tr title="#belge# - #DateFormat(GET_DURUM.PURCHASE_START_DATE,dateformat_style)# - #GET_DURUM.PROCESS_NO# ">
                                	<input type="hidden" name="row_control_#currentrow#" id="row_control_#currentrow#" value="0">
                                 	<td style="text-align:center;cursor:pointer; <cfif GET_DURUM.PROCESS_CAT eq 115>color:red;</cfif>" onClick="seviye(#currentrow#)">#currentrow#</td>
                                    <td style="text-align:center">#DEPO#</td>
                                    <td style="text-align:center">#SHELF_CODE#</td>
                                	<td style="text-align:center">#PALET_BARCODE#</td>
                                  	<td style="text-align:center">#SERIAL_NO#</td>
                                    <td style="text-align:center">#ORDER_NUMBER#</td>
                              	</tr>
                                <tr id="tr_#currentrow#" style="display:none">
                                	<td colspan="5" style="font-weight:bolder; font-size:10px"></td>
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
			document.getElementById("add_ezgi_order_inquiry_warehouse").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=stock.add_ezgi_product_inquiry_warehouse";
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
	function product_control()/*Ürün seçmeden spect seçemesin.*/
	{
		if(document.add_ezgi_product_inquiry_warehouse.stock_id.value=="" || document.add_ezgi_product_inquiry_warehouse.product_name.value=="" )
		{
		alert("<cf_get_lang dictionary_id ='36828.Spect Seçmek için öncelikle ürün seçmeniz gerekmektedir'>");
		return false;
		}
		else
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_spect_main&field_main_id=add_ezgi_product_inquiry_warehouse.spect_main_id&field_name=add_ezgi_product_inquiry_warehouse.spect_name&is_display=1&stock_id='+document.add_ezgi_product_inquiry_warehouse.stock_id.value,'list');
	}
	function spect_remove()/*Eğer ürün seçildikten sonra spect seçilmişse yeniden ürün seçerse ilgili spect'i kaldır.*/
	{
		document.add_ezgi_product_inquiry_warehouse.spect_main_id.value = "";
		document.add_ezgi_product_inquiry_warehouse.spect_name.value = "";	
	}
	function input_control()
	{
		if(document.getElementById('add_order_barcod').value !='' || document.getElementById('stock_id').value !='')
			return true;
		else
		{
			alert('Filtreye Değer Girmelisiniz!!!')
			return false;
		}
	}
</script>