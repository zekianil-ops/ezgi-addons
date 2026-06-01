<!---
    File: upd_ezgi_iflow_production_order.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfparam name="attributes.sort_type" default="10">
<cfif isdefined('attributes.iflow_p_order_id') and isdefined('attributes.floor_id_list') and listlen(attributes.floor_id_list)>
	<cfquery name="get_old_floor" datasource="#dsn3#">
    	SELECT FLOOR_IDS FROM EZGI_IFLOW_PRODUCTION_ORDERS WHERE IFLOW_P_ORDER_ID = #attributes.iflow_p_order_id#
    </cfquery>
    <cfif len(get_old_floor.FLOOR_IDS)>
    	<cfset new_floor_id_list = ListAppend(attributes.floor_id_list,get_old_floor.FLOOR_IDS)>
   	<cfelse>
    	<cfset new_floor_id_list = attributes.floor_id_list>
    </cfif>
    <cfif Listlen(new_floor_id_list)>
    	<cfquery name="upd_floor" datasource="#dsn3#">
        	UPDATE EZGI_IFLOW_PRODUCTION_ORDERS SET FLOOR_IDS = '#new_floor_id_list#' WHERE IFLOW_P_ORDER_ID = #attributes.iflow_p_order_id#
        </cfquery>
    </cfif>
</cfif>
<cfinclude template="../query/get_ezgi_iflow_production_order.cfm">
<cfquery name="get_p_order_control" dbtype="query">
	SELECT IS_STAGE FROM get_production_orders WHERE IS_STAGE IN (1,2)
</cfquery>
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT 
    	P_ORDER_PARTI_DETAIL, 
        P_ORDER_PARTI_DATE, 
        P_ORDER_PARTI_NUMBER,
        P_ORDER_START_DATE, 
        P_ORDER_FINISH_DATE,
    	ISNULL(P_ORDER_PARTI_TYPE,0) AS P_ORDER_PARTI_TYPE, 
        RECORD_EMP, 
        RECORD_DATE, 
        RECORD_IP 
  	FROM 
    	EZGI_IFLOW_PRODUCTION_ORDERS_PARTI 
   	WHERE 
    	P_ORDER_PARTI_ID = #attributes.rel_p_order_id#
</cfquery>
<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
    <cfquery name="get_master_plan" datasource="#dsn3#">
        SELECT MASTER_PLAN_NUMBER FROM EZGI_IFLOW_MASTER_PLAN WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
    </cfquery>
    <cfset master_plan_number = get_master_plan.MASTER_PLAN_NUMBER>
<cfelse>
	<cfset master_plan_number = ''>
</cfif>
<cfset attributes.p_order_date = DateFormat(get_upd.P_ORDER_PARTI_DATE,dateformat_style)>
<cfset attributes.p_start_date = DateFormat(get_upd.P_ORDER_START_DATE,dateformat_style)>
<cfset attributes.p_finish_date = DateFormat(get_upd.P_ORDER_FINISH_DATE,dateformat_style)>
<cfset attributes.process_stage = get_production_orders.PROD_ORDER_STAGE>
<cfset attributes.parti_no = get_upd.P_ORDER_PARTI_NUMBER>
<cfset attributes.p_order_type = get_upd.P_ORDER_PARTI_TYPE>
<cfset sepet_satir = 0>
<cfset var_="upd_purchase_basket">
<cfsavecontent variable="sag_menu">
	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_iflow_demands&action_type=1&is_filter=1&master_plan_id=#attributes.master_plan_id#</cfoutput>','longpage');"><img src="/images/messenger8.gif" title="<cf_get_lang dictionary_id='533.Planlama Talebinden Ekleme'>" border="0"></a>
 	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_iflow_demands&action_type=2&master_plan_id=#attributes.master_plan_id#</cfoutput>','longpage');"><img src="/images/messenger3.gif" title="<cf_get_lang dictionary_id='534.Satış Siparişinden Ekleme'>" border="0"></a>
  	<a href="javascript://" onClick="openProducts();"><img src="/images/messenger5.gif" title="<cf_get_lang dictionary_id='535.Serbest Ekleme'>" border="0"></a>
</cfsavecontent>
<cfsavecontent variable="baslik"><cf_get_lang dictionary_id='617.Üretim Emri Güncelle'></cfsavecontent>
<cf_box title="<cfoutput>#baslik#</cfoutput>" right_images="<cfoutput>#sag_menu#</cfoutput>">
	<div class="col col-12 col-xs-12">
        <cf_box>
        	<cfform name="form_basket" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_iflow_production_order">
                <cfinput name="master_plan_id" type="hidden" value="#attributes.master_plan_id#">
                <cfinput name="rel_p_order_id" type="hidden" value="#attributes.rel_p_order_id#">
                <cf_box_elements>
                 	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                      	<div class="form-group" id="item-plandate">
                          	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='536.Planlama Tarihi'></label>
                         	<div class="col col-8 col-xs-12">
                            	<div class="input-group">
                           			<cfsavecontent variable="message"><cf_get_lang dictionary_id='292.Planlama Tarihi Girmelisiniz'> !</cfsavecontent>
                        			<cfinput type="text" name="p_order_date" id="p_order_date" required="yes" value="#attributes.p_order_date#" validate="eurodate" message="#message#" maxlength="10" style="width:70px;" readonly>
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="p_order_date"></span>
                        			
                                </div>
                         	</div>
                       	</div>
                        <div class="col col-12">
                            <div class="form-group" id="item-process">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
                                <div class="col col-8 col-xs-12">
                                    <cf_workcube_process is_upd='0' select_value='#attributes.process_stage#' process_cat_width='125' is_detail='1'>
                                </div>
                            </div>
                        </div>
                  	</div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                      	<div class="form-group" id="item-partino">
                          	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="36528.Parti No"></label>
                         	<div class="col col-8 col-xs-12">
                            	<cfinput type="text" name="parti_no" id="parti_no" value="#attributes.parti_no#" maxlength="10" readonly>
                         	</div>
                       	</div>
                        <div class="col col-12">
                            <div class="form-group" id="item-plantype">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="1030.Planlama Türü"></label>
                                <div class="col col-8 col-xs-12">
                                    <select name="p_order_type" id="p_order_type">
                                        <option value="0" <cfif attributes.p_order_type eq 0>selected</cfif>><cf_get_lang dictionary_id="57236.Standart"></option>
                                        <option value="1" <cfif attributes.p_order_type eq 1>selected</cfif>><cf_get_lang dictionary_id="40935.Revize"></option>
                                    </select>
                                </div>
                           	</div>
                        </div>
                  	</div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                            <div class="form-group" id="item-start_date">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58053.Başlangıç Tarihi'></label>
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='39354.Başlangıç Tarihi Giriniz'> !</cfsavecontent>
                                        <cfinput type="text" name="p_start_date" id="p_start_date" value="#attributes.p_start_date#" validate="eurodate" message="#message#" maxlength="10" style="width:70px;" readonly>
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="p_start_date"></span>
                                        
                                    </div>
                                </div>
                            </div>
                            <div class="form-group" id="item-finish_date">
                                <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57700.Bitiş Tarihi'></label>
                                <div class="col col-8 col-xs-12">
                                    <div class="input-group">
                                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='39357.Bitiş Tarihi Giriniz'> !</cfsavecontent>
                                        <cfinput type="text" name="p_finish_date" id="p_finish_date" value="#attributes.p_finish_date#" validate="eurodate" message="#message#" maxlength="10" style="width:70px;" readonly>
                                        <span class="input-group-addon"><cf_wrk_date_image date_field="p_finish_date"></span>
                                        
                                    </div>
                                </div>
                            </div>	
                        
                  	</div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true">
                      	<div class="form-group" id="item-status">
                          	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                         	<div class="col col-8 col-xs-12">
                            	<textarea name="detail" style="height:60px"><cfoutput>#get_production_orders.P_ORDER_PARTI_DETAIL#</cfoutput></textarea>
                         	</div>
                       	</div>
                  	</div>
              	</cf_box_elements>
            	<cf_box_footer>
					<div class="col col-12 col-xs-12">
                    	<cfif get_p_order_control.recordcount>
                            <cf_workcube_buttons is_upd='1' is_delete='0' add_function='kontrol()' >
                        <cfelse>
                            <cf_workcube_buttons is_upd='1'  add_function='kontrol()' delete_page_url='#request.self#?fuseaction=prod.emptypopup_del_ezgi_iflow_production_order&rel_p_order_id=#attributes.rel_p_order_id#&master_plan_id=#attributes.master_plan_id#' del_function='kontrol()'>
                        </cfif>
                        <cf_record_info 
                         	query_name="get_upd"
                         	record_emp="RECORD_EMP" 
                         	record_date="record_date">
                	</div>
              	</cf_box_footer>
                <br>
                 <cf_grid_list sort="0">
                    <thead>
                        <tr>
                         	<th nowrap width="40px" id="basket_header_add" style="text-align:center"></th>
                          	<th width="90px" nowrap><cf_get_lang dictionary_id='35792.Kaynak'></th>
                           	<th width="70px" nowrap><cf_get_lang dictionary_id="695.Plan No"></th>
                        	<th width="70px" nowrap><cf_get_lang dictionary_id="45498.Lot No"></th>
                          	<th width="70px" nowrap><cf_get_lang dictionary_id='537.Ürün Tipi'></th>
                         	<th width="110px" nowrap><cf_get_lang dictionary_id='58800.Ürün Kodu'></th>
                          	<th nowrap><cf_get_lang dictionary_id='57657.Ürün'></th>
                           	<th width="70px" nowrap><cf_get_lang dictionary_id='57635.Miktar'></th>
                           	<th width="60px" nowrap><cf_get_lang dictionary_id='57636.Birim'></th>
                          	<th width="200px" nowrap><cf_get_lang dictionary_id='57629.Açıklama'></th>
                        	<th width="25px"><cf_get_lang dictionary_id='538.DRM'></th>
							<th width="25px">VRF</th>
						</tr>
                   	</thead>
                    <tbody name="new_row" id="new_row">
                   		<input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_production_orders.recordcount#</cfoutput>">
                     	<cfif get_production_orders.recordcount>
                        <!---<cfdump var="#get_production_orders#">--->
                            <cfoutput query="get_production_orders">
                            	<cfquery name="get_floor" datasource="#dsn3#">
                                	SELECT DISTINCT 
                                    	EWOF.EZGI_VIRTUAL_OFFER_ROW_FLOOR_ID
									FROM            
                                    	EZGI_IFLOW_PRODUCTION_ORDERS AS EPO INNER JOIN
                         				ORDER_ROW AS ORR ON EPO.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                         				EZGI_VIRTUAL_OFFER_ROW AS EWOR ON ORR.WRK_ROW_RELATION_ID = EWOR.WRK_ROW_RELATION_ID INNER JOIN
                         				EZGI_VIRTUAL_OFFER_ROW_FLOOR AS EWOF ON EWOR.EZGI_ID = EWOF.EZGI_ID
									WHERE   
                                    	EPO.IFLOW_P_ORDER_ID = #get_production_orders.IFLOW_P_ORDER_ID#     
                                </cfquery>
                                <input type="hidden" value="1" name="row_kontrol#currentrow#">
                                <input type="hidden" name="iflow_p_order_id_list" id="iflow_p_order_id_list" value="#get_production_orders.iflow_p_order_id#">
                                <tr height="20" id="frm_row#currentrow#">
                                    <td style="text-align:right">
                                    	<cfif IS_STAGE eq 0 or IS_STAGE eq 4>
                                            <a style="cursor:pointer" onclick="sil(#currentrow#);" >
                                                <img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0">
                                            </a> 
                                        </cfif>
                                        #currentrow#&nbsp;
                                    </td>
                                    <td class="boxtext" style="text-align:center">
                                    	<cfif ACTION_TYPE eq 1><cf_get_lang dictionary_id='619.Planlama Talebi'>
                                        <cfelseif ACTION_TYPE eq 2><cf_get_lang dictionary_id='620.Sipariş Emri'>
                                        <cfelse><cf_get_lang dictionary_id='621.Serbest Giriş'>
                                        </cfif>
                                    </td>
                                    <td style="text-align:center">#MASTER_PLAN_NUMBER#</td>
                                    <td style="text-align:center">#LOT_NO#</td>
                                    <td class="boxtext">
                                       <cfif PRODUCT_TYPE eq 1><cf_get_lang dictionary_id='58511.Takım'>
                                        <cfelseif PRODUCT_TYPE eq 2><cf_get_lang dictionary_id='141.Modül'>
                                        <cfelseif PRODUCT_TYPE eq 3><cf_get_lang dictionary_id='100.Paket'>
                                        <cfelseif PRODUCT_TYPE eq 4><cf_get_lang dictionary_id='45.Parça'>
                                        <cfelse><cf_get_lang dictionary_id='404.Hammadde'>
                                        </cfif>
                                        <input type="hidden" name="type#currentrow#" id="type#currentrow#" value="#PRODUCT_TYPE#"> 
                                    </td>
                                    <td nowrap style="text-align:left;" title="">
                                        <input type="text" id="stock_code#currentrow#" name="stock_code#currentrow#" style="width:110px;" class="boxtext" value="#PRODUCT_CODE#" readonly=yes>
                                    </td>
                                    <td nowrap style="text-align:left;" title="">
                                        <input type="Hidden" name="stock_id#currentrow#" value="#stock_id#">
                                        <input type="text" name="product_name#currentrow#" style="width:300px;" class="boxtext" value="#product_name#">
                                    </td>
                                    <td nowrap style="text-align:right;" title="">
                                   		<input type="text" id="quantity#currentrow#" name="quantity#currentrow#" value="#TlFormat(quantity,2)#" style="width:70px; text-align:right;">
                                        <input type="hidden" id="old_quantity#currentrow#" name="old_quantity#currentrow#" value="#TlFormat(quantity,2)#">
                                    </td>
                                    <td nowrap style="text-align:left;" title="">
                                        <input type="text" name="main_unit#currentrow#" style="width:60px;" class="boxtext" value="#unit#">
                                    </td>
                                    <td nowrap style="text-align:left;" title="">
                                        <input type="text" name="detail#currentrow#" style="width:200px;" value="#DETAIL#">
                                    </td>
                                    <td style="text-align:center; <cfif get_floor.recordcount>cursor:pointer</cfif>" <cfif get_floor.recordcount>onclick="gizle_goster(product_order_detail#currentrow#);connectAjax('#currentrow#','#quantity#','#IFLOW_P_ORDER_ID#');gizle_goster_nested('siparis_goster#currentrow#','siparis_gizle#currentrow#');"</cfif>>
                                    	<cfif IS_STAGE eq 4>
                                            <img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='1058.Sanal Üretim Emri'>">
                                        <cfelseif IS_STAGE eq 0>
                                            <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id='476.Başlamadı'>">
                                        <cfelseif IS_STAGE eq 1>
                                            <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id='398.Başladı'>">
                                        <cfelseif IS_STAGE eq 2>
                                            <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id='305.Bitti'>">
                                        <cfelseif IS_STAGE eq 3>
                                            <img src="/images/grey_glob.gif" title="<cf_get_lang dictionary_id='298.Arıza'>">
                                        </cfif>
                                    </td>
									<td nowrap style="text-align:left;" title="">
										<a href="javascript://" onclick="openBoxDraggable('#request.self#?fuseaction=prod.popup_upd_ezgi_iflow_production_order_verifaction&iflow_production_order_id=#get_production_orders.IFLOW_P_ORDER_ID#','list');"><img src="/images/care.gif" title="Eşitle" border="0"></a>
                                    </td>
                                </tr>
                                 <tr id="product_order_detail#currentrow#" class="nohover" style="display:none" >
                                    <td colspan="11">
                                        <div align="left" id="DISPLAY_PRODUCT_ORDER_INFO#currentrow#" style="border:none;"></div>
                                    </td>
                                </tr>
                            </cfoutput>
                    	</cfif>
                	</tbody>
              	</cf_grid_list>
        	</cfform>
        </cf_box>
   	</div>
</cf_box>
<script type="text/javascript">
	var row_count = document.form_basket.record_num.value;
	function kontrol()
	{
		if (form_basket.p_order_date.value.length == 0)
		{
			alert("<cf_get_lang dictionary_id='292.Planlama Tarihi Girmelisiniz'> !");
			return false;
		}
		if(process_cat_control())
			return true;
		else
			return false;
	}
	function openProducts()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_ezgi_stocks&price_cat=-2&ezgi_production=1&add_product_cost=1&module_name=product&var_=#var_#&is_action=1&startdate=&price_lists='</cfoutput>,'page');
	}
	function add_row(stockid,stockprop,sirano,product_id,product_name,stock_code,type,type_detail,main_unit,sales_price,money,discount,action_id,action_amount,action_type,action_detail,spect_main_id)
	{
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
		newRow.className = 'color-row';
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		document.form_basket.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.setAttribute("style", "text-align:right;");
		newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a> '+row_count+'&nbsp;';	
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.setAttribute("style", "text-align:center;");
		newCell.innerHTML = action_detail;	
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.setAttribute("style", "text-align:center;");
		newCell.innerHTML = '<cfoutput>#master_plan_number#</cfoutput>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.setAttribute("style", "text-align:center;");
		newCell.innerHTML = '';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" id="action_type' + row_count + '" name="action_type' + row_count + '" value="'+action_type+'"><input type="hidden" id="action_id' + row_count + '" name="action_id' + row_count + '" value="'+action_id+'"><input type="hidden" name="type' + row_count + '" value="'+type+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="text" name="type_detail' + row_count + '" style="width:70px;" class="boxtext" value="'+type_detail+'">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="stock_code' + row_count + '" style="width:110px;" class="boxtext" value="'+stock_code+'">';
		
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="stock_id'+row_count+'" value="' + stockid + '">';
		newCell.innerHTML = newCell.innerHTML + '<input type="Hidden" name="spect_main_id'+row_count+'" value="' + spect_main_id + '">';

		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="product_id'+row_count+'" value="'+product_id+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="text" name="product_name' + row_count + '" style="width:300px;" class="boxtext" value="'+product_name+'">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.setAttribute("style", "text-align:right;");
		newCell.innerHTML = '<input type="text" id="quantity' + row_count +'" name="quantity' + row_count +'" value="'+commaSplit(action_amount,2)+'" style="width:70px; text-align:right;">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="main_unit' + row_count + '" style="width:60px;" class="boxtext" value="'+main_unit+'">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="detail' + row_count + '" style="width:200px;" value="">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute("nowrap","nowrap");
		newCell.setAttribute("style", "text-align:center;");
		newCell.innerHTML = '<img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id='622.Hesaplanmadı'>">';
	}
	function sil(sy)
	{
		var element=eval("form_basket.row_kontrol"+sy);
		element.value=0;
		var element=eval("frm_row"+sy); 
		element.style.display="none";		
	}
	function connectAjax(crtrow,order_amount,IFLOW_P_ORDER_ID)
	{
		var bb = '<cfoutput>#request.self#?fuseaction=prod.emptypopup_ajax_ezgi_iflow_product_order_floor&master_plan_id=#attributes.master_plan_id#&rel_p_order_id=#attributes.rel_p_order_id#</cfoutput>&amount='+order_amount+'&IFLOW_P_ORDER_ID='+IFLOW_P_ORDER_ID;
		AjaxPageLoad(bb,'DISPLAY_PRODUCT_ORDER_INFO'+crtrow,1);
	}
</script>