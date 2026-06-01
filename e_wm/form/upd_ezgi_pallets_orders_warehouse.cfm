<!---
    File: add_ezgi_pallets_order_shelf_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Transfer Bölgesine Transfer İşlemi
--->
<!---<cfdump var="#attributes#"><cfabort>--->
<cfparam name="attributes.anamenu" default="1">
<cfquery name="get_detail_package_list" datasource="#DSN3#">
  	SELECT 
     	O.ORDER_ID,
     	O.ORDER_NUMBER
 	FROM     
    	ORDERS AS O
   	WHERE  
   		O.ORDER_ID = #attributes.order_id#
</cfquery>
<cfif isdefined('attributes.order_id') and len(attributes.order_id)>
    <cf_catalystHeader>
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
            <cfsavecontent variable="title"><b><cf_get_lang dictionary_id='58211.Sipariş No'> :</b><cfoutput>#get_detail_package_list.ORDER_NUMBER#</cfoutput></cfsavecontent>
            <cf_box title=#title#>
                <cf_basket_form id="add_ezgi_pallets_to_storage_shelf_warehouse">
                    <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                    <div class="col col-12 uniqueRow" id="first_area">
                                        <div class="col col-12">
                                            <div class="col col-3">
                                                <label><cf_get_lang dictionary_id='57637.Seri No'></label>
                                            </div>
                                            <div class="col col-9">
                                                <div class="form-group" id="item-barcod">
                                                    <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col col-12" id="fourth_area">
                                        <div class="col col-12">
                                            <div class="col col-3">
                                                <label><cf_get_lang dictionary_id='45363.Kontrol Edilen Miktar'></label>
                                            </div>
                                            <cfoutput>
                                            <div class="col col-3">
                                                <div class="form-group" id="item-serial_control">
                                                    <input type="text" name="total_control_amount" readonly="readonly" class="box" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" id="total_control_amount" value="" />
                                                </div>
                                            </div>
                                            <div class="col col-6">
                                                <div class="form-group" id="item-serial_controled">
                                                    <input type="text" name="total_paket_sayisi" readonly="readonly" class="box" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" id="total_paket_sayisi" value="" />
                                                </div>
                                            </div>
                                            </cfoutput>
                                        </div>
                                    </div>
                                </cf_box_elements>
                            </div>
                        </div>
                    </div>
                </cf_basket_form>
            </cf_box>
            
            <cfsavecontent variable="sekme1"><cf_get_lang dictionary_id="57718.Seri No lar"></cfsavecontent>
            <cfsavecontent variable="sekme2"><cf_get_lang dictionary_id="57564.Ürünler"></cfsavecontent>
            <cfsavecontent variable="sekme3"><cf_get_lang dictionary_id="40808.Sipariş"></cfsavecontent>
            <div id="basket_main_div">
                <div class="row">
                    <div class="col col-12 uniqueRow">
                        <cf_basket_form id="upd_connect" class="row">
                            <div id="tab-container" class="tabStandart margin-top-5">
                                <div id="tab-head">
                                    <ul class="tabNav">
                                        <li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_sekme1" href="#order_list" onclick="SerialNoListAjax()";><cfoutput>#sekme1#</cfoutput></a></li>
                                        <li class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_sekme2" href="#order_list" onclick="ProductListAjax();"><cfoutput>#sekme2#</cfoutput></a></li>
                                        
                                        <li class="<cfif attributes.anamenu eq 3>active</cfif>"><a id="href_sekme3" href="#order_list" onclick="OrderListAjax();"><cfoutput>#sekme3#</cfoutput></a></li>
                                    </ul>
                                </div>
                                <div id="tab-content" class="margin-top-10"> 
                                    <div id="order_list" class="content row">
                                        
                                    </div>
                                </div>
                            </div>
                        </cf_basket_form>
                    </div>
                </div>                     
            </div>
       	</div>                         
    </div>
    <div id="serial_div"></div>
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
                if (document.getElementById('add_other_barcod').value.length == '') /*Barkod Boşsa*/
                {
                    alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>'); 
                    document.getElementById('add_other_barcod').value = '';
                    document.getElementById('add_other_barcod').focus();	
                }
                else /*Barkod Doluysa*/
                {
					AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_pallets_orders_warehouse&type=2&order_id=#attributes.order_id#</cfoutput>&serial_no='+document.getElementById('add_other_barcod').value,'order_list',1);
					document.getElementById('add_other_barcod').value='';
					document.getElementById('add_other_barcod').focus();
                }
            }
        }
		function SerialNoListAjax()
        {
            AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_pallets_orders_warehouse&type=2&order_id=#attributes.order_id#</cfoutput>','order_list',1);
			document.getElementById('add_other_barcod').focus();
        }
		function ProductListAjax()
        {
            AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_pallets_orders_warehouse&type=1&order_id=#attributes.order_id#</cfoutput>','order_list',1);
			document.getElementById('add_other_barcod').focus();
        }
		function OrderListAjax()
        {
            AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_pallets_orders_warehouse&type=3&order_id=#attributes.order_id#</cfoutput>','order_list',1);
			document.getElementById('add_other_barcod').focus();
        }
		function sil(serialno)
		{
			soru=confirm(serialno+' Seri Nolu Ürünü Rezervasyondan Çıkarıyorum ?')
			if(soru==true)
			{
				AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_pallets_orders_warehouse&type=2&sil=1&order_id=#attributes.order_id#</cfoutput>&serial_no='+serialno,'order_list',1);
				document.getElementById('add_other_barcod').value='';
				document.getElementById('add_other_barcod').focus();
			}
			else
				return false;
		}
		window.onload = function() {
    	SerialNoListAjax(); // Sayfa yüklendiğinde varsayılan sekme içeriğini getir
};
    </script>
</cfif>