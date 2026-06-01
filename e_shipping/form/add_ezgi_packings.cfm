<!---
    File: add_ezgi_packings.cfm
    Folder: Add_Ons\ezgi\e_shipping\form
    Author: Ezgi Yazılım
    Date: 01/01/2022
    Description:
--->
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfset attributes.barcode = get_defaults.PALET_BARCODE+1>
<cf_catalystHeader>
<div class="col col-12 col-xs-12">
    <cf_box>
    	<cfform name="add_packings" method="post" action="#request.self#?fuseaction=sales.emptypopup_add_ezgi_packings">
        	<cf_box_elements>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                        <div class="form-group" id="item-is_active">
                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                            <div class="col col-8 col-xs-12">
                                <cfinput type="checkbox" id="is_active" name="is_active" value="1" checked="yes">
                            </div>
                       	</div>
                        <div class="form-group" id="item-barcode">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57633.Barkod'>*</label>
                            <div class="col col-8 col-xs-12">
                             	<cfinput type="text"  maxlength="50" name="barcode" value="#attributes.barcode#" readonly="yes">
                            </div>
                      	</div> 
                        <div class="form-group" id="item-type">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='823.Palet Türü'>*</label>
                            <div class="col col-8 col-xs-12">
                                <select name="type" id="type" style="width:100px; height:20px" onchange="type_change(this.value)">
                                    <option value="1"><cf_get_lang dictionary_id='820.Standart Paket'></option>
                                    <option value="2"><cf_get_lang dictionary_id='821.Özel Paket'></option>
                                    <option value="3"><cf_get_lang dictionary_id='822.Lokasyon Paleti'></option>
                                    <option value="4"><cf_get_lang dictionary_id='59323.Lot Bazında'> <cf_get_lang dictionary_id='37244.Palet'></option>
                                </select>
                            </div>
                      	</div> 
                        <div class="form-group" id="item-amount">
                        	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57635.Miktar'>*</label>
                            <div class="col col-8 col-xs-12">
                             	<cfinput type="text"  maxlength="2" name="amount" value="1">
                            </div>
                      	</div> 
                        <div class="form-group" id="item-lotno" style="display:none">
                      		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='41701.Lot No'></label>
                           	<div class="col col-4 col-xs-12">
                             	<cfinput type="text"  maxlength="50" name="lot_no" id="lot_no" value="" onChange="lot_no_change(this.value)">
                          	</div>
                         	<div class="col col-4 col-xs-12" id="item-sipno"  style="display:none">
                            	<cfsavecontent variable="siparis"><cf_get_lang dictionary_id='58211.Sipariş No'></cfsavecontent>
                            	<cfinput type="text"  maxlength="50" name="order_no" id="order_no" value="" readonly="yes" placeholder="#siparis#">
                                <cfinput type="hidden" name="order_id" id="order_id" value="0">
                                <cfinput type="hidden" name="order_row_id" id="order_row_id" value="0">
                                <cfinput type="hidden" name="company_id" id="company_id" value="0">
                                <cfinput type="hidden" name="consumer_id" id="consumer_id" value="0"> 
                          	</div>
                            <div class="col col-4 col-xs-12" id="item-sipselect"  style="display:none">
                                <select name="get_new_order" id="get_new_order" style="width:120px" onChange="new_order_select(this.value);">
                                    <option value="">Seçiniz</option>
                                </select>
                            </div>
                       	</div>
                        <div class="form-group" id="item-detail">
                       		<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                        	<div class="col col-8 col-xs-12">
                             	<textarea name="detail" id="detail" style="width:150px;height:100px;" maxlength="250"></textarea>
                         	</div>
                      	</div> 
              	</div> 
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-12" id="buton">
                	<cf_workcube_buttons type_format="1" is_upd='0' add_function='kontrol()'>
                </div>
            </cf_box_footer>
        </cfform> 
    </cf_box>
</div>
<script type="text/javascript">
	document.onkeydown = checkKeycode
	function checkKeycode(e) 
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			/*var new_sql = "SELECT DISTINCT O.ORDER_NUMBER, O.ORDER_ID, ISNULL(O.COMPANY_ID,0) AS COMPANY_ID, ISNULL(O.CONSUMER_ID,0) AS CONSUMER_ID FROM ORDER_ROW AS ORR INNER JOIN PRODUCTION_ORDERS_ROW AS POR ON ORR.ORDER_ROW_ID = POR.ORDER_ROW_ID INNER JOIN PRODUCTION_ORDERS AS PO ON POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID INNER JOIN ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID WHERE PO.PRODUCTION_LEVEL = '0' AND PO.LOT_NO = '"+document.getElementById('lot_no').value+"' UNION ALL SELECT DISTINCT O.ORDER_NUMBER, O.ORDER_ID, ISNULL(O.COMPANY_ID, 0) AS COMPANY_ID, ISNULL(O.CONSUMER_ID, 0) AS CONSUMER_ID FROM ORDER_ROW AS ORR INNER JOIN ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS_ROW AS PORR ON ORR.ORDER_ROW_ID = PORR.ORDER_ROW_ID INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS AS EPO ON PORR.PRODUCTION_ORDER_ID = EPO.IFLOW_P_ORDER_ID INNER JOIN PRODUCTION_ORDERS AS PO ON EPO.LOT_NO = PO.LOT_NO WHERE PO.PRODUCTION_LEVEL = '0' AND PO.LOT_NO = '"+document.getElementById('lot_no').value+"'";*/
			/*var get_info = wrk_query(new_sql,'dsn3');*/
			
			var listParam = document.getElementById('lot_no').value;
			var get_info = wrk_safe_query('get_p_order_info_lotno_ezgi','dsn3',0,listParam);
			
			if(get_info.recordcount >1)
			{
				document.getElementById('item-sipselect').style.display='';
				document.getElementById('item-sipselect').focus();
            	var option_count = document.getElementById('get_new_order').options.length; 
            	for(x=option_count;x>=0;x--)
					document.getElementById('get_new_order').options[x] = null;
				if(get_info.recordcount != 0)
				{	
					document.getElementById('get_new_order').options[0] = new Option('Seçiniz','');
					for(var xx=0;xx<get_info.recordcount;xx++)
						document.getElementById('get_new_order').options[xx+1]=new Option(get_info.ORDER_NUMBER[xx],get_info.ORDER_ID[xx]);
				}
				else
					document.getElementById('get_new_order').options[0] = new Option('Seçiniz','');
			}
			else if (get_info.ORDER_ID == undefined)
			{
				alert('<cf_get_lang dictionary_id='34132.Sipariş Kaydı Bulunamdı'>');
				return false;
			}
			else
			{
				document.getElementById('item-sipno').style.display='';
				document.getElementById('order_no').value=get_info.ORDER_NUMBER;
				document.getElementById('order_id').value=get_info.ORDER_ID;
				document.getElementById('company_id').value=get_info.COMPANY_ID;
				document.getElementById('consumer_id').value=get_info.CONSUMER_ID;
				document.getElementById('buton').style.display='';
			}
		}
	}
	function kontrol()
	{
			if(document.getElementById('company_id').value == 0 && document.getElementById('consumer_id').value == 0 && document.getElementById('type').value==2)
			{
				alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> : <cf_get_lang dictionary_id='57658.Üye'>!");
				return false;
			}
			else
			{
				return true;	
			}
	}
	function type_change(type)
	{
		if(type != 1)
		{
			document.getElementById('item-lotno').style.display='';
			document.getElementById('item-amount').style.display='none';
			document.getElementById('lot_no').focus();
			document.getElementById('buton').style.display='none';
		}
		else
		{
			document.getElementById('item-lotno').style.display='none';
			document.getElementById('item-amount').style.display='';
		}
	}
	function new_order_select(order_id)
	{
		/*var new_select_sql = "SELECT DISTINCT O.ORDER_NUMBER, O.ORDER_ID, ISNULL(O.COMPANY_ID,0) AS COMPANY_ID, ISNULL(O.CONSUMER_ID,0) AS CONSUMER_ID FROM ORDER_ROW AS ORR INNER JOIN PRODUCTION_ORDERS_ROW AS POR ON ORR.ORDER_ROW_ID = POR.ORDER_ROW_ID INNER JOIN PRODUCTION_ORDERS AS PO ON POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID INNER JOIN ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID WHERE PO.PRODUCTION_LEVEL = '0' AND O.ORDER_ID = "+order_id+" AND PO.LOT_NO = '"+document.getElementById('lot_no').value+"' UNION ALL SELECT DISTINCT O.ORDER_NUMBER, O.ORDER_ID, ISNULL(O.COMPANY_ID, 0) AS COMPANY_ID, ISNULL(O.CONSUMER_ID, 0) AS CONSUMER_ID FROM ORDER_ROW AS ORR INNER JOIN ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS_ROW AS PORR ON ORR.ORDER_ROW_ID = PORR.ORDER_ROW_ID INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS AS EPO ON PORR.PRODUCTION_ORDER_ID = EPO.IFLOW_P_ORDER_ID INNER JOIN PRODUCTION_ORDERS AS PO ON EPO.LOT_NO = PO.LOT_NO WHERE PO.PRODUCTION_LEVEL = '0' AND O.ORDER_ID = "+order_id+" AND PO.LOT_NO = '"+document.getElementById('lot_no').value+"'";*/
		/*var get_new_info = wrk_query(new_select_sql,'dsn3');*/
		
		var listParam = order_id + "*" + document.getElementById('lot_no').value;
		var get_new_info = wrk_safe_query('get_p_order_info_order_id_lotno_ezgi','dsn3',0,listParam);
			
		if (get_new_info.ORDER_ID == undefined)
		{
			alert('<cf_get_lang dictionary_id='34132.Sipariş Kaydı Bulunamdı'>');
			return false;
		}
		else
		{
			document.getElementById('item-sipselect').style.display='none';
			document.getElementById('item-sipno').style.display='';
			document.getElementById('order_no').value=get_new_info.ORDER_NUMBER;
			document.getElementById('order_id').value=get_new_info.ORDER_ID;
			document.getElementById('company_id').value=get_new_info.COMPANY_ID;
			document.getElementById('consumer_id').value=get_new_info.CONSUMER_ID;
			document.getElementById('buton').style.display='';
		}
	}
</script>