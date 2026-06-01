<!---
    File: upd_ezgi_default_measure.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_VIRTUAL_OFFER_ROW_MEASURE WHERE MEASURE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.measure_id#">
</cfquery>
<cfquery name="get_row" datasource="#dsn3#">
	SELECT 
    	MEASURE_ROW_ID,
    	MEASURE_TYPE,
        ISNULL(IS_STANDART,0) IS_STANDART,
        ISNULL(IS_DEFAULT,0) IS_DEFAULT, 
        ISNULL(PRIVATE_RATE,0) PRIVATE_RATE,
        ISNULL(PRIVATE_PRICE,0) PRIVATE_PRICE,
        MEASURE,
        ISNULL(BIG_MEASURE,0) BIG_MEASURE,
        ISNULL(SMALL_MEASURE,0) SMALL_MEASURE,
        ISNULL(PRIVATE_MEASURE,0) PRIVATE_MEASURE,
        ISNULL(PRIVATE2_MEASURE,0) PRIVATE2_MEASURE,
		ISNULL(IS_SPECIAL_MEASURE,0) AS IS_SPECIAL_MEASURE,
        ALERT_MESSAGE
    FROM 
    	EZGI_VIRTUAL_OFFER_ROW_MEASURE_ROW WITH (NOLOCK)
    WHERE 
    	MEASURE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.measure_id#"> 
    ORDER BY 
    	MEASURE_TYPE,MEASURE
</cfquery>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
    	<cfform name="upd_default_measure" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_default_measure">
        	<cfinput type="hidden" name="measure_id" value="#attributes.measure_id#">
        	<cf_basket_form id="upd_default_measure">
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                        <div class="form-group" id="item-status">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                                            <div class="col col-8 col-xs-12">
                                                <input type="checkbox" id="status" name="status" value="1" <cfif get_upd.IS_ACTIVE>checked</cfif>>
                                            </div>
                                        </div>
                                  	</div>
                                	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                                        <div class="form-group" id="item-code">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="36570.Ölçü Kodu"> *</label>
	                            			<div class="col col-8 col-xs-12">
                                            	<cfinput type="text" name="default_code" id="default_code" value="#get_upd.measure_CODE#" maxlength="20" >
                            					<cfinput type="hidden" name="old_default_code" value="#get_upd.measure_CODE#">
                                          	</div>
                                     	</div>
                                 	</div>
                                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                                        <div class="form-group" id="item-name">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id="36569.Ölçü Adı"> *</label>
                                            <div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                <cfinput type="hidden" name="old_default_name" value="#get_upd.measure_NAME#">
                                                <cfinput type="text" name="default_name" id="default_name" value="#get_upd.measure_NAME#" maxlength="90" style="width:240px;" >
                                                <span class="input-group-addon">
                                                    <cf_language_info 
                                                        table_name="EZGI_VIRTUAL_OFFER_ROW_MEASURE" 
                                                        column_name="MEASURE_NAME" 
                                                        column_id_value="#attributes.measure_id#" 
                                                        maxlength="50" 
                                                        datasource="#dsn3#" 
                                                        column_id="MEASURE_ID" 
                                                        control_type="0">
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                  	</div>
                              	</cf_box_elements>
                    			<cf_box_footer>
									<div class="col col-12 col-xs-12">
                                        <cf_workcube_buttons 
                                        	is_upd='1' 
                                            add_function='kontrol()'
                                            is_delete = '0'>
                                      	<cf_record_info 
                                            query_name="get_upd"
                                            record_emp="RECORD_EMP" 
                                            record_date="record_date"
                                            update_emp="UPDATE_EMP"
                                            update_date="update_date">
                                    </div>
                				</cf_box_footer>
                			</div>
            			</div>
        		</div>
    		</cf_basket_form>
    		<cf_basket id="upd_default_measure_bask">
            	<cf_grid_list sort="0">
                    <thead>
                        <tr>
                        	<th style="text-align:center; width:20px">
                            	<input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_row.recordcount#</cfoutput>">
                        		<a href="javascript:add_row();"><img src="/images/plus_list.gif"  border="0" title="<cf_get_lang dictionary_id='57582.Ekle'>"></a>
                            </th>
                            <th style="text-align:center; width:30px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th style="text-align:center; width:100px"><cf_get_lang dictionary_id='43116.Default'></th>
                            <th style="text-align:center; width:100px">Tür</th>
                            <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='57686.Ölçü'></th>
                            <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='43677.Standart'></th>
                            <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='57142.Yüzde Oran'></th>
                            <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='58544.Sabit'> (<cfoutput>#session.ep.money#</cfoutput>)</th>
                            <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='57686.Ölçü'> 1</th>
                            <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='57686.Ölçü'> 2</th>
                            <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='57686.Ölçü'> 3</th>
                            <th style="text-align:center; width:80px"><cf_get_lang dictionary_id='57686.Ölçü'> 4</th>
							<th style="text-align:center; width:80px">Özel Ölçü</th>
							<th style="text-align:center; width:80px">Sanal Teklif</th>
                            <th style="text-align:center;"><cf_get_lang dictionary_id='44341.Uyarı Notu'></th>
						</tr>
                	</thead>
                    <tbody name="new_row" id="new_row">
                    	<cfif get_row.recordcount>
                    		<cfoutput query="get_row">
                    			<tr name="frm_row#currentrow#" id="frm_row#currentrow#">
                                	<td style="height:20px; text-align:center">
                                    	<a style="cursor:pointer" onclick="sil(#currentrow#);" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>
                                      	<input type="hidden" value="1" name="row_kontrol#currentrow#"  id="row_kontrol#currentrow#">                              	
                                  	</td>
                                	<td style="text-align:right">#currentrow#&nbsp;</td>
                                    <td style="text-align:center">
                                      	<input type="checkbox" name="is_default_#currentrow#" id="is_default_#currentrow#" <cfif IS_DEFAULT eq 1>checked</cfif>>
                                  	</td>
                                    <td style="text-align:left">&nbsp;
                                    	<cfif MEASURE_TYPE eq 1><cf_get_lang dictionary_id='99.Boy'></cfif>
                                        <cfif MEASURE_TYPE eq 2><cf_get_lang dictionary_id='98.En'></cfif>
                                        <cfif MEASURE_TYPE eq 3><cf_get_lang dictionary_id='42675.Derinlik'></cfif>
                                        <input type="hidden" name="type_id#currentrow#" value="#MEASURE_TYPE#">
                                    </td>
                                    <td style="text-align:right">
                                      	<input type="text" name="olcu_#currentrow#" id="olcu_#currentrow#" class="box" value="#get_row.MEASURE#"> 
                                  	</td>
                                    <td style="text-align:center">
                                      	<input type="checkbox" name="is_standart_#currentrow#" id="is_standart_#currentrow#" onChange="check_diff(#currentrow#)" <cfif IS_STANDART eq 1>checked</cfif>>
                                  	</td>
                                    <cfif PRIVATE_RATE gt 0>
                                      	<cfset price = 0>
                                  	<cfelse>
                                    	<cfset price = PRIVATE_PRICE>
                                  	</cfif>	
                                    <td style="text-align:center">
                                      	<input type="text" name="private_rate_#currentrow#" id="private_rate_#currentrow#" value="#PRIVATE_RATE#" onChange="private_field(1,#currentrow#)" maxlength="3" style="text-align:center" <cfif IS_STANDART eq 1>readonly<cfelse><cfif price gt 0>readonly</cfif></cfif>>
                                  	</td>
                                    <td style="text-align:right">
                                      	<input type="text" name="private_price_#currentrow#" id="private_price_#currentrow#" value="#price#" onChange="private_field(2,#currentrow#)" style="text-align:right" <cfif IS_STANDART eq 1>readonly<cfelse><cfif PRIVATE_RATE gt 0>readonly</cfif></cfif>>
                                  	</td>
                                    <td style="text-align:right">
                                      	<input type="text" name="olcu1_#currentrow#" id="olcu1_#currentrow#" value="#BIG_MEASURE#" style="text-align:right">
                                  	</td>
                                    <td style="text-align:right">
                                      	<input type="text" name="olcu2_#currentrow#" id="olcu2_#currentrow#" value="#SMALL_MEASURE#" style="text-align:right">
                                  	</td>
                                    <td style="text-align:right">
                                      	<input type="text" name="olcu3_#currentrow#" id="olcu3_#currentrow#" value="#PRIVATE_MEASURE#" style="text-align:right">
                                  	</td>
                                    <td style="text-align:right">
                                      	<input type="text" name="olcu4_#currentrow#" id="olcu4_#currentrow#" value="#PRIVATE2_MEASURE#" style="text-align:right">
                                  	</td>
									  <td style="text-align:center">
										<input type="checkbox" name="is_special_measure_#currentrow#" id="is_special_measure_#currentrow#" <cfif IS_SPECIAL_MEASURE eq 1>checked</cfif>>
									</td>
									<td style="text-align:center">
                                    	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_virtual_offer_special&type=measure&measure_type=#MEASURE_TYPE#&measure=#get_row.MEASURE#&row_id=#url.measure_id#','small');"></span>
											<img src="images/elements.gif" id="is_virtual_offer_#currentrow#" title="Görünmesini İstediğiniz Sanal Telifi Ekleyin" <cfif IS_SPECIAL_MEASURE eq 0>style="display:none"</cfif>/>
                                        </a>
									</td>
                                    <td style="text-align:left">
                                      	<input type="text" name="alert_message_#currentrow#" id="alert_message_#currentrow#" value="#ALERT_MESSAGE#" maxlength="500" style="text-align:LEFT; width:100%" <cfif IS_STANDART eq 1>readonly</cfif>>
                                  	</td>
                                </tr>
                         	</cfoutput>
                      	</cfif>
                    </tbody>
            	</cf_grid_list>
            </cf_basket>
 		</cfform>
   	</cf_box>
</div>
<script type="text/javascript">
	var row_count=document.upd_default_measure.record_num.value;
	function add_row()
	{
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		
		document.upd_default_measure.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'center';
		newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a><input type="hidden" value="1" name="row_kontrol' + row_count + '"  id="row_kontrol' + row_count + '">';	
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.innerHTML = row_count+'&nbsp;';	
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'center';
		newCell.innerHTML = '<input type="checkbox" name="is_default_'+ row_count +'" id="is_default_'+ row_count +'">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'center';
		newCell.setAttribute("nowrap","nowrap");
		b = '<select name="type_id' + row_count +'" id="type_id' + row_count +'" style="width:100%; height:20px"><option value="1"><cf_get_lang dictionary_id='99.Boy'></option><option value="2"><cf_get_lang dictionary_id='98.En'></option><option value="3"><cf_get_lang dictionary_id='42675.Derinlik'></option>';
		newCell.innerHTML = b + '</select>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.innerHTML = '<input type="text" name="olcu_'+ row_count +'" id="olcu_'+ row_count +'" class="box" value="">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'center';
		newCell.innerHTML = '<input type="checkbox" name="is_standart_'+ row_count +'" id="is_standart_'+ row_count +'" onChange="check_diff('+ row_count +')" checked>';
			
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.innerHTML = '<input type="text" name="private_rate_'+ row_count +'" id="private_rate_'+ row_count +'" value="0" maxlength="3" style="text-align:center" onChange="private_field(1,'+ row_count +')" readonly>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.innerHTML = '<input type="text" name="private_price_'+ row_count +'" id="private_price_'+ row_count +'" value="0,00" style="text-align:right" onChange="private_field(2,'+ row_count +')" readonly>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.innerHTML = '<input type="text" name="olcu1_'+ row_count +'" id="olcu1_'+ row_count +'" value="0" style="text-align:right">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.innerHTML = '<input type="text" name="olcu2_'+ row_count +'" id="olcu2_'+ row_count +'" value="0" style="text-align:right">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.innerHTML = '<input type="text" name="olcu3_'+ row_count +'" id="olcu3_'+ row_count +'" value="0" style="text-align:right">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.innerHTML = '<input type="text" name="olcu4_'+ row_count +'" id="olcu4_'+ row_count +'" value="0" style="text-align:right">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'center';
		newCell.innerHTML = '<input type="checkbox" name="is_special_measure_'+ row_count +'" id="is_special_measure_'+ row_count +'">';

		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'center';
		newCell.innerHTML = '';

		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.innerHTML = '<input type="text" name="alert_message_'+ row_count +'" id="alert_message_'+ row_count +'" value="" maxlength="500" style="text-align:LEFT; width:100%" readonly>';
	}
	function check_diff(sira)
	{
		if(eval('document.all.is_standart_'+sira).checked==false)
		{
			document.getElementById('private_rate_'+sira).readOnly = false;
			document.getElementById('private_price_'+sira).readOnly = false;
			document.getElementById('alert_message_'+sira).readOnly = false;
		}
		else
		{
			document.getElementById('private_rate_'+sira).value = 0;
			document.getElementById('private_price_'+sira).value = 0;
			document.getElementById('alert_message_'+sira).value = '';
			document.getElementById('private_rate_'+sira).readOnly = true;
			document.getElementById('private_price_'+sira).readOnly = true;
			document.getElementById('alert_message_'+sira).readOnly = true;
		}
	}
	function private_field(tur,sira)
	{
		if(tur==1)
		{
			if(document.getElementById('private_rate_'+sira).value == 0)
				document.getElementById('private_price_'+sira).readOnly = false;
			else
				document.getElementById('private_price_'+sira).readOnly = true;
		}
		else
		{
			if(document.getElementById('private_price_'+sira).value == 0)
				document.getElementById('private_rate_'+sira).readOnly = false;
			else
				document.getElementById('private_rate_'+sira).readOnly = true;
		}
	}
	function sil(sy)
	{
		document.getElementById('row_kontrol'+sy).value = 0;
		document.getElementById('frm_row'+sy).style.display='none';
	} 
	function kontrol()
	{
		if(document.getElementById("default_name").value == "")
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='36569.Ölçü Adı'> !");
			document.getElementById('default_name').focus();
			return false;
		}
		if(document.getElementById("default_code").value == "")
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='36570.Ölçü Kodu'> !");
			document.getElementById('default_code').focus();
			return false;
		}
	}
</script>