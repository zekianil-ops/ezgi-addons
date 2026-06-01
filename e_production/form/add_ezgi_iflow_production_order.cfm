<!---
    File: add_ezgi_iflow_production_order.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_paper_no" datasource="#dsn3#">
 	SELECT  TOP (1) P_ORDER_PARTI_NUMBER FROM EZGI_IFLOW_PRODUCTION_ORDERS_PARTI WHERE P_ORDER_PARTI_NUMBER > 1 ORDER BY P_ORDER_PARTI_NUMBER DESC
</cfquery>
<cfquery name="get_iflow_master_plan_info" datasource="#dsn3#">
	SELECT MASTER_PLAN_CAT_ID,MASTER_PLAN_START_DATE, MASTER_PLAN_FINISH_DATE FROM EZGI_IFLOW_MASTER_PLAN WHERE MASTER_PLAN_ID = #attributes.master_plan_id#
</cfquery>
<cfset attributes.p_order_date = DateFormat(now(),dateformat_style)>
<cfset attributes.p_start_date = DateFormat(get_iflow_master_plan_info.MASTER_PLAN_START_DATE,dateformat_style)>
<cfset attributes.p_finish_date = DateFormat(get_iflow_master_plan_info.MASTER_PLAN_FINISH_DATE,dateformat_style)>
<cfset attributes.p_order_detail = "">
<cfparam name="attributes.p_order_status" default="">
<cfset attributes.p_order_status = 1>
<cfif get_paper_no.recordcount>
	<cfset attributes.parti_no = get_paper_no.P_ORDER_PARTI_NUMBER + 1>
<cfelse>
	<cfset attributes.parti_no = 30000001>
</cfif>
<cfset get_p_order.recordcount =0>
<cfset sepet_satir = 0>
<cfset var_="upd_purchase_basket">
<cfsavecontent variable="sag_menu">
	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_iflow_demands&action_type=3&cat_id=#get_iflow_master_plan_info.MASTER_PLAN_CAT_ID#&master_plan_id=#attributes.master_plan_id#</cfoutput>','longpage');"><img src="/images/messenger2.gif" title="<cf_get_lang dictionary_id='58937.Transfer İşlemi'>" border="0"></a>
	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_iflow_demands&action_type=1&is_filter=1&master_plan_id=#attributes.master_plan_id#</cfoutput>','longpage');"><img src="/images/messenger8.gif" title="<cf_get_lang dictionary_id='533.Planlama Talebinden Ekleme'>" border="0"></a>
  	<a href="javascript://" onclick="windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_iflow_demands&action_type=2&master_plan_id=#attributes.master_plan_id#</cfoutput>','longpage');"><img src="/images/messenger3.gif" title="<cf_get_lang dictionary_id='534.Satış Siparişinden Ekleme'>" border="0"></a>
  	<a href="javascript://" onClick="openProducts();"><img src="/images/messenger5.gif" title="<cf_get_lang dictionary_id='535.Serbest Ekleme'>" border="0"></a>
</cfsavecontent>
<cfsavecontent variable="uretim_emri"><cf_get_lang dictionary_id='36378.Üretim Emri Ekle'></cfsavecontent>
<cf_box title="<cfoutput>#uretim_emri#</cfoutput>" right_images="<cfoutput>#sag_menu#</cfoutput>">
	<div class="col col-12 col-xs-12">
        <cf_box>
            <cfform name="form_basket" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_iflow_production_order">
				<cfif isdefined('attributes.master_plan_id') and len(attributes.master_plan_id)>
                    <cfinput name="master_plan_id" type="hidden" value="#attributes.master_plan_id#">
                </cfif>
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
                        <div class="form-group" id="item-process">
                          	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
                         	<div class="col col-8 col-xs-12">
                            	<cf_workcube_process is_upd='0' process_cat_width='125' is_detail='0'>
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
                        <div class="form-group" id="item-plantype">
                          	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="1030.Planlama Türü"></label>
                         	<div class="col col-8 col-xs-12">
                            	<select name="p_order_type" id="p_order_type">
                                	<option value="0"><cf_get_lang dictionary_id="57236.Standart"></option>
                                    <option value="1"><cf_get_lang dictionary_id="40935.Revize"></option>
                                </select>
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
                      	<div class="form-group" id="item-detail">
                          	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                         	<div class="col col-8 col-xs-12">
                            	<textarea name="detail" style="height:60px"></textarea>
                         	</div>
                       	</div>
                  	</div>
              	</cf_box_elements>
            	<cf_box_footer>
					<div class="col col-6 col-xs-12">
                    	<cf_workcube_buttons is_upd='0' add_function='kontrol()'>
                	</div>
              	</cf_box_footer>
                <br>
                <cf_grid_list sort="0">
                    <thead>
                        <tr>
                         	<th nowrap width="40px" id="basket_header_add" style="text-align:center"></th>
                          	<th width="70px" nowrap><cf_get_lang dictionary_id='48799.Kaynak'></th>
                           	<th width="90px" nowrap><cf_get_lang dictionary_id='537.Ürün Tipi'></th>
                          	<th width="150px" nowrap><cf_get_lang dictionary_id='58800.Ürün Kodu'></th>
                         	<th nowrap><cf_get_lang dictionary_id='57657.Ürün'></th>
                          	<th width="90px" nowrap><cf_get_lang dictionary_id='57635.Miktar'></th>
                          	<th width="60px" nowrap><cf_get_lang dictionary_id='57636.Birim'></th>
                         	<th width="300px" nowrap><cf_get_lang dictionary_id='57629.Açıklama'></th>
                           	<th width="25px"><cf_get_lang dictionary_id='538.DRM'></th>
						</tr>
                   	</thead>
                    <tbody name="new_row" id="new_row">
                    	<input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_p_order.recordcount#</cfoutput>">
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
		newCell.innerHTML = '<input type="hidden" id="action_type' + row_count + '" name="action_type' + row_count + '" value="'+action_type+'"><input type="hidden" id="action_id' + row_count + '" name="action_id' + row_count + '" value="'+action_id+'"><input type="hidden" name="type' + row_count + '" value="'+type+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="text" name="type_detail' + row_count + '" style="width:70px;" class="boxtext" value="'+type_detail+'">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="stock_code' + row_count + '" style="width:140px;" class="boxtext" value="'+stock_code+'">';
		
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="Hidden" name="spect_main_id'+row_count+'" value="' + spect_main_id + '">';
		newCell.innerHTML = newCell.innerHTML + '<input type="Hidden" name="stock_id'+row_count+'" value="' + stockid + '">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="product_id'+row_count+'" value="'+product_id+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="text" name="product_name' + row_count + '" style="width:300px;" class="boxtext" value="'+product_name+'">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="quantity' + row_count +'" name="quantity' + row_count +'" value="'+commaSplit(action_amount,2)+'" style="width:90px; text-align:right;">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="main_unit' + row_count + '" style="width:60px;" class="boxtext" value="'+main_unit+'">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="detail' + row_count + '" style="width:300px;" value="">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute("nowrap","nowrap");
		newCell.setAttribute("style", "text-align:center;");
		newCell.innerHTML = '<a style="cursor:pointer" onclick="dsp_row_detail(' + action_type + ',' + action_id + ');" ><img src="/images/blue_glob.gif" alt="<cf_get_lang dictionary_id='622.Hesaplanmadı'>" border="0"></a> ';
	}
	function sil(sy)
	{
	
		var element=eval("form_basket.row_kontrol"+sy);
		element.value=0;
		var element=eval("frm_row"+sy); 
		element.style.display="none";		
	}
	function dsp_row_detail(action_type,action_id)
	{
		if(action_type == 2 && action_id >0)
		{
			/*var ezgi_sql = "SELECT EZGI_ID FROM EZGI_ORGE_RELATIONS WHERE ORDER_ROW_ID = "+action_id;*/
			/*var get_ezgi = wrk_query(ezgi_sql,'dsn3');*/
			
			var listParam = action_id;
			var get_ezgi = wrk_safe_query('get_orge_relations_ezgi_id_ezgi','dsn3',0,listParam);
			
			if(get_ezgi.recordcount != 0 && get_ezgi.EZGI_ID > 0)
			{
				windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_upd_ezgi_virtual_offer_row_floor_info&kilit=1&ezgi_id='+get_ezgi.EZGI_ID,'list');
			}
		}
	}
</script>