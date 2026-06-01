<!---
    File: add_ezgi_prod_order_demand.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---Ezgi Bilgisayar Özelleştirme ZAG - 01/12/2013--->
<cfif isdefined("form.internal_row_info")>
	<cfset internal_row_id_list = ''>
	<cfloop list="#form.internal_row_info#" index="id">
		<cfset internal_row_id_list = ListAppend(internal_row_id_list,listlast(id,';'))>
	</cfloop>
	<cfquery name="get_internaldemand" datasource="#dsn3#">
		SELECT
			I_ROW.STOCK_ID,
			I_ROW.QUANTITY,
			I_ROW.PRODUCT_NAME,
			I_ROW.UNIT,
			I_ROW.SPECT_VAR_ID,
			S.IS_PRODUCTION,
			WRK_ROW_ID,
			I.INTERNAL_NUMBER,
			I.TARGET_DATE,
			I.INTERNAL_ID,
			I_ROW.I_ROW_ID
		FROM
			INTERNALDEMAND I,
			INTERNALDEMAND_ROW I_ROW,
			STOCKS S
		WHERE
			S.STOCK_ID = I_ROW.STOCK_ID AND
			I.INTERNAL_ID = I_ROW.I_ID AND
			I_ROW.I_ROW_ID IN (#internal_row_id_list#)
	</cfquery>
</cfif>
<!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
<cfform name="add_collacted_demand" method="post" action="#request.self#?fuseaction=prod.emptypopup_add_ezgi_production_order_all_sub&is_manuel=1" enctype="multipart/form-data">
<input type="hidden" name="master_alt_plan_id" id="master_alt_plan_id"  value="<cfoutput>#attributes.master_alt_plan_id#</cfoutput>">
<input type="hidden" name="islem_id" id="islem_id"  value="<cfoutput>#attributes.islem_id#</cfoutput>">	
<!---Ezgi Bilgisayar Özelleştirme Bitiş--->
<input type="hidden" name="record_num" id="record_num" value="0">
<input type="hidden" name="is_demand" id="is_demand" value="<cfif isdefined("attributes.is_demand")><cfoutput>#attributes.is_demand#</cfoutput><cfelse>0</cfif>">
<cf_basket_form id="prod_order">
<div class="row">
    <div class="col col-12 uniqueRow">
        <div class="row formContent">
            <div class="row" type="row">
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-process">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
                        <div class="col col-8 col-xs-12">
                        	<cf_workcube_process is_upd='0' process_cat_width='150' is_detail='0'>
                        </div>
					</div>
                    <div class="form-group" id="item-project_head">
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57416.Proje'></label>
                        <div class="col col-8 col-xs-12">
                        	<div class="input-group">
				            	<cfoutput>
				                	<cfif isdefined('is_generate_serial_nos') and is_generate_serial_nos eq 1>
										<input type="hidden" name="is_generate_serial_nos" id="is_generate_serial_nos" value="1">
									</cfif>
				                    <input type="hidden" name="is_select_sub_product" id="is_select_sub_product" value="#is_select_sub_product#" />
									<input type="hidden" name="project_id" id="project_id" value="">
									<input type="text" name="project_head" id="project_head" value="" style="width:150px;"onFocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','','3','135')"autocomplete="off">
                                    <span class="input-group-addon icon-ellipsis btnPointer" title="" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_id=add_collacted_demand.project_id&project_head=add_collacted_demand.project_head');"></span>
								</cfoutput>
                            </div>
                        </div>
					</div>
                    <div class="form-group" id="item-stage_info" >
                    	<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36466.Seviye'></label>
                        <div class="col col-8 col-xs-12">
                        	<!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
							<input name="stage_info" id="stage_info" value="<cfoutput>#attributes.stage_info#</cfoutput>" type="text" onkeyup="return(FormatCurrency(this,event,8))" style="width:50px; height:20px" title="<cf_get_lang dictionary_id='557.Seviye alanına değer girilirse o kadar kırılım için kayıt açılır.'>">
            				<!---Ezgi Bilgisayar Özelleştirme Bitişi--->
                        </div>
					</div>
				</div>
			</div>
            <div class="row formContentFooter" style="position:relative">
			    <div class="col col-12">
			        <cf_workcube_buttons is_upd='0' add_function='kontrol_row()'>
			    </div>
                
			</div>
		</div>
	</div>
</div>
</cf_basket_form>
<cf_basket id="prod_order_bask">
	<table name="table1" id="table1" class="detail_basket_list">
		<thead>
			<tr>
				<th><a href="javascript://" onClick="pencere_ac_product();"><img src="images/plus_list.gif" title="<cf_get_lang dictionary_id ='57582.Ekle'>" style="cursor:pointer;" border="0"></a></th>
				<th width="170">
					<cf_get_lang dictionary_id='57629.Açıklama'>
					<br/>
					<cfinput type="text" name="temp_demand_no" id="temp_demand_no" value="" style="width:70px;" class="boxlist" onBlur="change_demand_no()">
				</th>
				<th width="180" ><cf_get_lang dictionary_id='57657.Ürün'> *</th>
				<th width="180"><cf_get_lang dictionary_id='34299.Spec'></th>
				<th width="90"><cf_get_lang dictionary_id='57635.Miktar'> *</th>
				<th width="90"><cf_get_lang dictionary_id='57636.Birim'> *</th>
				<th width="150"><cf_get_lang dictionary_id='58834.İstasyon'> *</th>
				<th width="150" colspan="2">
					<cf_get_lang dictionary_id='36604.Hedef Başlangıç'> *
					<br/>
					<cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='57742.Tarih'></cfsavecontent>
					<cfinput type="text" name="temp_date" id="temp_date" value="#dateformat(now(),dateformat_style)#" style="width:70px;" class="box" onBlur="change_date_info(1);" validate="eurodate" message="#message#">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='57491.Saat'></cfsavecontent>
					<cfinput type="text" name="temp_hour" id="temp_hour" value="00" style="width:30px;" class="box" onKeyUp="isNumber(this);" onBlur="change_date_info(1);" validate="integer" message="#message#">
					<cfinput type="text" name="temp_min" id="temp_min" value="00" style="width:30px;" class="box" onKeyUp="isNumber(this);" onBlur="change_date_info(1);" validate="integer" message="#message#">
				</th>
				<th width="150" colspan="2">
					<cf_get_lang dictionary_id='36606.Hedef Bitiş'> *
					<br/>
					<cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='57742.Tarih'></cfsavecontent>
					<cfinput type="text" name="temp_date_2" id="temp_date_2" value="#dateformat(now(),dateformat_style)#" style="width:70px;" class="box" onBlur="change_date_info(2);" validate="eurodate" message="#message#">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id="58194.Zorunlu Alan"> : <cf_get_lang dictionary_id='57491.Saat'></cfsavecontent>
					<cfinput type="text" name="temp_hour_2" id="temp_hour_2" value="00" style="width:30px;" class="box" onKeyUp="isNumber(this);" onBlur="change_date_info(2);" validate="integer" message="#message#">
					<cfinput type="text" name="temp_min_2" id="temp_min_2" value="00" style="width:30px;" class="box" onKeyUp="isNumber(this);" onBlur="change_date_info(2);" validate="integer" message="#message#">
				</th>
			</tr>
		 </thead>
		 <tbody></tbody>
	</table>
</cf_basket>
</cfform>
<cfoutput>
<script type="text/javascript">
	function open_file()
	{
		document.getElementById('demand_file').style.display='';
		<cfif isdefined("attributes.is_demand") and attributes.is_demand eq 1>
			AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_add_demand_file&is_demand=1','demand_file',1);
		<cfelse>
			AjaxPageLoad('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_add_demand_file','demand_file',1);
		</cfif>
		return false;
	}
	function kontrol_row()
	{
		for(r=1;r<=document.all.record_num.value;r++)
		{
			if(eval("document.all.row_kontrol"+r).value==1)
			{
				<cfif isdefined("attributes.is_demand") and attributes.is_demand eq 1>
					if(document.getElementById('demand_no'+r).value == "")
					{
						alert("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='507.Talep Numarası'>");
						return false;
					}
				</cfif>
				if(document.getElementById('stock_id'+r).value == "")
				{
					alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id ='57657.Ürün'>");
					return false;
				}
				if(document.getElementById('quantity'+r).value == "")
				{
					alert("<cf_get_lang dictionary_id='58194.Zorunlu Alan'> : <cf_get_lang dictionary_id ='57635.Miktar'>");
					return false;
				}
				if(document.getElementById('start_date'+r).value == "")
				{
					alert("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='58053.Başlangıç Tarihi'>");
					return false;
				}
				if(document.getElementById('finish_date'+r).value == "")
				{
					alert("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='57700.Bitiş Tarihi'>");
					return false;
				}
				if(eval('document.all.station_id_'+r+'_0').value == "")
				{
					alert("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='58834.İstasyon'>");
					return false;
				}
			}
		}
		if(process_cat_control())
			unformat_fields();
		else
			return false;
	}
	function change_demand_no()
	{
		if(document.all.record_num.value > 0)
		{
			for(var k=1;k<=document.all.record_num.value;k++)
				if(eval("document.all.row_kontrol"+k).value==1)
					eval("document.all.demand_no"+k).value = document.all.temp_demand_no.value;
		}
	}
	function change_date_info(type)
	{
		if(type == 1)//hedef başlangıç
		{
			if(document.getElementById('temp_hour').value == '' || document.getElementById('temp_hour').value > 23)
				document.getElementById('temp_hour').value = '00';
			if(document.getElementById('temp_min').value == '' || document.getElementById('temp_min').value > 59)
				document.getElementById('temp_min').value = '00';
			if(document.getElementById('temp_date').value!= '')
				for(r=1;r<=document.all.record_num.value;r++)
				{
					if(eval("document.all.row_kontrol"+r).value==1)
					{
						document.getElementById('start_date'+r).value = document.getElementById('temp_date').value;
						document.getElementById('start_h'+r).value = parseFloat(document.getElementById('temp_hour').value);
						document.getElementById('start_m'+r).value = parseFloat(document.getElementById('temp_min').value);
					}
				}
		}
		else//hedef bitiş
		{
			if(document.getElementById('temp_hour_2').value == '' || document.getElementById('temp_hour_2').value > 23)
				document.getElementById('temp_hour_2').value = '00';
			if(document.getElementById('temp_min_2').value == '' || document.getElementById('temp_min_2').value > 59)
				document.getElementById('temp_min_2').value = '00';
			if(document.getElementById('temp_date_2').value!= '')
				for(r=1;r<=document.all.record_num.value;r++)
				{
					if(eval("document.all.row_kontrol"+r).value==1)
					{
						document.getElementById('finish_date'+r).value = document.getElementById('temp_date_2').value;
						document.getElementById('finish_h'+r).value = parseFloat(document.getElementById('temp_hour_2').value);
						document.getElementById('finish_m'+r).value = parseFloat(document.getElementById('temp_min_2').value);
					}
				}
		}
	}
	function unformat_fields()
	{
		for(r=1;r<=document.all.record_num.value;r++)
		{
			if(eval("document.all.row_kontrol"+r).value==1)
			{
				document.getElementById("quantity"+r).value = filterNum(document.getElementById("quantity"+r).value);	
			}
		}
		return true;
	}
	function sil(sy)
	{
		var my_element=eval("document.all.row_kontrol"+sy);
		my_element.value=0;
		var my_element=eval("frm_row"+sy);
		my_element.style.display="none";
	}
	row_count = 0;
	row_date = "#dateformat(now(),dateformat_style)#";
	function add_row(stock_id,product_name,amount,unit,date1,date2,order_id,order_row_id,spect_main_id,demand_no,wrk_row_relation_id)
	{
		if(stock_id == undefined) stock_id='';
		if(product_name == undefined) product_name='';
		if(amount == undefined) amount='';
		if(unit == undefined) unit='';
		if(date1 == undefined) date1=row_date;
		if(date2 == undefined) date2=row_date;
		if(date1 == ' ') date1=row_date;
		if(date2 == ' ') date2=row_date;
		if(order_id == undefined) order_id='';
		if(order_row_id == undefined) order_row_id='';
		if(spect_main_id == undefined) spect_main_id='';
		if(demand_no == undefined) demand_no='';
		if(wrk_row_relation_id == undefined) wrk_row_relation_id='';
		row_count++;
		var newRow;
		var newCell;	
		document.all.record_num.value=row_count;
		newRow = document.getElementById("table1").insertRow(document.getElementById("table1").rows.length);
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);		
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);		
		newRow.className = 'color-row';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol' + row_count +'" ><input type="hidden" value="'+order_id+'" name="order_id' + row_count +'" ><input type="hidden" value="'+wrk_row_relation_id+'" name="wrk_row_relation_id' + row_count +'" ><input type="hidden" value="'+order_row_id+'" name="order_row_id' + row_count +'" ><a href="javascript://" onclick="sil(' + row_count + ');"><img src="/images/delete_list.gif" border="0" align="top"></a>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" name="demand_no' + row_count +'" id="demand_no' + row_count +'" value="'+demand_no+'" style="width:95%;height:20px;border-color:lightsilver">';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" name="stock_id'+ row_count +'" id="stock_id'+ row_count +'" value="'+stock_id+'"><input type="text" style="width:190px;height:20px;border-color:lightsilver" name="product_name'+ row_count +'" id="product_name'+ row_count +'" value="'+product_name+'" onFocus="autocomp_product('+row_count+');" autocomplete="off"><a href="javascript://" onClick="pencere_ac_product('+ row_count +');"><img src="/images/plus_thin.gif"  align="absmiddle" border="0" alt="<cf_get_lang dictionary_id="57734.Seçiniz">"></a>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="spect_main_id'+ row_count +'" id="spect_main_id'+ row_count +'" value="" readonly style="width:45px;height:20px;border-color:lightsilver"><input type="text" name="spect_var_id'+ row_count +'" id="spect_var_id'+ row_count +'" value="" readonly style="width:40px;height:20px;border-color:lightsilver"><input type="text" name="spect_var_name'+ row_count +'" id="spect_var_name'+ row_count +'" value="" readonly style="width:70px;height:20px;border-color:lightsilver"><a href="javascript://" onClick="open_spec('+ row_count +');"><img src="/images/plus_thin.gif"  align="top" border="0" alt="<cf_get_lang dictionary_id="57734.Seçiniz">"></a>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="quantity'+ row_count +'" id="quantity'+ row_count +'" value="'+amount+'"  passThrough="onkeyup=""return(FormatCurrency(this,event));""" style="width:100px;text-align:right;height:20px;border-color:lightsilver">';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="unit'+ row_count +'" style="width:98px;height:20px;border-color:lightsilver" readonly value="'+unit+'">';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<select name="station_id_'+ row_count +'_0" id="station_id_'+ row_count +'_0" style="width:158px;height:25px;border-color:lightsilver"><option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option></select><input type="hidden" name="station_name'+ row_count +'" id="station_name'+ row_count +'" value="aaaaa">';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute("id","start_date" + row_count + "_td");
		newCell.innerHTML = '<input type="text" name="start_date'+ row_count +'" id="start_date'+ row_count +'" value="'+date1+'" style="width:65px;height:20px;border-color:lightsilver">';
		wrk_date_image('start_date' + row_count);
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<select name="start_h'+ row_count +'" id="start_h'+ row_count +'" style="height:25px;"><cfloop from="0" to="23" index="i"><option value="#i#"><cfif i lt 10>0</cfif>#i#</option></cfloop></select><select name="start_m'+ row_count +'" id="start_m'+ row_count +'" style="height:25px;"><cfloop from="0" to="59" index="i"><option value="#i#"><cfif i lt 10>0</cfif>#i#</option></cfloop></select>';
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute("id","finish_date" + row_count + "_td");
		newCell.innerHTML = '<input type="text" name="finish_date'+ row_count +'" id="finish_date'+ row_count +'" value="'+date2+'" style="width:65px;height:20px;border-color:lightsilver">';
		wrk_date_image('finish_date' + row_count);
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<select name="finish_h'+ row_count +'" id="finish_h'+ row_count +'" style="height:25px;"><cfloop from="0" to="23" index="i"><option value="#i#"><cfif i lt 10>0</cfif>#i#</option></cfloop></select><select name="finish_m'+ row_count +'" id="finish_m'+ row_count +'" style="height:25px;"><cfloop from="0" to="59" index="i"><option value="#i#"><cfif i lt 10>0</cfif>#i#</option></cfloop></select>';
		get_product_main_spec_row(row_count,spect_main_id);
	}
	function autocomp_product(no)
	{
		AutoComplete_Create("product_name"+no,"PRODUCT_NAME","PRODUCT_NAME,STOCK_CODE","get_product","0","STOCK_ID","stock_id"+no,"",2,200,'get_product_main_spec_row('+row_count+',0)');
	}
	function pencere_ac_product(no)
	{
		if(no == undefined)
		{
			no = row_count + 1;
			row_count_new = row_count + 1;
			windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_product&field_amount=add_collacted_demand.quantity' + no +'&is_production=1&page_close=1&call_function_first_prod=add_row&call_function_first_parameter='+row_count_new+'&call_function=get_product_main_spec_row&call_function_parameter='+row_count_new+'&field_unit_name=add_collacted_demand.unit' + no +'&spec_field_id=add_collacted_demand.spect_main_id' + no +'&field_name=add_collacted_demand.product_name' + no +'&field_id=add_collacted_demand.stock_id' + no,'list','popup_add_ezgi_product');
		}
		else
		{
			windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_product&field_amount=add_collacted_demand.quantity' + no +'&is_production=1&call_function=get_product_main_spec_row&call_function_parameter='+row_count+'&field_unit_name=add_collacted_demand.unit' + no +'&spec_field_id=add_collacted_demand.spect_main_id' + no +'&field_name=add_collacted_demand.product_name' + no +'&field_id=add_collacted_demand.stock_id' + no,'list','popup_add_ezgi_product');
		}
	}
	function station_stock_control_row(row_info)
	{
		var ws_id_len = eval('document.all.station_id_'+row_info+'_0').options.length;
		for(j=ws_id_len;j>=0;j--)
			eval('document.all.station_id_'+row_info+'_0').options[j] = null;	

		eval('document.all.station_id_'+row_info+'_0').options[0] = new Option('<cf_get_lang dictionary_id='57734.Seçiniz'>','');
		if(document.getElementById('stock_id'+row_info) != undefined && document.getElementById('stock_id'+row_info).value != '')
		{
			var get_ws = wrk_safe_query('prdp_get_ws','dsn3',0,document.getElementById('stock_id'+row_info).value);
			for(var jj=0;jj < get_ws.recordcount;jj++)
				eval('document.all.station_id_'+row_info+'_0').options[jj+1]=new Option(get_ws.STATION_NAME[jj],get_ws.STATION_ID[jj]);
			
			var get_product_station = wrk_safe_query('prdp_get_product_station','dsn3',0,document.getElementById('stock_id'+row_info).value);
			if(get_product_station.recordcount)
			{
				eval('document.all.station_id_'+row_info+'_0').value = get_product_station.STATION_ID ;
			}
			else
			{
				eval('document.all.station_id_'+row_info+'_0').value = "" ;
			}
		}
	}
	function get_product_main_spec_row(row_info,spect_main_id)
	{
		if(document.getElementById('stock_id'+row_info).value != "" && document.getElementById('product_name'+row_info).value != "")
		{
			//spec_main_id de düştüğü için bu bloğa sokmuyoruz sadece istasyonunu seçili getiriyoruz.
			if(spect_main_id != undefined && spect_main_id != '' && spect_main_id != 0)
			{
				var listParam = spect_main_id + "*" + document.getElementById('stock_id'+row_info).value;
				QueryTextSpec = 'prdp_get_main_spec_id_2';
			}
			else
			{
				var listParam = document.getElementById('stock_id'+row_info).value;
				QueryTextSpec = 'prdp_get_main_spec_id_3';
			}
			var get_main_spec_id = wrk_safe_query(QueryTextSpec,'dsn3',0,listParam);
			if(get_main_spec_id.recordcount){
				document.getElementById('spect_main_id'+row_info).value = get_main_spec_id.SPECT_MAIN_ID ;
				document.getElementById('spect_var_name'+row_info).value = get_main_spec_id.SPECT_MAIN_NAME ;
			}
			else{
				document.getElementById('spect_main_id'+row_info).value = "";
				document.getElementById('spect_var_name'+row_info).value = "";
			}
			station_stock_control_row(row_info);
		}	
		else
			alert('<cf_get_lang dictionary_id="36831.Önce Ürün Seçiniz">');
	}
	<cfif isdefined('frm_prod_report')>/*sayfa rapordan cagrılmıssa secilen satırları toplu talep sayfasına ekliyor*/
		function add_row_from_production_trace_report()
		{
			<cfif isdefined("attributes.report_row_stock_id_") and len(report_row_stock_id_)>
				<cfloop list="#attributes.report_row_stock_id_#" index="r_stock_id">
					<cfif isdefined('stock_last_amount_#r_stock_id#') and filterNum(evaluate("stock_last_amount_#r_stock_id#")) gt 0>
						r_stock_id_info='<cfoutput>#listfirst(r_stock_id,"_")#</cfoutput>';
						row_amount_info_='<cfoutput>#evaluate("stock_last_amount_#r_stock_id#")#</cfoutput>';
						row_stock_unit_info_='<cfoutput>#evaluate("row_stock_unit_#r_stock_id#")#</cfoutput>';
						row_prod_name_info_='<cfoutput>#evaluate("row_stock_name_#r_stock_id#")#</cfoutput>';
						//row_unit_info='row_stock_unit_'
						if(row_prod_name_info_!='' && row_stock_unit_info_!='' & row_amount_info_!='')
						{
							add_row(r_stock_id_info,row_prod_name_info_,row_amount_info_,row_stock_unit_info_)
						}
					</cfif>
				</cfloop>
			</cfif>
		}
		add_row_from_production_trace_report();
	</cfif>
	<cfif isdefined('form.internal_row_info') and get_internaldemand.recordcount>/*sayfaya iç talep listeleme sayfasından  secilen satırları toplu talep sayfasına ekliyor*/
		function add_row_from_internal_row_info()
		{
			<cfloop query="get_internaldemand">
				r_stock_id_info='#STOCK_ID#';
				row_amount_info_='#evaluate("attributes.ADD_STOCK_AMOUNT_#INTERNAL_ID#_#I_ROW_ID#")#';
				row_stock_unit_info_='#UNIT#';
				row_prod_name_info_='#PRODUCT_NAME#';
				row_production_info_='#IS_PRODUCTION#';
				row_wrk_row_id_='#WRK_ROW_ID#';
				row_number_='#INTERNAL_NUMBER#';
				row_date1="#dateformat(now(),dateformat_style)#";
				//row_unit_info='row_stock_unit_'
				if(row_prod_name_info_!='' && row_stock_unit_info_!='' & row_amount_info_!='' & row_production_info_ != 0)
				{
					add_row(r_stock_id_info,row_prod_name_info_,row_amount_info_,row_stock_unit_info_,row_date1,row_date1,'','','',row_number_,row_wrk_row_id_)
				}
			</cfloop>
		}
		add_row_from_internal_row_info();
	</cfif>
</script>
</cfoutput>
<!---Ezgi Bilgisayar Özelleştirme Başlangıcı--->
<cfif isdefined("attributes.is_from_file")>
	<cfinclude template="../../../production_plan/query/get_demand_row_from_file.cfm">
</cfif>
<cfif isdefined('attributes.is_active') and len(attributes.is_active)>
	<cfloop list="#attributes.is_active#" index="kk">
    	<cfoutput>
			<script type="text/javascript">
				add_row("#Evaluate('stock_id_#kk#')#","#Evaluate('product_name_#kk#')#","#Evaluate('production_amount_#kk#')#","#Evaluate('main_unit#kk#')#","#Evaluate('production_start_date_#kk#')#","#Evaluate('production_finish_date_#kk#')#","","","#Evaluate('spect_main_id#kk#')#","");
			</script>
		</cfoutput>
	</cfloop>
</cfif>
<!---Ezgi Bilgisayar Özelleştirme Bitişi--->